import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

enum AppLanguage { turkish, english }

class ThemeProvider with ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;
  AppLanguage language = AppLanguage.turkish;
  double textScaleFactor = 1.0;
  bool notificationsEnabled = true;

  // --- SÖZLÜK (ÇEVİRİLER BURADA) ---
  final Map<String, Map<String, String>> _localizedStrings = {
    // GENEL
    'app_name': {'tr': 'Akıllı Belediye', 'en': 'Smart Municipality'},
    'cancel': {'tr': 'İptal', 'en': 'Cancel'},
    'confirm': {'tr': 'Onayla', 'en': 'Confirm'},
    'close': {'tr': 'Kapat', 'en': 'Close'},

    // MENÜ & ANA SAYFA
    'home': {'tr': 'Ana Sayfa', 'en': 'Home'},
    'profile': {'tr': 'Profilim', 'en': 'My Profile'},
    'notifications': {'tr': 'Bildirimler', 'en': 'Notifications'},
    'history': {'tr': 'Şikayet Geçmişim', 'en': 'History'},
    'events': {'tr': 'Etkinlik Takvimi', 'en': 'Events'},
    'survey': {'tr': 'Öneri/Anket', 'en': 'Polls/Survey'},
    'contact': {'tr': 'İletişim', 'en': 'Contact'},
    'help': {'tr': 'Yardım/SSS', 'en': 'Help/FAQ'},
    'settings_title': {'tr': 'Ayarlar', 'en': 'Settings'},
    'logout': {'tr': 'Çıkış Yap', 'en': 'Logout'},
    'btn_complaint': {'tr': 'Şikayet/Durum Bildir', 'en': 'Report Issue'},
    'btn_call': {'tr': 'Başkent 153', 'en': 'Call Center 153'},
    'btn_emergency': {'tr': 'Acil Bildir', 'en': 'Emergency'},

    // ŞİKAYET EKRANI (Complaint Screen)
    'complaint_title': {
      'tr': 'Şikayet Bildirimi Oluştur',
      'en': 'Create Complaint',
    },
    'photo_label': {'tr': 'Fotoğraf Çek/Yükle', 'en': 'Take/Upload Photo'},
    'photo_ai_hint': {
      'tr': 'Yapay Zeka Analizi İçin Dokunun',
      'en': 'Tap for AI Analysis',
    },
    'pick_source': {
      'tr': 'Görsel Kaynağını Seçin',
      'en': 'Select Image Source',
    },
    'camera': {'tr': 'Kamera İle Çek', 'en': 'Take with Camera'},
    'gallery': {'tr': 'Galeriden Seç', 'en': 'Select from Gallery'},
    'location_auto': {
      'tr': 'Konum (Otomatik Alındı)',
      'en': 'Location (Auto-detected)',
    },
    'issue_type': {'tr': 'Sorun Türü', 'en': 'Issue Type'},
    'ai_selected': {'tr': 'AI Seçti ✨', 'en': 'AI Selected ✨'},
    'desc_label': {
      'tr': 'Açıklama (Opsiyonel)',
      'en': 'Description (Optional)',
    },
    'desc_hint': {'tr': 'Ek detaylar...', 'en': 'Extra details...'},
    'btn_submit': {'tr': 'RAPORU GÖNDER', 'en': 'SUBMIT REPORT'},
    'toast_ai_found': {'tr': 'Tespit Edildi:', 'en': 'Detected:'},
    'toast_no_obj': {
      'tr': 'Nesne bulunamadı, DİĞER seçildi.',
      'en': 'No object found, OTHER selected.',
    },

    // KATEGORİLER
    'cat_pothole': {
      'tr': '🚧 Kaldırım/Yol Çukuru',
      'en': '🚧 Pothole/Road Damage',
    },
    'cat_bench': {'tr': '🪑 Kırık Bank/Oturma Alanı', 'en': '🪑 Broken Bench'},
    'cat_garbage': {
      'tr': '🗑️ Aşırı Çöp/Kirlilik',
      'en': '🗑️ Garbage/Trash Overflow',
    },
    'cat_electric': {
      'tr': '⚡ Elektrik Panosu/Direk',
      'en': '⚡ Electrical Panel/Pole',
    },
    'cat_traffic': {
      'tr': '🚦 Trafik Işığı Arızası',
      'en': '🚦 Traffic Light Issue',
    },
    'cat_scooter': {
      'tr': '🛴 Yanlış Park Edilmiş Scooter',
      'en': '🛴 Improperly Parked Scooter',
    },
    'cat_poster': {
      'tr': '📜 İzinsiz Afiş/Poster',
      'en': '📜 Illegal Poster/Graffiti',
    },
    'cat_tree': {
      'tr': '🌳 Ağaç/Peyzaj Sorunu',
      'en': '🌳 Tree/Landscape Issue',
    },
    'cat_other': {'tr': '❓ Diğer/Tanımlanamayan', 'en': '❓ Other/Unidentified'},

    // AYARLAR EKRANI
    'font_size': {'tr': 'Yazı Boyutu', 'en': 'Font Size'},
    'dark_mode': {'tr': 'Karanlık Mod', 'en': 'Dark Mode'},
    'language': {'tr': 'Dil / Language', 'en': 'Language'},
    'privacy': {'tr': 'Gizlilik Politikası', 'en': 'Privacy Policy'},
    'rate_app': {'tr': 'Uygulamayı Puanla', 'en': 'Rate App'},
    'about': {'tr': 'Hakkında', 'en': 'About'},
    'accessibility': {'tr': 'Erişilebilirlik', 'en': 'Accessibility'},
    'general': {'tr': 'Genel', 'en': 'General'},

    // PROFİL EKRANI
    'personal_info': {'tr': 'Kişisel Bilgiler', 'en': 'Personal Information'},
    'stats': {'tr': 'İstatistikler', 'en': 'Statistics'},
    'full_name': {'tr': 'Ad Soyad', 'en': 'Full Name'},
    'email': {'tr': 'E-posta', 'en': 'E-mail'},
    'phone': {'tr': 'Telefon', 'en': 'Phone'},
    'address': {'tr': 'Adres', 'en': 'Address'},
    'total_reports': {'tr': 'Toplam Şikayet', 'en': 'Total Reports'},
    'resolved': {'tr': 'Çözüldü', 'en': 'Resolved'},
    'surveys_joined': {'tr': 'Katıldığı Anket', 'en': 'Surveys Joined'},
    'edit_profile': {'tr': 'Profili Düzenle', 'en': 'Edit Profile'},

    // İLETİŞİM EKRANI
    'contact_title': {'tr': 'İletişim ve Destek', 'en': 'Contact & Support'},
    'contact_header': {
      'tr': 'Bize Ulaşın (7/24 Destek)',
      'en': 'Contact Us (24/7 Support)',
    },
    'call_center': {'tr': 'Çağrı Merkezi (Mavi Masa)', 'en': 'Call Center'},
    'call_desc': {
      'tr': '7/24 Sorun Bildirimi ve Bilgi',
      'en': '24/7 Issue Reporting & Info',
    },
    'email_support': {'tr': 'E-Posta (Yazılı Destek)', 'en': 'E-Mail Support'},
    'email_desc': {
      'tr': 'Geri bildirim ve detaylı sorularınız',
      'en': 'Feedback and detailed inquiries',
    },
    'center_address': {'tr': 'Merkez Adres', 'en': 'Central Address'},
    'address_desc': {
      'tr': 'Belediye binası ve ana hizmet noktası',
      'en': 'Municipality building & main service point',
    },
    'follow_us': {'tr': 'Bizi Takip Edin', 'en': 'Follow Us'},
    'app_version': {
      'tr': 'Akıllı Belediye Uygulaması v1.0.0 (MVP)',
      'en': 'Smart Municipality App v1.0.0 (MVP)',
    },

    // PERFORMANS EKRANI
    'perf_title': {
      'tr': 'Performans ve Rozetler',
      'en': 'Performance & Badges',
    },
    'perf_score_title': {
      'tr': 'Genel Performans Puanınız',
      'en': 'Your Overall Score',
    },
    'level': {'tr': 'Seviye', 'en': 'Level'},
    'next_level': {
      'tr': 'Bir sonraki seviyeye kalan ilerleme',
      'en': 'Progress to next level',
    },
    'badges_won': {'tr': 'Kazanılan Rozetler', 'en': 'Badges Earned'},
    'leaderboard_btn': {
      'tr': 'Liderlik Tablosunu Gör',
      'en': 'View Leaderboard',
    },

    // AUTH EKRANLARI
    'login': {'tr': 'Giriş Yap', 'en': 'Login'},
    'logout_confirm': {
      'tr': 'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
      'en': 'Are you sure you want to log out?',
    },
    'account': {'tr': 'Hesap', 'en': 'Account'},
    'privacy_content': {
      'tr': 'Gizlilik Politikası Metni:\n\nBu uygulama kişisel verilerinizi korumayı taahhüt eder. Toplanan veriler sadece belediye hizmetlerinin iyileştirilmesi amacıyla kullanılır...\n(Burası örnek metindir.)',
      'en': 'Privacy Policy Text:\n\nThis application is committed to protecting your personal data. Collected data is used solely for improving municipal services...\n(This is sample text.)',
    },
  };

  // Çeviri Metodu
  String translate(String key) {
    String langCode = language == AppLanguage.turkish ? 'tr' : 'en';
    return _localizedStrings[key]?[langCode] ??
        key; // Bulamazsa key'in kendisini döner
  }

  // Dil Değiştirme
  void setLanguage(AppLanguage lang) {
    language = lang;
    notifyListeners();
  }

  // Tema Değiştirme
  void toggleTheme(bool isDark) {
    themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Font Değiştirme
  void setFontSize(double scale) {
    textScaleFactor = scale;
    notifyListeners();
  }

  // Bildirim Aç/Kapa
  void toggleNotifications(bool value) {
    notificationsEnabled = value;
    notifyListeners();
  }
}