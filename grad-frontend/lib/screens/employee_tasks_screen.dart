import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; 
import '../providers/auth_provider.dart';
import '../services/report_service.dart'; 
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

class EmployeeTasksScreen extends StatefulWidget {
  final int initialIndex;
  const EmployeeTasksScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<EmployeeTasksScreen> createState() => _EmployeeTasksScreenState();
}

class _EmployeeTasksScreenState extends State<EmployeeTasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ReportService _reportService = ReportService(); 
  late Future<List<Map<String, dynamic>>> _combinedTasksFuture;

  String _statusFilter = 'TÜMÜ'; 
  String _instFilter = 'TÜMÜ';
  bool _onlyUrgent = false; 

  final List<Map<String, dynamic>> _formalTasks = [
    {'title': 'task_park_maint', 'loc': 'loc_aybu_campus', 'icon': Icons.grass, 'color': Colors.green},
    {'title': 'task_lighting_insp', 'loc': 'loc_esenboga_road', 'icon': Icons.lightbulb, 'color': Colors.amber},
    {'title': 'task_manhole_check', 'loc': 'loc_yenimahalle_dist', 'icon': Icons.waves, 'color': Colors.blue},
    {'title': 'task_traffic_sign', 'loc': 'loc_kecioren_junction', 'icon': Icons.traffic, 'color': Colors.red},
    {'title': 'task_market_hygiene', 'loc': 'loc_cubuk_market', 'icon': Icons.cleaning_services, 'color': Colors.teal},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialIndex);
    _fetchData();
  }

  void _fetchData() {
    if (!mounted) return;
    setState(() { _combinedTasksFuture = _getAllReports(); });
  }

  Future<List<Map<String, dynamic>>> _getAllReports() async {
    List<Map<String, dynamic>> combinedList = [];
    try {
      final realReports = await _reportService.getAllReports(); 
      for (var report in realReports) {
        String? imageUrl;
        if (report['imageUrls'] != null && report['imageUrls'] is List && report['imageUrls'].isNotEmpty) {
          imageUrl = report['imageUrls'][0].toString();
        } else if (report['images'] != null && report['images'] is List && report['images'].isNotEmpty) {
          imageUrl = report['images'][0].toString(); 
        } else if (report['imageUrl'] != null) {
          imageUrl = report['imageUrl'].toString(); 
        } else if (report['image'] != null) {
          imageUrl = report['image'].toString(); 
        }

        bool isUrgentFlag = report['isUrgent'] == true || report['isUrgent'].toString() == 'true';

        combinedList.add({
          'id': report['id']?.toString() ?? '',
          'categoryRaw': report['category']?.toString() ?? 'DIGER',
          'titleStr': _getCategoryTitle(report['category']?.toString() ?? 'DIGER'),
          'locStr': report['location']?['address']?.toString() ?? report['address']?.toString() ?? 'loc_unknown'.tr(),
          'description': report['description']?.toString() ?? '',
          'imageUrl': imageUrl,
          'timeStr': _formatDate(report['createdAt']),
          'createdAt': report['createdAt'],
          'status': report['status']?.toString() ?? 'PENDING',
          'assignedInstitution': report['assignedInstitution']?.toString() ?? '', 
          'isUrgent': isUrgentFlag, 
        });
      }
    } catch (e) { debugPrint("Fetch error: $e"); }
    return combinedList;
  }

  String _getInstitutionName(String? code) {
  if (code == null || code.isEmpty || code == 'ATANMADI' || code == 'PENDING' || code == 'STATUS_PENDING') return 'inst_unassigned'.tr();
  
  String cleanCode = code.toUpperCase().replaceAll('INST_', '');
  
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
    default: return code; 
  }
}

  String _predictInstitution(String category) {
    String cat = category.toUpperCase().replaceAll('İ', 'I').replaceAll('Ç', 'C').replaceAll('Ş', 'S').replaceAll('Ğ', 'G').replaceAll('Ü', 'U').replaceAll('Ö', 'O');
    
    if (cat.contains('YANGIN')) return 'EMNIYET';
    if (cat.contains('GAZ') || cat.contains('ELEKTRIK')) return 'TEDAS';
    if (cat.contains('SU')) return 'ASKI';
    if (cat.contains('COP') || cat.contains('TEMIZLIK')) return 'TEMIZLIK';
    
    // Trafik artık UKOME'ye gidecek
    if (cat.contains('TRAFIK')) return 'UKOME';
    
    // Ağaç ve Bank artık Park Bahçeler'e gidecek
    if (cat.contains('AGAC') || cat.contains('BANK')) return 'PARK_BAHCE';
    
    // Scooter ve Afiş/Poster Zabıta'da kalacak
    if (cat.contains('SCOOTER') || cat.contains('POSTER') || cat.contains('AFIS')) return 'ZABITA';
    
    return 'FEN_ISLERI';
  }

  void _showAssignmentDialog(BuildContext context, Map<String, dynamic> task) {
    String currentSelection = _predictInstitution(task['categoryRaw'].toString());
    final TextEditingController _customController = TextEditingController();
    bool _isOther = false;
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
                    value: _isOther ? 'DIGER' : (['FEN_ISLERI', 'TEDAS', 'ASKI', 'ZABITA', 'TEMIZLIK', 'EMNIYET', 'UKOME', 'PARK_BAHCE'].contains(currentSelection) ? currentSelection : 'FEN_ISLERI'),
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
                        _isOther = (val == 'DIGER');
                      });
                    },
                  ),
                  if (_isOther) ...[
                    const SizedBox(height: 15),
                    TextField(
                      controller: _customController,
                      autofocus: true,
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
                  String finalInst = _isOther ? _customController.text.trim() : currentSelection;
                  if (_isOther && finalInst.isEmpty) return;

                  Navigator.pop(ctx);
                  await _reportService.assignInstitution(task['id'], finalInst);
                  _fetchData();
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
      _fetchData(); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _updateCategory(String taskId, String newCategory) async {
    try {
      await _reportService.updateReportCategory(taskId, newCategory);
      _fetchData(); 
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kategori başarıyla güncellendi!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kategori güncellenemedi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showReportDetails(BuildContext context, Map<String, dynamic> item, bool isDark) {
    String rawStatus = item['status']?.toString().toUpperCase() ?? 'PENDING';
    String rawCat = item['categoryRaw']?.toString().toUpperCase() ?? item['category']?.toString().toUpperCase() ?? '';

    String normalizedCat = rawCat.replaceAll('İ', 'I').replaceAll('Ğ', 'G').replaceAll('Ç', 'C').replaceAll('Ş', 'S').replaceAll('Ö', 'O').replaceAll('Ü', 'U').trim();

    final List<String> normalCategories = [
      'CUKUR', 'COPLUK', 'KIRIK_BANK', 'TRAFIK', 'ELEKTRIK', 'SCOOTER', 'POSTER', 'AGAC', 'DIGER'
    ];

    String currentDropdownCategory = normalCategories.contains(normalizedCat) ? normalizedCat : 'DIGER';

    bool isSystemCritical = ['YANGIN', 'GAZ KACAGI', 'SU PATLAGI', 'ELEKTRIK ARIZASI', 'YOL COKMESI'].contains(normalizedCat);
    bool isUserUrgent = item['isUrgent'] == true;
    bool showAsRed = (isSystemCritical || isUserUrgent) && rawStatus != 'RESOLVED';
    
    bool canEditCategory = (rawStatus != 'RESOLVED' && rawStatus != 'COMPLETED') && !isSystemCritical && !isUserUrgent;

    String assignedTo = item['assignedInstitution']?.toString() ?? '';
    bool isAssigned = assignedTo.isNotEmpty && assignedTo != 'ATANMADI' && assignedTo != 'PENDING' && assignedTo != 'STATUS_PENDING' && assignedTo != 'NULL';
    String? imageUrl = item['imageUrl'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder( 
        builder: (BuildContext context, StateSetter setModalState) {
          return Container(
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
                        backgroundColor: showAsRed ? Colors.red : Colors.orange.shade100,
                        radius: 25,
                        child: Icon(showAsRed ? Icons.warning : Icons.campaign, color: showAsRed ? Colors.white : Colors.orange),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (canEditCategory) 
                              Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: currentDropdownCategory,
                                    dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
                                    icon: const Padding(padding: EdgeInsets.only(right: 8.0), child: Icon(Icons.edit, size: 16, color: Colors.blue)),
                                    items: normalCategories.map((String category) {
                                      return DropdownMenuItem<String>(
                                        value: category,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 8.0),
                                          child: Text(
                                            _getCategoryTitle(category),
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      if (newValue != null && newValue != currentDropdownCategory) {
                                        setModalState(() { currentDropdownCategory = newValue; });
                                        _updateCategory(item['id'], newValue); 
                                      }
                                    },
                                  ),
                                ),
                              )
                            else 
                              Text(item['titleStr'] ?? _getCategoryTitle(rawCat), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: showAsRed ? Colors.red : (isDark ? Colors.white : Colors.black87))),
                            
                            const SizedBox(height: 4),
                            Text(item['timeStr'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30),

                  Text('desc_label'.tr(), style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                    child: Text(item['description']?.toString() ?? 'desc_empty'.tr(), style: const TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 20),

                  Text('loc_exact'.tr(), style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item['locStr'] ?? 'loc_unknown'.tr(), style: const TextStyle(fontSize: 15))),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const SizedBox(height: 20),

                  if ((imageUrl != null && imageUrl.isNotEmpty && imageUrl != 'null') || !(isSystemCritical || isUserUrgent)) ...[
                    Text('photo_added'.tr(), style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
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
                        child: Column(
                          children: [
                            Icon(Icons.image_not_supported, color: Colors.grey.shade400, size: 40),
                            const SizedBox(height: 8),
                            Text('photo_not_added'.tr(), style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                          ],
                        ),
                      ),
                    const SizedBox(height: 30),
                  ],

                  if (isAssigned) ...[
                    Text('inst_assigned'.tr(), style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
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
                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800),
                        onPressed: () { Navigator.pop(ctx); _showAssignmentDialog(context, item); },
                        icon: const Icon(Icons.send, color: Colors.white),
                        label: Text('btn_assign_team'.tr(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    )
                  else if (rawStatus == 'IN_PROGRESS')
                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600),
                        onPressed: () { Navigator.pop(ctx); _markAsResolved(item['id']); },
                        icon: const Icon(Icons.build, color: Colors.white),
                        label: Text('btn_mark_resolved'.tr(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
          );
        }
      ),
    );
  }

  String _getCategoryTitle(String category) {
    String key = category.trim().toUpperCase().replaceAll('İ', 'I').replaceAll('Ğ', 'G').replaceAll('Ç', 'C').replaceAll('Ş', 'S').replaceAll('Ö', 'O').replaceAll('Ü', 'U');
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

  String _formatDate(dynamic dateData) {
    if (dateData == null) return '';
    try {
      final date = DateTime.parse(dateData.toString()).toLocal();
      return '${date.day}.${date.month} ${date.hour}:${date.minute}';
    } catch (e) { return ''; }
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
              if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('logout'.tr(), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTrailingWidget(Map<String, dynamic> task, bool showAsRed) {
    if (task['status'] == 'PENDING') {
      return ElevatedButton(
        onPressed: () => _showAssignmentDialog(context, task), 
        style: ElevatedButton.styleFrom(backgroundColor: showAsRed ? Colors.red.shade700 : Colors.orange),
        child: Text('btn_assign_team'.tr(), style: const TextStyle(color: Colors.white, fontSize: 10)),
      );
    } else if (task['status'] == 'IN_PROGRESS') {
      return ElevatedButton.icon(
        onPressed: () => _markAsResolved(task['id']), 
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600),
        icon: const Icon(Icons.build, color: Colors.white, size: 14),
        label: Text('btn_mark_resolved'.tr(), style: const TextStyle(color: Colors.white, fontSize: 10)),
      );
    } else {
      return const Icon(Icons.check_circle, color: Colors.green, size: 32);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark; 
    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
      appBar: AppBar(
        title: Text('employee_app_bar_title'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange.shade800,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          tabs: [
            Tab(icon: const Icon(Icons.engineering), text: 'employee_tab_standard'.tr()),
            Tab(icon: const Icon(Icons.list_alt), text: 'admin_tab_live'.tr()),
          ],
        ),
      ),
      drawer: Drawer(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.orange.shade800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                   const CircleAvatar(radius: 30, backgroundColor: Colors.white, child: Icon(Icons.engineering, size: 35, color: Colors.orange)),
                   const SizedBox(height: 10),
                  Text('employee_app_bar_title'.tr(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),                ],
              ),
            ),
            ListTile(leading: const Icon(Icons.person, color: Colors.blue), title: Text('prof_title'.tr()), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())); }),
            ListTile(leading: const Icon(Icons.settings, color: Colors.grey), title: Text('settings_title'.tr()), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())); }),
            const Divider(),
            ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: Text('logout'.tr()), onTap: () { Navigator.pop(context); _showLogoutConfirmDialog(context); }),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView(
            padding: const EdgeInsets.all(12),
            children: [
              ..._formalTasks.map((t) => Card(
                color: isDark ? Colors.grey.shade800 : Colors.white,
                child: ListTile(
                  leading: Icon(t['icon'] as IconData, color: t['color'] as Color),
                  title: Text(t['title'].toString().tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(t['loc'].toString().tr()),
                ),
              )),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  _tabController.animateTo(1);
                  setState(() { _onlyUrgent = true; });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
                icon: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
                label: Text('admin_go_urgent'.tr(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
            ],
          ),
          
          Column(
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
                            decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), labelText: 'filter_status'.tr()),
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
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), labelText: 'filter_inst'.tr()),
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
                      title: Text('admin_filter_urgent_only'.tr(), style: TextStyle(fontWeight: FontWeight.bold, color: _onlyUrgent ? Colors.red : null)),
                      secondary: Icon(Icons.emergency, color: _onlyUrgent ? Colors.red : Colors.grey),
                      value: _onlyUrgent,
                      activeColor: Colors.red,
                      onChanged: (val) => setState(() => _onlyUrgent = val),
                    )
                  ],
                ),
              ),
              
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _fetchData(),
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _combinedTasksFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Gösterilecek şikayet yok."));
                      
                      List<Map<String, dynamic>> allTasks = snapshot.data!;
                      
                      List<Map<String, dynamic>> filteredTasks = allTasks.where((task) {
                        String currentInstRaw = task['assignedInstitution']?.toString() ?? '';
                        String currentInst = currentInstRaw.toUpperCase().replaceAll('INST_', '');
                        if (currentInst.isEmpty) currentInst = 'ATANMADI';

                        if (_onlyUrgent && task['isUrgent'] != true) return false;
                        if (_statusFilter == 'YENİ' && task['status'] != 'PENDING') return false;
                        if (_statusFilter == 'İŞLEMDE' && task['status'] != 'IN_PROGRESS') return false;
                        if (_statusFilter == 'ÇÖZÜLENLER' && task['status'] != 'RESOLVED' && task['status'] != 'COMPLETED') return false;
                        
                        if (_instFilter != 'TÜMÜ') {
                          List<String> stdInst = ['FEN_ISLERI', 'TEDAS', 'ASKI', 'ZABITA', 'TEMIZLIK', 'EMNIYET', 'UKOME', 'PARK_BAHCE', 'ATANMADI'];
                          if (_instFilter == 'DIGER') {
                            if (stdInst.contains(currentInst)) return false; 
                          } else {
                            if (currentInst != _instFilter) return false; 
                          }
                        }
                        
                        return true;
                      }).toList();

                      // KRONOLOJİK SIRALAMA (EN YENİ EN ÜSTTE)
                      filteredTasks.sort((a, b) {
                        DateTime dateA = DateTime.tryParse(a['createdAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
                        DateTime dateB = DateTime.tryParse(b['createdAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
                        return dateB.compareTo(dateA);
                      });

                      if (filteredTasks.isEmpty) return Center(child: Text('admin_no_match'.tr(), style: const TextStyle(color: Colors.grey)));

                      return ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          
                          String rawStatus = task['status']?.toString().toUpperCase() ?? 'PENDING';
                          String assignedTo = task['assignedInstitution']?.toString().toUpperCase().replaceAll('INST_', '') ?? '';

                          String rawCat = task['categoryRaw']?.toString().toUpperCase() ?? '';
                          String normalizedCatList = rawCat.replaceAll('İ', 'I').replaceAll('Ğ', 'G').replaceAll('Ç', 'C').replaceAll('Ş', 'S').replaceAll('Ö', 'O').replaceAll('Ü', 'U').trim();
                          
                          bool isSystemCritical = ['YANGIN', 'GAZ KACAGI', 'SU PATLAGI', 'ELEKTRIK ARIZASI', 'YOL COKMESI'].contains(normalizedCatList);
                          bool isUserUrgent = task['isUrgent'] == true;

                          bool showAsRed = isSystemCritical || isUserUrgent;
                          
                          bool isAssigned = assignedTo.isNotEmpty && assignedTo != 'ATANMADI' && assignedTo != 'PENDING' && assignedTo != 'STATUS_PENDING' && assignedTo != 'NULL';

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
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _showReportDetails(context, task, isDark),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: showAsRed ? Colors.red : Colors.orange.shade100,
                                      child: Icon(showAsRed ? Icons.warning : Icons.campaign, color: showAsRed ? Colors.white : Colors.orange),
                                    ),
                                    title: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(task['titleStr']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text("${task['locStr']}\n${task['timeStr']}"),
                                    ),
                                    trailing: _buildTrailingWidget(task, showAsRed),
                                  ),
                                  if (isAssigned && rawStatus != 'PENDING')
                                    Padding(
                                      padding: const EdgeInsets.only(left: 72, bottom: 12, right: 16),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                          child: Text(
                                            "${'inst_label'.tr()}: ${_getInstitutionName(assignedTo)}", 
                                            style: const TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}