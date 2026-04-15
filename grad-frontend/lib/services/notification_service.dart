import 'api_client.dart';
import 'api_config.dart';

class NotificationService {
  final ApiClient _client = ApiClient();

  Future<List<dynamic>> getMyNotifications() async {
    try {
      final response = await _client.get('${ApiConfig.reportsUrl}/notifications', requireAuth: true);
      return response is List ? response : [];
    } catch (e) {
      return [];
    }
  }

  Future<void> markAsRead(String id) async {
    await _client.put('${ApiConfig.reportsUrl}/notifications/$id/read', requireAuth: true);
  }

  Future<void> markAllAsRead() async {
    await _client.put('${ApiConfig.reportsUrl}/notifications/read-all', requireAuth: true);
  }

  Future<void> deleteNotification(String id) async {
    await _client.delete('${ApiConfig.reportsUrl}/notifications/$id', requireAuth: true);
  }
}