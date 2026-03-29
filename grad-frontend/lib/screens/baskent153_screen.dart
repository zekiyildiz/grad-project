import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // En üste eklendi

class Baskent153Screen extends StatelessWidget {
  const Baskent153Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Başkent 153"),
        centerTitle: true,
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // ÜST KISIM: LOGO VE BİLGİ
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.support_agent, size: 80, color: Colors.orange),
                const SizedBox(height: 20),
                const Text(
                  "7/24 Çözüm Merkezi",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "Her türlü istek, öneri ve şikayetiniz için\nbize ulaşabilirsiniz.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // ORTA KISIM: BUTONLAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // 1. HEMEN ARA BUTONU
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    icon: const Icon(
                      Icons.phone,
                      color: Colors.white,
                      size: 28,
                    ),
                    label: const Text(
                      "ALO 153'ü Ara",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () async {
                      // Arama ekranını açan yeni kod bloğumuz:
                      final Uri launchUri = Uri(
                        scheme: 'tel',
                        path: '153',
                      );
                      
                      try {
                        if (await canLaunchUrl(launchUri)) {
                          await launchUrl(launchUri);
                        } else {
                          // Eğer emülatörde arama özelliği yoksa bu uyarı çıkar
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Arama özelliği bu cihazda desteklenmiyor.")),
                          );
                        }
                      } catch (e) {
                        debugPrint("Arama hatası: $e");
                      }
                    },
                  ),
                ),
const SizedBox(height: 10), 
               // 2. WHATSAPP HATTI
SizedBox(
  width: double.infinity,
  height: 60,
  child: OutlinedButton.icon(
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: Colors.green, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
    icon: const Icon(Icons.chat, color: Colors.green, size: 28),
    label: const Text(
      "WhatsApp Destek",
      style: TextStyle(
        fontSize: 20,
        color: Colors.green,
        fontWeight: FontWeight.bold,
      ),
    ),
    onPressed: () async {
      // WhatsApp numarasını uluslararası formatta yazıyoruz (Başkent 153 Hattı)
      const String phoneNumber = "903121530000"; 
      const String message = "Merhaba, bir konu hakkında bilgi almak istiyorum.";
      
      // WhatsApp URL formatı (wa.me)
      final Uri whatsappUri = Uri.parse("https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");

      try {
        if (await canLaunchUrl(whatsappUri)) {
          await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("WhatsApp uygulaması bulunamadı.")),
          );
        }
      } catch (e) {
        debugPrint("WhatsApp hatası: $e");
      }
    },
  ),
),
const SizedBox(height: 20), // <-- aradaki mesafe için
              ],
            ),
          ),
          // ALT KISIM: Footer
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Text(
              "Sizlere hizmet etmekten mutluluk duyuyoruz.",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
