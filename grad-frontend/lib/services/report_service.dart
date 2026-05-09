import 'api_client.dart';
import 'api_config.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Report Service for complaint/report management
class ReportService {
  final ApiClient _apiClient = ApiClient();

  /// 1. The citizen submits their own complaints
  Future<List<dynamic>> getMyReports() async {
    try {
      final response = await _apiClient.get(
        ApiConfig.reportsUrl,
        requireAuth: true,
      );
      return response is List ? response : [];
    } catch (e) {
      return [];
    }
  }

  /// 2. Retrieves ALL complaints in the system for Admin/Municipality
  Future<List<dynamic>> getAllReports() async {
    try {
      final response = await _apiClient.get(
        '${ApiConfig.reportsUrl}/all',
        requireAuth: true,
      );
      return response is List ? response : [];
    } catch (e) {
      return [];
    }
  }

  /// 3. Retrieves a single report in detail by ID
  Future<Map<String, dynamic>> getReport(String id) async {
    return await _apiClient.get(
      '${ApiConfig.reportsUrl}/$id',
      requireAuth: true,
    );
  }

  /// 4. Creating a new complaint (EMERGENCY support added)
  Future<void> createReport({
    required String category,
    required String description,
    required double latitude,
    required double longitude,
    required String address,
    required bool isUrgent, 
    required List<String> imageUrls,
  }) async {
    try {
      await _apiClient.post( // or http.post
        ApiConfig.reportsUrl, 
        body: {
          'category': category,
          'description': description,
          'latitude': latitude,
          'longitude': longitude,
          'address': address,
          'isUrgent': isUrgent,
          'imageUrls': imageUrls,
        },
        requireAuth: true,
      );
    } catch (e) {
      throw Exception('Rapor oluşturulamadı: $e');
    }
  }
  /// 5. Update the report status (e.g., RESOLVED / UNDER REVIEW)
  Future<Map<String, dynamic>> updateReportStatus({
    required String id,
    required String status,
    String? comment,
  }) async {
    return await _apiClient.put(
      '${ApiConfig.reportsUrl}/$id/status',
      body: {
        'status': status,
        if (comment != null) 'comment': comment,
      },
      requireAuth: true,
    );
  }

  /// 6. Submits the complaint to an agency
  Future<bool> assignInstitution(String reportId, String institutionCode) async {
    try {
      await _apiClient.put( 
        '${ApiConfig.reportsUrl}/$reportId/assign',
        body: {
          'institutionCode': institutionCode, 
          'status': 'IN_PROGRESS', 
        },
        requireAuth: true,
      );
      return true;
    } catch (e) {
      return false;
    }
  }
  Future<String?> uploadImage(File imageFile) async {
    try {
      String uploadUrl = '${ApiConfig.baseUrl}/upload';
      if (!uploadUrl.contains('/api/v1')) {
         uploadUrl = uploadUrl.replaceFirst('/upload', '/api/v1/upload');
      }

      print("🚀 [UPLOAD] Fotoğraf yükleniyor... Hedef URL: $uploadUrl");

      var uri = Uri.parse(uploadUrl);
      var request = http.MultipartRequest('POST', uri);
      
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      print("📸 [UPLOAD] API Cevabı: ${response.statusCode} - ${response.body}");
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = json.decode(response.body);
        return data['imageUrl'] ?? data['url']; 
      } else {
        print("❌ [UPLOAD] Sunucu resmi reddetti!");
      }
    } catch (e) {
      print("💥 [UPLOAD] Kritik Hata (Bağlantı koptu veya URL yanlış): $e");
    }
    return null; 
  }


  Future<void> updateReportCategory(String id, String newCategory) async {
    try {
      final response = await _apiClient.put( // If you're using the http package directly, use http.put
        '${ApiConfig.reportsUrl}/$id/category', 
        body: { 'category': newCategory },
        requireAuth: true,
      );
      
    } catch (e) {
      throw Exception("Kategori backend'e iletilemedi: $e");
    }
  }
  
}