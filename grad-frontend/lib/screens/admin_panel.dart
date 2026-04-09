import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; // EKLENDİ
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final int initialIndex;

  const AdminDashboardScreen({Key? key, this.initialIndex = 0})
    : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryAdminColor = Color(0xFF0D47A1); 
  static const Color alertColor = Color(0xFFC62828); 

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
  }

  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('logout'.tr()),
        content: Text('logout_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('cancel'.tr()),
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
              'logout'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark; // KARANLIK MOD KONTROLÜ
    
    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100, // DİNAMİK ARKA PLAN
      appBar: AppBar(
        title: Text(
          'admin_app_bar_title'.tr(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryAdminColor,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(icon: const Icon(Icons.analytics), text: "admin_tab_stats".tr()),
            Tab(icon: const Icon(Icons.notification_important), text: "admin_tab_live".tr()),
          ],
        ),
      ),
      
      drawer: Drawer(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white, // DİNAMİK DRAWER
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: primaryAdminColor),
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
                  Text(
                    'admin_drawer_title'.tr(),
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'admin_drawer_subtitle'.tr(),
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: Text('prof_title'.tr()),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.blueGrey),
              title: Text('settings_title'.tr()),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text('logout'.tr()),
              onTap: () {
                Navigator.pop(context);
                _showLogoutConfirmDialog(context);
              },
            ),
          ],
        ),
      ),
      
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatisticsTab(isDark),
          _buildEmergencyFeedTab(isDark),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatGrid(isDark),
          const SizedBox(height: 25),
          Text(
            "admin_stats_personnel".tr(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.white, // DİNAMİK KUTU
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  "admin_stats_active_total".tr(),
                  style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                ),
                const SizedBox(height: 10),
                const LinearProgressIndicator(
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

  Widget _buildEmergencyFeedTab(bool isDark) {
    final urgentItems = [
      {
        "city": "admin_live_city_1".tr(),
        "title": "admin_live_title_1".tr(),
        "status": "admin_live_status_1".tr(),
        "time": "2 dk",
        "color": Colors.green,
      },
      {
        "city": "admin_live_city_2".tr(),
        "title": "admin_live_title_2".tr(),
        "status": "admin_live_status_2".tr(),
        "time": "15 dk",
        "color": Colors.green,
      },
      {
        "city": "admin_live_city_3".tr(),
        "title": "admin_live_title_3".tr(),
        "status": "admin_live_status_3".tr(),
        "time": "23 dk",
        "color": Colors.green,
      },
      {
        "city": "admin_live_city_4".tr(),
        "title": "admin_live_title_4".tr(),
        "status": "admin_live_status_4".tr(),
        "time": "40 dk",
        "color": Colors.red,
      },
      {
        "city": "admin_live_city_5".tr(),
        "title": "admin_live_title_5".tr(),
        "status": "admin_live_status_5".tr(),
        "time": "1 saat",
        "color": Colors.green,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: urgentItems.length,
      itemBuilder: (context, index) {
        final item = urgentItems[index];
        bool isCritical = item['status'].toString().toLowerCase().contains("kritik") || item['status'].toString().toLowerCase().contains("critical");

        return Card(
          elevation: 3,
          color: isDark ? Colors.grey.shade800 : Colors.white, // DİNAMİK KART ARKA PLANI
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
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item['time'].toString(),
                      style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isCritical ? Colors.red : Colors.orange.shade100,
                      radius: 22,
                      child: Icon(
                        Icons.notifications_active,
                        color: isCritical ? Colors.white : Colors.orange.shade900,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'].toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCritical ? Colors.red : Colors.green,
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

  Widget _buildStatGrid(bool isDark) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _buildStatCard("admin_stat_all".tr(), "15,240", Icons.public, Colors.blue, isDark),
        _buildStatCard("admin_stat_active".tr(), "342", Icons.engineering, Colors.orange, isDark),
        _buildStatCard("admin_stat_solved".tr(), "14,800", Icons.check_circle, Colors.green, isDark),
        _buildStatCard("admin_stat_emergency".tr(), "5", Icons.warning, Colors.red, isDark),
      ],
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white, // DİNAMİK KUTU
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
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade400 : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}