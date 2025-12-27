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
  Badge(
    'İlk Adım',
    'İlk şikayet raporunuzu başarıyla gönderdiniz.',
    Icons.star,
    true, // Kazanıldı
    Colors.amber,
  ),
  Badge(
    'Mahalle Gözcüsü',
    'Toplam 5 sorunu başarıyla bildirdiniz.',
    Icons.visibility,
    true, // Kazanıldı
    Colors.green,
  ),
  Badge(
    'Çözüm Elçisi',
    'Bildirdiğiniz 10 sorun başarıyla çözüldü.',
    Icons.check_circle,
    false, // Henüz kazanılmadı
    Colors.grey,
  ),
  Badge(
    'Katılımcı Vatandaş',
    '3 farklı ankete/öneriye katkıda bulundunuz.',
    Icons.poll,
    true, // Kazanıldı
    Colors.blue,
  ),
  Badge(
    'Uzman Gözlemci',
    'Farklı kategorilerde 20 sorun bildirin.',
    Icons.workspace_premium,
    false, // Henüz kazanılmadı
    Colors.brown,
  ),
];

// Performans ve Rozetler Ekranı
class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({Key? key}) : super(key: key);

  // Sabit Renkler
  static const Color accentPurple = Color(0xFF9C27B0);
  static const Color primaryBlue = Color(0xFF4094FF);

  // Puan ve Seviye Başlık Alanını Oluşturan Widget
  Widget _buildPerformanceHeader(BuildContext context, int currentPoints, int currentLevel, double progressToNextLevel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: primaryBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Genel Performans Puanınız',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currentPoints Puan',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryBlue),
              ),
              Chip(
                // Burada 'const' Text OLAMAZ çünkü currentLevel parametreden geliyor.
                label: Text('Seviye $currentLevel', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                backgroundColor: accentPurple,
              ),
            ],
          ),
          const SizedBox(height: 15),
          
          // Seviye İlerleme Çubuğu
          const Text( // Buradaki Text const olabilir çünkü içindeki metin sabit
             'Bir sonraki seviyeye kalan ilerleme',
             style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 5),
          LinearProgressIndicator(
            value: progressToNextLevel,
            backgroundColor: Colors.grey.shade300,
            color: Colors.green, // İlerleme rengi
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          
          const SizedBox(height: 5),
          Text(
            '${(progressToNextLevel * 100).toStringAsFixed(0)}%',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Tek bir Rozet Kartını Oluşturan Widget
  Widget _buildBadgeCard(Badge badge) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: badge.color.withOpacity(badge.unlocked ? 0.3 : 0.1),
              child: Icon(
                badge.icon,
                size: 30,
                color: badge.unlocked ? badge.color : Colors.grey.shade400,
              ),
            ),
            if (!badge.unlocked)
              const Positioned(
                bottom: 0,
                right: 0,
                child: Icon(Icons.lock, color: Colors.black54, size: 18),
              ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          badge.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: badge.unlocked ? Colors.black87 : Colors.grey,
          ),
        ),
        Tooltip(
          message: badge.description,
          child: Icon(Icons.info_outline, size: 12, color: Colors.grey.shade400),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // DÜZELTME BURADA: 'const' yerine 'final' kullanıyoruz.
    // Bu, "Invalid constant value" hatasını kesin olarak çözer.
    final int currentPoints = 850;
    final int currentLevel = 4;
    final double progressToNextLevel = 0.65;
    
    // Rozet sayılarının hesaplanması
    final int unlockedCount = dummyBadges.where((b) => b.unlocked).length;
    final int totalCount = dummyBadges.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performans ve Rozetler', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. GENEL PERFORMANS (Puan ve Seviye)
            _buildPerformanceHeader(context, currentPoints, currentLevel, progressToNextLevel),
            const SizedBox(height: 30),

            // 2. ROZETLER BAŞLIĞI
            Text(
              'Kazanılan Rozetler ($unlockedCount/$totalCount)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryBlue),
            ),
            const Divider(height: 15, thickness: 1),

            // 3. ROZETLER LISTESI
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: totalCount,
              itemBuilder: (context, index) {
                return _buildBadgeCard(dummyBadges[index]);
              },
            ),
            
            const SizedBox(height: 30),
            
            // 4. LİDERLİK TABLOSU BUTONU
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  print('Liderlik Tablosu açılıyor');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.leaderboard),
                label: const Text(
                  'Liderlik Tablosunu Gör',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}