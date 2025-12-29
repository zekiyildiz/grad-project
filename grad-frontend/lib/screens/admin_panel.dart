import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  // 0: Genel İstatistik, 1: Canlı Acil Akış
  final int initialIndex;

  const AdminDashboardScreen({Key? key, this.initialIndex = 0})
    : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryAdminColor = Color(0xFF0D47A1); // Koyu Mavi
  static const Color alertColor = Color(0xFFC62828); // Kırmızı

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Gelen isteğe göre (Mavi buton=0, Kırmızı buton=1) sekmeyi açar
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialIndex,
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Merkezi Yönetim Sistemi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryAdminColor,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: "GENEL DURUM"),
            Tab(
              icon: Icon(Icons.notification_important),
              text: "CANLI ACİL AKIŞ",
            ),
          ],
        ),
      ),
      
      // DRAWER MENÜ
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: primaryAdminColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.admin_panel_settings, size: 35, color: Color(0xFF0D47A1)),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Admin Panel',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Yönetici Hesabı',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: const Text('Profilim'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.blueGrey),
              title: Text(themeProvider.translate('settings_title')),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Çıkış Yap'),
              onTap: () {
                Navigator.pop(context);
                _showLogoutConfirmDialog(context, themeProvider);
              },
            ),
          ],
        ),
      ),
      
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. SEKME: İSTATİSTİKLER
          _buildStatisticsTab(),

          // 2. SEKME: SADECE ACİL BİLDİRİM LİSTESİ (Senin istediğin ekran)
          _buildEmergencyFeedTab(),
        ],
      ),
    );
  }

  // --- 1. SEKME İÇERİĞİ (İSTATİSTİK) ---
  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatGrid(),
          const SizedBox(height: 25),
          const Text(
            "Saha Personel Yoğunluğu",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Text(
                  "Toplam Aktif Personel: 1,250",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                LinearProgressIndicator(
                  value: 0.85,
                  color: Colors.blue,
                  minHeight: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. SEKME İÇERİĞİ (CANLI AKIŞ LİSTESİ) ---
  Widget _buildEmergencyFeedTab() {
    // Örnek Veriler
    final urgentItems = [
      {
        "city": "İSTANBUL / Kadıköy",
        "title": "Zincirleme Trafik Kazası",
        "status": "Ekipler Sevk Edildi",
        "time": "2 dk önce",
        "color": Colors.green,
      },
      {
        "city": "ANKARA / Çankaya",
        "title": "Doğalgaz Kaçağı İhbarı",
        "status": "İnceleniyor",
        "time": "15 dk önce",
        "color": Colors.green,
      },
      {
        "city": "İZMİR / Karşıyaka",
        "title": "Ağaç Devrilmesi (Yol Kapalı)",
        "status": "İtfaiye Bölgede",
        "time": "23 dk önce",
        "color": Colors.green,
      },
      {
        "city": "ANTALYA / Muratpaşa",
        "title": "Aşırı Yağış / Su Baskını",
        "status": "Bekliyor (Kritik)",
        "time": "40 dk önce",
        "color": Colors.red,
      },
      {
        "city": "VAN / Bahçesaray",
        "title": "Çığ Tehlikesi Uyarısı",
        "status": "Yol Trafiğe Kapatıldı",
        "time": "1 saat önce",
        "color": Colors.green,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: urgentItems.length,
      itemBuilder: (context, index) {
        final item = urgentItems[index];
        bool isCritical = item['status'].toString().contains("Kritik");

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: isCritical
                ? const BorderSide(color: Colors.red, width: 1)
                : BorderSide.none,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['city'].toString(),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item['time'].toString(),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isCritical
                          ? Colors.red
                          : Colors.orange.shade100,
                      radius: 22,
                      child: Icon(
                        Icons.notifications_active,
                        color: isCritical
                            ? Colors.white
                            : Colors.orange.shade900,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'].toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  item['status'].toString().contains("Bekliyor")
                                  ? Colors.red
                                  : Colors.green,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item['status'].toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _buildStatCard("Tüm Şikayetler", "15,240", Icons.public, Colors.blue),
        _buildStatCard(
          "Aktif Görevler",
          "342",
          Icons.engineering,
          Colors.orange,
        ),
        _buildStatCard("Çözülen", "14,800", Icons.check_circle, Colors.green),
        _buildStatCard("Acil Durum", "5", Icons.warning, Colors.red),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 30),
              Text(
                count,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
