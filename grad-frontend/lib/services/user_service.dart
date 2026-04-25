import 'api_client.dart';
import 'api_config.dart';

/// User Service for profile management
class UserService {
  final ApiClient _client = ApiClient();

  /// Get user profile
  Future<Map<String, dynamic>> getProfile() async {
    return await _client.get(
      ApiConfig.profileUrl,
      requireAuth: true,
    );
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? avatarUrl,
  }) async {
    final body = <String, dynamic>{};
    
    // 🌟 KRİTİK: Backend "fullName" bekliyor
    if (name != null) body['fullName'] = name; 
    
    if (phone != null) body['phone'] = phone;
    // 🌟 KRİTİK: Adresi veritabanına gönderiyoruz
    if (address != null) body['address'] = address; 
    if (avatarUrl != null) body['avatarUrl'] = avatarUrl;

    return await _client.put(
      ApiConfig.profileUrl,
      body: body,
      requireAuth: true,
    );
  }
}
