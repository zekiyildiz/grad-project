import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; 
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';

// BİLGİ KARTI
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
      color: isDark ? Colors.grey.shade900 : Colors.white, // DİNAMİK ARKA PLAN
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(icon, color: Colors.blue, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      // KARANLIK MODDA BEYAZ YAPTIK Kİ OKUNSUN!
                      color: isDark ? Colors.white : const Color(0xFF343A40), 
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// İSTATİSTİK KARTI
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
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey.shade300 : const Color(0xFF343A40),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            count,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color),
          ),
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (authProvider.isAuthenticated) {
      await userProvider.fetchProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    final user = authProvider.user ?? userProvider.profile;
    
    final String adSoyad = user?.displayName ?? 'prof_guest_user'.tr();
    final String eposta = user?.email ?? 'prof_not_logged_in'.tr();
    final String telefon = user?.phone ?? 'prof_not_specified'.tr();
    final String lokasyon = user?.fullLocation.isNotEmpty == true ? user!.fullLocation : 'prof_not_specified'.tr();
    
    const String sikayetSayisi = '0';
    const String cozulenSayisi = '0';
    const String anketSayisi = '0';
    
    const Color accentPurple = Color(0xFF9C27B0);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('prof_title'.tr(), style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4094FF),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (authProvider.isAuthenticated)
            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadProfile, tooltip: 'prof_refresh'.tr()),
        ],
      ),
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (userProvider.errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.red.withOpacity(0.1) : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade700),
                            const SizedBox(width: 8),
                            Expanded(child: Text(userProvider.errorMessage!, style: TextStyle(color: Colors.red.shade700))),
                          ],
                        ),
                      ),
                    
                    if (!authProvider.isAuthenticated)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.blue.withOpacity(0.1) : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade700, size: 32),
                            const SizedBox(height: 8),
                            Text('prof_login_prompt'.tr(), style: TextStyle(color: Colors.blue.shade700), textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    
                    Text('prof_personal_info'.tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                    const Divider(height: 15, thickness: 1),

                    InfoCard(icon: Icons.person, title: 'prof_name'.tr(), subtitle: adSoyad),
                    InfoCard(icon: Icons.email, title: 'prof_email'.tr(), subtitle: eposta),
                    InfoCard(icon: Icons.phone, title: 'prof_phone'.tr(), subtitle: telefon),
                    InfoCard(icon: Icons.location_on, title: 'prof_location'.tr(), subtitle: lokasyon),
                    
                    const SizedBox(height: 30),

                    Text('prof_stats'.tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                    const Divider(height: 15, thickness: 1),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        StatCard(icon: Icons.report_problem, label: 'prof_total_complaints'.tr(), count: sikayetSayisi, color: Colors.red.shade700),
                        StatCard(icon: Icons.check_circle, label: 'prof_resolved'.tr(), count: cozulenSayisi, color: Colors.green.shade700),
                        StatCard(icon: Icons.description, label: 'prof_surveys'.tr(), count: anketSayisi, color: accentPurple),
                      ],
                    ),

                    const SizedBox(height: 50),

                    if (authProvider.isAuthenticated)
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: () { _showEditProfileDialog(context); },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentPurple,
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

  void _showEditProfileDialog(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = userProvider.profile ?? authProvider.user;
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
              TextField(
                controller: nameController, 
                decoration: InputDecoration(labelText: 'prof_name'.tr(), prefixIcon: const Icon(Icons.person)),
                style: TextStyle(color: isDark ? Colors.white : Colors.black)
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController, 
                decoration: InputDecoration(labelText: 'prof_phone'.tr(), prefixIcon: const Icon(Icons.phone)), 
                keyboardType: TextInputType.phone,
                style: TextStyle(color: isDark ? Colors.white : Colors.black)
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController, 
                decoration: InputDecoration(labelText: 'prof_address'.tr(), prefixIcon: const Icon(Icons.home)), 
                maxLines: 2,
                style: TextStyle(color: isDark ? Colors.white : Colors.black)
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('prof_cancel'.tr())),
          ElevatedButton(
            onPressed: () async {
              final success = await userProvider.updateProfile(name: nameController.text.trim(), phone: phoneController.text.trim(), address: addressController.text.trim());
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('prof_update_success'.tr()), backgroundColor: Colors.green));
              } else if (context.mounted && userProvider.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(userProvider.errorMessage!), backgroundColor: Colors.red));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4094FF)),
            child: Text('prof_save'.tr(), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}