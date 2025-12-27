import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

// Enumlar (Sadece burada kullanılanlar)
enum AppFontSize { small, medium, large, extraLarge }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  
  // Font Size Label Helper
  String _getFontSizeLabel(double scale) {
    if (scale == 0.8) return 'Küçük / Small';
    if (scale == 1.0) return 'Orta / Medium';
    if (scale == 1.2) return 'Büyük / Large';
    if (scale == 1.4) return 'Çok Büyük / Extra Large';
    return 'Orta';
  }

  double _getScaleFromEnum(AppFontSize size) {
    switch (size) {
      case AppFontSize.small: return 0.8;
      case AppFontSize.medium: return 1.0;
      case AppFontSize.large: return 1.2;
      case AppFontSize.extraLarge: return 1.4;
    }
  }

  // --- DİYALOGLAR ---

  // 1. Yazı Boyutu Diyaloğu
  void _showFontSizeDialog(ThemeProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(provider.translate('font_size')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppFontSize.values.map((size) {
            double scale = _getScaleFromEnum(size);
            return RadioListTile<double>(
              title: Text(_getFontSizeLabel(scale)),
              value: scale,
              groupValue: provider.textScaleFactor,
              onChanged: (val) {
                if (val != null) {
                  provider.setFontSize(val);
                  Navigator.pop(ctx);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  // 2. Dil Seçim Diyaloğu (ARTIK ÇALIŞIYOR)
  void _showLanguageDialog(ThemeProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(provider.translate('language')),
        children: [
          SimpleDialogOption(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text('Türkçe'),
                if (provider.language == AppLanguage.turkish) 
                  const Icon(Icons.check, color: Colors.blue),
              ],
            ),
            onPressed: () {
              provider.setLanguage(AppLanguage.turkish); // Dili değiştir
              Navigator.pop(ctx);
            },
          ),
          SimpleDialogOption(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text('English'),
                if (provider.language == AppLanguage.english) 
                  const Icon(Icons.check, color: Colors.blue),
              ],
            ),
            onPressed: () {
              provider.setLanguage(AppLanguage.english); // Dili değiştir
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  // 3. Gizlilik Politikası Diyaloğu (YENİ)
  void _showPrivacyDialog(ThemeProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(provider.translate('privacy')),
        content: SingleChildScrollView(
          child: Text(provider.translate('privacy_content')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(provider.translate('close')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Provider'ı dinle
    final provider = Provider.of<ThemeProvider>(context);
    final isDark = provider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        // Başlık artık dinamik!
        title: Text(provider.translate('settings_title'), style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          _buildHeader(provider.translate('accessibility')),
          
          ListTile(
            leading: const Icon(Icons.format_size, color: Colors.purple),
            title: Text(provider.translate('font_size')),
            subtitle: Text(_getFontSizeLabel(provider.textScaleFactor)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showFontSizeDialog(provider),
          ),
          
          SwitchListTile(
            activeColor: Colors.blue,
            secondary: const Icon(Icons.dark_mode, color: Colors.blueGrey),
            title: Text(provider.translate('dark_mode')),
            value: isDark,
            onChanged: (val) => provider.toggleTheme(val),
          ),

          const Divider(),
          _buildHeader(provider.translate('general')),

          ListTile(
            leading: const Icon(Icons.language, color: Colors.blue),
            title: Text(provider.translate('language')),
            subtitle: Text(provider.language == AppLanguage.turkish ? 'Türkçe' : 'English'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageDialog(provider),
          ),

          SwitchListTile(
            activeColor: Colors.green,
            secondary: Icon(
              provider.notificationsEnabled ? Icons.notifications_active : Icons.notifications_off, 
              color: Colors.red
            ),
            title: Text(provider.translate('notifications')),
            subtitle: Text(provider.notificationsEnabled ? 'Açık / On' : 'Kapalı / Off'),
            value: provider.notificationsEnabled,
            onChanged: (val) {
              // Bildirim ayarını değiştir
              provider.toggleNotifications(val);
              
              // Kullanıcıya bilgi ver
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(val ? 'Bildirimler açıldı.' : 'Bildirimler kapatıldı.'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),

          const Divider(),
          _buildHeader(provider.translate('about')),

          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Colors.grey),
            title: Text(provider.translate('privacy')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showPrivacyDialog(provider),
          ),
          
          ListTile(
            leading: const Icon(Icons.star, color: Colors.amber),
            title: Text(provider.translate('rate_app')),
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Store sayfasına yönlendiriliyor...')),
              );
            },
          ),
          
          // Logout section
          const Divider(),
          _buildHeader(provider.translate('account')),
          
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.isAuthenticated) {
                return ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: Text(
                    provider.translate('logout'),
                    style: const TextStyle(color: Colors.red),
                  ),
                  onTap: () => _showLogoutDialog(context, authProvider, provider),
                );
              } else {
                return ListTile(
                  leading: const Icon(Icons.login, color: Colors.blue),
                  title: Text(provider.translate('login')),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                );
              }
            },
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  void _showLogoutDialog(BuildContext context, AuthProvider authProvider, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(themeProvider.translate('logout')),
        content: Text(themeProvider.translate('logout_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(themeProvider.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              themeProvider.translate('logout'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}