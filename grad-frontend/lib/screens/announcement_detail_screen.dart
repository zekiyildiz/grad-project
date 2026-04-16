import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/announcement_model.dart';

class AnnouncementDetailScreen extends StatelessWidget {
  final Announcement announcement;

  const AnnouncementDetailScreen({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    // 🌐 Mevcut dil kodunu alıyoruz (tr veya en)
    final String currentLocale = context.locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text('home_announcements'.tr()), // "Duyurular" veya "Announcements"
      ),
      body: SingleChildScrollView( // İçerik uzun olursa kaydırılabilmesi için eklendi
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📌 BAŞLIK (Dile Göre)
            Text(
              currentLocale == 'tr' ? announcement.titleTr : announcement.titleEn,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            // 📅 TARİH
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(announcement.date),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            
            const Divider(height: 30, thickness: 1),
            
            // 📝 İÇERİK (Dile Göre)
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