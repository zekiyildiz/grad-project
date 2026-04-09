import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; 
import 'contact_screen.dart';

class FAQItem {
  final String question;
  final String answer;
  FAQItem(this.question, this.answer);
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final List<FAQItem> faqList = [
      FAQItem('help_q1'.tr(), 'help_a1'.tr()),
      FAQItem('help_q2'.tr(), 'help_a2'.tr()),
      FAQItem('help_q3'.tr(), 'help_a3'.tr()),
      FAQItem('help_q4'.tr(), 'help_a4'.tr()),
      FAQItem('help_q5'.tr(), 'help_a5'.tr()),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('help_title'.tr()),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'help_faq_header'.tr(),
                style: TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.bold, 
                  color: isDark ? Colors.blue.shade300 : Colors.blue.shade800
                ),
              ),
            ),
            
            ...faqList.map((faq) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Card(
                  elevation: 1,
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  color: isDark ? Colors.grey.shade900 : Colors.white,
                  child: ExpansionTile(
                    title: Text(
                      faq.question,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          faq.answer,
                          style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            
            const Divider(height: 40, thickness: 1, indent: 20, endIndent: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, 
                children: [
                  Text(
                    'help_still_need_help'.tr(),
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.w600, 
                      color: isDark ? Colors.white : Colors.black87
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'help_contact_desc'.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ContactScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.support_agent), 
                    label: Text('help_contact_btn'.tr(), style: const TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}