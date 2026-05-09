import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

import '../screens/profile_screen.dart';
import '../screens/notification_screen.dart';
import '../screens/history_screen.dart';
import '../screens/events_screen.dart';
import '../screens/survey_screen.dart';
import '../screens/performance_screen.dart';
import '../screens/contact_screen.dart';
import '../screens/help_screen.dart';
import '../screens/settings_screen.dart';

class HomeDrawer extends StatelessWidget {
  final int unreadNotifCount;
  final Function(Widget) onNavigate;
  final VoidCallback onLogout;

  const HomeDrawer({
    Key? key,
    required this.unreadNotifCount,
    required this.onNavigate,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    const Color primaryBlue = Color(0xFF4094FF);
    final authProvider = Provider.of<AuthProvider>(context);

    return Drawer(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
              decoration: const BoxDecoration(color: primaryBlue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 30, 
                    backgroundColor: Colors.white, 
                    child: Icon(Icons.person, size: 35, color: primaryBlue)
                  ),
                  const SizedBox(height: 15),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'app_name'.tr(), 
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)
                    ),
                  ),
                ],
              ),
            ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.blue),
            title: Text('home'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: Text('home_profile'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            onTap: () { Navigator.pop(context); onNavigate(const ProfileScreen()); },
          ),
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.blue),
            title: Row(
              children: [
                Text('home_notifications'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                if (unreadNotifCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                    child: Text('$unreadNotifCount', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ),
            onTap: () { Navigator.pop(context); onNavigate(const NotificationScreen()); },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Colors.blue),
            title: Text('home_history'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            onTap: () { Navigator.pop(context); onNavigate(const HistoryScreen()); },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today, color: Colors.blue),
            title: Text('home_events'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            onTap: () { Navigator.pop(context); onNavigate(const EventsScreen()); },
          ),
          ListTile(
            leading: const Icon(Icons.poll, color: Colors.blue),
            title: Text('home_survey'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            onTap: () { Navigator.pop(context); onNavigate(const SurveyScreen()); },
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events, color: Colors.blue),
            title: Text('home_performance'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            onTap: () { Navigator.pop(context); onNavigate(const PerformanceScreen()); },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.blueGrey),
            title: Text('home_contact'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            onTap: () { Navigator.pop(context); onNavigate(const ContactScreen()); },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.blueGrey),
            title: Text('home_help'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            onTap: () { Navigator.pop(context); onNavigate(const HelpScreen()); },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.blueGrey),
            title: Text('settings_title'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            onTap: () { Navigator.pop(context); onNavigate(const SettingsScreen()); },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text('home_logout'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            onTap: () { Navigator.pop(context); onLogout(); },
          ),
        ],
      ),
    );
  }
}