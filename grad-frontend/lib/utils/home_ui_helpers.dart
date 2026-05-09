import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../screens/homepage_screen.dart';

class HomeUIHelpers {
  /// A warning window for screens that require login.
  static void showLoginWarningDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.orange.shade700, size: 28),
            const SizedBox(width: 10),
            Expanded(child: Text("login_required_title".tr(), style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        content: Text("login_required_desc".tr(), style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.black87)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("cancel".tr())),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () { Navigator.pop(ctx); Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())); },
            child: Text("login_btn".tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// A subpanel displaying announcement details - Detail Panel That Opens When Posters Are Clicked
  static void showBannerDetail(BuildContext context, String title, String desc, String imgPath, Color primaryBlue) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(imgPath, width: double.infinity, height: 180, fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),
            Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 10),
            Text(desc, style: TextStyle(fontSize: 15, height: 1.4, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700)),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () => Navigator.pop(ctx),
                child: Text('ok_btn'.tr(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}