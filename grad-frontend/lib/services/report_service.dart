import 'api_client.dart';
import 'api_config.dart';

/// Report Service for complaint/report management
class ReportService {
  final ApiClient _client = ApiClient();

  /// Get all reports for current user
  Future<List<dynamic>> getMyReports() async {
    final response = await _client.get(
      ApiConfig.reportsUrl,
      requireAuth: true,
    );
    return response is List ? response : [];
  }

  /// Get a specific report by ID
  Future<Map<String, dynamic>> getReport(String id) async {
    return await _client.get(
      '${ApiConfig.reportsUrl}/$id',
      requireAuth: true,
    );
  }

  /// Create a new report
  Future<Map<String, dynamic>> createReport({
    required String category,
    required String description,
    required double latitude,
    required double longitude,
    String? address,
    List<String>? imageUrls,
  }) async {
    return await _client.post(
      ApiConfig.reportsUrl,
      body: {
        'category': category,
        'description': description,
        'location': {
          'latitude': latitude,
          'longitude': longitude,
          if (address != null) 'address': address,
        },
        if (imageUrls != null) 'images': imageUrls,
      },
      requireAuth: true,
    );
  }

  /// Update report status (for admins)
  Future<Map<String, dynamic>> updateReportStatus({
    required String id,
    required String status,
    String? comment,
  }) async {
    return await _client.put(
      '${ApiConfig.reportsUrl}/$id/status',
      body: {
        'status': status,
        if (comment != null) 'comment': comment,
      },
      requireAuth: true,
    );
  }
}
