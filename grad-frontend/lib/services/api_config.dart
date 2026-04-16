import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// API Configuration for the Flutter app
class ApiConfig {
  // Base URL for the backend API
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3001';
    }
    try {
      if (Platform.isAndroid) {
         // EĞER GERÇEK TELEFON KULLANIYORSAN (Kendi IP'ni yazmalısın):
       return 'http://10.0.2.2:3001';
      }
    } catch (e) {
      // Fallback for platforms where Platform.isAndroid points to something else
    }
    return 'http://localhost:3001';
  }

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

  // Announcements endpoints
  static String get announcementsUrl => '$apiUrl/announcements';
}
