import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

class EmployeeTasksScreen extends StatefulWidget {
  // 0: Standart İşler, 1: Acil Bildirimler
  final int initialIndex;

  const EmployeeTasksScreen({Key? key, this.initialIndex = 0})
    : super(key: key);

  @override
  State<EmployeeTasksScreen> createState() => _EmployeeTasksScreenState();
}

class _EmployeeTasksScreenState extends State<EmployeeTasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _normalTasks = [
    {
      'title': 'Kırık Bank Onarımı',
      'loc': 'Bahçelievler Parkı',
      'status': 'Bekliyor',
      'time': '2 saat önce',
    },
    {
      'title': 'Çöp Konteyneri Değişimi',
      'loc': 'Emek 8. Cadde',
      'status': 'Tamamlandı',
      'time': 'Dün',
    },
  ];

  final List<Map<String, dynamic>> _urgentTasks = [
    {
      'title': 'Ana Su Borusu Patlağı',
      'loc': 'Demetevler 12. Cadde',
      'time': '10 dk önce',
      'assigned': false,
    },
    {
      'title': 'Trafik Kazası / Yol Kapalı',
      'loc': 'Eskişehir Yolu 15. km',
      'time': '25 dk önce',
      'assigned': true,
    },
    {
      'title': 'Ağaç Devrilmesi',
      'loc': 'Kızılay Meydanı',
      'time': '40 dk önce',
      'assigned': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Gelen index'e göre açılacak sekmeyi ayarla
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
          'Saha Yönetimi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.assignment), text: 'Standart İşler'),
            Tab(
              icon: Icon(Icons.notification_important),
              text: 'ACİL BİLDİRİMLER',
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
              decoration: BoxDecoration(color: Colors.orange.shade800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.engineering, size: 35, color: Colors.orange),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Saha Yönetimi',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Belediye Çalışanı',
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
          // 1. SEKME: NORMAL GÖREVLER
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _normalTasks.length,
            itemBuilder: (context, index) {
              final task = _normalTasks[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.engineering, color: Colors.blue),
                  title: Text(task['title']),
                  subtitle: Text(task['loc']),
                ),
              );
            },
          ),

          // 2. SEKME: ACİL BİLDİRİM (ATA BUTONLU)
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _urgentTasks.length,
            itemBuilder: (context, index) {
              final task = _urgentTasks[index];
              bool isAssigned = task['assigned'];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isAssigned ? Colors.transparent : Colors.red,
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isAssigned
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      child: Icon(
                        isAssigned ? Icons.check : Icons.campaign,
                        color: isAssigned
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                      ),
                    ),
                    title: Text(
                      task['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("${task['loc']} • ${task['time']}"),
                    trailing: isAssigned
                        ? const Text(
                            "EKİP SAHADA",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () {
                              setState(() {
                                task['assigned'] = true;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Ekip yönlendirildi!"),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("EKİP ATA"),
                          ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
