import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // EKLENDİ

class ConfirmationScreen extends StatelessWidget {
  // Başarılı bir gönderim sonrası bu ekranı kullanacağız.
  const ConfirmationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Onay İkonu (Büyük ve Yeşil)
              const Icon(
                Icons.check_circle,
                color: Colors.green, // Başarı için yeşil renk
                size: 120,
              ),
              const SizedBox(height: 30),

              // 2. Başlık ve Açıklama
              Text(
                'conf_title'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'conf_desc'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 60),

              // 3. Ana Sayfaya Dön Butonu
              ElevatedButton.icon(
                onPressed: () {
                  // Kullanıcıyı direkt ana sayfaya döndürmek için
                  // Mevcut tüm ekranları pop edip ana sayfaya gider.
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.arrow_back_ios_new),
                label: Text(
                  'conf_back_btn'.tr(),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}