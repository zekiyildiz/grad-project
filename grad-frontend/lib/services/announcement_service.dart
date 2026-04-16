import 'dart:convert';
import 'package:akilli_belediye/services/api_config.dart';
import 'package:http/http.dart' as http;
import '../models/announcement_model.dart';

class AnnouncementService {
 // Artık elle adres yazmıyoruz, ApiConfig'den çekiyoruz:
  final String url = ApiConfig.announcementsUrl;

  Future<List<Announcement>> fetchAnnouncements() async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((json) => Announcement.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Hata: $e");
      return [];
    }
  }
}