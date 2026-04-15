import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; 
import 'package:carousel_slider/carousel_slider.dart';

import 'complaint_screen.dart';
import 'history_screen.dart';
import 'contact_screen.dart';
import 'survey_screen.dart';
import 'help_screen.dart';
import 'events_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'notification_screen.dart';
import 'login_screen.dart';
import 'baskent153_screen.dart';
import 'emergency_screen.dart';
import 'performance_screen.dart'; 

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/weather_service.dart'; 
import '../services/notification_service.dart'; // EKLENDİ

class QuickActionItem {
  final String id;
  final IconData icon;
  final String labelKey;
  final Widget screen;
  int? badgeCount; // 'final' kelimesi kaldırıldı ki sayıyı dinamik olarak güncelleyebilelim

  QuickActionItem({
    required this.id,
    required this.icon,
    required this.labelKey,
    required this.screen,
    this.badgeCount,
  });
}

class HomepageScreen extends StatefulWidget {
  const HomepageScreen({Key? key}) : super(key: key);

  @override
  State<HomepageScreen> createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen> {
  static const Color primaryBlue = Color(0xFF4094FF);
  static const Color accentPurple = Color(0xFF9C27B0);

  final WeatherService _weatherService = WeatherService(); 
  final NotificationService _notificationService = NotificationService(); // Servis eklendi

  late List<QuickActionItem> allAvailableActions;
  List<String> userSelectedActionIds = [
    'notif', 'events', 'survey', 'history', 'perf', 'settings'
  ];

  int _unreadNotifCount = 0; // Dinamik sayı tutucu

  @override
  void initState() {
    super.initState();
    _initializeActions();
    _fetchUnreadNotificationCount(); // Sayfa açıldığında sayıyı çek
  }

  void _initializeActions() {
    allAvailableActions = [
      QuickActionItem(id: 'notif', icon: Icons.notifications_active, labelKey: 'home_quick_notifications', screen: const NotificationScreen(), badgeCount: _unreadNotifCount),
      QuickActionItem(id: 'events', icon: Icons.calendar_month, labelKey: 'home_quick_events', screen: const EventsScreen()),
      QuickActionItem(id: 'survey', icon: Icons.lightbulb_outline, labelKey: 'home_quick_survey', screen: const SurveyScreen()),
      QuickActionItem(id: 'history', icon: Icons.history, labelKey: 'home_quick_history', screen: const HistoryScreen()),
      QuickActionItem(id: 'perf', icon: Icons.emoji_events, labelKey: 'home_quick_performance', screen: const PerformanceScreen()),
      QuickActionItem(id: 'profile', icon: Icons.person, labelKey: 'home_profile', screen: const ProfileScreen()),
      QuickActionItem(id: 'settings', icon: Icons.settings, labelKey: 'home_quick_settings', screen: const SettingsScreen()),
      QuickActionItem(id: 'contact', icon: Icons.headset_mic, labelKey: 'home_contact', screen: const ContactScreen()),
      QuickActionItem(id: 'help', icon: Icons.help_outline, labelKey: 'home_help', screen: const HelpScreen()),
    ];
  }

  // --- KRİTİK EKLENTİ: OKUNMAMIŞ BİLDİRİMLERİ GETİR ---
  Future<void> _fetchUnreadNotificationCount() async {
    try {
      final notifications = await _notificationService.getMyNotifications();
      if (!mounted) return;

      int unreadCount = 0;
      for (var notif in notifications) {
        if (notif['isRead'] == false || notif['isRead'] == null) {
          unreadCount++;
        }
      }

      setState(() {
        _unreadNotifCount = unreadCount;
        // Listeyi bul ve güncelle
        final notifAction = allAvailableActions.firstWhere((a) => a.id == 'notif');
        notifAction.badgeCount = _unreadNotifCount;
      });
    } catch (e) {
      debugPrint("Bildirim sayısı çekilemedi: $e");
    }
  }

  void _showCustomizeDialog() {
    List<String> tempSelectedIds = List.from(userSelectedActionIds);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final bool isDark = Theme.of(context).brightness == Brightness.dark;
          
          return AlertDialog(
            backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
            title: Text('home_edit_title'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('home_edit_desc'.tr(), style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                  const SizedBox(height: 15),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: allAvailableActions.length,
                      itemBuilder: (context, index) {
                        final action = allAvailableActions[index];
                        final isSelected = tempSelectedIds.contains(action.id);
                        
                        return CheckboxListTile(
                          activeColor: Colors.blue,
                          checkColor: Colors.white,
                          title: Row(
                            children: [
                              Icon(action.icon, size: 20, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                              const SizedBox(width: 10),
                              Text(action.labelKey.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                            ],
                          ),
                          value: isSelected,
                          onChanged: (bool? value) {
                            setDialogState(() {
                              if (value == true) {
                                if (tempSelectedIds.length < 6) {
                                  tempSelectedIds.add(action.id);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('home_edit_max'.tr()), duration: const Duration(seconds: 1)),
                                  );
                                }
                              } else {
                                tempSelectedIds.remove(action.id);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text('cancel'.tr())),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                onPressed: () {
                  setState(() {
                    userSelectedActionIds = tempSelectedIds; 
                  });
                  Navigator.pop(ctx);
                }, 
                child: Text('home_edit_save'.tr()) 
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildQuickActionButton(BuildContext context, QuickActionItem action) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: isDark ? primaryBlue.withOpacity(0.2) : primaryBlue.withOpacity(0.1),
              child: IconButton(
                icon: Icon(action.icon, size: 28, color: isDark ? Colors.lightBlueAccent : primaryBlue),
                onPressed: () async {
                  // YÖNLENDİRME EKRANINDAN DÖNÜLÜNCE BİLDİRİM SAYISINI TEKRAR ÇEK
                  await Navigator.push(context, MaterialPageRoute(builder: (context) => action.screen));
                  _fetchUnreadNotificationCount();
                },
              ),
            ),
            if (action.badgeCount != null && action.badgeCount! > 0)
              Positioned(
                right: -5, top: -5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white, width: 2)),
                  constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                  child: Text('${action.badgeCount}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ),
              ),
          ],
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: 90, 
          child: Text(
            action.labelKey.tr(),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey.shade300 : primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionCard({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.3))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('logout'.tr()),
        content: Text('logout_confirm'.tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('cancel'.tr())),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
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

  String _capitalizeName(String name) {
    if (name.isEmpty) return "";
    return name[0].toUpperCase() + name.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    final bool simpleMode = themeProvider.isSimpleMode;
    
    final String? rawName = authProvider.user?.name; 
    final String formattedName = (rawName != null && rawName.isNotEmpty) ? _capitalizeName(rawName) : "";

    final List<QuickActionItem> activeActions = userSelectedActionIds
        .map((id) => allAvailableActions.firstWhere((action) => action.id == id))
        .toList();
        
    final List<QuickActionItem> simpleModeActions = [
      allAvailableActions.firstWhere((action) => action.id == 'notif'),    
      allAvailableActions.firstWhere((action) => action.id == 'history'),  
      allAvailableActions.firstWhere((action) => action.id == 'settings'), 
    ];

    final List<QuickActionItem> displayActions = simpleMode ? simpleModeActions : activeActions;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: Text('app_name'.tr(), style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: primaryBlue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('app_name'.tr(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('home_menu'.tr(), style: const TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
            ListTile(leading: const Icon(Icons.home, color: Colors.blue), title: Text('home'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.person, color: Colors.blue), title: Text('home_profile'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())); }),
            ListTile(
              leading: const Icon(Icons.notifications, color: Colors.blue), 
              title: Row(
                children: [
                  Text('home_notifications'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  if (_unreadNotifCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                      child: Text('$_unreadNotifCount', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    )
                  ]
                ],
              ), 
              onTap: () async { 
                Navigator.pop(context); 
                await Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
                _fetchUnreadNotificationCount(); // Drawer'dan gidilip dönülürse güncellensin
              }
            ),
            ListTile(leading: const Icon(Icons.history, color: Colors.blue), title: Text('home_history'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen())); }),
            ListTile(leading: const Icon(Icons.calendar_today, color: Colors.blue), title: Text('home_events'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const EventsScreen())); }),
            ListTile(leading: const Icon(Icons.poll, color: Colors.blue), title: Text('home_survey'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const SurveyScreen())); }),
            ListTile(leading: const Icon(Icons.emoji_events, color: Colors.blue), title: Text('home_performance'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const PerformanceScreen())); }),
            const Divider(),
            ListTile(leading: const Icon(Icons.help_outline, color: Colors.blueGrey), title: Text('home_contact'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactScreen())); }),
            ListTile(leading: const Icon(Icons.help_outline, color: Colors.blueGrey), title: Text('home_help'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpScreen())); }),
            ListTile(leading: const Icon(Icons.settings, color: Colors.blueGrey), title: Text('settings_title'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())); }),
            ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: Text('home_logout'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)), onTap: () { Navigator.pop(context); _showLogoutConfirmDialog(context); }),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  const SizedBox(height: 20),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: (authProvider.isAuthenticated && formattedName.isNotEmpty)
                        ? Text.rich(
                            TextSpan(
                              text: '${'welcome'.tr()} ', 
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.italic, 
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                              children: [
                                TextSpan(
                                  text: formattedName, 
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600, 
                                    fontStyle: FontStyle.normal, 
                                    color: primaryBlue, 
                                  ),
                                ),
                                TextSpan(
                                  text: ' ✨', 
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontStyle: FontStyle.normal,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Text(
                            'welcome_to_app'.tr(),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 180.0, autoPlay: true, autoPlayInterval: const Duration(seconds: 3),
                      autoPlayAnimationDuration: const Duration(milliseconds: 800), autoPlayCurve: Curves.fastOutSlowIn,
                      pauseAutoPlayOnTouch: true, viewportFraction: 1.0, enlargeCenterPage: false,
                    ),
                    items: ['assets/model/images/belediye1.png', 'assets/model/images/belediye2.jpg', 'assets/model/images/belediye3.jpg'].map((i) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(horizontal: 16.0),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 3))]),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(i, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Center(child: Text('home_banner_error'.tr()))),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 15),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ComplaintScreen())),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentPurple, foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 5,
                      ),
                      icon: const Icon(Icons.add_a_photo, size: 28),
                      label: Text('home_btn_complaint'.tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: FutureBuilder<Map<String, dynamic>>(
                              future: _weatherService.fetchWeather(),
                              builder: (context, snapshot) {
                                String temp = "--°C";
                                IconData weatherIcon = Icons.cloud_queue;

                                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data!.isNotEmpty) {
                                  final data = snapshot.data!;
                                  temp = "${data['main']['temp'].toInt()}°C";
                                  
                                  String desc = data['weather'][0]['description'].toLowerCase();
                                  if (desc.contains("güneş") || desc.contains("açık")) {
                                    weatherIcon = Icons.wb_sunny;
                                  } else if (desc.contains("yağmur")) {
                                    weatherIcon = Icons.umbrella;
                                  } else {
                                    weatherIcon = Icons.cloud;
                                  }
                                }

                                return Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.blue.withOpacity(0.1) : Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: isDark ? Colors.blue.withOpacity(0.3) : Colors.blue.shade100),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(weatherIcon, color: Colors.orange, size: 30),
                                      const SizedBox(height: 5),
                                      Text('home_weather_city'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text(temp, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.campaign, color: Colors.red.shade400, size: 18),
                                      const SizedBox(width: 5),
                                      Text('home_announcements'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    ],
                                  ),
                                  const Divider(height: 8),
                                  Text('home_ann1'.tr(), style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade300 : Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text('home_ann2'.tr(), style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade300 : Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('home_quick_access'.tr(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                        
                        if (!simpleMode)
                          InkWell(
                            onTap: _showCustomizeDialog,
                            child: Row(
                              children: [
                                const Icon(Icons.edit, size: 16, color: primaryBlue),
                                const SizedBox(width: 4),
                                Text('home_edit'.tr(), style: const TextStyle(fontSize: 14, color: primaryBlue, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          )
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true, 
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, 
                        childAspectRatio: 0.9, 
                        crossAxisSpacing: 10, 
                        mainAxisSpacing: 10, 
                      ),
                      itemCount: displayActions.length,
                      itemBuilder: (context, index) {
                        return _buildQuickActionButton(context, displayActions[index]);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 30),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomActionCard(icon: Icons.info_outline, label: 'home_bottom_153'.tr(), color: Colors.orange.shade700, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Baskent153Screen()))),
                const SizedBox(width: 8),
                _buildBottomActionCard(icon: Icons.warning_amber, label: 'home_bottom_emergency'.tr(), color: Colors.red.shade700, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EmergencyScreen()))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}