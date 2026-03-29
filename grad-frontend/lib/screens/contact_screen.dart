import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // PAKETİ İÇERİ ALDIK

// Temiz ve tıklanabilir kart yapısı (Aynı Tasarım)
class ContactCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const ContactCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

class ContactScreen extends StatelessWidget {
  const ContactScreen({Key? key}) : super(key: key);

  // LİNK, TELEFON VEYA MAİL AÇAN ANA FONKSİYON
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        // externalApplication modu, uygulamayı (WhatsApp, Maps vb.) dışarıda açar
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Hata: $url adresi açılamadı.');
      }
    } catch (e) {
      debugPrint('Sistem Hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İletişim ve Destek', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bize Ulaşın (7/24 Destek)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF343A40)),
            ),
            const SizedBox(height: 10),

            // 1. ÇAĞRI MERKEZİ (153)
            ContactCard(
              title: "Çağrı Merkezi (Mavi Masa)",
              subtitle: "7/24 Sorun Bildirimi ve Bilgi",
              icon: Icons.call,
              iconColor: Colors.blue,
              onTap: () => _launchURL('tel:153'),
            ),

            // 2. E-POSTA
            ContactCard(
              title: "E-Posta (Yazılı Destek)",
              subtitle: "Geri bildirim ve detaylı sorularınız",
              icon: Icons.email,
              iconColor: Colors.green,
              onTap: () => _launchURL('mailto:mavi-masa@ankara.bel.tr'),
            ),

            // 3. ADRES (Google Haritalar Konumu)
            ContactCard(
              title: "Merkez Adres",
              subtitle: "Emniyet Mh. Hipodrom Cd. No:5 Yenimahalle",
              icon: Icons.location_on,
              iconColor: Colors.red.shade400,
              onTap: () => _launchURL('https://www.google.com/maps/search/?api=1&query=39.939318,32.839351'),
            ),
            
            const SizedBox(height: 30),
            
            const Text(
              "Bizi Takip Edin",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF343A40)),
            ),
            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildSocialIcon(Icons.facebook, 'Facebook', Colors.blue.shade700, 'https://www.facebook.com/ankarabbld'),
                buildSocialIcon(Icons.camera_alt, 'Instagram', Colors.purple, 'https://instagram.com/ankarabbld'),
                buildSocialIcon(Icons.play_circle_fill, 'YouTube', Colors.red, 'https://youtube.com/ankarabbld'),
              ],
            ),

            const SizedBox(height: 50),
            
            Center(
              child: Text(
                "Akıllı Belediye Uygulaması v1.0.0 (MVP)",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SOSYAL MEDYA BUTON YAPISI
  Widget buildSocialIcon(IconData icon, String label, Color color, String url) {
    return Column(
      children: [
        InkWell(
          onTap: () => _launchURL(url),
          child: CircleAvatar(
            radius: 25,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 30),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}