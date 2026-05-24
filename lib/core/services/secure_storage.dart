import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const String _keyToken = 'auth_token';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  static Future<String?> getToken() async {
    return _storage.read(key: _keyToken);
  }

  static Future<void> saveUserRole(String role) async {
    await _storage.write(key: _keyUserRole, value: role);
  }

  static Future<String?> getUserRole() async {
    return _storage.read(key: _keyUserRole);
  }

  static Future<void> saveUserName(String name) async {
    await _storage.write(key: _keyUserName, value: name);
  }

  static Future<String?> getUserName() async {
    return _storage.read(key: _keyUserName);
  }

  static Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _keyUserEmail, value: email);
  }

  static Future<String?> getUserEmail() async {
    return _storage.read(key: _keyUserEmail);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
