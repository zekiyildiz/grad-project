import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; 

// 1. Bildirim Veri Modeli
class NotificationItem {
  final String titleKey;
  final String bodyKey;
  final DateTime time;
  final IconData icon;
  final Color iconColor;
  bool isRead; // Değiştirilebilir
  final String type; 

  NotificationItem({
    required this.titleKey,
    required this.bodyKey,
    required this.time,
    required this.icon,
    required this.iconColor,
    this.isRead = false,
    required this.type,
  });
}

// Zamanı okunaklı hale getiren fonksiyon
String formatNotificationTime(DateTime time) {
  final duration = DateTime.now().difference(time);
  if (duration.inMinutes < 60) {
    return 'notif_mins_ago'.tr(args: [duration.inMinutes.toString()]);
  } else if (duration.inHours < 24) {
    return 'notif_hours_ago'.tr(args: [duration.inHours.toString()]);
  } else {
    return 'notif_days_ago'.tr(args: [duration.inDays.toString()]);
  }
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Bildirimleri silebilmemiz için listeyi State içine alıp "late" ile tanımlıyoruz
  late List<NotificationItem> myNotifications;

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında örnek verileri listemize yüklüyoruz
    myNotifications = [
      NotificationItem(
        titleKey: 'notif_dummy_title_1',
        bodyKey: 'notif_dummy_body_1',
        time: DateTime.now().subtract(const Duration(minutes: 5)),
        icon: Icons.pending_actions,
        iconColor: Colors.orange,
        isRead: false, 
        type: 'şikayet',
      ),
      NotificationItem(
        titleKey: 'notif_dummy_title_2',
        bodyKey: 'notif_dummy_body_2',
        time: DateTime.now().subtract(const Duration(hours: 2)),
        icon: Icons.calendar_month,
        iconColor: Colors.blue,
        isRead: false, 
        type: 'etkinlik',
      ),
      NotificationItem(
        titleKey: 'notif_dummy_title_3',
        bodyKey: 'notif_dummy_body_3',
        time: DateTime.now().subtract(const Duration(days: 1)),
        icon: Icons.check_circle,
        iconColor: Colors.green,
        isRead: true, 
        type: 'şikayet',
      ),
      NotificationItem(
        titleKey: 'notif_dummy_title_4',
        bodyKey: 'notif_dummy_body_4',
        time: DateTime.now().subtract(const Duration(days: 3)),
        icon: Icons.info,
        iconColor: Colors.grey,
        isRead: true, 
        type: 'genel',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Okunmamışları en üste alacak şekilde sıralıyoruz
    myNotifications.sort((a, b) => a.isRead == b.isRead ? b.time.compareTo(a.time) : (a.isRead ? 1 : -1));

    return Scaffold(
      appBar: AppBar(
        title: Text('notif_title'.tr(), style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Sadece bildirim varsa "Tümünü Oku" butonunu göster
          if (myNotifications.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  for (var notif in myNotifications) {
                    notif.isRead = true;
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('notif_read_all_snack'.tr())),
                );
              },
              child: Text('notif_read_all'.tr(), style: const TextStyle(color: Colors.white)),
            ),
        ],
      ),
      
      // 1. BOŞ DURUM (EMPTY STATE) KONTROLÜ
      body: myNotifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_paused, size: 80, color: isDark ? Colors.grey.shade700 : Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    // "Henüz hiç bildiriminiz yok" yazısı (Eğer JSON'da yoksa burayı kendi dil mantığına göre ayarlayabilirsin)
                    context.locale.languageCode == 'tr' ? "Henüz hiç bildiriminiz yok." : "You have no notifications yet.",
                    style: TextStyle(fontSize: 16, color: isDark ? Colors.grey.shade500 : Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: myNotifications.length,
              itemBuilder: (context, index) {
                final notification = myNotifications[index];
                
                // 2. KAYDIRARAK SİLME (DISMISSIBLE) EKLENDİ
                return Dismissible(
                  key: Key(notification.titleKey + notification.time.toString()),
                  direction: DismissDirection.endToStart, // Sadece sağdan sola kaydırma
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white, size: 30),
                  ),
                  onDismissed: (direction) {
                    setState(() {
                      myNotifications.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.locale.languageCode == 'tr' ? 'Bildirim silindi' : 'Notification deleted'),
                        action: SnackBarAction(
                          label: 'OK',
                          onPressed: () {},
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        // Okunmamışsa arka planı çok hafif renklendiriyoruz (Daha profesyonel durur)
                        color: notification.isRead 
                            ? Colors.transparent 
                            : (isDark ? Colors.blue.withOpacity(0.05) : Colors.blue.withOpacity(0.03)),
                        child: ListTile(
                          leading: Container(
                            width: 5,
                            height: double.infinity,
                            color: notification.isRead ? Colors.transparent : Colors.blue.shade600,
                            margin: const EdgeInsets.only(right: 10),
                          ),
                          title: Text(
                            notification.titleKey.tr(),
                            style: TextStyle(
                              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(notification.bodyKey.tr(), style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700)),
                              const SizedBox(height: 4),
                              Text(
                                formatNotificationTime(notification.time),
                                style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade500 : Colors.grey.shade500),
                              ),
                            ],
                          ),
                          trailing: Icon(notification.icon, color: notification.iconColor),
                          onTap: () {
                            setState(() {
                              notification.isRead = true;
                            });
                          },
                        ),
                      ),
                      const Divider(height: 1), 
                    ],
                  ),
                );
              },
            ),
    );
  }
}