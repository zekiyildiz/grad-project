import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; 
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../services/report_service.dart';

// --- BİLGİ KARTI BİLEŞENİ ---
class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const InfoCard({Key? key, required this.icon, required this.title, required this.subtitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: isDark ? Colors.grey.shade900 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(icon, color: Colors.blue, size: 24),
                const SizedBox(width: 10),
                Expanded(child: Text(subtitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF343A40)))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- İSTATİSTİK KARTI BİLEŞENİ ---
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String count;
  final Color color;

  const StatCard({Key? key, required this.icon, required this.label, required this.count, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 50, color: color),
          const SizedBox(height: 5),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.grey.shade300 : const Color(0xFF343A40))),
          const SizedBox(height: 5),
          Text(count, textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ReportService _reportService = ReportService();
  
  // İstatistik Değişkenleri
  int _totalCount = 0;
  int _resolvedCount = 0;
  int _pollValue = 0;
  bool _isStatsLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  // --- KRİTİK: ROL BAZLI VERİ ÇEKME MANTIĞI ---
  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (authProvider.isAuthenticated) {
      await userProvider.fetchProfile();
    }

    final user = authProvider.user ?? userProvider.profile;
    // DİKKAT: Veritabanındaki 'role' değerinin 'EMPLOYEE' veya 'ADMIN' olduğundan emin ol.
    bool isEmployee = user?.role?.toUpperCase() == 'EMPLOYEE' || user?.role?.toUpperCase() == 'ADMIN';
    
    try {
      if (isEmployee) {
        // --- BELEDİYE ÇALIŞANI: SİSTEMDEKİ TÜM ŞİKAYETLERİ SAY ---
        final allReports = await _reportService.getAllReports();
        _totalCount = allReports.length;
        _resolvedCount = allReports.where((r) => r['status'] == 'RESOLVED').length;
        
        // Şimdilik sistemdeki toplam ankete katılımı simüle ediyoruz (PollService gelince bağlanacak)
        _pollValue = 450; 
      } else {
        // --- VATANDAŞ: SADECE KENDİ ŞİKAYETLERİNİ SAY ---
        final myReports = await _reportService.getMyReports();
        _totalCount = myReports.length;
        _resolvedCount = myReports.where((r) => r['status'] == 'RESOLVED').length;
        _pollValue = 3; 
      }
    } catch (e) {
      debugPrint("İstatistik Yükleme Hatası: $e");
    }

    if (mounted) setState(() => _isStatsLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    final user = authProvider.user ?? userProvider.profile;
    bool isEmployee = user?.role?.toUpperCase() == 'EMPLOYEE' || user?.role?.toUpperCase() == 'ADMIN';

    return Scaffold(
      appBar: AppBar(
        title: Text('prof_title'.tr(), style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4094FF),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: (userProvider.isLoading || _isStatsLoading)
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- KİŞİSEL BİLGİLER ---
                    Text('prof_personal_info'.tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                    const Divider(height: 15, thickness: 1),

                    InfoCard(icon: Icons.person, title: 'prof_name'.tr(), subtitle: user?.displayName ?? 'prof_guest_user'.tr()),
                    InfoCard(icon: Icons.email, title: 'prof_email'.tr(), subtitle: user?.email ?? 'prof_not_logged_in'.tr()),
                    InfoCard(icon: Icons.phone, title: 'prof_phone'.tr(), subtitle: user?.phone ?? 'prof_not_specified'.tr()),
                    InfoCard(icon: Icons.location_on, title: 'prof_location'.tr(), subtitle: user?.fullLocation ?? 'prof_not_specified'.tr()),
                    
                    const SizedBox(height: 30),

                    // --- İSTATİSTİKLER ---
                    Text('prof_stats'.tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                    const Divider(height: 15, thickness: 1),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        StatCard(
                          icon: Icons.report_problem, 
                          // Belediye çalışanı ise 'Toplam Şikayet', Vatandaş ise 'Şikayetlerim'
                          label: isEmployee ? 'prof_stat_total'.tr() : 'prof_total_complaints'.tr(), 
                          count: _totalCount.toString(), 
                          color: Colors.red.shade700
                        ),
                        StatCard(
                          icon: Icons.check_circle, 
                          label: 'prof_resolved'.tr(), 
                          count: _resolvedCount.toString(), 
                          color: Colors.green.shade700
                        ),
                        StatCard(
                          // Belediye çalışanı ise 'Ankete Katılım Sayısı', Vatandaş ise 'Katıldığım Anketler'
                          icon: isEmployee ? Icons.analytics : Icons.description, 
                          label: isEmployee ? 'prof_stat_polls_manage'.tr() : 'prof_surveys'.tr(), 
                          count: _pollValue.toString(), 
                          color: const Color(0xFF9C27B0)
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),

                    // --- PROFİL DÜZENLEME BUTONU ---
                    if (authProvider.isAuthenticated)
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: () => _showEditProfileDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9C27B0),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.edit, size: 24),
                          label: Text('prof_edit_btn'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  // --- DÜZENLEME DİALOGU ---
  void _showEditProfileDialog(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.profile;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    final nameController = TextEditingController(text: user?.name ?? '');
    final phoneController = TextEditingController(text: user?.phone ?? '');
    final addressController = TextEditingController(text: user?.address ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        title: Text('prof_edit_btn'.tr()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'prof_name'.tr(), prefixIcon: const Icon(Icons.person))),
              const SizedBox(height: 16),
              TextField(controller: phoneController, decoration: InputDecoration(labelText: 'prof_phone'.tr(), prefixIcon: const Icon(Icons.phone)), keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              TextField(controller: addressController, decoration: InputDecoration(labelText: 'prof_address'.tr(), prefixIcon: const Icon(Icons.home)), maxLines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('prof_cancel'.tr())),
          ElevatedButton(
            onPressed: () async {
              await userProvider.updateProfile(name: nameController.text.trim(), phone: phoneController.text.trim(), address: addressController.text.trim());
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4094FF)),
            child: Text('prof_save'.tr(), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}