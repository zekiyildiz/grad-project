import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // NOTE: Paste your API key here.
  final String apiKey = "f648ef858a9cb7cee87f1271582bc49a"; 
  final String city = "Ankara";

  Future<Map<String, dynamic>> fetchWeather() async {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=tr');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        // In case of an error, we return an empty map
        return {}; 
      }
    } catch (e) {
      print("Hava durumu servisi hatası: $e");
      return {};
    }
  }
}