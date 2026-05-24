import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/dio_client.dart';
import '../../../../core/services/secure_storage.dart';
import '../../data/models/auth_response_model.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  emailNotVerified,
  error,
}

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthStatus _status = AuthStatus.initial;
  User? _firebaseUser;
  AppUserModel? _appUser;
  String? _backendToken;
  String? _errorMessage;

  String? _tempEmail;
  String? _tempPassword;
  Map<String, dynamic>? _pendingRegistrationData;

  AuthStatus get status => _status;
  User? get firebaseUser => _firebaseUser;
  AppUserModel? get appUser => _appUser;
  String? get backendToken => _backendToken;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  String get userRole => _appUser?.role ?? 'resident';

  Future<void> initializeAuthState() async {
    _setLoading();

    try {
      final savedToken = await SecureStorageService.getToken();
      final savedRole = await SecureStorageService.getUserRole();
      final savedName = await SecureStorageService.getUserName();
      final savedEmail = await SecureStorageService.getUserEmail();

      _firebaseUser = _auth.currentUser;

      if (savedToken != null && savedToken.isNotEmpty) {
        _backendToken = savedToken;

        _appUser = AppUserModel(
          id: '',
          firebaseUid: _firebaseUser?.uid ?? '',
          name: savedName ?? _firebaseUser?.displayName ?? 'User',
          email: savedEmail ?? _firebaseUser?.email ?? '',
          phone: '',
          role: savedRole ?? 'resident',
          status: 'active',
        );

        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _setError('Gagal memeriksa status login: $e');
      return;
    }

    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String block,
    required String houseNumber,
  }) async {
    _setLoading();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _firebaseUser = credential.user;

      await _firebaseUser?.updateDisplayName(name);
      await _firebaseUser?.sendEmailVerification();

      _tempEmail = email;
      _tempPassword = password;

      _pendingRegistrationData = {
        'name': name,
        'email': email,
        'phone': phone,
        'role': 'resident',
        'block': block,
        'house_number': houseNumber,
      };

      _status = AuthStatus.emailNotVerified;
      _errorMessage = null;
      notifyListeners();

      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
      return false;
    } catch (e) {
      _setError('Pendaftaran gagal: $e');
      return false;
    }
  }

  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _firebaseUser = credential.user;

      if (!(_firebaseUser?.emailVerified ?? false)) {
        _tempEmail = email;
        _tempPassword = password;

        _status = AuthStatus.emailNotVerified;
        _errorMessage = null;
        notifyListeners();

        return false;
      }

      return await _verifyTokenToBackend();
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
      return false;
    } catch (e) {
      _setError('Login gagal: $e');
      return false;
    }
  }

  Future<bool> checkEmailVerified() async {
    _setLoading();

    try {
      await _firebaseUser?.reload();
      _firebaseUser = _auth.currentUser;

      if (!(_firebaseUser?.emailVerified ?? false)) {
        _status = AuthStatus.emailNotVerified;
        notifyListeners();
        return false;
      }

      if (_tempEmail != null && _tempPassword != null) {
        final credential = await _auth.signInWithEmailAndPassword(
          email: _tempEmail!,
          password: _tempPassword!,
        );

        _firebaseUser = credential.user;

        _tempEmail = null;
        _tempPassword = null;
      }

      return await _verifyTokenToBackend(
        registrationData: _pendingRegistrationData,
      );
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
      return false;
    } catch (e) {
      _setError('Gagal mengecek verifikasi email: $e');
      return false;
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      await _firebaseUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
    } catch (e) {
      _setError('Gagal mengirim ulang email verifikasi: $e');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    _setLoading();

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
    } catch (e) {
      _setError('Gagal mengirim email reset password: $e');
    }
  }

  Future<void> logout() async {
    _setLoading();

    try {
      await _auth.signOut();
      await SecureStorageService.clearAll();

      _firebaseUser = null;
      _appUser = null;
      _backendToken = null;
      _tempEmail = null;
      _tempPassword = null;
      _pendingRegistrationData = null;

      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _setError('Logout gagal: $e');
    }
  }

  Future<bool> _verifyTokenToBackend({
    Map<String, dynamic>? registrationData,
  }) async {
    try {
      final firebaseToken = await _firebaseUser?.getIdToken();

      if (firebaseToken == null || firebaseToken.isEmpty) {
        _setError('Firebase token tidak ditemukan');
        return false;
      }

      final payload = <String, dynamic>{'firebase_token': firebaseToken};

      if (registrationData != null) {
        payload.addAll(registrationData);
      }

      final response = await DioClient.instance.post(
        ApiConstants.verifyToken,
        data: payload,
      );

      final authResponse = AuthResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (authResponse.accessToken.isEmpty) {
        _setError('Token backend kosong');
        return false;
      }

      _backendToken = authResponse.accessToken;
      _appUser = authResponse.user;

      await SecureStorageService.saveToken(authResponse.accessToken);
      await SecureStorageService.saveUserRole(authResponse.user.role);
      await SecureStorageService.saveUserName(authResponse.user.name);
      await SecureStorageService.saveUserEmail(authResponse.user.email);

      _pendingRegistrationData = null;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();

      return true;
    } on DioException catch (e) {
      final message = e.response?.data is Map<String, dynamic>
          ? e.response?.data['message']?.toString()
          : null;

      _setError(message ?? 'Gagal verifikasi token ke backend');
      return false;
    } catch (e) {
      _setError('Terjadi kesalahan saat verifikasi token: $e');
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;

    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  String _mapFirebaseError(String code) {
    return switch (code) {
      'email-already-in-use' => 'Email sudah terdaftar. Gunakan email lain.',
      'invalid-email' => 'Format email tidak valid.',
      'operation-not-allowed' => 'Metode login belum diaktifkan di Firebase.',
      'weak-password' => 'Password terlalu lemah. Minimal 8 karakter.',
      'user-disabled' => 'Akun ini telah dinonaktifkan.',
      'user-not-found' =>
        'Akun tidak ditemukan. Silakan daftar terlebih dahulu.',
      'wrong-password' => 'Password salah. Coba lagi.',
      'invalid-credential' => 'Email atau password salah.',
      'network-request-failed' => 'Tidak ada koneksi internet.',
      'too-many-requests' => 'Terlalu banyak percobaan. Coba lagi nanti.',
      'requires-recent-login' => 'Silakan login ulang untuk melanjutkan.',
      _ => 'Terjadi kesalahan autentikasi. Kode: $code',
    };
  }
}
