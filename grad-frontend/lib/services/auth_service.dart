import 'api_client.dart';
import 'api_config.dart';

/// Authentication Service for login, register, and user session management
class AuthService {
  final ApiClient _client = ApiClient();

  /// Register a new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? district,
    String? neighborhood,
  }) async {
    final response = await _client.post(
      ApiConfig.registerUrl,
      body: {
        'email': email,
        'password': password,
        'name': name,
        if (phone != null) 'phone': phone,
        if (district != null) 'district': district,
        if (neighborhood != null) 'neighborhood': neighborhood,
      },
    );

    // Extract data from wrapper response {success, data}
    final data = response['data'] ?? response;
    
    // Save token if provided
    if (data['token'] != null) {
      await _client.saveToken(data['token']);
    }

    return data;
  }

  /// Login with email and password
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      ApiConfig.loginUrl,
      body: {
        'email': email,
        'password': password,
      },
    );

    // Extract data from wrapper response {success, data}
    final data = response['data'] ?? response;
    
    // Save token if provided
    if (data['token'] != null) {
      await _client.saveToken(data['token']);
    }

    return data;
  }

  /// Request password reset
  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    return await _client.post(
      ApiConfig.forgotPasswordUrl,
      body: {'email': email},
    );
  }

  /// Get current user info
  Future<Map<String, dynamic>> getCurrentUser() async {
    return await _client.get(
      ApiConfig.meUrl,
      requireAuth: true,
    );
  }

  /// Logout user
  Future<void> logout() async {
    await _client.deleteToken();
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _client.isAuthenticated();
  }
}
