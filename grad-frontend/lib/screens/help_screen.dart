import 'package:flutter/material.dart';
import 'contact_screen.dart';

// Soru-Cevap Veri Modeli
class FAQItem {
  final String question;
  final String answer;

  FAQItem(this.question, this.answer);
}

final List<FAQItem> faqList = [
  FAQItem(
    '1. Şikayetimi nasıl oluşturabilirim?',
    'Uygulama ana sayfasındaki "Şikayet/Durum Bildir" butonuna tıklayın. Fotoğraf çekin ve yapay zekanın sorunu otomatik belirlemesini bekleyin. Ek açıklama girmeden raporunuzu gönderin.',
  ),
  FAQItem(
    '2. Yapay zeka kategoriyi yanlış belirlerse ne yapmalıyım?',
    'Bildirim gönderim ekranında, AI tarafından belirlenen kategori başlığının yanındaki "Düzelt" seçeneği ile doğru kategoriyi manuel olarak seçebilirsiniz. Sistem bu düzeltmeden öğrenir.',
  ),
  FAQItem(
    '3. Şikayetimin durumunu nasıl takip edebilirim?',
    'Yan menüden "Şikayet Geçmişim" sekmesine giderek gönderdiğiniz tüm raporların durumunu (Yeni, İşlemde, Tamamlandı) anlık olarak takip edebilirsiniz.',
  ),
  FAQItem(
    '4. Misafir modu nedir?',
    'e-Devlet ile giriş yapmayan geçici kullanıcıların (turistler/ziyaretçiler) temel sorun bildirimini yapmasını sağlayan moddur.',
  ),
  FAQItem(
    '5. Sesle bildirim özelliği nasıl çalışır?',
    'Özellikle görme engelli veya yaşlı kullanıcılar için tasarlanmıştır. "Sesle Bildir" seçeneği ile sorununuzu sesli olarak anlatın, yapay zeka sesinizi analiz ederek uygun kategoriyi seçer.',
  ),
];


class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yardım ve Sıkça Sorulan Sorular (SSS)'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Sıkça Sorulan Sorular',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
              ),
            ),
            
            // Soru-Cevap Listesi
            ...faqList.map((faq) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Card(
                  elevation: 1,
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ExpansionTile(
                    title: Text(
                      faq.question,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          faq.answer,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            
            // ... Soru-Cevap Listesi bittikten sonra ...

const Divider(height: 40, thickness: 1, indent: 20, endIndent: 20),

Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.center, // Ortalamak daha şık durur
    children: [
      const Text(
        'Hâlâ yardıma mı ihtiyacınız var?',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
      ),
      const SizedBox(height: 8),
      const Text(
        'Aklınıza takılan diğer konular için bize yazılı olarak ulaşabilirsiniz.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, color: Colors.grey),
      ),
      const SizedBox(height: 20),
      // HelpScreen içindeki butonun olduğu yer
ElevatedButton.icon(
  onPressed: () {
    // Mevcut olan ContactScreen'e yönlendiriyoruz
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ContactScreen()),
    );
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 50),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  icon: const Icon(Icons.support_agent), // İkonu istersen Icons.contact_support yapabilirsin
  label: const Text('İletişim Kanallarını Gör', style: TextStyle(fontSize: 16)),
),
      const SizedBox(height: 30),
    ],
  ),
),
          ],
        ),
      ),
    );
  }
}