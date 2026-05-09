import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/announcement_model.dart';

/// To avoid generating an extra network request, this detail screen retrieves the ‘Announcement’ 
/// data model directly (by passing by value) from the previous screen, ensuring zero latency.
class AnnouncementDetailScreen extends StatelessWidget {
  final Announcement announcement;

  const AnnouncementDetailScreen({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    final String currentLocale = context.locale.languageCode; // We retrieve the current language code (tr or en)

    return Scaffold(
      appBar: AppBar(
        title: Text('home_announcements'.tr(), style: const TextStyle(color: Colors.white)), 
        backgroundColor: const Color(0xFF4094FF), 
        foregroundColor: Colors.white, 
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView( // Added so that the content can be scrolled if it's long
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Title
            Text(
              currentLocale == 'tr' ? announcement.titleTr : announcement.titleEn,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            // Date
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(announcement.date),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            
            const Divider(height: 30, thickness: 1),
            
            // Content
            Text(
              currentLocale == 'tr' ? announcement.contentTr : announcement.contentEn,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}