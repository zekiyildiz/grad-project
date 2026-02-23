import 'package:flutter/material.dart';

// Simüle Edilen Rozet Veri Modeli
class Badge {
  final String name;
  final String description;
  final IconData icon;
  final bool unlocked;
  final Color color;

  const Badge(this.name, this.description, this.icon, this.unlocked, this.color);
}

// Simüle Edilen Rozet Listesi
const List<Badge> dummyBadges = [
  Badge('İlk Adım', 'İlk şikayet raporunuzu başarıyla gönderdiniz.', Icons.star, true, Colors.amber),
  Badge('Mahalle Gözcüsü', 'Toplam 5 sorunu başarıyla bildirdiniz.', Icons.visibility, true, Colors.green),
  Badge('Çözüm Elçisi', 'Bildirdiğiniz 10 sorun başarıyla çözüldü.', Icons.check_circle, false, Colors.grey),
  Badge('Katılımcı Vatandaş', '3 farklı ankete/öneriye katkıda bulundunuz.', Icons.poll, true, Colors.blue),
  Badge('Uzman Gözlemci', 'Farklı kategorilerde 20 sorun bildirin.', Icons.workspace_premium, false, Colors.brown),
];

class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({Key? key}) : super(key: key);

  static const Color primaryBlue = Color(0xFF4094FF);

  // PUAN ALANI - Sadece Puan ve Açıklama
  Widget _buildPointsHeader(int currentPoints) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue, primaryBlue.withOpacity(0.8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          const Text(
            'Toplam Performans Puanınız',
            style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Text(
            '$currentPoints',
            style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Şehriniz için değer üretiyorsunuz!',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ROZET KARTI
  Widget _buildBadgeCard(Badge badge) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 75,
          height: 75,
          decoration: BoxDecoration(
            color: badge.unlocked ? badge.color.withOpacity(0.12) : Colors.grey.shade100,
            shape: BoxShape.circle,
            border: Border.all(
              color: badge.unlocked ? badge.color : Colors.grey.shade300,
              width: 2.5,
            ),
          ),
          child: Icon(
            badge.unlocked ? badge.icon : Icons.lock_outline,
            size: 32,
            color: badge.unlocked ? badge.color : Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          badge.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: badge.unlocked ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
            color: badge.unlocked ? Colors.black87 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final int currentPoints = 850;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performans ve Rozetler', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPointsHeader(currentPoints),
            
            const SizedBox(height: 40),

            const Text(
              'Rozet Koleksiyonunuz',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 24),

            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 30,
                childAspectRatio: 0.75,
              ),
              itemCount: dummyBadges.length,
              itemBuilder: (context, index) {
                return _buildBadgeCard(dummyBadges[index]);
              },
            ),
          ],
        ),
      ),
    );
  }
}