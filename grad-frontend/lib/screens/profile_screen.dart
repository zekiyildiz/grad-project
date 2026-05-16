import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; 
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../services/report_service.dart';
import 'edit_profile_screen.dart';

/// Independent “Reusable” widget classes were created for cards with the same design in the UI layer
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
            Text(title, style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,fontWeight: FontWeight.bold)),
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, size: 45, color: color), 
          const SizedBox(height: 8),
          
          // FOR ALIGNMENT: The text section expands and pushes the numbers to the bottom
          Expanded(
            child: Container(
              alignment: Alignment.center, // Center the single-line text vertically
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label, 
                  textAlign: TextAlign.center, 
                  maxLines: 2, 
                  style: TextStyle(
                    fontSize: 13, 
                    fontWeight: FontWeight.bold, 
                    height: 1.1, 
                    color: isDark ? Colors.grey.shade300 : const Color(0xFF343A40)
                  )
                ),
              ),
            ),
          ),
          
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

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (authProvider.isAuthenticated) {
      await userProvider.fetchProfile(); 
    }

    final authUser = authProvider.user;
    final profile = userProvider.profile;
    
    // Checks whether the profile data retrieved via the session (Auth) matches. This is a security measure 
    //to prevent the old user, whose data remains in RAM, from appearing in the UI if the user has switched accounts.
    bool isStale = (profile != null && authUser != null && profile.email != authUser.email);
    final activeProfile = isStale ? null : profile;

    bool isEmployee = (activeProfile?.role?.toUpperCase() == 'EMPLOYEE' || activeProfile?.role?.toUpperCase() == 'ADMIN') || 
                      (authUser?.role?.toUpperCase() == 'EMPLOYEE' || authUser?.role?.toUpperCase() == 'ADMIN');
    
    try {
      if (isEmployee) {
        final allReports = await _reportService.getAllReports();
        _totalCount = allReports.length;
        _resolvedCount = allReports.where((r) => r['status'] == 'RESOLVED').length;
        _pollValue = 450; 
      } else {
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

  String _formatPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return 'prof_not_specified'.tr();
    String p = phone.replaceAll(' ', '');
    if (p.startsWith('+90') && p.length == 13) {
      return '+90 ${p.substring(3, 6)} ${p.substring(6, 9)} ${p.substring(9, 11)} ${p.substring(11, 13)}';
    }
    return phone; 
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    final authUser = authProvider.user;
    final profile = userProvider.profile;

    bool isStale = (profile != null && authUser != null && profile.email != authUser.email);
    final activeProfile = isStale ? null : profile;

    String currentEmail = authUser?.email ?? activeProfile?.email ?? '';
    
    ProfileSessionCache.checkUser(currentEmail);

    bool isEmployee = (activeProfile?.role?.toUpperCase() == 'EMPLOYEE' || activeProfile?.role?.toUpperCase() == 'ADMIN') || 
                      (authUser?.role?.toUpperCase() == 'EMPLOYEE' || authUser?.role?.toUpperCase() == 'ADMIN');

    String displayAddress = '';
    if (ProfileSessionCache.address != null && ProfileSessionCache.address!.trim().isNotEmpty) {
      displayAddress = ProfileSessionCache.address!;
    } else if (activeProfile?.address != null && activeProfile!.address!.isNotEmpty) {
      displayAddress = activeProfile.address!;
    } else {
      displayAddress = activeProfile?.fullLocation ?? '';
    }

    if (displayAddress.trim().isEmpty) {
      displayAddress = 'prof_not_specified'.tr(); 
    }

    String displayName = '';
    if (ProfileSessionCache.name != null && ProfileSessionCache.name!.trim().isNotEmpty) {
      displayName = ProfileSessionCache.name!;
    } else if (activeProfile?.name != null && activeProfile!.name!.isNotEmpty) {
      displayName = activeProfile.name!;
    } else {
      displayName = authUser?.displayName ?? 'prof_guest_user'.tr();
    }

    String rawPhone = '';
    if (ProfileSessionCache.phone != null && ProfileSessionCache.phone!.trim().isNotEmpty) {
      rawPhone = ProfileSessionCache.phone!;
    } else if (activeProfile?.phone != null && activeProfile!.phone!.isNotEmpty) {
      rawPhone = activeProfile.phone!;
    } else {
      rawPhone = authUser?.phone ?? '';
    }
    
    String displayEmail = currentEmail.isNotEmpty ? currentEmail : 'prof_not_logged_in'.tr();

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
                    Text('prof_personal_info'.tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                    const Divider(height: 15, thickness: 1),

                    InfoCard(icon: Icons.person, title: 'prof_name'.tr(), subtitle: displayName),
                    InfoCard(icon: Icons.email, title: 'prof_email'.tr(), subtitle: displayEmail),
                    InfoCard(icon: Icons.phone, title: 'prof_phone'.tr(), subtitle: _formatPhoneNumber(rawPhone)), 
                    InfoCard(icon: Icons.location_on, title: 'prof_location'.tr(), subtitle: displayAddress),
                    
                    const SizedBox(height: 30),

                    Text('prof_stats'.tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                    const Divider(height: 15, thickness: 1),
                    
                    // We used `IntrinsicHeight` to make all cards the same height
                    IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.stretch, // Force them all to the same size
                        children: [
                          StatCard(icon: Icons.report_problem, label: isEmployee ? 'prof_stat_total'.tr() : 'prof_total_complaints'.tr(), count: _totalCount.toString(), color: Colors.red.shade700),
                          StatCard(icon: Icons.check_circle, label: 'prof_resolved'.tr(), count: _resolvedCount.toString(), color: Colors.green.shade700),
                          StatCard(icon: isEmployee ? Icons.analytics : Icons.description, label: isEmployee ? 'prof_stat_polls_manage'.tr() : 'prof_surveys'.tr(), count: _pollValue.toString(), color: const Color(0xFF9C27B0)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),

                    if (authProvider.isAuthenticated)
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (context) => EditProfileScreen(
                                  initialName: displayName,
                                  initialEmail: displayEmail,
                                  initialPhone: rawPhone,
                                  initialAddress: displayAddress,
                                )
                              )
                            );
                            
                            setState(() {}); 
                            _loadData(); 
                          },
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
}