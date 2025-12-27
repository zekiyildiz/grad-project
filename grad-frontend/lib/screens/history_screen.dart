import 'package:flutter/material.dart';

// Veri Simülasyonu: Backend'den gelecek örnek rapor verileri
// Gerçek projede bu liste API'dan çekilecektir.
class Complaint {
  final String title;
  final String location;
  final String status;
  final Color statusColor;
  final IconData icon;

  Complaint(this.title, this.location, this.status, this.statusColor, this.icon);
}

// Örnek şikayet listesi
final List<Complaint> dummyComplaints = [
  Complaint(
    'Kaldırım Çukuru',
    'Küçükdoğan Cd.',
    'TAMAMLANDI',
    Colors.green, // Çözüme Ulaşan Sorun (İlgili birim ilgilendiğini hissettirmeli)
    Icons.check_circle_outline,
  ),
  Complaint(
    'Kırık Park Bankı',
    'Fıstıklı Parkı',
    'İŞLEMDE',
    Colors.orange, // Durum Takibi (İşlemde)
    Icons.pending_actions,
  ),
  Complaint(
    'Bozuk Trafik Levhası',
    'Ana Cadde Kavşağı',
    'YENİ',
    Colors.blue, // Yeni Rapor
    Icons.add_alert_sharp,
  ),
  Complaint(
    'Aşırı Çöp Birikintisi',
    'Atatürk Mah. Köşe',
    'TAMAMLANDI',
    Colors.green,
    Icons.check_circle_outline,
  ),
];


class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şikayet Geçmişim'),
        backgroundColor: Colors.blue,
      ),
      // Listeleme alanı
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: dummyComplaints.length,
        itemBuilder: (context, index) {
          final complaint = dummyComplaints[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              // Sol taraftaki durum ikonu
              leading: Icon(complaint.icon, color: complaint.statusColor, size: 30),
              
              // Şikayet Başlığı ve Konumu
              title: Text(
                complaint.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(complaint.location),
              
              // Sağ taraftaki Durum Etiketi
              trailing: Chip(
                label: Text(
                  complaint.status,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                backgroundColor: complaint.statusColor,
              ),
              
              onTap: () {
                // TASK 3: İleride bu rapora ait detay sayfasını açacağız.
                print('${complaint.title} rapor detayları gösteriliyor.');
              },
            ),
          );
        },
      ),
    );
  }
}