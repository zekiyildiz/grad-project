import 'package:flutter/material.dart';

// Helper widget for drawing clean and actionable contact cards
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
        onTap: onTap, // Tıklandığında yapılacak eylem
      ),
    );
  }
}

class ContactScreen extends StatelessWidget {
  const ContactScreen({Key? key}) : super(key: key);

  // Bu fonksiyonlar ileride telefon/harita uygulamalarını açmak için kullanılacaktır
  void launchUrl(String url) {
    // Gerçek projede 'url_launcher' paketi kullanılarak link/telefon açılır.
    print('Aksiyon: $url açıldı');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İletişim ve Destek'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. İletişim Kanalları Başlığı
            const Text(
              "Bize Ulaşın (7/24 Destek)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF343A40)),
            ),
            const SizedBox(height: 10),

            // 2. İletişim Kartları
            ContactCard(
              title: "Çağrı Merkezi (Mavi Masa)",
              subtitle: "7/24 Sorun Bildirimi ve Bilgi",
              icon: Icons.call,
              iconColor: Colors.blue,
              onTap: () => launchUrl('tel:153'), // Örn: 153'ü arama
            ),
            ContactCard(
              title: "E-Posta (Yazılı Destek)",
              subtitle: "Geri bildirim ve detaylı sorularınız",
              icon: Icons.email,
              iconColor: Colors.green,
              onTap: () => launchUrl('mailto:destek@belediye.gov.tr'),
            ),
            ContactCard(
              title: "Merkez Adres",
              subtitle: "Belediye binası ve ana hizmet noktası (Haritada Gör)",
              icon: Icons.location_on,
              iconColor: Colors.grey,
              onTap: () => launchUrl('map://belediye_adres'),
            ),
            
            const SizedBox(height: 30),
            
            // 3. Sosyal Medya Başlığı
            const Text(
              "Bizi Takip Edin",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF343A40)),
            ),
            const SizedBox(height: 15),

            // 4. Sosyal Medya İkonları (Horizontal List)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildSocialIcon(Icons.thumb_up, 'Facebook', Colors.blue.shade700),
                buildSocialIcon(Icons.camera_alt, 'Instagram', Colors.purple),
                buildSocialIcon(Icons.play_circle_fill, 'YouTube', Colors.red),
              ],
            ),

            const SizedBox(height: 50),
            
            // 5. Uygulama Versiyonu
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

  // Helper function to build the clickable social icons
  Widget buildSocialIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        InkWell(
          onTap: () => launchUrl('social://${label.toLowerCase()}'),
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