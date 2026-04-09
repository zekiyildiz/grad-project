import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // EKLENDİ
import '../services/report_service.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';

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

  // Kategorilere göre başlık, renk ve ikon haritalama
  Map<String, dynamic> _getCategoryDetails(String category) {
    switch (category) {
      case 'CUKUR':
        return {'title': 'hist_cat_pothole'.tr(), 'icon': Icons.edit_road, 'color': Colors.brown};
      case 'COPLUK':
        return {'title': 'hist_cat_garbage'.tr(), 'icon': Icons.delete_outline, 'color': Colors.green};
      case 'KIRIK_BANK':
        return {'title': 'hist_cat_bench'.tr(), 'icon': Icons.park, 'color': Colors.green[800]};
      case 'TRAFIK':
        return {'title': 'hist_cat_traffic'.tr(), 'icon': Icons.traffic, 'color': Colors.red};
      case 'ELEKTRIK':
        return {'title': 'hist_cat_electric'.tr(), 'icon': Icons.lightbulb_outline, 'color': Colors.amber};
      case 'SCOOTER':
        return {'title': 'hist_cat_scooter'.tr(), 'icon': Icons.electric_scooter, 'color': Colors.blue};
      case 'POSTER':
        return {'title': 'hist_cat_poster'.tr(), 'icon': Icons.format_paint, 'color': Colors.purple};
      case 'AGAC':
        return {'title': 'hist_cat_tree'.tr(), 'icon': Icons.nature, 'color': Colors.teal};
      default:
        return {'title': 'hist_cat_other'.tr(), 'icon': Icons.report_problem, 'color': Colors.grey};
    }
  }

  // Duruma göre renk ve etiket
  Map<String, dynamic> _getStatusDetails(String status) {
    switch (status) {
      case 'PENDING':
        return {'label': 'hist_stat_new'.tr(), 'color': Colors.blue};
      case 'IN_PROGRESS':
        return {'label': 'hist_stat_in_progress'.tr(), 'color': Colors.orange};
      case 'RESOLVED':
        return {'label': 'hist_stat_completed'.tr(), 'color': Colors.green};
      case 'REJECTED':
        return {'label': 'hist_stat_rejected'.tr(), 'color': Colors.red};
      default:
        return {'label': status, 'color': Colors.grey};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('history_title'.tr()),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchReports,
          )
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('hist_error'.tr(args: [snapshot.error.toString()]), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchReports,
                    child: Text('hist_retry'.tr()),
                  )
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'hist_empty'.tr(),
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final reports = snapshot.data!;
          // Tarihe göre yeninden eskiye sırala
          reports.sort((a, b) {
            final dateA = a['createdAt'] != null ? DateTime.tryParse(a['createdAt'].toString()) : null;
            final dateB = b['createdAt'] != null ? DateTime.tryParse(b['createdAt'].toString()) : null;
            if (dateA == null || dateB == null) return 0;
            return dateB.compareTo(dateA); // Yeniden eskiye
          });

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              final categoryStr = report['category'] as String? ?? 'DIGER';
              final statusStr = report['status'] as String? ?? 'PENDING';
              
              final catDetails = _getCategoryDetails(categoryStr);
              final statusDetails = _getStatusDetails(statusStr);
              
              final locationData = report['location'];
              String address = 'hist_no_address'.tr();
              
              if (locationData is Map<String, dynamic>) {
                if (locationData['address'] != null && locationData['address'].toString().trim().isNotEmpty) {
                  address = locationData['address'].toString();
                }
                else if (locationData['latitude'] != null && locationData['longitude'] != null) {
                  address = '📍 ${double.tryParse(locationData['latitude'].toString())?.toStringAsFixed(4) ?? '?'}, ${double.tryParse(locationData['longitude'].toString())?.toStringAsFixed(4) ?? '?'}';
                }
              } else if (locationData is String && locationData.isNotEmpty) {
                address = locationData;
              }
              
              String dateStr = '';
              if (report['createdAt'] != null) {
                try {
                  final date = DateTime.parse(report['createdAt'].toString()).toLocal();
                  dateStr = '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                } catch (e) {
                  dateStr = '';
                }
              }

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    backgroundColor: catDetails['color']?.withOpacity(0.2) ?? Colors.grey.shade200,
                    child: Icon(catDetails['icon'], color: catDetails['color'], size: 28),
                  ),
                  title: Text(
                    catDetails['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(child: Text(address, style: const TextStyle(fontSize: 13))),
                          ],
                        ),
                        if (dateStr.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(dateStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ]
                      ],
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusDetails['color'],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusDetails['label'],
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  onTap: () {
                    // Detay sayfasına ileride gidilebilir
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}