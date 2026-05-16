import 'package:flutter/material.dart';

enum AppLanguage { turkish, english }

class ThemeProvider with ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;
  AppLanguage language = AppLanguage.turkish; 
  double textScaleFactor = 1.0;
  bool notificationsEnabled = true;
  
  // Simple Mode (Accessibility) Flag
  bool isSimpleMode = false;

  // Change Language
  void setLanguage(AppLanguage lang) {
    language = lang;
    notifyListeners();
  }

  // Change Theme (Dark/Light)
  void toggleTheme(bool isDark) {
    themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Change Font Size
  void setFontSize(double scale) {
    textScaleFactor = scale;
    notifyListeners();
  }

  // Turn Notifications On/Off
  void toggleNotifications(bool value) {
    notificationsEnabled = value;
    notifyListeners();
  }

  // Simple Mode (Accessibility) On/Off
  void toggleSimpleMode(bool value) {
    isSimpleMode = value;
    if (value) {
      // When simple mode is enabled, automatically enlarge text by 40% (1.4x scale)
      textScaleFactor = 1.4;
    } else {
      // Restore text to normal size when simple mode is turned off (1.0 scale)
      textScaleFactor = 1.0;
    }
    notifyListeners(); //It only redraws the relevant widgets (screen elements) and optimizes performance
  }
}