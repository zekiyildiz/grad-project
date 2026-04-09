import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; // EKLENDİ
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

class EmployeeTasksScreen extends StatefulWidget {
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
      'titleKey': 'emp_task1_title',
      'locKey': 'emp_task1_loc',
      'statusKey': 'task_status_waiting',
      'timeKey': 'emp_task1_time',
    },
    {
      'titleKey': 'emp_task2_title',
      'locKey': 'emp_task2_loc',
      'statusKey': 'task_status_completed',
      'timeKey': 'emp_task2_time',
    },
  ];

  final List<Map<String, dynamic>> _urgentTasks = [
    {
      'titleKey': 'emp_urgent1_title',
      'locKey': 'emp_urgent1_loc',
      'timeKey': 'emp_urgent1_time',
      'assigned': false,
    },
    {
      'titleKey': 'emp_urgent2_title',
      'locKey': 'emp_urgent2_loc',
      'timeKey': 'emp_urgent2_time',
      'assigned': true,
    },
    {
      'titleKey': 'emp_urgent3_title',
      'locKey': 'emp_urgent3_loc',
      'timeKey': 'emp_urgent3_time',
      'assigned': false,
    },
  ];

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
            child: Text('logout'.tr(), style: const TextStyle(color: Colors.white)),
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
          'employee_app_bar_title'.tr(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(icon: const Icon(Icons.assignment), text: 'employee_tab_standard'.tr()),
            Tab(icon: const Icon(Icons.notification_important), text: 'employee_tab_urgent'.tr()),
          ],
        ),
      ),
      
      drawer: Drawer(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
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
                  Text(
                    'employee_app_bar_title'.tr(),
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'employee_drawer_subtitle'.tr(),
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
          // 1. SEKME: NORMAL GÖREVLER
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _normalTasks.length,
            itemBuilder: (context, index) {
              final task = _normalTasks[index];
              return Card(
                color: isDark ? Colors.grey.shade800 : Colors.white, // DİNAMİK KART
                child: ListTile(
                  leading: const Icon(Icons.engineering, color: Colors.blue),
                  title: Text(task['titleKey'].toString().tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  subtitle: Text(task['locKey'].toString().tr(), style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700)),
                ),
              );
            },
          ),

          // 2. SEKME: ACİL BİLDİRİM
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _urgentTasks.length,
            itemBuilder: (context, index) {
              final task = _urgentTasks[index];
              bool isAssigned = task['assigned'];
              return Card(
                elevation: 3,
                color: isDark ? Colors.grey.shade800 : Colors.white, // DİNAMİK KART
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
                      backgroundColor: isAssigned ? Colors.green.shade100 : Colors.red.shade100,
                      child: Icon(
                        isAssigned ? Icons.check : Icons.campaign,
                        color: isAssigned ? Colors.green.shade800 : Colors.red.shade800,
                      ),
                    ),
                    title: Text(
                      task['titleKey'].toString().tr(),
                      style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                    ),
                    subtitle: Text(
                      "${task['locKey'].toString().tr()} • ${task['timeKey'].toString().tr()}",
                      style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                    ),
                    trailing: isAssigned
                        ? Text(
                            "urgent_status_on_field".tr(),
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          )
                        : ElevatedButton(
                            onPressed: () {
                              setState(() {
                                task['assigned'] = true;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("urgent_snack_dispatched".tr())),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                              foregroundColor: Colors.white,
                            ),
                            child: Text("urgent_btn_assign".tr()),
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