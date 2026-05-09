import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/notification_service.dart';
import '../utils/admin_helpers.dart';

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

  /// Function for Smart Message Translation 
  /// By analyzing static notification texts received from the backend (e.g., “Your complaint has been forwarded to FEN_ISLERI”)
  /// and translating them autonomously at runtime based on the application's current language (Turkish/English)
  String _getLocalizedMessage(String rawMessage) {
    String m = rawMessage;

    // New Complaint Template: “... Your complaint regarding [subject] has been recorded in the system...”
    if (m.contains('sisteme kaydedildi') && !m.contains('acil')) {
      String cat = m.split(' konulu').first.trim(); 
      return 'notif_msg_created'.tr(args: [AdminHelpers.getCategoryTitle(cat)]);
    }

    // Status Change Template: “... status has been updated to Resolved”
    if (m.contains('durumu') && m.contains('güncellenmiştir')) {
      if (m.contains('RESOLVED') || m.contains('Çözüldü') || m.contains('COMPLETED')) {
        return 'notif_msg_status_resolved'.tr();
      } else if (m.contains('IN_PROGRESS') || m.contains('İşlemde')) {
        return 'notif_msg_status_in_progress'.tr();
      }
      return 'notif_msg_status_updated'.tr();
    }

    // “Forwarded to the Relevant Authority” Template: “Your complaint has been forwarded to the relevant authority (...).”
    if (m.contains('ilgili kuruma') && m.contains('iletildi')) {
      String inst = "";
      if (m.contains('(') && m.contains(')')) {
        inst = m.substring(m.indexOf('(') + 1, m.indexOf(')')); 
      }
      
      // Convert the raw code (PARK_BAHCE) to a user-friendly name and add it to the message
      String translatedInst = AdminHelpers.getInstitutionName(inst);
      return 'notif_msg_assigned'.tr(args: [translatedInst]);
    }

    // Emergency Template: “... Your report has been logged in our system with an emergency code...”
    if (m.contains('acil koduyla')) {
      String cat = m.split(' ihbarınız').first.trim();
      return 'notif_msg_urgent'.tr(args: [AdminHelpers.getCategoryTitle(cat)]);
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
        title: Text('notif_title'.tr(), style: const TextStyle(color: Colors.white)),
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

                  // To enhance the user experience (UX), the ‘Swipe-to-Delete’ gesture has been integrated. While the deletion process 
                  // is sent asynchronously to the backend, the UI updates instantly
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
                          _getLocalizedMessage(message), // SMART MESSAGE TRANSLATION 
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