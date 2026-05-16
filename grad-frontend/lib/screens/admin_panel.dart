import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/report_service.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';
import '../data/ankara_locations.dart';
import '../utils/admin_helpers.dart';
import '../utils/admin_ui_helpers.dart';

class AdminDashboardScreen extends StatefulWidget {
  final int initialIndex;

  const AdminDashboardScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  static const Color primaryAdminColor = Color(0xFF0D47A1); 
  static const Color alertColor = Color(0xFFC62828); 

  late TabController _tabController;
  final ReportService _reportService = ReportService();

  List<dynamic> _allReports = [];
  bool _isLoading = true;
  
  int totalReports = 0;
  int activeTasks = 0;
  int resolvedTasks = 0;
  int urgentTasks = 0;
  
  Map<String, int> _institutionStats = {};
  // A map to track district-level crisis data
  Map<String, int> _districtStats = {};

  String _statusFilter = 'TÜMÜ';
  String _instFilter = 'TÜMÜ'; 
  bool _onlyUrgent = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialIndex);
    _fetchLiveDashboardData();
  }  

  /// The core engine that processes raw data retrieved from the backend at the UI layer, 
  /// converting it into statistical data based on organizations' workloads, regional crisis intensity, and urgency levels.
  Future<void> _fetchLiveDashboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final reports = await _reportService.getAllReports();
      
      if (mounted) {
        int total = reports.length;
        int active = 0;
        int resolved = 0;
        int urgent = 0;
        
        Map<String, int> instCounts = {
          'FEN_ISLERI': 0, 'TEDAS': 0, 'ASKI': 0, 'ZABITA': 0, 'TEMIZLIK': 0, 'EMNIYET': 0, 'UKOME': 0, 'PARK_BAHCE': 0, 'DIGER': 0, 'ATANMADI': 0
        };
        
        Map<String, int> tempDistrictStats = {};

        for (var r in reports) {
          // Cast the data to String and Boolean for type safety
          String status = (r['status'] ?? '').toString().toUpperCase().trim();
          bool isUrgentFlag = (r['isUrgent'] == true || r['isUrgent'].toString().toLowerCase() == 'true');
          
          String inst = r['assignedInstitution']?.toString().toUpperCase().replaceAll('INST_', '') ?? '';
          if (inst.isEmpty) inst = 'ATANMADI';
          
          // Count institutional statistics (based on all complaints)
          if (instCounts.containsKey(inst)) {
            instCounts[inst] = instCounts[inst]! + 1;
          } else {
            instCounts['DIGER'] = instCounts['DIGER']! + 1;
          }

          // Count by Complaint Status
          if (status == 'RESOLVED' || status == 'COMPLETED') {
            resolved++;
          } else {
            active++; 
            
            // COUNT ONLY ACTIVE EMERGENCIES (Administrator priority)
            if (isUrgentFlag) {
              urgent++;
            }

            // REGIONAL ANALYSIS (For active crises only)
            String address = (r['location']?['address'] ?? r['address'] ?? '').toString();
            String district = AdminHelpers.parseDistrict(address);
            tempDistrictStats[district] = (tempDistrictStats[district] ?? 0) + 1;
          }
        }

        // Sort the crisis regions from most to least
        var sortedDistricts = Map.fromEntries(
            tempDistrictStats.entries.toList()..sort((e1, e2) => e2.value.compareTo(e1.value))
        );

        setState(() {
          _allReports = reports;
          totalReports = total;
          activeTasks = active;
          resolvedTasks = resolved;
          urgentTasks = urgent;
          _institutionStats = instCounts; 
          _districtStats = sortedDistricts;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Veri çekme hatası: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsResolved(String taskId) async {
    try {
      await _reportService.updateReportStatus(
        id: taskId,
        status: 'RESOLVED',
        comment: 'Şikayet saha ekiplerimiz tarafından çözülmüştür.',
      );
      _fetchLiveDashboardData(); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark; 
    
    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
      appBar: AppBar(
        title: Text('admin_app_bar_title'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryAdminColor,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(icon: const Icon(Icons.analytics), text: "admin_tab_stats".tr()),
            Tab(icon: const Icon(Icons.notification_important), text: "admin_tab_live".tr()),
          ],
        ),
      ),
      
      drawer: Drawer(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // TAŞMA KORUMALI HEADER: DrawerHeader yerine esnek Container kullandık
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 20), // Üstten güvenli boşluk (StatusBar için)
              decoration: const BoxDecoration(color: primaryAdminColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // İçerik kadar yer kapla
                children: [
                  const CircleAvatar(
                    radius: 30, 
                    backgroundColor: Colors.white, 
                    child: Icon(Icons.admin_panel_settings, size: 35, color: Color(0xFF0D47A1))
                  ),
                  const SizedBox(height: 15),
                  // Metin çok büyürse sığması için FittedBox ile sarmaladık
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'admin_drawer_title'.tr(), 
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'admin_drawer_subtitle'.tr(), 
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blue), 
              title: Text('prof_title'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)), 
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())); }
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.blueGrey), 
              title: Text('settings_title'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)), 
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())); }
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red), 
              title: Text('logout'.tr(), style: TextStyle(color: isDark ? Colors.white : Colors.black87)), 
              onTap: () { Navigator.pop(context); AdminUIHelpers.showLogoutConfirmDialog(context); }
            ),
          ],
        ),
      ),
      
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: primaryAdminColor))
        : TabBarView(
            controller: _tabController,
            children: [
              _buildStatisticsTab(isDark),
              _buildEmergencyFeedTab(isDark),
            ],
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchLiveDashboardData,
        backgroundColor: primaryAdminColor,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
  /// When a user clicks on any card in the Statistics tab (e.g., Emergency Alerts), 
  /// it automatically redirects the user to the filtered live feed by simultaneously updating the TabBar index and the filtering state.
  void _jumpToFilteredFeed({String? status, bool? onlyUrgent}) {
    setState(() {
      if (status != null) _statusFilter = status;
      if (onlyUrgent != null) _onlyUrgent = onlyUrgent;
      _tabController.animateTo(1); // Switch to the LIVE EMERGENCY FEED tab
    });
  }

  Widget _buildStatisticsTab(bool isDark) {
    return RefreshIndicator(
      onRefresh: _fetchLiveDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatGrid(isDark), 
            const SizedBox(height: 25),
            
            Row(
              children: [
                Icon(Icons.local_fire_department, color: Colors.red.shade700, size: 24),
                const SizedBox(width: 8),
                Text("admin_regional_crisis_map".tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.2), width: 1.5),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: _districtStats.isEmpty
                  ? Center(child: Padding(padding: const EdgeInsets.all(20), child: Text("admin_no_data".tr())))
                  : Column(
                      children: _districtStats.entries.map((entry) {
                        double citySharePercentage = (activeTasks <= 0) ? 0.0 : (entry.value / activeTasks);
                        Color heatColor = citySharePercentage > 0.4 ? Colors.red.shade700 : (citySharePercentage > 0.15 ? Colors.orange.shade700 : Colors.amber.shade600);
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Icon(Icons.location_city, size: 16, color: heatColor),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            entry.key, 
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                                            overflow: TextOverflow.ellipsis, // If it's too long, add an ellipsis at the end
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // By wrapping the badge section in a FittedBox, we ensure that the text size automatically shrinks if it doesn't fit
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(color: heatColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                      child: Text(
                                        "admin_crisis_with_percent".tr(args: [
                                          entry.value.toString(), 
                                          (citySharePercentage * 100).toStringAsFixed(1)
                                        ]), 
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: heatColor)
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Stack(
                                children: [
                                  Container(height: 10, decoration: BoxDecoration(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, borderRadius: BorderRadius.circular(5))),
                                  FractionallySizedBox(
                                    widthFactor: citySharePercentage.clamp(0.02, 1.0), 
                                    child: Container(
                                      height: 10, 
                                      decoration: BoxDecoration(color: heatColor, borderRadius: BorderRadius.circular(5))
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
            
            const SizedBox(height: 25),

            Text("admin_stats_inst_workload".tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: isDark ? Colors.grey.shade900 : Colors.white, borderRadius: BorderRadius.circular(12)),
              child: _institutionStats.isEmpty
                  ? Center(child: Text("admin_no_data".tr()))
                  : Column(
                      children: _institutionStats.entries.map((entry) {
                        if (entry.value == 0 && entry.key != 'ATANMADI') return const SizedBox.shrink();
                        double percentage = totalReports == 0 ? 0 : (entry.value / totalReports).clamp(0.0, 1.0);
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      AdminHelpers.getInstitutionName(entry.key), 
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.grey.shade300 : Colors.black87), 
                                      maxLines: 1, 
                                      overflow: TextOverflow.ellipsis
                                    )
                                  ),
                                  const SizedBox(width: 8),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "admin_task_with_percent".tr(args: [
                                        entry.value.toString(), 
                                        (percentage * 100).toStringAsFixed(1)
                                      ]), 
                                      style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(value: percentage, minHeight: 8, backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200, color: const Color(0xFF0D47A1)),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyFeedTab(bool isDark) {
    List<dynamic> filteredReports = _allReports.where((item) {
      String status = item['status']?.toString().toUpperCase() ?? 'PENDING';
      String assignedInstRaw = item['assignedInstitution']?.toString() ?? '';
      String assignedInst = assignedInstRaw.toUpperCase().replaceAll('INST_', '');
      
      if (assignedInst.isEmpty) assignedInst = 'ATANMADI';
      bool isUrgent = item['isUrgent'] == true;

      if (_onlyUrgent && !isUrgent) return false;
      if (_statusFilter == 'YENİ' && status != 'PENDING') return false;
      if (_statusFilter == 'İŞLEMDE' && status != 'IN_PROGRESS') return false;
      if (_statusFilter == 'ÇÖZÜLENLER' && status != 'RESOLVED' && status != 'COMPLETED') return false;
      
      if (_instFilter != 'TÜMÜ') {
        List<String> stdInst = ['FEN_ISLERI', 'TEDAS', 'ASKI', 'ZABITA', 'TEMIZLIK', 'EMNIYET', 'UKOME', 'PARK_BAHCE', 'ATANMADI'];
        if (_instFilter == 'DIGER') {
          if (stdInst.contains(assignedInst)) return false; 
        } else {
          if (assignedInst != _instFilter) return false; 
        }
      }

      return true;
    }).toList();

    filteredReports.sort((a, b) {
      DateTime dateA = DateTime.tryParse(a['createdAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      DateTime dateB = DateTime.tryParse(b['createdAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      return dateB.compareTo(dateA);
    });

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: isDark ? Colors.grey.shade800 : Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), labelText: 'filter_status'.tr()),
                      value: _statusFilter,
                      dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
                      items: [
                        DropdownMenuItem(value: 'TÜMÜ', child: Text('filter_all'.tr(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'YENİ', child: Text('filter_new'.tr(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'İŞLEMDE', child: Text('filter_in_progress'.tr(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'ÇÖZÜLENLER', child: Text('filter_resolved'.tr(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
                      ],
                      onChanged: (val) => setState(() => _statusFilter = val!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), labelText: 'filter_inst'.tr()),
                      value: _instFilter,
                      dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
                      items: [
                        DropdownMenuItem(value: 'TÜMÜ', child: Text('filter_all'.tr(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'FEN_ISLERI', child: Text('inst_fen'.tr(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'TEDAS', child: Text('inst_tedas'.tr(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'ASKI', child: Text('inst_aski'.tr(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'ZABITA', child: Text('inst_zabita'.tr(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'TEMIZLIK', child: Text('inst_temizlik'.tr(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'EMNIYET', child: Text('inst_police_fire'.tr(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'UKOME', child: Text('inst_ukome'.tr(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))), 
                        DropdownMenuItem(value: 'PARK_BAHCE', child: Text('inst_park_bahce'.tr(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))), 
                        DropdownMenuItem(value: 'DIGER', child: Text('inst_other_manual'.tr(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'ATANMADI', child: Text('inst_unassigned'.tr(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
                      ],
                      onChanged: (val) => setState(() => _instFilter = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('admin_filter_urgent_only'.tr(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _onlyUrgent ? Colors.red : null)),
                secondary: Icon(Icons.emergency, color: _onlyUrgent ? Colors.red : Colors.grey),
                value: _onlyUrgent,
                activeColor: Colors.red,
                onChanged: (val) => setState(() => _onlyUrgent = val),
              )
            ],
          ),
        ),

        Expanded(
          child: filteredReports.isEmpty
              ? Center(child: Text("admin_no_match".tr(), style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)))
              : RefreshIndicator(
                  onRefresh: _fetchLiveDashboardData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredReports.length,
                    itemBuilder: (context, index) {
                      final item = filteredReports[index];
                      
                      String address = item['location']?['address']?.toString() ?? item['address']?.toString() ?? '';
                      String district = address.isNotEmpty ? address.split(',').first : "loc_unknown".tr();
                      String cityDisplay = "ANKARA / $district";

                      String rawStatus = item['status']?.toString().toUpperCase() ?? 'PENDING';
                      String statusText = "";
                      Color statusColor = Colors.orange;
                      
                      String assignedTo = item['assignedInstitution']?.toString() ?? '';

                      String rawCat = item['category']?.toString().toUpperCase() ?? '';
                      bool isSystemCritical = ['YANGIN', 'GAZ KAÇAĞI', 'SU PATLAĞI', 'ELEKTRİK ARIZASI', 'YOL ÇÖKMESİ'].contains(rawCat);
                      bool isUserUrgent = item['isUrgent'] == true;

                      bool showAsRed = isSystemCritical || isUserUrgent;

                      if (rawStatus == 'PENDING') {
                        statusText = showAsRed ? "status_urgent_pending".tr() : "status_pending".tr();
                        statusColor = Colors.red;
                      } else if (rawStatus == 'IN_PROGRESS') {
                        statusText = "status_sevk".tr();
                        statusColor = Colors.orange;
                      } else if (rawStatus == 'RESOLVED' || rawStatus == 'COMPLETED') {
                        statusText = "status_resolved".tr();
                        statusColor = Colors.green;
                      }

                      return Card(
                        elevation: showAsRed ? 6 : (isUserUrgent ? 4 : 2),
                        color: showAsRed 
                            ? (isDark ? Colors.red.shade900.withOpacity(0.4) : Colors.red.shade50) 
                            : (isDark ? Colors.grey.shade800 : Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: (showAsRed ? const BorderSide(color: Colors.red, width: 2) : BorderSide.none),
                        ),
                        child: InkWell(
                          onTap: () => AdminUIHelpers.showReportDetails(context, item, isDark),
                          borderRadius: BorderRadius.circular(15),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded( 
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cityDisplay,
                                            style: TextStyle(
                                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis, 
                                            maxLines: 1, 
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8), 
                                    Text(
                                      AdminHelpers.getTimeAgo(item['createdAt']),
                                      style: TextStyle(
                                        color: showAsRed ? Colors.red : (isDark ? Colors.grey.shade500 : Colors.grey),
                                        fontSize: 12,
                                        fontWeight: showAsRed ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: showAsRed ? Colors.red : Colors.orange.shade100,
                                      radius: 25,
                                      child: Icon(showAsRed ? Icons.warning : Icons.campaign, color: showAsRed ? Colors.white : Colors.orange),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['titleStr']?.toString() ?? AdminHelpers.getCategoryTitle(item['category']?.toString() ?? 'DİĞER'), 
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: showAsRed ? Colors.red.shade700 : (isDark ? Colors.white : Colors.black87))
                                          ),
                                          const SizedBox(height: 5),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(6)),
                                            child: Text(statusText, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (rawStatus == 'RESOLVED' || rawStatus == 'COMPLETED')
                                      const Icon(Icons.check_circle, color: Colors.green, size: 32)
                                    else
                                      const Icon(Icons.chevron_right, color: Colors.grey),
                                  ],
                                ),
                                if (assignedTo.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1), 
                                        borderRadius: BorderRadius.circular(6)
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min, // Ensures that the badge takes up no more space than the content
                                        children: [
                                          const Icon(Icons.business, color: Colors.blue, size: 14),
                                          const SizedBox(width: 6),
                                          // OVERFLOW PROTECTION: We wrap the text with the "Expanded" tag
                                          Flexible( 
                                            child: Text(
                                              "${'inst_label'.tr()}: ${AdminHelpers.getInstitutionName(assignedTo)}",
                                              style: const TextStyle(
                                                color: Colors.blue, 
                                                fontSize: 11, 
                                                fontWeight: FontWeight.bold
                                              ),
                                              // If the text doesn't fit, it adds "..." at the end
                                              overflow: TextOverflow.ellipsis, 
                                              maxLines: 1, 
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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
  }

  Widget _buildStatGrid(bool isDark) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: [
        _buildStatCard("admin_stat_all".tr(), totalReports.toString(), Icons.public, Colors.blue, isDark, 
          onTap: () => _jumpToFilteredFeed(status: 'TÜMÜ', onlyUrgent: false)),
        
        _buildStatCard("admin_stat_active".tr(), activeTasks.toString(), Icons.engineering, Colors.orange, isDark, 
          onTap: () => _jumpToFilteredFeed(status: 'İŞLEMDE', onlyUrgent: false)),
        
        _buildStatCard("admin_stat_solved".tr(), resolvedTasks.toString(), Icons.check_circle, Colors.green, isDark, 
          onTap: () => _jumpToFilteredFeed(status: 'ÇÖZÜLENLER', onlyUrgent: false)),
        
        _buildStatCard("admin_stat_emergency".tr(), urgentTasks.toString(), Icons.warning, Colors.red, isDark, 
          onTap: () => _jumpToFilteredFeed(onlyUrgent: true)),
      ],
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color, bool isDark, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap, // Clickable Link Added
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
          boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 24)),
                Text(count, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(title, style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700, fontWeight: FontWeight.bold))),
                Icon(Icons.arrow_forward_ios, size: 12, color: color.withOpacity(0.5)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}