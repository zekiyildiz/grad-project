import 'package:flutter/material.dart';

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
            
            const Divider(height: 30),

            // Canlı Destek Alanına Yönlendirme
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Sorununuzu Çözemediniz mi?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  // İletişim sayfasına yönlendirme (ContactScreen)
                  Navigator.pushNamed(context, '/contact'); // Rota adıyla yönlendirme örneği
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                icon: const Icon(Icons.support_agent),
                label: const Text('Canlı Destek ve İletişim Kanalları', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}