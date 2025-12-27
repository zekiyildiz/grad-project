import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider paketini ekledik

// Diğer ekranların importları
import 'complaint_screen.dart';
import 'history_screen.dart';
import 'contact_screen.dart';
import 'survey_screen.dart';
import 'help_screen.dart';
import 'events_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart'; // Ayarlar sayfası importu
import 'notification_screen.dart'; // Bildirimler sayfası importu
import 'login_screen.dart'; // Login sayfası importu
import '../providers/theme_provider.dart'; // ThemeProvider importu
import '../providers/auth_provider.dart'; // AuthProvider importu

class HomepageScreen extends StatelessWidget {
  const HomepageScreen({Key? key}) : super(key: key);

  // KULLANILACAK ÖZEL RENKLER
  static const Color primaryBlue = Color(0xFF4094FF);
  static const Color accentPurple = Color(0xFF9C27B0);
  static const Color bottomNavBackground = Color(0xFFF0F0F0);

  // Hızlı Erişim Butonları için Yardımcı Widget
  Widget _buildQuickActionButton(BuildContext context, IconData icon, String label, Widget screen, {int? badgeCount}) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Dairesel Buton
            CircleAvatar(
              radius: 30,
              backgroundColor: primaryBlue.withOpacity(0.1),
              child: IconButton(
                icon: Icon(icon, size: 30, color: primaryBlue),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
                },
              ),
            ),
            // Bildirim Sayısı (Yalnızca varsa)
            if (badgeCount != null && badgeCount > 0)
              Positioned(
                right: -5,
                top: -5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 5),
        // Etiket
        SizedBox(
          width: 80,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: primaryBlue, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // Alt Menü Kartları için Yardımcı Widget
  Widget _buildBottomActionCard({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Çıkış Onay Dialoğu
  void _showLogoutConfirmDialog(BuildContext context, ThemeProvider themeProvider) {
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
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
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

  @override
  Widget build(BuildContext context) {
    // 1. Provider'ı çağırarak ayarlara ve çeviriye erişim sağlıyoruz
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      // 1. AppBar: Başlık Çubuğu
      appBar: AppBar(
        backgroundColor: primaryBlue,
        // 2. Başlığı Dinamik Yapıyoruz (Türkçe/İngilizce değişir)
        title: Text(
          themeProvider.translate('app_name'), 
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),

      // Drawer (Yan Menü)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header
            DrawerHeader(
              decoration: const BoxDecoration(
                color: primaryBlue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    themeProvider.translate('app_name'), // Dinamik Başlık
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Menü',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),

            // MENÜ ÖGELERİ
            ListTile(
              leading: const Icon(Icons.home, color: Colors.blue),
              title: Text(themeProvider.translate('home')), // Dinamik "Ana Sayfa" yazısı
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: const Text('Profilim'), // Diğerlerini çevirmek için ThemeProvider sözlüğüne ekleme yapmalısınız
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: Colors.blue),
              title: const Text('Bildirimlerim'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.blue),
              title: const Text('Şikayet Geçmişim'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.blue),
              title: const Text('Etkinlik Takvimi'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const EventsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.poll, color: Colors.blue),
              title: const Text('Öneri/Anket'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SurveyScreen()));
              },
            ),
            // Performans & Rozetler Sayfası
            ListTile(
              leading: const Icon(Icons.emoji_events, color: Colors.blue), // Kupa ikonu
              title: const Text('Performans & Rozetler'),
              onTap: () {
                Navigator.pop(context);
                // Performans ekranına yönlendirme
                // NOT: performance_screen.dart dosyasının import edildiğinden emin olun.
                // Eğer import hatası alırsanız dosyanın en üstüne import 'performance_screen.dart'; ekleyin.
                // Şimdilik yorum satırı olarak bırakıyorum, dosya varsa açabilirsiniz:
                // Navigator.push(context, MaterialPageRoute(builder: (context) => const PerformanceScreen()));
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.help_outline, color: Colors.blueGrey),
              title: const Text('İletişim'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline, color: Colors.blueGrey),
              title: const Text('Yardım/SSS'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpScreen()));
              },
            ),
            
            // AYARLAR BUTONU
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.blueGrey),
              title: Text(themeProvider.translate('settings_title')), // Dinamik Ayarlar Yazısı
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Çıkış Yap'),
              onTap: () {
                Navigator.pop(context); // Drawer'ı kapat
                _showLogoutConfirmDialog(context, themeProvider);
              },
            ),
          ],
        ),
      ),

      // 3. Body: Ana Sayfa Gövdesi
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Üstteki Afiş Alanı (Görsel Varsa Gösterir)
            Container(
              height: 200,
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
                color: Colors.black54,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/yesilcam_geceleri.jpg', // Eklediğiniz görselin yolu
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Text(
                      'DUYURU AFİŞİ\n(assets/images/yesilcam_geceleri.jpg\nklasörünü kontrol edin)',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Ana Eylem Butonu (Şikayet/Durum Bildir)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ComplaintScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentPurple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                icon: const Icon(Icons.add_a_photo, size: 28),
                label: const Text(
                  'Şikayet/Durum Bildir',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Hızlı Erişim Butonları
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickActionButton(
                    context,
                    Icons.notifications_active,
                    'Bildirimler',
                    const NotificationScreen(),
                    badgeCount: 2, // Örnek sayı
                  ),
                  _buildQuickActionButton(
                    context,
                    Icons.calendar_month,
                    'Etkinlik Takvimi',
                    const EventsScreen(),
                  ),
                  _buildQuickActionButton(
                    context,
                    Icons.lightbulb_outline,
                    'Öneri/\nAnket',
                    const SurveyScreen(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Divider(height: 1, indent: 16, endIndent: 16),
            const SizedBox(height: 10),

            // Alt Kısım: Başkent 153 ve Acil Bildir
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomActionCard(
                    icon: Icons.info_outline,
                    label: 'Başkent 153',
                    color: Colors.orange.shade700,
                    onTap: () => print('Başkent 153 (Call) tıklandı'),
                  ),
                  const SizedBox(width: 10),
                  _buildBottomActionCard(
                    icon: Icons.warning_amber,
                    label: 'Acil Bildir',
                    color: Colors.red.shade700,
                    onTap: () => print('Acil Bildir tıklandı'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}