import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/report_service.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

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

  String _statusFilter = 'TÜMÜ';
  String _instFilter = 'TÜMÜ'; 
  bool _onlyUrgent = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialIndex);
    _fetchLiveDashboardData();
  }

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
          'FEN_ISLERI': 0, 'TEDAS': 0, 'ASKI': 0, 'ZABITA': 0, 'TEMIZLIK': 0, 'EMNIYET': 0, 'ATANMADI': 0
        };

        for (var r in reports) {
          String status = r['status']?.toString().toUpperCase() ?? '';
          bool isUrgentFlag = r['isUrgent'] == true;
          
          String inst = r['assignedInstitution']?.toString().toUpperCase().replaceAll('INST_', '') ?? '';
          if (inst.isEmpty) inst = 'ATANMADI';
          if (instCounts.containsKey(inst)) {
            instCounts[inst] = instCounts[inst]! + 1;
          }

          if (status == 'RESOLVED' || status == 'COMPLETED') {
            resolved++;
          } else {
            active++; 
          }

          if (isUrgentFlag && status != 'RESOLVED') {
            urgent++;
          }
        }

        setState(() {
          _allReports = reports;
          totalReports = total;
          activeTasks = active;
          resolvedTasks = resolved;
          urgentTasks = urgent;
          _institutionStats = instCounts; 
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getTimeAgo(String? dateStr) {
    if (dateStr == null) return "time_new".tr();
    DateTime date = DateTime.tryParse(dateStr) ?? DateTime.now();
    Duration diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return "time_now".tr();
    if (diff.inMinutes < 60) return "${diff.inMinutes} ${"time_min".tr()}";
    if (diff.inHours < 24) return "${diff.inHours} ${"time_hour".tr()}";
    return "${diff.inDays} ${"time_day".tr()}";
  }

  String _getCategoryTitle(String category) {
    String key = category.trim().toUpperCase();
    switch (key) {
      case 'YANGIN': return 'cat_fire'.tr();
      case 'GAZ KAÇAĞI': return 'cat_gas'.tr();
      case 'SU PATLAĞI': return 'cat_water'.tr();
      case 'ELEKTRİK ARIZASI': return 'cat_electric_urgent'.tr();
      case 'YOL ÇÖKMESİ': return 'cat_road_collapse'.tr();
      case 'CUKUR': return 'cat_pothole'.tr();
      case 'COPLUK': return 'cat_garbage'.tr();
      case 'KIRIK_BANK': return 'cat_bench'.tr();
      case 'TRAFIK': return 'cat_traffic'.tr();
      case 'ELEKTRIK': return 'cat_electric'.tr();
      case 'SCOOTER': return 'cat_scooter'.tr();
      default: return category; 
    }
  }

  String _predictInstitution(String category) {
    String cat = category.toUpperCase()
        .replaceAll('İ', 'I').replaceAll('Ç', 'C').replaceAll('Ş', 'S')
        .replaceAll('Ğ', 'G').replaceAll('Ü', 'U').replaceAll('Ö', 'O');
    
    if (cat.contains('YANGIN')) return 'EMNIYET';
    if (cat.contains('GAZ') || cat.contains('ELEKTRIK')) return 'TEDAS';
    if (cat.contains('SU')) return 'ASKI';
    if (cat.contains('COP') || cat.contains('TEMIZLIK')) return 'TEMIZLIK';
    if (cat.contains('SCOOTER') || cat.contains('TRAFIK') || cat.contains('POSTER')) return 'ZABITA';
    return 'FEN_ISLERI';
  }

  // --- TAMAMEN DİLE DUYARLI KURUM İSİMLERİ ---
  String _getInstitutionName(String? code) {
    if (code == null || code.isEmpty || code == 'ATANMADI') return 'inst_unassigned'.tr();
    String cleanCode = code.toUpperCase().replaceAll('INST_', '');
    switch (cleanCode) {
      case 'FEN_ISLERI': return 'inst_fen'.tr();
      case 'TEDAS': return 'inst_tedas'.tr(); 
      case 'ASKI': return 'inst_aski'.tr(); 
      case 'ZABITA': return 'inst_zabita'.tr();
      case 'TEMIZLIK': return 'inst_temizlik'.tr();
      case 'EMNIYET': return 'inst_emniyet'.tr();
      default: return code;
    }
  }

  void _showAssignmentDialog(BuildContext context, Map<String, dynamic> task) {
    String currentSelection = _predictInstitution(task['category'].toString());
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text("admin_assign_title".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
            content: DropdownButtonFormField<String>(
              value: currentSelection,
              dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              // items içindeki const'lar kaldırıldı, .tr() eklendi
              items: [
                DropdownMenuItem(value: 'FEN_ISLERI', child: Text('inst_fen'.tr())),
                DropdownMenuItem(value: 'TEDAS', child: Text('inst_tedas'.tr())), 
                DropdownMenuItem(value: 'ASKI', child: Text('inst_aski'.tr())),  
                DropdownMenuItem(value: 'ZABITA', child: Text('inst_zabita'.tr())),
                DropdownMenuItem(value: 'TEMIZLIK', child: Text('inst_temizlik'.tr())),
                DropdownMenuItem(value: 'EMNIYET', child: Text('inst_emniyet'.tr())),
              ],
              onChanged: (val) => setDialogState(() => currentSelection = val!),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text('cancel'.tr())),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _reportService.assignInstitution(task['id'], currentSelection);
                  _fetchLiveDashboardData();
                },
                child: Text('btn_assign'.tr(), style: const TextStyle(color: Colors.white)),
              )
            ],
          );
        },
      ),
    );
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

  void _showLogoutConfirmDialog(BuildContext context) {
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

  // --- ADMİN İÇİN GÜNCELLENMİŞ DETAY EKRANI (SADECE OKUMA, BUTON YOK) ---
  void _showReportDetails(BuildContext context, Map<String, dynamic> item, bool isDark) {
    String rawStatus = item['status']?.toString().toUpperCase() ?? 'PENDING';
    bool isCritical = item['isUrgent'] == true && rawStatus != 'RESOLVED';
    String assignedTo = item['assignedInstitution']?.toString() ?? '';
    
    String? imageUrl;
    if (item['imageUrls'] != null && item['imageUrls'] is List && item['imageUrls'].isNotEmpty) {
      imageUrl = item['imageUrls'][0].toString();
    } else if (item['images'] != null && item['images'] is List && item['images'].isNotEmpty) {
      imageUrl = item['images'][0].toString();
    } else if (item['imageUrl'] != null) {
      imageUrl = item['imageUrl'].toString();
    } else if (item['image'] != null) {
      imageUrl = item['image'].toString();
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
                          _getCategoryTitle(item['category']?.toString() ?? 'DİĞER'), 
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isCritical ? Colors.red : (isDark ? Colors.white : Colors.black87))
                        ),
                        Text(_getTimeAgo(item['createdAt']), style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  )
                ],
              ),
              const Divider(height: 30),

              Text("Açıklama", style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                child: Text(item['description']?.toString() ?? "Açıklama girilmemiş.", style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 20),

              Text("Tam Konum", style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
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

              // 🌟 GÜNCELLENEN FOTOĞRAF ALANI (ADMİN PANELİ)
              if (imageUrl != null && imageUrl.isNotEmpty && imageUrl != 'null' || !isCritical) ...[
                Text("Eklenen Fotoğraf", style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                if (imageUrl != null && imageUrl.isNotEmpty && imageUrl != 'null')
                  GestureDetector(
                    onTap: () {
                      // Resim büyütme diyaloğu kodu
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        imageUrl, width: double.infinity, height: 200, fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(height: 150, color: Colors.grey.shade300, child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey))),
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100, borderRadius: BorderRadius.circular(15), border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300)),
                    child: Center(child: Text("Vatandaş fotoğraf eklememiş.", style: TextStyle(color: Colors.grey.shade500))),
                  ),
                const SizedBox(height: 30),
              ],

              if (assignedTo.isNotEmpty) ...[
                Text("Görevli Kurum", style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.business, color: Colors.blue),
                      const SizedBox(width: 10),
                      Text(_getInstitutionName(assignedTo), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],

              if (rawStatus == 'PENDING')
                Container(
                  width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.orange)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.hourglass_empty, color: Colors.orange, size: 24),
                      const SizedBox(width: 8),
                      Text('status_pending'.tr(), style: const TextStyle(color: Colors.orange, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              else if (rawStatus == 'IN_PROGRESS')
                Container(
                  width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.blue)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.engineering, color: Colors.blue, size: 24),
                      const SizedBox(width: 8),
                      Text('filter_in_progress'.tr(), style: const TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              else 
                Container(
                  width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.green)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 24),
                      const SizedBox(width: 8),
                      Text('status_resolved'.tr(), style: const TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
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
            DrawerHeader(
              decoration: const BoxDecoration(color: primaryAdminColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(radius: 30, backgroundColor: Colors.white, child: Icon(Icons.admin_panel_settings, size: 35, color: Color(0xFF0D47A1))),
                  const SizedBox(height: 10),
                  Text('admin_drawer_title'.tr(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('admin_drawer_subtitle'.tr(), style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                ],
              ),
            ),
            ListTile(leading: const Icon(Icons.person, color: Colors.blue), title: Text('prof_title'.tr()), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())); }),
            ListTile(leading: const Icon(Icons.settings, color: Colors.blueGrey), title: Text('settings_title'.tr()), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())); }),
            const Divider(),
            ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: Text('logout'.tr()), onTap: () { Navigator.pop(context); _showLogoutConfirmDialog(context); }),
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

  // ==========================================
  // --- İSTATİSTİKLER VE GRAFİK BÖLÜMÜ ---
  // ==========================================
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
            
            // --- TAMAMEN DİLE DUYARLI GRAFİK BAŞLIĞI ---
            Text("admin_stats_inst_workload".tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: isDark ? Colors.grey.shade800 : Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]),
              child: _institutionStats.isEmpty
                  ? Center(child: Text("admin_no_data".tr()))
                  : Column(
                      children: _institutionStats.entries.map((entry) {
                        if (entry.value == 0 && entry.key != 'ATANMADI') return const SizedBox.shrink();
                        
                        double percentage = totalReports == 0 ? 0 : entry.value / totalReports;
                        Color barColor = entry.key == 'ATANMADI' ? Colors.grey : Colors.blue;
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // --- ÇÖZÜM 1: UZUN İSİMLER İÇİN EXPANDED VE ELLIPSIS EKLENDİ ---
                                  Expanded(
                                    child: Text(
                                      _getInstitutionName(entry.key), 
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.grey.shade300 : Colors.black87),
                                      maxLines: 1, // Tek satıra zorla
                                      overflow: TextOverflow.ellipsis, // Sığmazsa "..." koy
                                    ),
                                  ),
                                  const SizedBox(width: 8), // Araya boşluk eklendi
                                  Text(
                                    "${entry.value} ${'admin_stats_complaint_count'.tr()} (%${(percentage * 100).toStringAsFixed(1)})", 
                                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: percentage,
                                  minHeight: 8,
                                  backgroundColor: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                                  color: barColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
            
            const SizedBox(height: 25),
            Text("admin_stats_personnel".tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: isDark ? Colors.grey.shade800 : Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Text("${"admin_stats_active_total".tr()}: 45", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(value: activeTasks == 0 ? 0.1 : (activeTasks / (activeTasks + 10)).clamp(0.1, 1.0), color: Colors.blue, minHeight: 8),
                ],
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
      String assignedInst = item['assignedInstitution']?.toString().toUpperCase().replaceAll('INST_', '') ?? '';
      if (assignedInst.isEmpty) assignedInst = 'ATANMADI';
      bool isUrgent = item['isUrgent'] == true;

      if (_onlyUrgent && !isUrgent) return false;
      if (_statusFilter == 'YENİ' && status != 'PENDING') return false;
      if (_statusFilter == 'İŞLEMDE' && status != 'IN_PROGRESS') return false;
      if (_statusFilter == 'ÇÖZÜLENLER' && status != 'RESOLVED' && status != 'COMPLETED') return false;
      if (_instFilter != 'TÜMÜ' && assignedInst != _instFilter) return false;

      return true;
    }).toList();

    filteredReports.sort((a, b) {
      bool isUrgentA = a['isUrgent'] == true && a['status'] != 'RESOLVED';
      bool isUrgentB = b['isUrgent'] == true && b['status'] != 'RESOLVED';
      if (isUrgentA && !isUrgentB) return -1;
      if (!isUrgentA && isUrgentB) return 1;
      DateTime dateA = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime.now();
      DateTime dateB = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime.now();
      return dateB.compareTo(dateA);
    });

    return Column(
      children: [
        // --- TAMAMEN DİLE DUYARLI İKİLİ FİLTRE PANELİ ---
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

        // LİSTE KISMI
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

                      // Vatandaş Sayfası Detay Mantığı
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
                          onTap: () => _showReportDetails(context, item, isDark),
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
                                      _getTimeAgo(item['createdAt']),
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
                                            item['titleStr']?.toString() ?? _getCategoryTitle(item['category']?.toString() ?? 'DİĞER'), 
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
                                    // 🌟 ADMİN İÇİN BUTON YOK, SADECE İKON VAR
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
                                      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.business, color: Colors.blue, size: 14),
                                          const SizedBox(width: 6),
                                          Text(
                                            "${'inst_label'.tr()}: ${_getInstitutionName(assignedTo)}",
                                            style: const TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold),
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
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _buildStatCard("admin_stat_all".tr(), totalReports.toString(), Icons.public, Colors.blue, isDark),
        _buildStatCard("admin_stat_active".tr(), activeTasks.toString(), Icons.engineering, Colors.orange, isDark),
        _buildStatCard("admin_stat_solved".tr(), resolvedTasks.toString(), Icons.check_circle, Colors.green, isDark),
        _buildStatCard("admin_stat_emergency".tr(), urgentTasks.toString(), Icons.warning, Colors.red, isDark),
      ],
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 30),
              Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          Text(title, style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}