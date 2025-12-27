import 'package:flutter/material.dart';
import 'confirmation_screen.dart';

class ComplaintScreen extends StatelessWidget {
  const ComplaintScreen({Key? key}) : super(key: key);

  // FOTOĞRAF KAYNAĞI SEÇİM MODALI GÖSTEREN METOT
  void _showImageSourceSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              // Başlık
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Görsel Kaynağını Seçin',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),

              // Kamera İle Çek Seçeneği
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.blue),
                title: const Text('Kamera İle Çek'),
                onTap: () {
                  Navigator.pop(bc); // Modalı kapat
                  // GERÇEK UYGULAMADA: Kamera açma fonksiyonu buraya gelecek.
                  print('Kamera açıldı...');
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kamera fonksiyonu MVP sonrası eklenecek.')),
                  );
                },
              ),

              // Galeriden Seç Seçeneği
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('Galeriden Seç'),
                onTap: () {
                  Navigator.pop(bc); // Modalı kapat
                  // GERÇEK UYGULAMADA: Galeri açma fonksiyonu buraya gelecek.
                  print('Galeri açıldı...');
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Galeri fonksiyonu MVP sonrası eklenecek.')),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şikayet Bildirimi Oluştur'),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Fotoğraf Çek/Yükle Alanı
            Center(
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_camera, size: 40, color: Colors.grey[600]),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        // BURADA DEĞİŞİKLİK YAPILDI
                        _showImageSourceSelection(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Fotoğraf Çek/Yükle'), // Buton metni güncellendi
                    ),
                    const SizedBox(height: 5),
                    const Text('Sorunu görselle destekleyin.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // 2. Konum (Otomatik Alınacak - Placeholder)
            const Text(
              'Konum (Otomatik Alındı)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  '16050 Osmangazi/Bursa (Placeholder)', // MVP aşamasında yer tutucu
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            
            const Divider(height: 30),

            // 3. Kategori (MVP: Manuel Seçim)
            const Text(
              'Sorun Türü (Lütfen Seçiniz)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            // Seçim Alanı (Dropdown veya Radio Button kullanılabilir)
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              hint: const Text('Bir sorun kategorisi seçin (Çukur, Kırık Bank vb.)'),
              value: null, // Başlangıçta boş
              items: const [
                DropdownMenuItem(value: 'CUKUR', child: Text('🚧 Kaldırım/Yol Çukuru')),
                DropdownMenuItem(value: 'KIRIK_BANK', child: Text('🪑 Kırık Bank/Oturma Alanı')),
                DropdownMenuItem(value: 'COPLUK', child: Text('🗑️ Aşırı Çöp/Kirlilik')),
                // ... Diğer kategoriler buraya eklenecek
              ],
              onChanged: (String? newValue) {
                // Seçilen kategori burada kaydedilecek
                print('Seçilen Kategori: $newValue');
              },
            ),

            const Divider(height: 30),

            // 4. Açıklama (Opsiyonel)
            const Text(
              'Açıklama (Opsiyonel)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Ek detaylar ve önemli notları yazın...',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),

            const SizedBox(height: 30),
            
            // 5. Raporu Gönder Butonu
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Önce mevcut ComplaintScreen'i kapatıyoruz.
                  Navigator.pop(context); 
                  
                  // Ardından ConfirmationScreen'i gösteriyoruz.
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ConfirmationScreen()),
                  );
                print('Rapor Gönderildi ve Onay Ekranı Açıldı!');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Ana eylem rengi
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.send),
                label: const Text(
                  'RAPORU GÖNDER',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
