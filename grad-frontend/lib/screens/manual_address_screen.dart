import 'package:flutter/material.dart';

class ManualAddressScreen extends StatefulWidget {
  final String emergencyType; // Hangi acil durum için geldiği (Örn: Yangın)

  const ManualAddressScreen({Key? key, required this.emergencyType})
    : super(key: key);

  @override
  State<ManualAddressScreen> createState() => _ManualAddressScreenState();
}

class _ManualAddressScreenState extends State<ManualAddressScreen> {
  final _addressController = TextEditingController();
  bool _isLoading = false;

  void _submitAddress() async {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen açık adres giriniz veya konum tarifi yazınız."),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Sunucuya gönderim simülasyonu
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isLoading = false);

    // İşlem başarılı olunca kullanıcıya bildir ve ana ekrana dön
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle, size: 60, color: Colors.green),
        title: const Text("Adres Alındı"),
        content: Text(
          "${widget.emergencyType} ihbarınız, girdiğiniz adres bilgisiyle ekiplere iletildi.",
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // Dialogu kapat
              Navigator.pop(context); // Bu ekranı kapat
              Navigator.pop(
                context,
              ); // Acil durum ekranını kapat (Ana sayfaya dön)
            },
            child: const Text("Tamam"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adres / Konum Belirle"),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.red),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "${widget.emergencyType} ekiplerinin size ulaşması için adresinizi detaylı yazınız.",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "Adres / Tarif:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _addressController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    "Mahalle, Sokak, No veya bilinen bir yer tarifi giriniz...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),

            const SizedBox(height: 20),

            // Harita Görseli (Placeholder - İleride buraya Google Maps gelir)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.map, size: 50, color: Colors.grey),
                    SizedBox(height: 10),
                    Text(
                      "(Harita Modülü Entegre Edilecek)",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white),
                label: Text(
                  _isLoading ? " GÖNDERİLİYOR..." : "KONUMU ONAYLA VE GÖNDER",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
