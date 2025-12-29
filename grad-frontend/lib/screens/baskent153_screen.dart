import 'package:flutter/material.dart';

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
                    onPressed: () {
                      // İleride url_launcher paketi ile buraya tel:153 eklenecek
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Arama başlatılıyor...")),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // 2. WHATSAPP HATTI (Opsiyonel ama çok popüler)
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
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("WhatsApp açılıyor...")),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

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
