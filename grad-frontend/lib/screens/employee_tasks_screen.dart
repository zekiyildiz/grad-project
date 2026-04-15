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
        
        // Fotoğraf URL'sini akıllıca yakala
        String? imageUrl;
        if (report['imageUrls'] != null && report['imageUrls'] is List && report['imageUrls'].isNotEmpty) {
          imageUrl = report['imageUrls'][0].toString(); // Vatandaş uygulamasından gelen dizi formatı
        } else if (report['images'] != null && report['images'] is List && report['images'].isNotEmpty) {
          imageUrl = report['images'][0].toString(); // Alternatif dizi formatı
        } else if (report['imageUrl'] != null) {
          imageUrl = report['imageUrl'].toString(); // Tekil URL formatı
        } else if (report['image'] != null) {
          imageUrl = report['image'].toString(); // Alternatif isim
        } else if (report['image_url'] != null) {
          imageUrl = report['image_url'].toString(); // Backend/Acil formatı
        }

        // 🌟 DÜZELTME: isUrgent bilgisini hem boolean hem string olarak güvenle okuyoruz
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
          'assignedInstitution': report['assignedInstitution']?.toString().toUpperCase().replaceAll('INST_', '') ?? '', 
          'isUrgent': isUrgentFlag, // Artık kesinlikle doğru çalışacak
        });
      }
    } catch (e) { debugPrint("Fetch error: $e"); }
    return combinedList;
  }

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
      default: return 'inst_other'.tr();
    }
  }

  void _showAssignmentDialog(BuildContext context, Map<String, dynamic> task) {
    String currentSelection = _predictInstitution(task['categoryRaw'].toString());
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

  void _showEditCategoryDialog(BuildContext context, Map<String, dynamic> task, bool isDark) {
    String currentCat = task['categoryRaw'].toString();
    const validCategories = ['CUKUR', 'KIRIK_BANK', 'COPLUK', 'ELEKTRIK', 'TRAFIK', 'SCOOTER', 'POSTER', 'AGAC', 'DIGER'];
    if (!validCategories.contains(currentCat)) currentCat = 'DIGER';

    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          bool isUpdating = false; 

          return AlertDialog(
            backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text("btn_edit_category".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
            content: DropdownButtonFormField<String>(
              value: currentCat,
              dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: [
                DropdownMenuItem(value: 'CUKUR', child: Text('cat_pothole'.tr())),
                DropdownMenuItem(value: 'KIRIK_BANK', child: Text('cat_bench'.tr())),
                DropdownMenuItem(value: 'COPLUK', child: Text('cat_garbage'.tr())),
                DropdownMenuItem(value: 'ELEKTRIK', child: Text('cat_electric'.tr())),
                DropdownMenuItem(value: 'TRAFIK', child: Text('cat_traffic'.tr())),
                DropdownMenuItem(value: 'SCOOTER', child: Text('cat_scooter'.tr())),
                DropdownMenuItem(value: 'POSTER', child: Text('cat_poster'.tr())),
                DropdownMenuItem(value: 'AGAC', child: Text('cat_tree'.tr())),
                DropdownMenuItem(value: 'DIGER', child: Text('cat_other'.tr())),
              ],
              onChanged: isUpdating ? null : (val) => setDialogState(() => currentCat = val!),
            ),
            actions: [
              TextButton(
                onPressed: isUpdating ? null : () => Navigator.pop(ctx), 
                child: Text('cancel'.tr(), style: const TextStyle(color: Colors.grey))
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: isUpdating ? null : () async {
                  setDialogState(() => isUpdating = true); 
                  try {
                    await _reportService.updateReportCategory(task['id'], currentCat);
                    _fetchData(); 
                    if (context.mounted) {
                      Navigator.pop(ctx); 
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kategori başarıyla güncellendi!'), backgroundColor: Colors.green)
                      );
                    }
                  } catch (e) {
                    setDialogState(() => isUpdating = false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red)
                      );
                    }
                  }
                },
                child: isUpdating 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('home_edit_save'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          );
        },
      ),
    );
  }

  void _showReportDetails(BuildContext context, Map<String, dynamic> item, bool isDark) {
    String rawStatus = item['status']?.toString().toUpperCase() ?? 'PENDING';
    String assignedTo = item['assignedInstitution']?.toString() ?? '';
    String? imageUrl = item['imageUrl'];

    String rawCat = item['categoryRaw']?.toString().toUpperCase() ?? item['category']?.toString().toUpperCase() ?? '';

    bool isSystemCritical = ['YANGIN', 'GAZ KAÇAĞI', 'SU PATLAĞI', 'ELEKTRİK ARIZASI', 'YOL ÇÖKMESİ'].contains(rawCat);
    bool isUserUrgent = item['isUrgent'] == true || item['isUrgent'].toString() == 'true';

    bool showAsRed = (isSystemCritical || isUserUrgent) && rawStatus != 'RESOLVED';

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
                    backgroundColor: showAsRed ? Colors.red : Colors.orange.shade100,
                    radius: 25,
                    child: Icon(showAsRed ? Icons.warning : Icons.campaign, color: showAsRed ? Colors.white : Colors.orange),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['titleStr'] ?? _getCategoryTitle(rawCat), 
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: showAsRed ? Colors.red : (isDark ? Colors.white : Colors.black87))
                        ),
                        Text(item['timeStr'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                  // 🌟 ÇÖZÜM: Kategori Düzenleme Butonu Buraya Geri Döndü!
                  IconButton(
                    icon: Icon(Icons.edit, color: isDark ? Colors.white70 : Colors.grey.shade700, size: 28),
                    onPressed: () {
                      Navigator.pop(ctx); // Önce detay sayfasını kapatır
                      _showEditCategoryDialog(context, item, isDark); // Sonra düzenleme kutusunu açar
                    },
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

              // 🌟 GÜNCELLENEN FOTOĞRAF ALANI (ACİLSE VE FOTO YOKSA GİZLER)
              if (imageUrl != null && imageUrl.isNotEmpty && imageUrl != 'null' || !(isUserUrgent || isSystemCritical)) ...[
                Text('photo_added'.tr(), style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                if (imageUrl != null && imageUrl.isNotEmpty && imageUrl != 'null')
                  GestureDetector(
                    onTap: () {
                       // Resim büyütme diyaloğu kodu buraya gelecek
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

              if (assignedTo.isNotEmpty) ...[
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
      ),
    );
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

  String _getCategoryTitle(String category) {
    // 🌟 ÇÖZÜM: Türkçe karakterleri evrensel karakterlere çeviriyoruz
    String key = category.trim().toUpperCase()
        .replaceAll('İ', 'I').replaceAll('Ğ', 'G')
        .replaceAll('Ç', 'C').replaceAll('Ş', 'S')
        .replaceAll('Ö', 'O').replaceAll('Ü', 'U');
        
    switch (key) {
      case 'YANGIN': return 'cat_fire'.tr();
      case 'GAZ KACAGI': return 'cat_gas'.tr(); // 'Ç' ve 'Ğ' temizlendi
      case 'SU PATLAGI': return 'cat_water'.tr(); // 'Ğ' temizlendi
      case 'ELEKTRIK ARIZASI': return 'cat_electric_urgent'.tr(); // 'İ' temizlendi
      case 'YOL COKMESI': return 'cat_road_collapse'.tr(); // 'Ç' ve 'Ö' temizlendi
      case 'CUKUR': return 'cat_pothole'.tr();
      case 'COPLUK': return 'cat_garbage'.tr();
      case 'KIRIK_BANK': return 'cat_bench'.tr();
      case 'TRAFIK': return 'cat_traffic'.tr();
      case 'ELEKTRIK': return 'cat_electric'.tr();
      case 'SCOOTER': return 'cat_scooter'.tr();
      case 'POSTER': return 'cat_poster'.tr();
      case 'AGAC': return 'cat_tree'.tr();
      case 'DIGER': return 'cat_other'.tr(); // 🌟 "DİĞER" artık "DIGER" olarak yakalanacak
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

  Widget _buildTrailingWidget(Map<String, dynamic> task, bool isUrgent) {
    if (task['status'] == 'PENDING') {
      return ElevatedButton(
        onPressed: () => _showAssignmentDialog(context, task), 
        style: ElevatedButton.styleFrom(backgroundColor: isUrgent ? Colors.red.shade700 : Colors.orange),
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
                   CircleAvatar(radius: 30, backgroundColor: Colors.white, child: Icon(Icons.engineering, size: 35, color: Colors.orange)),
                   SizedBox(height: 10),
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
                        String currentInst = task['assignedInstitution']?.toString() ?? '';
                        if (currentInst.isEmpty) currentInst = 'ATANMADI';

                        if (_onlyUrgent && task['isUrgent'] != true) return false;
                        if (_statusFilter == 'YENİ' && task['status'] != 'PENDING') return false;
                        if (_statusFilter == 'İŞLEMDE' && task['status'] != 'IN_PROGRESS') return false;
                        if (_statusFilter == 'ÇÖZÜLENLER' && task['status'] != 'RESOLVED' && task['status'] != 'COMPLETED') return false;
                        if (_instFilter != 'TÜMÜ' && currentInst != _instFilter) return false;
                        
                        return true;
                      }).toList();

                      if (filteredTasks.isEmpty) {
                        return Center(child: Text('admin_no_match'.tr(), style: const TextStyle(color: Colors.grey)));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          
                          String rawStatus = task['status']?.toString().toUpperCase() ?? 'PENDING';
                          String assignedTo = task['assignedInstitution']?.toString() ?? '';

                          String rawCat = task['categoryRaw']?.toString().toUpperCase() ?? '';
                          bool isSystemCritical = ['YANGIN', 'GAZ KAÇAĞI', 'SU PATLAĞI', 'ELEKTRİK ARIZASI'].contains(rawCat);
                          bool isUserUrgent = task['isUrgent'] == true;

                          bool showAsRed = isSystemCritical || isUserUrgent;

                          String statusText = "";
                          Color statusColor = Colors.orange;

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
                                        // 🌟 VATANDAŞ ÖNCELİKLİ ETİKETİ
                                        if (isUserUrgent && !isSystemCritical && rawStatus != 'RESOLVED')
                                          Container(
                                            margin: const EdgeInsets.only(bottom: 4, top: 4),
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: Colors.orange.shade600, borderRadius: BorderRadius.circular(4)),
                                            child: Text('⚠️ ${"citizen_priority".tr()}', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),                                          ),
                                        Text(task['titleStr']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text("${task['locStr']}\n${task['timeStr']}"),
                                    ),
                                    trailing: _buildTrailingWidget(task, showAsRed),
                                  ),
                                  if (assignedTo.isNotEmpty)
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