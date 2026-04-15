import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/report_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ReportService _reportService = ReportService();
  late Future<List<dynamic>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  void _fetchReports() {
    setState(() {
      _reportsFuture = _reportService.getMyReports();
    });
  }

  // --- 1. KURUM İSİMLERİ DİLE BAĞLANDI ---
  String _getInstitutionName(String? code) {
    if (code == null || code.isEmpty) return 'status_pending'.tr();
    switch (code.toUpperCase()) {
      case 'FEN_ISLERI': return 'inst_fen'.tr();
      case 'TEMIZLIK': return 'inst_temizlik'.tr();
      case 'ASKI': return 'inst_aski'.tr();
      case 'UKOME': return 'inst_ukome'.tr();
      case 'TEDAS': return 'inst_tedas'.tr();
      case 'PARK_BAHCE': return 'inst_park_bahce'.tr();
      case 'ZABITA': return 'inst_zabita'.tr();
      default: return 'status_pending'.tr();
    }
  }

  // --- 2. KATEGORİ VE ACİL DURUM İSİMLERİ DİLE BAĞLANDI ---
  Map<String, dynamic> _getCategoryDetails(String category) {
    switch (category.toUpperCase()) {
      case 'SCOOTER': return {'title': 'cat_scooter'.tr(), 'icon': Icons.electric_scooter, 'color': Colors.blue};
      case 'CUKUR': return {'title': 'cat_pothole'.tr(), 'icon': Icons.edit_road, 'color': Colors.brown};
      case 'COPLUK': return {'title': 'cat_garbage'.tr(), 'icon': Icons.delete_outline, 'color': Colors.green};
      case 'KIRIK_BANK': return {'title': 'cat_bench'.tr(), 'icon': Icons.park, 'color': Colors.green[800]};
      case 'TRAFIK': return {'title': 'cat_traffic'.tr(), 'icon': Icons.traffic, 'color': Colors.red};
      case 'ELEKTRIK': return {'title': 'cat_electric'.tr(), 'icon': Icons.lightbulb_outline, 'color': Colors.amber};
      
      // YENİ ACİL KATEGORİLER
      case 'YANGIN': return {'title': 'cat_fire'.tr(), 'icon': Icons.local_fire_department, 'color': Colors.red};
      case 'GAZ KAÇAĞI': return {'title': 'cat_gas'.tr(), 'icon': Icons.gas_meter, 'color': Colors.orange};
      case 'SU PATLAĞI': return {'title': 'cat_water'.tr(), 'icon': Icons.water_drop, 'color': Colors.blue};
      case 'ELEKTRİK ARIZASI': return {'title': 'cat_electric_urgent'.tr(), 'icon': Icons.bolt, 'color': Colors.yellow.shade800};
      case 'YOL ÇÖKMESİ': return {'title': 'cat_road_collapse'.tr(), 'icon': Icons.add_road, 'color': Colors.brown};
      
      default: return {
        'title': category.toUpperCase() == 'DİĞER' ? 'emerg_dialog_title_other'.tr() : 'cat_other'.tr(), 
        'icon': Icons.report_problem, 
        'color': Colors.grey
      };
    }
  }

  // --- 3. DURUM (STATUS) ETİKETLERİ DİLE BAĞLANDI ---
  Map<String, dynamic> _getStatusDetails(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING': return {'label': 'status_new'.tr(), 'color': Colors.blue};
      case 'IN_PROGRESS': return {'label': 'status_in_progress'.tr(), 'color': Colors.orange};
      case 'RESOLVED': 
      case 'COMPLETED': return {'label': 'status_resolved'.tr(), 'color': Colors.green};
      default: return {'label': status, 'color': Colors.grey};
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('history_title'.tr()),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchReports)],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text('hist_empty'.tr()));

          return RefreshIndicator(
            onRefresh: () async => _fetchReports(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final report = snapshot.data![index];
                final cat = _getCategoryDetails(report['category'] ?? '');
                final stat = _getStatusDetails(report['status'] ?? '');
                
                bool isUrgent = report['isUrgent'] == true;
                
                if (report['status'] == 'RESOLVED' || report['status'] == 'COMPLETED') {
                   isUrgent = false; 
                }

                return Card(
                  elevation: isUrgent ? 5 : 2, 
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: isUrgent 
                        ? const BorderSide(color: Colors.red, width: 2) 
                        : BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  color: isUrgent 
                      ? (isDark ? Colors.red.withOpacity(0.15) : Colors.red.shade50) 
                      : (isDark ? Colors.grey.shade800 : Colors.white),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: isUrgent ? Colors.red.shade100 : cat['color'].withOpacity(0.1), 
                              child: Icon(
                                isUrgent ? Icons.warning : cat['icon'], 
                                color: isUrgent ? Colors.red : cat['color']
                              )
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(
                                // --- 4. (ACİL) EKİ ARTIK JSON'DAN GELİYOR ---
                                isUrgent ? "🚨 ${cat['title']} ${'urgent_suffix'.tr()}" : cat['title'], 
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 15,
                                  color: isUrgent 
                                      ? Colors.red.shade700 
                                      : (isDark ? Colors.white : Colors.black87)
                                )
                              ),
                              Text(report['location']?['address'] ?? 'loc_unknown'.tr(), style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1),
                            ])),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 
                              decoration: BoxDecoration(
                                color: isUrgent && report['status'] == 'PENDING' ? Colors.red : stat['color'], 
                                borderRadius: BorderRadius.circular(12)
                              ), 
                              child: Text(
                                // --- 5. "YENİ" VEYA "ACİL" BADGE'İ DİLE BAĞLANDI ---
                                isUrgent && report['status'] == 'PENDING' ? 'complaint_urgent_badge'.tr() : stat['label'], 
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)
                              )
                            ),
                          ],
                        ),
                        if (report['status'] != 'PENDING') ...[
                          const Divider(),
                          Row(children: [
                            const Icon(Icons.business, size: 14, color: Colors.orange),
                            const SizedBox(width: 4),
                            // --- 6. "İletilen Kurum:" YAZISI DİLE BAĞLANDI ---
                            Text("${'inst_label'.tr()}: ", style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700)),
                            Text(_getInstitutionName(report['assignedInstitution']), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange)),
                          ]),
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}