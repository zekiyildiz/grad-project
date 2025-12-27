import 'package:flutter/material.dart';

// Diller
enum AppLanguage { turkish, english }

class ThemeProvider with ChangeNotifier {
  // --- AYAR DEĞİŞKENLERİ ---
  ThemeMode _themeMode = ThemeMode.light;
  double _textScaleFactor = 1.0;
  bool _notificationsEnabled = true; // Bildirim Ayarı
  AppLanguage _language = AppLanguage.turkish; // Dil Ayarı

  // --- GETTER'LAR (Okuma) ---
  ThemeMode get themeMode => _themeMode;
  double get textScaleFactor => _textScaleFactor;
  bool get notificationsEnabled => _notificationsEnabled;
  AppLanguage get language => _language;

  // --- SETTER'LAR (Değiştirme) ---
  
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setFontSize(double scale) {
    _textScaleFactor = scale;
    notifyListeners();
  }

  void toggleNotifications(bool isEnabled) {
    _notificationsEnabled = isEnabled;
    notifyListeners();
  }

  void setLanguage(AppLanguage lang) {
    _language = lang;
    notifyListeners(); // Dili değiştirince tüm sayfalar yenilenir
  }

  // --- BASİT ÇEVİRİ SİSTEMİ (MVP İÇİN) ---
  // Gerçek projede bu 'localization' dosyalarında olur ama MVP için burası harika çalışır.
  String translate(String key) {
    if (_language == AppLanguage.turkish) {
      return _turkishMap[key] ?? key;
    } else {
      return _englishMap[key] ?? key;
    }
  }

  // Türkçe Sözlük
  static const Map<String, String> _turkishMap = {
    'settings_title': 'Ayarlar',
    'accessibility': 'Erişilebilirlik ve Görünüm',
    'font_size': 'Yazı Boyutu',
    'dark_mode': 'Karanlık Mod',
    'general': 'Genel',
    'language': 'Uygulama Dili',
    'notifications': 'Bildirimler',
    'about': 'Uygulama Hakkında',
    'privacy': 'Gizlilik Politikası',
    'rate_app': 'Uygulamayı Değerlendir',
    'high_contrast': 'Yüksek Karşıtlık',
    'app_name': 'Akıllı Belediye',
    'home': 'Ana Sayfa',
    'close': 'Kapat',
    'privacy_content': 'Gizlilik Politikası Metni:\n\nBu uygulama kişisel verilerinizi korumayı taahhüt eder. Toplanan veriler sadece belediye hizmetlerinin iyileştirilmesi amacıyla kullanılır...\n(Burası örnek metindir.)',
    'account': 'Hesap',
    'login': 'Giriş Yap',
    'logout': 'Çıkış Yap',
    'logout_confirm': 'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
    'cancel': 'İptal',
  };

  // İngilizce Sözlük
  static const Map<String, String> _englishMap = {
    'settings_title': 'Settings',
    'accessibility': 'Accessibility & Appearance',
    'font_size': 'Font Size',
    'dark_mode': 'Dark Mode',
    'general': 'General',
    'language': 'App Language',
    'notifications': 'Notifications',
    'about': 'About App',
    'privacy': 'Privacy Policy',
    'rate_app': 'Rate App',
    'high_contrast': 'High Contrast',
    'app_name': 'Smart Municipality',
    'home': 'Home',
    'close': 'Close',
    'privacy_content': 'Privacy Policy Text:\n\nThis application is committed to protecting your personal data. Collected data is used solely for improving municipal services...\n(This is sample text.)',
    'account': 'Account',
    'login': 'Login',
    'logout': 'Logout',
    'logout_confirm': 'Are you sure you want to log out?',
    'cancel': 'Cancel',
  };
}