import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/announcement_model.dart';
import '../services/announcement_service.dart';
import 'announcement_detail_screen.dart';

class AllAnnouncementsScreen extends StatelessWidget {
  const AllAnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🌐 Mevcut dil kodunu alıyoruz
    final String currentLocale = context.locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text('home_announcements'.tr()),
      ),
      body: FutureBuilder<List<Announcement>>(
        // Dil değiştiğinde FutureBuilder'ın kendini yenilemesi için key ekliyoruz
        key: ValueKey(currentLocale),
        future: AnnouncementService().fetchAnnouncements(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final list = snapshot.data ?? [];

          if (list.isEmpty) {
            return const Center(child: Text("Henüz duyuru yok."));
          }
          
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final ann = list[index];
              
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.campaign, color: Colors.white),
                  ),
                  // 🌐 DİLE GÖRE BAŞLIK
                  title: Text(
                    currentLocale == 'tr' ? ann.titleTr : ann.titleEn, 
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // 🌐 DİLE GÖRE İÇERİK
                  subtitle: Text(
                    currentLocale == 'tr' ? ann.contentTr : ann.contentEn, 
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnnouncementDetailScreen(announcement: ann),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}