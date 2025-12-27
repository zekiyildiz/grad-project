import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';

// 1. Yardımcı Widget: Bilgi Kartı (Personal Information Card)
class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const InfoCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(icon, color: Colors.blue, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF343A40),
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

// 2. Yardımcı Widget: İstatistik Kartı (Statistics Card)
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String count;
  final Color color;

  const StatCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 50, color: color),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF343A40),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            count,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}


// ANA EKRAN: ProfileScreen
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch profile when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // If user is authenticated, try to fetch latest profile from API
    if (authProvider.isAuthenticated) {
      await userProvider.fetchProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    
    // Use auth provider user data (populated during login)
    // User provider is secondary (for future profile updates)
    final user = authProvider.user ?? userProvider.profile;
    
    // User data with fallbacks
    final String adSoyad = user?.displayName ?? 'Misafir Kullanıcı';
    final String eposta = user?.email ?? 'Giriş yapılmamış';
    final String telefon = user?.phone ?? 'Belirtilmemiş';
    final String lokasyon = user?.fullLocation.isNotEmpty == true 
        ? user!.fullLocation 
        : 'Belirtilmemiş';
    
    // Statistics (placeholder - will be fetched from API later)
    const String sikayetSayisi = '0';
    const String cozulenSayisi = '0';
    const String anketSayisi = '0';
    
    const Color accentPurple = Color(0xFF9C27B0);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4094FF),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (authProvider.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadProfile,
              tooltip: 'Yenile',
            ),
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
                    // Error message if any
                    if (userProvider.errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                userProvider.errorMessage!,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Login prompt if not authenticated
                    if (!authProvider.isAuthenticated)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade700, size: 32),
                            const SizedBox(height: 8),
                            Text(
                              'Profil bilgilerinizi görmek için giriş yapın',
                              style: TextStyle(color: Colors.blue.shade700),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    
                    // KİŞİSEL BİLGİLER BAŞLIĞI
                    const Text(
                      'Kişisel Bilgiler',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    const Divider(height: 15, thickness: 1),

                    // KİŞİSEL BİLGİLER KARTLARI
                    InfoCard(icon: Icons.person, title: 'Ad Soyad', subtitle: adSoyad),
                    InfoCard(icon: Icons.email, title: 'E-posta', subtitle: eposta),
                    InfoCard(icon: Icons.phone, title: 'Telefon', subtitle: telefon),
                    InfoCard(icon: Icons.location_on, title: 'Konum (İlçe/Mahalle)', subtitle: lokasyon),
                    
                    const SizedBox(height: 30),

                    // İSTATİSTİKLER BAŞLIĞI
                    const Text(
                      'İstatistikler',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    const Divider(height: 15, thickness: 1),
                    
                    // İSTATİSTİK KARTLARI
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        StatCard(
                          icon: Icons.report_problem, 
                          label: 'Toplam Şikayet', 
                          count: sikayetSayisi, 
                          color: Colors.red.shade700,
                        ),
                        StatCard(
                          icon: Icons.check_circle, 
                          label: 'Çözüldü', 
                          count: cozulenSayisi, 
                          color: Colors.green.shade700,
                        ),
                        StatCard(
                          icon: Icons.description, 
                          label: 'Katıldığı Anket', 
                          count: anketSayisi, 
                          color: accentPurple,
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),

                    // PROFİLİ DÜZENLE BUTONU
                    if (authProvider.isAuthenticated)
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showEditProfileDialog(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.edit, size: 24),
                          label: const Text(
                            'Profili Düzenle',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
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
    
    final nameController = TextEditingController(text: user?.name ?? '');
    final phoneController = TextEditingController(text: user?.phone ?? '');
    final addressController = TextEditingController(text: user?.address ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profili Düzenle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefon',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Adres',
                  prefixIcon: Icon(Icons.home),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await userProvider.updateProfile(
                name: nameController.text.trim(),
                phone: phoneController.text.trim(),
                address: addressController.text.trim(),
              );
              
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profil güncellendi'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (context.mounted && userProvider.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(userProvider.errorMessage!),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4094FF),
            ),
            child: const Text('Kaydet', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}