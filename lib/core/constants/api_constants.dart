class ApiConstants {
  // Ganti baseUrl ini nanti sesuai alamat backend Golang lu.
  // Kalau backend jalan di laptop dan dites dari HP Android fisik,
  // pakai IP laptop, contoh: http://192.168.1.10:8080/api/v1
  static const String baseUrl = 'http://localhost:8080/api/v1';

  // Auth endpoints
  static const String verifyToken = '/auth/verify-token';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';

  // User endpoints
  static const String users = '/users';

  // Emergency / SOS endpoints
  static const String emergencyAlerts = '/emergency-alerts';

  // Security report endpoints
  static const String securityReports = '/security-reports';

  // CCTV endpoints
  static const String cameraDevices = '/camera-devices';
  static const String cameraEvents = '/camera-events';

  // Notification endpoints
  static const String notifications = '/notifications';

  // Timeout
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
}
