import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/report_service.dart';
import '../utils/admin_helpers.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ReportService _reportService = ReportService();
  late Future<List<dynamic>> _reportsFuture;

  // Variable that tracks the active status for filtering
  String _currentFilter = 'ALL'; // ALL, ONGOING, RESOLVED

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

  Map<String, dynamic> _getCategoryDetails(String category) {
    String key = category.trim().toUpperCase()
        .replaceAll('İ', 'I').replaceAll('Ğ', 'G')
        .replaceAll('Ç', 'C').replaceAll('Ş', 'S')
        .replaceAll('Ö', 'O').replaceAll('Ü', 'U');

    switch (key) {
      case 'SCOOTER': return {'title': 'cat_scooter'.tr(), 'icon': Icons.electric_scooter, 'color': Colors.blue};
      case 'CUKUR': return {'title': 'cat_pothole'.tr(), 'icon': Icons.edit_road, 'color': Colors.brown};
      case 'COPLUK': return {'title': 'cat_garbage'.tr(), 'icon': Icons.delete_outline, 'color': Colors.green};
      case 'KIRIK_BANK': return {'title': 'cat_bench'.tr(), 'icon': Icons.park, 'color': Colors.green[800]};
      case 'TRAFIK': return {'title': 'cat_traffic'.tr(), 'icon': Icons.traffic, 'color': Colors.red};
      case 'ELEKTRIK': return {'title': 'cat_electric'.tr(), 'icon': Icons.lightbulb_outline, 'color': Colors.amber};
      case 'POSTER': return {'title': 'cat_poster'.tr(), 'icon': Icons.layers_clear, 'color': Colors.deepPurple};
      case 'AGAC': return {'title': 'cat_tree'.tr(), 'icon': Icons.nature, 'color': Colors.teal};
      case 'YANGIN': return {'title': 'cat_fire'.tr(), 'icon': Icons.local_fire_department, 'color': Colors.red};
      case 'GAZ KACAGI': return {'title': 'cat_gas'.tr(), 'icon': Icons.gas_meter, 'color': Colors.orange};
      case 'SU PATLAGI': return {'title': 'cat_water'.tr(), 'icon': Icons.water_drop, 'color': Colors.blue};
      case 'ELEKTRIK ARIZASI': return {'title': 'cat_electric_urgent'.tr(), 'icon': Icons.bolt, 'color': Colors.yellow.shade800};
      case 'YOL COKMESI': return {'title': 'cat_road_collapse'.tr(), 'icon': Icons.add_road, 'color': Colors.brown};
      case 'DIGER':
      default: return {
        'title': category.toUpperCase() == 'DİĞER' || key == 'DIGER' ? 'cat_other'.tr() : category, 
        'icon': Icons.report_problem, 
        'color': Colors.grey
      };
    }
  }

  Map<String, dynamic> _getStatusDetails(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING': return {'label': 'status_new'.tr(), 'color': Colors.blue};
      case 'IN_PROGRESS': return {'label': 'status_in_progress'.tr(), 'color': Colors.orange};
      case 'RESOLVED': 
      case 'COMPLETED': return {'label': 'status_resolved'.tr(), 'color': Colors.green};
      default: return {'label': status, 'color': Colors.grey};
    }
  }

  String _formatDate(dynamic dateData) {
    if (dateData == null) return '';
    try {
      final date = DateTime.parse(dateData.toString()).toLocal();
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) { return ''; }
  }

  void _showReportDetails(BuildContext context, Map<String, dynamic> item, bool isDark) {
    String rawStatus = item['status']?.toString().toUpperCase() ?? 'PENDING';
    final cat = _getCategoryDetails(item['category'] ?? '');
    final stat = _getStatusDetails(rawStatus);

    bool isUrgent = item['isUrgent'] == true;
    if (rawStatus == 'RESOLVED' || rawStatus == 'COMPLETED') isUrgent = false;

    String descText = item['description']?.toString().trim() ?? '';
    bool showDesc = descText.isNotEmpty && descText != 'desc_empty'.tr() && descText.toLowerCase() != 'açıklama girilmedi.' && descText != 'Acil durum bildirimi';

    String assignedTo = item['assignedInstitution']?.toString().toUpperCase().replaceAll('INST_', '') ?? '';
    bool isAssigned = assignedTo.isNotEmpty && assignedTo != 'ATANMADI' && assignedTo != 'PENDING' && assignedTo != 'STATUS_PENDING' && assignedTo != 'NULL';

    String displayAddress = item['location']?['address'] ?? item['address'] ?? 'loc_unknown'.tr();
    String timeStr = _formatDate(item['createdAt']);

    String? imageUrl;
    if (item['imageUrls'] != null && item['imageUrls'] is List && item['imageUrls'].isNotEmpty) {
      imageUrl = item['imageUrls'][0].toString();
    } else if (item['images'] != null && item['images'] is List && item['images'].isNotEmpty) {
      imageUrl = item['images'][0].toString(); 
    } else if (item['imageUrl'] != null) {
      imageUrl = item['imageUrl'].toString(); 
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
                    backgroundColor: isUrgent ? Colors.red.shade100 : cat['color'].withOpacity(0.1),
                    radius: 25,
                    child: Icon(isUrgent ? Icons.warning : cat['icon'], color: isUrgent ? Colors.red : cat['color'], size: 28),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isUrgent ? "🚨 ${cat['title']} ${'urgent_suffix'.tr()}" : cat['title'], 
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isUrgent ? Colors.red.shade700 : (isDark ? Colors.white : Colors.black87))
                        ),
                        Text(timeStr, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 30),

              if (showDesc) ...[
                Text('desc_label'.tr(), style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                  child: Text(descText, style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic)),
                ),
                const SizedBox(height: 20),
              ],

              Text('loc_exact'.tr(), style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(displayAddress, style: const TextStyle(fontSize: 15))),
                ],
              ),
              const SizedBox(height: 20),

              if (imageUrl != null && imageUrl.isNotEmpty && imageUrl != 'null') ...[
                Text('photo_added'.tr(), style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    imageUrl, width: double.infinity, height: 200, fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(height: 150, color: Colors.grey.shade300, child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey))),
                  ),
                ),
                const SizedBox(height: 30),
              ],

              if (isAssigned && rawStatus != 'PENDING') ...[
                Text('inst_assigned'.tr(), style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.blue.withOpacity(0.3))),
                  child: Row(
                    children: [
                      const Icon(Icons.business, color: Colors.blue, size: 24),
                      const SizedBox(width: 10),
                      Expanded(child: Text(AdminHelpers.getInstitutionName(assignedTo), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16))),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
              
              Container(
                width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(color: stat['color'].withOpacity(0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: stat['color'])),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(isUrgent && rawStatus == 'PENDING' ? Icons.warning : Icons.info_outline, color: stat['color'], size: 24),
                    const SizedBox(width: 8),
                    Text(
                      isUrgent && rawStatus == 'PENDING' ? 'status_urgent_pending'.tr() : stat['label'], 
                      style: TextStyle(color: stat['color'], fontSize: 16, fontWeight: FontWeight.bold)
                    ),
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

  /// A component that renders the filter buttons at the top of the screen and, when clicked, 
  /// triggers an immediate re-render by updating the UI state (_currentFilter) instead of creating a new network request.
  Widget _buildFilterChip(String label, String filterValue, bool isDark) {
    bool isSelected = _currentFilter == filterValue;
    return ChoiceChip(
      label: Text(label, style: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87), fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
      selected: isSelected,
      selectedColor: Colors.blue.shade600,
      backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (bool selected) {
        if(selected) {
          setState(() => _currentFilter = filterValue);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('history_title'.tr()),
        backgroundColor: const Color(0xFF4094FF),
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchReports)],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("history_error".tr() + ": ${snapshot.error}"));

          final reports = snapshot.data ?? [];
          
          if (reports.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('history_empty'.tr(), style: const TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          // FILTERING
          // Data retrieved once from the backend (snapshot.data) is filtered directly in device memory (RAM)
          // to avoid placing an additional load on the server. This ensures zero latency when switching between tabs.
          List<dynamic> filteredReports = reports.where((report) {
            if (_currentFilter == 'ALL') return true;
            String status = report['status']?.toString().toUpperCase() ?? 'PENDING';
            if (_currentFilter == 'ONGOING') {
              return status == 'PENDING' || status == 'IN_PROGRESS';
            }
            if (_currentFilter == 'RESOLVED') {
              return status == 'RESOLVED' || status == 'COMPLETED';
            }
            return true;
          }).toList();

          // Sorting (Newest to Oldest)
          // To ensure the most recent complaint appears at the top from a user experience perspective,
          // an algorithm that converts ISO dates in string format to DateTime objects and sorts them in reverse chronological order.
          filteredReports.sort((a, b) {
            DateTime dateA = DateTime.tryParse(a['createdAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
            DateTime dateB = DateTime.tryParse(b['createdAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
            return dateB.compareTo(dateA);
          });

          return Column(
            children: [
              Container(
                height: 60,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: isDark ? Colors.grey.shade900 : Colors.white,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip('filter_all'.tr(), 'ALL', isDark),
                    const SizedBox(width: 8),
                    _buildFilterChip('filter_ongoing'.tr(), 'ONGOING', isDark),
                    const SizedBox(width: 8),
                    _buildFilterChip('filter_resolved'.tr(), 'RESOLVED', isDark),
                  ],
                ),
              ),
              
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _fetchReports(),
                  child: filteredReports.isEmpty 
                    ? Center(child: Text('admin_no_match'.tr(), style: const TextStyle(color: Colors.grey))) // If the filter result is empty
                    : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    itemCount: filteredReports.length,
                    itemBuilder: (context, index) {
                      final report = filteredReports[index];
                      final cat = _getCategoryDetails(report['category'] ?? '');
                      final stat = _getStatusDetails(report['status'] ?? 'PENDING');
                      
                      bool isUrgent = report['isUrgent'] == true;
                      if (report['status'] == 'RESOLVED' || report['status'] == 'COMPLETED') {
                         isUrgent = false; 
                      }

                      String descText = report['description']?.toString().trim() ?? '';
                      bool showDesc = descText.isNotEmpty && 
                                      descText != 'desc_empty'.tr() && 
                                      descText.toLowerCase() != 'açıklama girilmedi.' &&
                                      descText != 'Acil durum bildirimi';

                      String assignedTo = report['assignedInstitution']?.toString().toUpperCase().replaceAll('INST_', '') ?? '';
                      bool isAssigned = assignedTo.isNotEmpty && assignedTo != 'ATANMADI' && assignedTo != 'PENDING' && assignedTo != 'STATUS_PENDING' && assignedTo != 'NULL';

                      String displayAddress = report['location']?['address'] ?? report['address'] ?? 'loc_unknown'.tr();

                      return Card(
                        elevation: isUrgent ? 5 : 2, 
                        margin: const EdgeInsets.only(bottom: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isUrgent ? const BorderSide(color: Colors.red, width: 2) : BorderSide(color: Colors.grey.shade200, width: 1),
                        ),
                        color: isUrgent ? (isDark ? Colors.red.withOpacity(0.15) : Colors.red.shade50) : (isDark ? Colors.grey.shade800 : Colors.white),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _showReportDetails(context, report, isDark), 
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: isUrgent ? Colors.red.shade100 : cat['color'].withOpacity(0.1), 
                                      child: Icon(isUrgent ? Icons.warning : cat['icon'], color: isUrgent ? Colors.red : cat['color'])
                                    ),
                                    const SizedBox(width: 12),
                                    
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start, 
                                        children: [
                                          Text(
                                            isUrgent ? "🚨 ${cat['title']} ${'urgent_suffix'.tr()}" : cat['title'], 
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isUrgent ? Colors.red.shade700 : (isDark ? Colors.white : Colors.black87))
                                          ),
                                          const SizedBox(height: 4),
                                          
                                          if (showDesc)
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 4.0),
                                              child: Text(
                                                "\"$descText\"", 
                                                style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                                                maxLines: 2, overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(displayAddress, style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
                                              ),
                                            ],
                                          ),
                                        ]
                                      )
                                    ),
                                    
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 
                                      decoration: BoxDecoration(color: isUrgent && report['status'] == 'PENDING' ? Colors.red : stat['color'], borderRadius: BorderRadius.circular(12)), 
                                      child: Text(
                                        isUrgent && report['status'] == 'PENDING' ? 'complaint_urgent_badge'.tr() : stat['label'], 
                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)
                                      )
                                    ),
                                  ],
                                ),
                                
                                if (isAssigned && report['status'] != 'PENDING') ...[
                                  const Padding(padding: EdgeInsets.symmetric(vertical: 4.0), child: Divider()),
                                  Row(children: [
                                    const Icon(Icons.business, size: 14, color: Colors.orange),
                                    const SizedBox(width: 4),
                                    Text("${'inst_label'.tr()}: ", style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700)),
                                    // OVERFLOW PROTECTION: Adding Flexible
                                    Flexible(
                                      child: Text(
                                        AdminHelpers.getInstitutionName(assignedTo), 
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange),
                                        // If the text doesn't fit, it displays "..." instead of overflowing
                                        overflow: TextOverflow.ellipsis, 
                                        maxLines: 1,
                                      ),
                                    ),
                                  ]),
                                ]
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}