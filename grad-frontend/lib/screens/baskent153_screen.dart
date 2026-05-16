import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:easy_localization/easy_localization.dart'; 

/// A communication module that triggers the device's native hardware (Phone Dialer) and third-party apps (WhatsApp) 
/// using the Deep Link (URI) method, and reduces the risk of crashes on SIM-less devices to zero through ‘canLaunchUrl’ checks.
class Baskent153Screen extends StatelessWidget {
  const Baskent153Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // We're checking whether the page is in dark mode
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("baskent153_title".tr()),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // TOP SECTION: LOGO AND INFORMATION
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              // Slightly translucent orange in dark mode, light orange in light mode
              color: isDark ? Colors.orange.withOpacity(0.1) : Colors.orange.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.support_agent, size: 80, color: Colors.orange),
                const SizedBox(height: 20),
                Text(
                  "baskent153_subtitle".tr(),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "baskent153_desc".tr(),
                  textAlign: TextAlign.center,
                  // The text color changes depending on whether the mode is dark or light
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, 
                    fontSize: 16
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // MIDDLE SECTION: BUTTONS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // 1. CALL NOW BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    icon: const Icon(
                      Icons.phone,
                      color: Colors.white,
                      size: 28,
                    ),
                    label: Text(
                      "baskent153_call_btn".tr(),
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () async {
                      final Uri launchUri = Uri(
                        scheme: 'tel',
                        path: '153',
                      );
                      
                      try {
                        if (await canLaunchUrl(launchUri)) {
                          await launchUrl(launchUri);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("baskent153_call_err".tr())),
                          );
                        }
                      } catch (e) {
                        debugPrint("Arama hatası: $e");
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10), 
               // 2. WhatsApp Line
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.green, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    icon: const Icon(Icons.chat, color: Colors.green, size: 28),
                    label: Text(
                      "baskent153_wp_btn".tr(),
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () async {
                      const String phoneNumber = "903121530000"; 
                      String message = "baskent153_wp_msg".tr();
                      
                      final Uri whatsappUri = Uri.parse("https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");

                      try {
                        if (await canLaunchUrl(whatsappUri)) {
                          await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("baskent153_wp_err".tr())),
                          );
                        }
                      } catch (e) {
                        debugPrint("WhatsApp hatası: $e");
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // BOTTOM SECTION: Footer
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Text(
              "baskent153_footer".tr(),
              style: TextStyle(
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400, 
                fontSize: 12
              ),
            ),
          ),
        ],
      ),
    );
  }
}