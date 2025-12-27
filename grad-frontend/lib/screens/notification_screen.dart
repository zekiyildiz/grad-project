import 'package:flutter/material.dart';

// 1. Bildirim Veri Modeli
class NotificationItem {
  final String title;
  final String body;
  final DateTime time;
  final IconData icon;
  final Color iconColor;
  final bool isRead;
  final String type; // 'şikayet', 'etkinlik', 'genel'

  const NotificationItem({
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.iconColor,
    this.isRead = false,
    required this.type,
  });
}

// 2. Simüle Edilen Bildirim Verileri (MVP)
final List<NotificationItem> dummyNotifications = [
  NotificationItem(
    title: 'Şikayet Durumu Güncellendi',
    body: 'R002 kodlu "Kırık Park Bankı" şikayetiniz artık İŞLEMDE.',
    time: DateTime.now().subtract(const Duration(minutes: 5)),
    icon: Icons.pending_actions,
    iconColor: Colors.orange,
    isRead: false, // Okunmamış (Badge'i tetikleyen)
    type: 'şikayet',
  ),
  NotificationItem(
    title: 'Yeni Etkinlik Duyurusu!',
    body: 'Yaz Konserleri biletleri satışa çıktı. Detaylar için tıklayın.',
    time: DateTime.now().subtract(const Duration(hours: 2)),
    icon: Icons.calendar_month,
    iconColor: Colors.blue,
    isRead: false, // Okunmamış
    type: 'etkinlik',
  ),
  NotificationItem(
    title: 'Şikayet Çözüldü!',
    body: 'R001 kodlu "Kaldırım Çukuru" şikayetiniz başarıyla TAMAMLANDI.',
    time: DateTime.now().subtract(const Duration(days: 1)),
    icon: Icons.check_circle,
    iconColor: Colors.green,
    isRead: true, // Okunmuş
    type: 'şikayet',
  ),
  NotificationItem(
    title: 'Genel Bilgilendirme',
    body: 'Uygulama sunucularında kısa süreli bakım çalışması yapılacaktır.',
    time: DateTime.now().subtract(const Duration(days: 3)),
    icon: Icons.info,
    iconColor: Colors.grey,
    isRead: true, // Okunmuş
    type: 'genel',
  ),
];

// Helper Function: Zamanı okunaklı hale getirir
String formatNotificationTime(DateTime time) {
  final duration = DateTime.now().difference(time);
  if (duration.inMinutes < 60) {
    return '${duration.inMinutes} dakika önce';
  } else if (duration.inHours < 24) {
    return '${duration.inHours} saat önce';
  } else {
    return '${duration.inDays} gün önce';
  }
}

// Bildirimler Ekranı
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Okunmamış bildirimleri listenin başına taşımak için sıralama yapalım
    final sortedNotifications = dummyNotifications.toList()
      ..sort((a, b) => a.isRead == b.isRead ? b.time.compareTo(a.time) : (a.isRead ? 1 : -1));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimlerim', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        // Sağ üstte "Tümünü Oku" butonu ekleyelim
        actions: [
          TextButton(
            onPressed: () {
              // Gerçek uygulamada tüm bildirimlerin isRead alanı true yapılır.
              print('Tüm bildirimler okundu olarak işaretlendi.');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tüm bildirimler okundu olarak işaretlendi.')),
              );
            },
            child: const Text('Tümünü Oku', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: sortedNotifications.length,
        itemBuilder: (context, index) {
          final notification = sortedNotifications[index];
          
          return Column(
            children: [
              ListTile(
                // Okunmamışsa solda mavi çizgi (okunmamış vurgusu)
                leading: Container(
                  width: 5,
                  height: double.infinity,
                  color: notification.isRead ? Colors.transparent : Colors.blue.shade600,
                  margin: const EdgeInsets.only(right: 10),
                ),
                
                // Bildirim İkonu
                title: Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                
                // Bildirim İçeriği
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(notification.body, style: TextStyle(color: Colors.grey.shade700)),
                    const SizedBox(height: 4),
                    // Zaman bilgisi
                    Text(
                      formatNotificationTime(notification.time),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
                
                // Sağdaki İkon (Bildirim tipi veya durum ikonu)
                trailing: Icon(notification.icon, color: notification.iconColor),
                
                onTap: () {
                  // Bildirime tıklanınca ilgili sayfaya yönlendirme yapılır.
                  print('${notification.title} ile ilgili detay sayfasına yönlendiriliyor.');
                  // İdeal olarak: notification.type kontrol edilerek HistoryScreen veya EventsScreen'e gidilir.
                },
              ),
              const Divider(height: 1), // Her bildirimin altında ayırıcı çizgi
            ],
          );
        },
      ),
    );
  }
}