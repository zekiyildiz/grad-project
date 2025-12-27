import 'package:flutter/material.dart';

// Basit bir anket kartı için model (Gerçek veritabanı bağlantısı Aşama 3'te yapılacak)
class PollItem {
  final String title;
  final String status;
  final Color statusColor;
  final double progress;

  PollItem(this.title, this.status, this.statusColor, this.progress);
}

final List<PollItem> dummyPolls = [
  PollItem("Mahallemizdeki Yeşil Alanlar Yeterli mi?", "Aktif", Colors.green, 0.65),
  PollItem("Toplu Taşıma Saatleri Düzenlemesi", "Son 2 Gün", Colors.blue, 0.80),
  PollItem("Kültür Etkinlikleri Önceliği", "Tamamlandı", Colors.grey, 1.0),
];

class SurveyScreen extends StatelessWidget {
  const SurveyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Öneri ve Anketler'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Yeni Öneri Alanı Başlığı
            const Text(
              "Görüşünüz Önemli!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              "Hizmetler ve projeler için bize yapısal önerilerinizi iletin.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 15),

            // 2. Yeni Öneri Giriş Kutusu
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Yeni Bir Öneri Gönderin", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                  const SizedBox(height: 10),
                  const TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Önerinizi detaylıca yazın...',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Öneri gönderme API çağrısı buraya gelecek
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Öneriniz başarıyla kaydedildi!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.send),
                      label: const Text('Gönder'),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),

            // 3. Aktif Anketler Başlığı
            const Text(
              "Aktif Anketler (Oylamaya Katılın)",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // 4. Anket Kartları Listesi
            ...dummyPolls.map((poll) {
              return PollCard(poll: poll);
            }).toList(),
          ],
        ),
      ),
    );
  }
}

// Tekrar kullanılabilir Anket Kartı Widget'ı
class PollCard extends StatelessWidget {
  final PollItem poll;
  const PollCard({Key? key, required this.poll}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          poll.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            LinearProgressIndicator(
              value: poll.progress, // İlerleme (0.0 ile 1.0 arası)
              backgroundColor: Colors.grey.shade300,
              color: poll.statusColor,
            ),
            const SizedBox(height: 5),
            Text(
              "Durum: ${poll.status}",
              style: TextStyle(color: poll.statusColor, fontSize: 12),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Anket detay sayfasına yönlendirme (Oylama yapmak için)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${poll.title} için oylama ekranı açılıyor.')),
          );
        },
      ),
    );
  }
}