class AppUserModel {
  final String id;
  final String firebaseUid;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String status;
  final String? block;
  final String? houseNumber;

  const AppUserModel({
    required this.id,
    required this.firebaseUid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    this.block,
    this.houseNumber,
  });

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      id: json['id']?.toString() ?? '',
      firebaseUid: json['firebase_uid']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: json['role']?.toString() ?? 'resident',
      status: json['status']?.toString() ?? 'active',
      block: json['block']?.toString(),
      houseNumber: json['house_number']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebase_uid': firebaseUid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'status': status,
      'block': block,
      'house_number': houseNumber,
    };
  }
}

class AuthResponseModel {
  final bool success;
  final String message;
  final String accessToken;
  final String tokenType;
  final AppUserModel user;

  const AuthResponseModel({
    required this.success,
    required this.message,
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return AuthResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      accessToken: data['access_token']?.toString() ?? '',
      tokenType: data['token_type']?.toString() ?? 'Bearer',
      user: AppUserModel.fromJson(data['user'] as Map<String, dynamic>? ?? {}),
    );
  }
}
