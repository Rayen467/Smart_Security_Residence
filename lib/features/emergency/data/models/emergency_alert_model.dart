class EmergencyAlertModel {
  final int id;
  final int userId;
  final String emergencyType;
  final String message;
  final String locationText;
  final double? latitude;
  final double? longitude;
  final String priority;
  final String status;
  final int? assignedSecurityId;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EmergencyAlertModel({
    required this.id,
    required this.userId,
    required this.emergencyType,
    required this.message,
    required this.locationText,
    this.latitude,
    this.longitude,
    required this.priority,
    required this.status,
    this.assignedSecurityId,
    this.acceptedAt,
    this.completedAt,
    this.cancelledAt,
    this.createdAt,
    this.updatedAt,
  });

  factory EmergencyAlertModel.fromJson(Map<String, dynamic> json) {
    return EmergencyAlertModel(
      id: _toInt(json['id']),
      userId: _toInt(json['user_id']),
      emergencyType: json['emergency_type']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      locationText: json['location_text']?.toString() ?? '',
      latitude: _toDoubleNullable(json['latitude']),
      longitude: _toDoubleNullable(json['longitude']),
      priority: json['priority']?.toString() ?? 'critical',
      status: json['status']?.toString() ?? 'waiting',
      assignedSecurityId: _toIntNullable(json['assigned_security_id']),
      acceptedAt: _toDateTimeNullable(json['accepted_at']),
      completedAt: _toDateTimeNullable(json['completed_at']),
      cancelledAt: _toDateTimeNullable(json['cancelled_at']),
      createdAt: _toDateTimeNullable(json['created_at']),
      updatedAt: _toDateTimeNullable(json['updated_at']),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static int? _toIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static double? _toDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _toDateTimeNullable(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
