import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:easy_localization/easy_localization.dart'; 

class ContactCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  /// Instead of manually rewriting contact cards over and over again, a parametric and reusable UI component was created
  const ContactCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      // Dark mode-compatible card color
      color: isDark ? Colors.grey.shade900 : Colors.white,
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 30),
        title: Text(
          title, 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

class ContactScreen extends StatelessWidget {
  const ContactScreen({Key? key}) : super(key: key);

  /// A safe transition function that checks whether the target app is installed on the device (using `canLaunchUrl`)
  /// when launching external apps (Mail, Maps, Browser) via a URI, and catches potential crashes using a try-catch block.
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Hata: $url adresi açılamadı.');
      }
    } catch (e) {
      debugPrint('Sistem Hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('contact_title'.tr(), style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'contact_reach_us'.tr(),
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                // Custom header color for dark mode
                color: isDark ? Colors.white : const Color(0xFF343A40)
              ),
            ),
            const SizedBox(height: 10),

            ContactCard(
              title: 'contact_call_center'.tr(),
              subtitle: 'contact_call_desc'.tr(),
              icon: Icons.call,
              iconColor: Colors.blue,
              onTap: () => _launchURL('tel:153'),
            ),

            ContactCard(
              title: 'contact_email'.tr(),
              subtitle: 'contact_email_desc'.tr(),
              icon: Icons.email,
              iconColor: Colors.green,
              onTap: () => _launchURL('mailto:mavi-masa@ankara.bel.tr'),
            ),

            ContactCard(
              title: 'contact_address'.tr(),
              subtitle: 'contact_address_desc'.tr(),
              icon: Icons.location_on,
              iconColor: Colors.red.shade400,
              onTap: () => _launchURL('https://www.google.com/maps/search/?api=1&query=39.939318,32.839351'),
            ),
            
            const SizedBox(height: 30),
            
            Text(
              'contact_follow_us'.tr(),
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: isDark ? Colors.white : const Color(0xFF343A40)
              ),
            ),
            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildSocialIcon(Icons.facebook, 'Facebook', Colors.blue.shade700, 'https://www.facebook.com/ankarabbld', isDark),
                buildSocialIcon(Icons.camera_alt, 'Instagram', Colors.purple, 'https://instagram.com/ankarabbld', isDark),
                buildSocialIcon(Icons.play_circle_fill, 'YouTube', Colors.red, 'https://youtube.com/ankarabbld', isDark),
              ],
            ),

            const SizedBox(height: 50),
            
            Center(
              child: Text(
                'contact_version'.tr(),
                style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade500 : Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSocialIcon(IconData icon, String label, Color color, String url, bool isDark) {
    return Column(
      children: [
        InkWell(
          onTap: () => _launchURL(url),
          child: CircleAvatar(
            radius: 25,
            backgroundColor: isDark ? color.withOpacity(0.2) : color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 30),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}