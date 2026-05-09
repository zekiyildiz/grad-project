import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // EKLENDİ
  
// We will use this screen after a successful submission.
class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Confirmation Icon (Large and Green)
              const Icon(
                Icons.check_circle,
                color: Colors.green, // Green for success
                size: 120,
              ),
              const SizedBox(height: 30),

              // 2. Title and Description
              Text(
                'conf_title'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'conf_desc'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 60),

              // 3. Back to Home Button
              ElevatedButton.icon(
                onPressed: () {
                  // To redirect the user directly to the home page
                  // Closes all open screens and navigates to the home page.
                  // A redirection mechanism that prevents memory leaks and safely returns the system to the root directory.
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.arrow_back_ios_new),
                label: Text(
                  'conf_back_btn'.tr(),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}