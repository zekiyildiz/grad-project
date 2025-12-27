import 'user_model.dart';

/// Auth Response Model for login/register responses
class AuthResponse {
  final String? token;
  final UserModel? user;
  final String? message;
  final bool success;

  AuthResponse({
    this.token,
    this.user,
    this.message,
    this.success = true,
  });

  /// Create AuthResponse from JSON
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      message: json['message'],
      success: json['success'] ?? true,
    );
  }

  /// Check if response has a valid token
  bool get hasToken => token != null && token!.isNotEmpty;
}
