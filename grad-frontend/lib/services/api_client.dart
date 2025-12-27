import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_config.dart';

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

/// HTTP Client wrapper for API communication
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';

  /// Get stored auth token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  /// Save auth token
  Future<void> saveToken(String token) async {
    print('🔑 Saving token: ${token.substring(0, 20)}...');
    await _secureStorage.write(key: _tokenKey, value: token);
    print('🔑 Token saved successfully');
  }

  /// Delete auth token
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Get common headers
  Future<Map<String, String>> _getHeaders({bool requireAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final token = await getToken();
      print('🔑 Retrieved token for auth: ${token != null ? token.substring(0, 20) + "..." : "NULL"}');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      } else {
        print('⚠️ No token available for authenticated request!');
      }
    }

    return headers;
  }

  /// Handle API response
  dynamic _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    // Türkçe hata mesajlarını belirle
    String errorMessage = _getLocalizedErrorMessage(response.statusCode, body);

    throw ApiException(
      errorMessage,
      statusCode: response.statusCode,
      data: body,
    );
  }

  /// Get localized error message based on status code and response body
  String _getLocalizedErrorMessage(int statusCode, dynamic body) {
    // Önce API'den gelen Türkçe mesajı kontrol et
    String? apiMessage;
    if (body != null && body is Map) {
      apiMessage = body['message'] ?? body['error'];
    }

    // Backend'den Türkçe mesaj geldiyse doğrudan kullan
    if (apiMessage != null && apiMessage.isNotEmpty && !apiMessage.contains('Error')) {
      return apiMessage;
    }

    // Fallback: Status koduna göre Türkçe hata mesajları
    switch (statusCode) {
      case 400:
        return apiMessage ?? 'Geçersiz istek. Lütfen bilgilerinizi kontrol edin.';
      case 401:
        if (apiMessage != null && apiMessage.toLowerCase().contains('token')) {
          return 'Oturum süresi dolmuş. Lütfen tekrar giriş yapın.';
        }
        return apiMessage ?? 'E-posta veya şifre hatalı.';
      case 403:
        return 'Bu işlem için yetkiniz bulunmuyor.';
      case 404:
        return apiMessage ?? 'Bu e-posta adresiyle kayıtlı bir hesap bulunamadı.';
      case 409:
        return apiMessage ?? 'Bu e-posta adresi zaten kullanılıyor.';
      case 422:
        return apiMessage ?? 'Girilen bilgiler doğrulanamadı.';
      case 429:
        return 'Çok fazla istek gönderildi. Lütfen biraz bekleyin.';
      case 500:
        return 'Sunucu hatası. Lütfen daha sonra tekrar deneyin.';
      case 502:
      case 503:
      case 504:
        return 'Sunucu şu anda kullanılamıyor. Lütfen daha sonra tekrar deneyin.';
      default:
        return apiMessage ?? 'Bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }

  /// GET request
  Future<dynamic> get(
    String endpoint, {
    bool requireAuth = false,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse(endpoint).replace(queryParameters: queryParams);
      final headers = await _getHeaders(requireAuth: requireAuth);

      print('🟢 GET Request: $endpoint');
      print('🟢 Headers: $headers');

      final response = await http
          .get(uri, headers: headers)
          .timeout(ApiConfig.timeout);

      print('🟢 Response Status: ${response.statusCode}');
      print('🟢 Response Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('🔴 GET Error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Bağlantı hatası: ${e.toString()}');
    }
  }

  /// POST request
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = false,
  }) async {
    try {
      final uri = Uri.parse(endpoint);
      final headers = await _getHeaders(requireAuth: requireAuth);

      print('🔵 POST Request: $endpoint');
      print('🔵 Body: $body');

      final response = await http
          .post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);

      print('🟢 Response Status: ${response.statusCode}');
      print('🟢 Response Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('🔴 Error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Bağlantı hatası: ${e.toString()}');
    }
  }

  /// PUT request
  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = false,
  }) async {
    try {
      final uri = Uri.parse(endpoint);
      final headers = await _getHeaders(requireAuth: requireAuth);

      final response = await http
          .put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Bağlantı hatası: ${e.toString()}');
    }
  }

  /// DELETE request
  Future<dynamic> delete(
    String endpoint, {
    bool requireAuth = false,
  }) async {
    try {
      final uri = Uri.parse(endpoint);
      final headers = await _getHeaders(requireAuth: requireAuth);

      final response = await http
          .delete(uri, headers: headers)
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Bağlantı hatası: ${e.toString()}');
    }
  }
}
