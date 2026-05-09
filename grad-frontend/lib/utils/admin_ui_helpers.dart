import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/report_service.dart';
import '../screens/login_screen.dart';
import 'admin_helpers.dart'; //for converters

/// [UI COMPONENTS] A UI helper class that improves code readability by separating complex pop-up windows 
/// (modals, dialogs) in the admin panel from the main screen.
class AdminUIHelpers {
  
  // LOGOUT CONFIRMATION WINDOW
  static void showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('logout'.tr()),
        content: Text('logout_confirm'.tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('cancel'.tr())),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('logout'.tr(), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // INSTITUTION ASSIGNMENT DIALOG BOX
  static void showAssignmentDialog({
    required BuildContext context, 
    required Map<String, dynamic> task, 
    required ReportService reportService, 
    required VoidCallback onRefresh // İşlem bitince ana ekranı yenilemek için tetikleyici
  }) {
    String currentSelection = AdminHelpers.predictInstitution(task['category'].toString());
    final TextEditingController customInstController = TextEditingController();
    bool isOtherSelected = false;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text("admin_assign_title".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: isOtherSelected ? 'DIGER' : (['FEN_ISLERI', 'TEDAS', 'ASKI', 'ZABITA', 'TEMIZLIK', 'EMNIYET', 'UKOME', 'PARK_BAHCE'].contains(currentSelection) ? currentSelection : 'FEN_ISLERI'),
                    dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: [
                      DropdownMenuItem(value: 'FEN_ISLERI', child: Text('inst_fen'.tr())),
                      DropdownMenuItem(value: 'TEDAS', child: Text('inst_tedas'.tr())), 
                      DropdownMenuItem(value: 'ASKI', child: Text('inst_aski'.tr())),  
                      DropdownMenuItem(value: 'ZABITA', child: Text('inst_zabita'.tr())),
                      DropdownMenuItem(value: 'TEMIZLIK', child: Text('inst_temizlik'.tr())),
                      DropdownMenuItem(value: 'EMNIYET', child: Text('inst_police_fire'.tr())),
                      DropdownMenuItem(value: 'UKOME', child: Text('inst_ukome'.tr())),
                      DropdownMenuItem(value: 'PARK_BAHCE', child: Text('inst_park_bahce'.tr())),
                      DropdownMenuItem(value: 'DIGER', child: Text('inst_other_manual'.tr())), 
                    ],
                    onChanged: (val) {
                      setDialogState(() {
                        currentSelection = val!;
                        isOtherSelected = (val == 'DIGER');
                      });
                    },
                  ),
                  
                  if (isOtherSelected) ...[
                    const SizedBox(height: 15),
                    TextField(
                      controller: customInstController,
                      decoration: InputDecoration(
                        labelText: "inst_manual_label".tr(), 
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text('cancel'.tr())),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800),
                onPressed: () async {
                  String finalInstitution = isOtherSelected ? customInstController.text.trim() : currentSelection;
                  if (isOtherSelected && finalInstitution.isEmpty) return;

                  Navigator.pop(ctx);
                  await reportService.assignInstitution(task['id'], finalInstitution);
                  onRefresh(); // Ana ekrandaki tabloyu yenile
                },
                child: Text('btn_assign'.tr(), style: const TextStyle(color: Colors.white)),
              )
            ],
          );
        },
      ),
    );
  }

  // COMPLAINT DETAILS SCREEN (BottomSheet Modal)
  /// To ensure the administrator doesn't lose context, the detail page is rendered within a dynamic BottomSheet (Modal) 
  /// that covers 85% of the screen, rather than opening it as a new route.
  static void showReportDetails(BuildContext context, Map<String, dynamic> item, bool isDark) {
    String rawStatus = item['status']?.toString().toUpperCase() ?? 'PENDING';
    String rawCat = item['category']?.toString().toUpperCase() ?? '';
    
    bool isUrgentEmergency = ['YANGIN', 'GAZ KAÇAĞI', 'SU PATLAĞI', 'ELEKTRİK ARIZASI', 'YOL ÇÖKMESİ'].contains(rawCat) || item['isUrgent'] == true;
    bool isCritical = isUrgentEmergency && rawStatus != 'RESOLVED';
    String assignedTo = item['assignedInstitution']?.toString() ?? '';
    
    String? imageUrl;
    if (item['imageUrls'] != null && item['imageUrls'] is List && item['imageUrls'].isNotEmpty) {
      imageUrl = item['imageUrls'][0].toString();
    } else if (item['imageUrl'] != null) {
      imageUrl = item['imageUrl'].toString();
    }

    String statusBadgeText = "";
    Color statusBadgeColor = Colors.orange;
    IconData statusBadgeIcon = Icons.hourglass_empty;

    if (rawStatus == 'RESOLVED' || rawStatus == 'COMPLETED') {
      statusBadgeText = 'status_resolved'.tr();
      statusBadgeColor = Colors.green;
      statusBadgeIcon = Icons.check_circle;
    } else if (rawStatus == 'IN_PROGRESS' || assignedTo.isNotEmpty) {
      statusBadgeText = "status_sevk".tr();
      statusBadgeColor = Colors.orange; 
      statusBadgeIcon = Icons.engineering;
    } else {
      statusBadgeText = isUrgentEmergency ? "status_urgent_pending".tr() : "status_pending".tr();
      statusBadgeColor = isUrgentEmergency ? Colors.red : Colors.orange;
      statusBadgeIcon = isUrgentEmergency ? Icons.warning : Icons.hourglass_empty;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85, 
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isCritical ? Colors.red : Colors.orange.shade100,
                    radius: 25,
                    child: Icon(isCritical ? Icons.warning : Icons.campaign, color: isCritical ? Colors.white : Colors.orange),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['titleStr'] ?? AdminHelpers.getCategoryTitle(rawCat), 
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isCritical ? Colors.red : (isDark ? Colors.white : Colors.black87))
                        ),
                        Text(AdminHelpers.getTimeAgo(item['createdAt']), style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  )
                ],
              ),
              const Divider(height: 30),

              Text("admin_detail_desc".tr(), style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                child: Text(item['description']?.toString() ?? "admin_detail_no_desc".tr(), style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 20),

              Text("admin_detail_location".tr(), style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item['location']?['address']?.toString() ?? item['address']?.toString() ?? 'loc_unknown'.tr(), style: const TextStyle(fontSize: 15))),
                ],
              ),
              const SizedBox(height: 20),

              if (!isUrgentEmergency) ...[
                Text("admin_detail_photo".tr(), style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                if (imageUrl != null && imageUrl.isNotEmpty && imageUrl != 'null')
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      imageUrl, width: double.infinity, height: 200, fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(height: 150, color: Colors.grey.shade300, child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey))),
                    ),
                  )
                else
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100, borderRadius: BorderRadius.circular(15), border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300)),
                    child: Center(child: Text("admin_detail_no_photo".tr(), style: TextStyle(color: Colors.grey.shade500))),
                  ),
                const SizedBox(height: 30),
              ],

              if (assignedTo.isNotEmpty) ...[
                Text("admin_detail_inst".tr(), style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.business, color: Colors.blue),
                      const SizedBox(width: 10),
                      Text(AdminHelpers.getInstitutionName(assignedTo), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],

              Container(
                width: double.infinity, 
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: statusBadgeColor.withOpacity(0.1), 
                  borderRadius: BorderRadius.circular(15), 
                  border: Border.all(color: statusBadgeColor, width: 2)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(statusBadgeIcon, color: statusBadgeColor, size: 24),
                    const SizedBox(width: 10),
                    Text(statusBadgeText, style: TextStyle(color: statusBadgeColor, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}