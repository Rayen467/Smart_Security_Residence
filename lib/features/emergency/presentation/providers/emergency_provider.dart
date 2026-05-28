import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/dio_client.dart';
import '../../data/models/emergency_alert_model.dart';

class EmergencyProvider extends ChangeNotifier {
  Future<void> fetchSosAlerts({String? status}) async {
    _setLoading(true);

    try {
      final response = await DioClient.instance.get(
        ApiConstants.emergencyAlerts,
        queryParameters: {
          if (status != null && status.isNotEmpty) 'status': status,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>? ?? {};
      final list = data['emergency_alerts'] as List<dynamic>? ?? [];

      _alerts = list
          .map(
            (item) =>
                EmergencyAlertModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();

      _errorMessage = null;
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        _errorMessage =
            data['message']?.toString() ?? 'Gagal mengambil data SOS';
      } else {
        _errorMessage = 'Gagal mengambil data SOS';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
    }

    _setLoading(false);
  }

  Future<bool> updateSosStatus({
    required int alertId,
    required String status,
  }) async {
    _setLoading(true);

    try {
      final response = await DioClient.instance.put(
        '${ApiConstants.emergencyAlerts}/$alertId/status',
        data: {'status': status},
      );

      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>? ?? {};
      final alertJson = data['emergency_alert'] as Map<String, dynamic>? ?? {};

      final updatedAlert = EmergencyAlertModel.fromJson(alertJson);

      _alerts = _alerts.map((alert) {
        if (alert.id == updatedAlert.id) {
          return updatedAlert;
        }

        return alert;
      }).toList();

      _latestAlert = updatedAlert;
      _errorMessage = null;

      _setLoading(false);
      return true;
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        _errorMessage =
            data['message']?.toString() ?? 'Gagal memperbarui status SOS';
      } else {
        _errorMessage = 'Gagal memperbarui status SOS';
      }

      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _setLoading(false);
      return false;
    }
  }

  bool _isLoading = false;
  String? _errorMessage;
  EmergencyAlertModel? _latestAlert;
  List<EmergencyAlertModel> _alerts = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  EmergencyAlertModel? get latestAlert => _latestAlert;
  List<EmergencyAlertModel> get alerts => _alerts;

  Future<bool> sendSos({
    required String emergencyType,
    required String message,
    required String locationText,
    double? latitude,
    double? longitude,
  }) async {
    _setLoading(true);

    try {
      final response = await DioClient.instance.post(
        ApiConstants.emergencyAlerts,
        data: {
          'emergency_type': emergencyType,
          'message': message,
          'location_text': locationText,
          'latitude': ?latitude,
          'longitude': ?longitude,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>? ?? {};
      final alertJson = data['emergency_alert'] as Map<String, dynamic>? ?? {};

      _latestAlert = EmergencyAlertModel.fromJson(alertJson);
      _errorMessage = null;

      _setLoading(false);
      return true;
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        _errorMessage = data['message']?.toString() ?? 'Gagal mengirim SOS';
      } else {
        _errorMessage = 'Gagal mengirim SOS';
      }

      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<void> fetchMySosHistory() async {
    _setLoading(true);

    try {
      final response = await DioClient.instance.get(
        ApiConstants.emergencyAlerts,
      );

      final responseData = response.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>? ?? {};
      final list = data['emergency_alerts'] as List<dynamic>? ?? [];

      _alerts = list
          .map(
            (item) =>
                EmergencyAlertModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();

      _errorMessage = null;
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        _errorMessage =
            data['message']?.toString() ?? 'Gagal mengambil data SOS';
      } else {
        _errorMessage = 'Gagal mengambil data SOS';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
    }

    _setLoading(false);
  }

  void clearLatestAlert() {
    _latestAlert = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
