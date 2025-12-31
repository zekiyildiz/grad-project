/// API Configuration for the Flutter app
class ApiConfig {
  // Base URL for the backend API
  // For Android emulator use: http://10.0.2.2:3001
  // For iOS simulator use: http://localhost:3001
  // For physical device use your computer's IP address
  // static const String baseUrl = 'http://localhost:3001';
  static const String baseUrl = 'http://10.0.2.2:3001';

  // API version prefix
  static const String apiPrefix = '/api/v1';

  // Full API URL
  static String get apiUrl => '$baseUrl$apiPrefix';

  // Request timeout duration
  static const Duration timeout = Duration(seconds: 30);

  // Auth endpoints
  static String get registerUrl => '$apiUrl/auth/register';
  static String get loginUrl => '$apiUrl/auth/login/email';
  static String get forgotPasswordUrl => '$apiUrl/auth/forgot-password';
  static String get meUrl => '$apiUrl/auth/me';

  // User endpoints
  static String get profileUrl => '$apiUrl/users/profile';

  // Reports endpoints
  static String get reportsUrl => '$apiUrl/reports';

  // Health check
  static String get healthUrl => '$baseUrl/health';
}
