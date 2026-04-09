import 'package:flutter/material.dart';

// Eğer başka sayfalarda eski sistemden kalma bir kullanım varsa hata vermesin diye 
// enum yapısını şimdilik tutuyoruz (İleride tamamen silebiliriz).
enum AppLanguage { turkish, english }

class ThemeProvider with ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;
  AppLanguage language = AppLanguage.turkish; 
  double textScaleFactor = 1.0;
  bool notificationsEnabled = true;
  
  // Basit Mod (Erişilebilirlik) Bayrağı
  bool isSimpleMode = false;

  // --- KONTROL FONKSİYONLARI ---

  // Dil Değiştirme
  void setLanguage(AppLanguage lang) {
    language = lang;
    notifyListeners();
  }

  // Tema (Karanlık/Aydınlık) Değiştirme
  void toggleTheme(bool isDark) {
    themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Yazı Boyutu Değiştirme
  void setFontSize(double scale) {
    textScaleFactor = scale;
    notifyListeners();
  }

  // Bildirim Ayarı Aç/Kapa
  void toggleNotifications(bool value) {
    notificationsEnabled = value;
    notifyListeners();
  }

  // Basit Mod (Erişilebilirlik) Aç/Kapa
  void toggleSimpleMode(bool value) {
    isSimpleMode = value;
    if (value) {
      // Basit mod açılınca yazıları otomatik %40 büyüt (1.4 scale)
      textScaleFactor = 1.4;
    } else {
      // Basit mod kapanınca yazıları normale döndür (1.0 scale)
      textScaleFactor = 1.0;
    }
    notifyListeners();
  }
}