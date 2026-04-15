import 'api_client.dart';
import 'api_config.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Report Service for complaint/report management
class ReportService {
  // ApiClient ismini tutarlı olması için _apiClient olarak tanımlıyoruz
  final ApiClient _apiClient = ApiClient();

  /// 1. Vatandaşın kendi şikayetlerini getirir
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

  /// 2. Admin/Belediye için sistemdeki TÜM şikayetleri getirir
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

  /// 3. Tek bir raporu ID ile detaylı getirir
  Future<Map<String, dynamic>> getReport(String id) async {
    return await _apiClient.get(
      '${ApiConfig.reportsUrl}/$id',
      requireAuth: true,
    );
  }

  /// 4. Yeni şikayet oluşturma (ACİL DURUM desteği eklendi)
  Future<void> createReport({
    required String category,
    required String description,
    required double latitude,
    required double longitude,
    required String address,
    required bool isUrgent, // <-- Parametre olarak gelmeli
    required List<String> imageUrls,
  }) async {
    try {
      await _apiClient.post( // veya http.post
        ApiConfig.reportsUrl, // Kendi URL yapına göre değişebilir
        body: {
          'category': category,
          'description': description,
          'latitude': latitude,
          'longitude': longitude,
          'address': address,
          'isUrgent': isUrgent, // 🌟 KRİTİK NOKTA: Bu satır yoksa backend'e gitmez!
          'imageUrls': imageUrls,
        },
        requireAuth: true,
      );
    } catch (e) {
      throw Exception('Rapor oluşturulamadı: $e');
    }
  }
  /// 5. Rapor durumunu güncelle (Örn: ÇÖZÜLDÜ / İNCELEMEDE)
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

  /// 6. Şikayeti bir kuruma atar
  Future<bool> assignInstitution(String reportId, String institutionCode) async {
    try {
      await _apiClient.put( // _client veya _apiClient, hangisini kullanıyorsan
        '${ApiConfig.reportsUrl}/$reportId/assign',
        body: { // data: veya body: (senin yapına göre)
          'institutionCode': institutionCode, // DÜZELTME BURADA: Backend'in beklediği isim!
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
      // 1. URL'yi güvenli hale getir. (Senin API yapına göre /api/v1 içermesi gerekebilir)
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
// Şikayet Kategorisini Düzenleme (Admin/Saha Görevlisi)
  Future<void> updateReportCategory(String id, String newCategory) async {
    try {
      final response = await _apiClient.put( // Eğer http paketini direkt kullanıyorsan http.put yap
        '${ApiConfig.reportsUrl}/$id/category', 
        body: { 'category': newCategory },
        requireAuth: true,
      );
      
      
    } catch (e) {
      throw Exception("Kategori backend'e iletilemedi: $e");
    }
  }
  
}