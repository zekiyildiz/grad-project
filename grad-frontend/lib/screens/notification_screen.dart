import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notifService = NotificationService();
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLiveNotifications(); 
  }

  Future<void> _fetchLiveNotifications() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await _notifService.getMyNotifications();
      if (mounted) {
        setState(() {
          _notifications = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getCategoryTitle(String category) {
    String key = category.trim().toUpperCase()
        .replaceAll('İ', 'I').replaceAll('Ğ', 'G')
        .replaceAll('Ç', 'C').replaceAll('Ş', 'S')
        .replaceAll('Ö', 'O').replaceAll('Ü', 'U');

    switch (key) {
      case 'YANGIN': return 'cat_fire'.tr();
      case 'GAZ KACAGI': return 'cat_gas'.tr();
      case 'SU PATLAGI': return 'cat_water'.tr();
      case 'ELEKTRIK ARIZASI': return 'cat_electric_urgent'.tr();
      case 'YOL COKMESI': return 'cat_road_collapse'.tr(); 
      case 'CUKUR': return 'cat_pothole'.tr();
      case 'COPLUK': return 'cat_garbage'.tr();
      case 'KIRIK_BANK': return 'cat_bench'.tr();
      case 'TRAFIK': return 'cat_traffic'.tr();
      case 'ELEKTRIK': return 'cat_electric'.tr();
      case 'SCOOTER': return 'cat_scooter'.tr();
      case 'POSTER': return 'cat_poster'.tr();
      case 'AGAC': return 'cat_tree'.tr();
      case 'DIGER': return 'cat_other'.tr(); 
      default: return category;
    }
  }

  String _getInstitutionName(String code) {
    String cleanCode = code.trim().toUpperCase().replaceAll('INST_', '');
    switch (cleanCode) {
      case 'FEN_ISLERI': return 'inst_fen'.tr();
      case 'TEDAS': return 'inst_tedas'.tr(); 
      case 'ASKI': return 'inst_aski'.tr(); 
      case 'ZABITA': return 'inst_zabita'.tr();
      case 'TEMIZLIK': return 'inst_temizlik'.tr();
      case 'EMNIYET': return 'inst_police_fire'.tr();
      case 'UKOME': return 'inst_ukome'.tr();
      case 'PARK_BAHCE': return 'inst_park_bahce'.tr();
      case 'DIGER': return 'inst_other_manual'.tr();
      default: return code; // yönetici manuel ne yazdıysa onu bozmadan gösterir
    }
  }

  String _getLocalizedTitle(String rawTitle) {
    String t = rawTitle.toUpperCase();
    if (t.contains('ACİL') || t.contains('URGENT') || t.contains('🚨')) {
      return 'notif_title_urgent'.tr();
    }
    if (t.contains('ALINDI') || t.contains('RECEIVED')) {
      return 'notif_title_received'.tr();
    }
    if (t.contains('İŞLEME') || t.contains('PROCESSED')) {
      return 'notif_title_processed'.tr();
    }
    if (t.contains('OLUŞTURULDU') || t.contains('CREATED')) {
      return 'notif_title_created'.tr();
    }
    if (t.contains('ÇÖZÜLDÜ') || t.contains('RESOLVED')) {
      return 'notif_title_resolved'.tr();
    }
    return rawTitle; 
  }

  //  MESAJLARI AKILLI ÇEVİREN FONKSİYON 
  String _getLocalizedMessage(String rawMessage) {
    String m = rawMessage;

    // Yeni Şikayet Kalıbı: "... konulu şikayetiniz sisteme kaydedildi..."
    if (m.contains('sisteme kaydedildi') && !m.contains('acil')) {
      String cat = m.split(' konulu').first.trim(); 
      return 'notif_msg_created'.tr(args: [_getCategoryTitle(cat)]);
    }

    // Durum Değişikliği Kalıbı: "... durumu Resolved olarak güncellenmiştir"
    if (m.contains('durumu') && m.contains('güncellenmiştir')) {
      if (m.contains('RESOLVED') || m.contains('Çözüldü') || m.contains('COMPLETED')) {
        return 'notif_msg_status_resolved'.tr();
      } else if (m.contains('IN_PROGRESS') || m.contains('İşlemde')) {
        return 'notif_msg_status_in_progress'.tr();
      }
      return 'notif_msg_status_updated'.tr();
    }

    // Kuruma İletildi Kalıbı: "Şikayetiniz ilgili kuruma (...) iletildi."
    if (m.contains('ilgili kuruma') && m.contains('iletildi')) {
      String inst = "";
      if (m.contains('(') && m.contains(')')) {
        inst = m.substring(m.indexOf('(') + 1, m.indexOf(')')); 
      }
      
      // Ham kodu (PARK_BAHCE) kullanıcı dostu isme çevirerek mesaja ekleme
      String translatedInst = _getInstitutionName(inst);
      return 'notif_msg_assigned'.tr(args: [translatedInst]);
    }

    // Acil Durum Kalıbı: "... ihbarınız sistemimize acil koduyla kaydedildi..."
    if (m.contains('acil koduyla')) {
      String cat = m.split(' ihbarınız').first.trim();
      return 'notif_msg_urgent'.tr(args: [_getCategoryTitle(cat)]);
    }

    m = m.replaceAll("'RESOLVED'", 'status_resolved'.tr());
    m = m.replaceAll("RESOLVED", 'status_resolved'.tr());
    m = m.replaceAll("'IN_PROGRESS'", 'status_in_progress'.tr());
    m = m.replaceAll("IN_PROGRESS", 'status_in_progress'.tr());
    m = m.replaceAll("'PENDING'", 'status_new'.tr());
    m = m.replaceAll("PENDING", 'status_new'.tr());

    return m;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('notif_title'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.white),
            onPressed: () async {
              await _notifService.markAllAsRead(); 
              _fetchLiveNotifications(); 
            },
            tooltip: 'notif_mark_all'.tr(),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLiveNotifications,
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : _notifications.isEmpty
            ? Center(child: Text('notif_empty'.tr()))
            : ListView.builder(
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notif = _notifications[index];
                  final String id = notif['id']?.toString() ?? '';
                  bool isRead = notif['isRead'] ?? false;
                  
                  String rawTitle = notif['title']?.toString() ?? '';
                  String message = notif['message']?.toString() ?? '';

                  bool isUrgentNotif = rawTitle.toUpperCase().contains('ACİL') || rawTitle.contains('🚨');

                  return Dismissible(
                    key: Key(id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) async {
                      await _notifService.deleteNotification(id); 
                      setState(() => _notifications.removeAt(index));
                    },
                    child: Container(
                      color: isUrgentNotif && !isRead 
                          ? Colors.red.withOpacity(0.08) 
                          : (isRead ? Colors.transparent : Colors.blue.withOpacity(0.05)),
                      child: ListTile(
                        leading: Container(
                          width: 4, height: 40, 
                          color: isRead ? Colors.transparent : (isUrgentNotif ? Colors.red : Colors.blue)
                        ),
                        title: Text(
                          _getLocalizedTitle(rawTitle), 
                          style: TextStyle(
                            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                            color: isUrgentNotif ? Colors.red.shade700 : (isDark ? Colors.white : Colors.black87),
                          )
                        ),
                        subtitle: Text(
                          _getLocalizedMessage(message), // AKILLI MESAJ ÇEVİRİSİ 
                          style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.black54, fontSize: 13)
                        ),
                        trailing: Icon(
                          isUrgentNotif 
                              ? Icons.warning 
                              : (rawTitle.contains('Çözüldü') ? Icons.check_circle : Icons.notifications_active),
                          color: isUrgentNotif 
                              ? Colors.red 
                              : (rawTitle.contains('Çözüldü') ? Colors.green : Colors.orange),
                        ),
                        onTap: () async {
                          if (!isRead) {
                            await _notifService.markAsRead(id); 
                            setState(() => notif['isRead'] = true); 
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}