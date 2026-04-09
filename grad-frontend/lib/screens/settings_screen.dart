import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; 
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

enum AppFontSize { small, medium, large, extraLarge }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  
  String _getFontSizeLabel(double scale) {
    if (scale == 0.8) return 'settings_font_small'.tr();
    if (scale == 1.0) return 'settings_font_medium'.tr();
    if (scale == 1.2) return 'settings_font_large'.tr();
    if (scale == 1.4) return 'settings_font_xlarge'.tr();
    return 'settings_font_medium'.tr();
  }

  double _getScaleFromEnum(AppFontSize size) {
    switch (size) {
      case AppFontSize.small: return 0.8;
      case AppFontSize.medium: return 1.0;
      case AppFontSize.large: return 1.2;
      case AppFontSize.extraLarge: return 1.4;
    }
  }

  void _showFontSizeDialog(ThemeProvider provider, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        title: Text('font_size'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppFontSize.values.map((size) {
            double scale = _getScaleFromEnum(size);
            return RadioListTile<double>(
              title: Text(_getFontSizeLabel(scale), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
              value: scale,
              groupValue: provider.textScaleFactor,
              activeColor: Colors.blue,
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

  void _showLanguageDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        title: Text('language'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        children: [
          SimpleDialogOption(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text('Türkçe', style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                const Spacer(),
                if (context.locale.languageCode == 'tr') 
                  const Icon(Icons.check, color: Colors.blue),
              ],
            ),
            onPressed: () async {
              await context.setLocale(const Locale('tr', 'TR'));
              if (ctx.mounted) Navigator.pop(ctx);
            },
          ),
          SimpleDialogOption(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text('English', style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                const Spacer(),
                if (context.locale.languageCode == 'en') 
                  const Icon(Icons.check, color: Colors.blue),
              ],
            ),
            onPressed: () async {
              await context.setLocale(const Locale('en', 'US'));
              if (ctx.mounted) Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        title: Text('privacy'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        content: SingleChildScrollView(
          child: Text('privacy_content'.tr(), style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.black87)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('close'.tr())),
        ],
      ),
    );
  }

  void _showRatingDialog(bool isDark) {
    int rating = 0;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Column(
              children: [
                const Icon(Icons.star_border_purple500, size: 50, color: Colors.amber),
                const SizedBox(height: 10),
                Text('rate_dialog_title'.tr(), textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('rate_dialog_desc'.tr(), textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      iconSize: 40,
                      padding: EdgeInsets.zero,
                      icon: Icon(index < rating ? Icons.star : Icons.star_border, color: Colors.amber),
                      onPressed: () => setDialogState(() => rating = index + 1),
                    );
                  }),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text('cancel'.tr(), style: const TextStyle(color: Colors.grey))),
              ElevatedButton(
                onPressed: rating > 0 ? () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('rate_dialog_thanks'.tr()), backgroundColor: Colors.green));
                } : null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                child: Text('rate_dialog_submit'.tr()), 
              ),
            ],
          );
        }
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        title: Text('logout'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        content: Text('logout_confirm'.tr(), style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.black87)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('cancel'.tr())),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('logout'.tr(), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(title.toUpperCase(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = provider.themeMode == ThemeMode.dark;

    // --- SENİN MANTIĞINLA ROL KONTROLÜ EKLENDİ ---
    // 0: Admin, 2: Çalışan. Bunlardan hiçbiri değilse vatandaştır.
    final bool isNormalUser = authProvider.userRoleId != 0 && authProvider.userRoleId != 2;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
      appBar: AppBar(
        title: Text('settings_title'.tr(), style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          // Erişilebilirlik başlığını sadece Vatandaşsa (isNormalUser) göster
          if (isNormalUser)
            _buildHeader('accessibility'.tr()),
          
          // Basit Mod seçeneğini sadece Vatandaşsa (isNormalUser) göster
          if (isNormalUser)
            SwitchListTile(
              activeColor: Colors.orange,
              secondary: const Icon(Icons.accessibility_new, color: Colors.orange),
              title: Text('settings_simple_mode'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
              subtitle: Text('settings_simple_mode_desc'.tr(), style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
              value: provider.isSimpleMode,
              onChanged: (val) => provider.toggleSimpleMode(val),
            ),
          
          // Eğer vatandaş değilse (Admin/Çalışan ise) Görünüm başlığı atalım ki aşağıdaki ayarlar havada kalmasın
          if (!isNormalUser)
            _buildHeader('Görünüm'), // JSON'a eklemeye gerek yok, idari bir panel

          ListTile(
            leading: const Icon(Icons.format_size, color: Colors.purple),
            title: Text('font_size'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            subtitle: Text(_getFontSizeLabel(provider.textScaleFactor), style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => _showFontSizeDialog(provider, isDark),
          ),
          
          SwitchListTile(
            activeColor: Colors.blue,
            secondary: const Icon(Icons.dark_mode, color: Colors.blueGrey),
            title: Text('dark_mode'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            value: isDark,
            onChanged: (val) => provider.toggleTheme(val),
          ),

          const Divider(),
          _buildHeader('general'.tr()),

          ListTile(
            leading: const Icon(Icons.language, color: Colors.blue),
            title: Text('language'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            subtitle: Text(context.locale.languageCode == 'tr' ? 'Türkçe' : 'English', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => _showLanguageDialog(isDark),
          ),

          SwitchListTile(
            activeColor: Colors.green,
            secondary: Icon(provider.notificationsEnabled ? Icons.notifications_active : Icons.notifications_off, color: Colors.red),
            title: Text('notifications'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            subtitle: Text(provider.notificationsEnabled ? 'settings_notif_on'.tr() : 'settings_notif_off'.tr(), style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
            value: provider.notificationsEnabled,
            onChanged: (val) => provider.toggleNotifications(val),
          ),

          const Divider(),
          _buildHeader('about'.tr()),

          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Colors.grey),
            title: Text('privacy'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => _showPrivacyDialog(isDark),
          ),
          
          ListTile(
            leading: const Icon(Icons.star, color: Colors.amber),
            title: Text('rate_app'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            onTap: () => _showRatingDialog(isDark),
          ),
          
          const Divider(),
          _buildHeader('account'.tr()),
          
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.isAuthenticated) {
                return ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: Text('logout'.tr(), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  onTap: () => _showLogoutDialog(context, authProvider, isDark),
                );
              } else {
                return ListTile(
                  leading: const Icon(Icons.login, color: Colors.blue),
                  title: Text('login'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
                  onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                );
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}