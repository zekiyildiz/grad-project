import 'package:flutter/material.dart';
import 'manual_address_screen.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  bool _isLoading = false;

  // "Diğer" seçeneği için açıklama metnini tutan kontrolcü
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _emergencyTypes = [
    {
      'title': 'Yangın İhbar',
      'icon': Icons.local_fire_department,
      'color': Colors.red,
    },
    {'title': 'Gaz Kaçağı', 'icon': Icons.gas_meter, 'color': Colors.orange},
    {'title': 'Su Patlağı', 'icon': Icons.water_drop, 'color': Colors.blue},
    {
      'title': 'Elektrik Arıza',
      'icon': Icons.bolt,
      'color': Colors.yellow.shade800,
    },
    {'title': 'Yol Çökmesi', 'icon': Icons.add_road, 'color': Colors.brown},
    {'title': 'Diğer', 'icon': Icons.report_problem, 'color': Colors.blueGrey},
  ];

  void _showLocationDialog(String title) {
    // Her açılışta açıklama kutusunu temizle
    _descriptionController.clear();

    // "Diğer" seçeneği mi kontrol et?
    bool isOtherOption = (title == 'Diğer');

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => StatefulBuilder(
        // Dialog içinde ekranı güncellemek için StatefulBuilder şart
        builder: (context, setDialogState) {
          return AlertDialog(
            titlePadding: EdgeInsets.zero,
            title: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isOtherOption
                            ? Icons.edit_note
                            : Icons.notifications_active,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isOtherOption ? "Acil Durum Tanımı" : "$title",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(ctx),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // EĞER "DİĞER" SEÇİLDİYSE BU KISIM GÖRÜNÜR
                  if (isOtherOption) ...[
                    const Text(
                      "Lütfen acil durumu kısaca açıklayınız:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: "Örn: Binadan parça düştü, Ağaç devrildi...",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      onChanged: (val) {
                        // Yazı yazıldıkça butonları aktif etmek için dialogu yenile
                        setDialogState(() {});
                      },
                    ),
                    const SizedBox(height: 15),
                    const Divider(),
                    const SizedBox(height: 10),
                  ],

                  const Text(
                    "Ekiplerin size ulaşabilmesi için konum seçimi yapınız:",
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),

            actionsAlignment: MainAxisAlignment.center,
            actionsPadding: const EdgeInsets.only(
              bottom: 20,
              left: 15,
              right: 15,
            ),
            actions: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // SEÇENEK A: Anlık Konum
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      // Eğer "Diğer" ise ve yazı boşsa butonu gri yap (Disable)
                      disabledBackgroundColor: Colors.red.shade200,
                    ),
                    icon: const Icon(Icons.my_location, color: Colors.white),
                    label: const Text(
                      "Anlık Konumumu Gönder",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    // Eğer "Diğer" seçili ve yazı boşsa tıklanamaz (null)
                    onPressed:
                        (isOtherOption &&
                            _descriptionController.text.trim().isEmpty)
                        ? null
                        : () {
                            Navigator.pop(ctx);
                            // Gönderirken başlığı güncelle: "Diğer: Ağaç Devrildi"
                            String finalTitle = isOtherOption
                                ? "Diğer: ${_descriptionController.text}"
                                : title;
                            _simulateSubmission(finalTitle, "GPS Konumu");
                          },
                  ),

                  const SizedBox(height: 10),

                  // SEÇENEK B: Manuel Adres
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color:
                            (isOtherOption &&
                                _descriptionController.text.trim().isEmpty)
                            ? Colors.grey.shade300
                            : Colors.red.shade200,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Icon(
                      Icons.map,
                      color:
                          (isOtherOption &&
                              _descriptionController.text.trim().isEmpty)
                          ? Colors.grey
                          : Colors.red,
                    ),
                    label: Text(
                      "Adres Gir / Haritadan Seç",
                      style: TextStyle(
                        color:
                            (isOtherOption &&
                                _descriptionController.text.trim().isEmpty)
                            ? Colors.grey
                            : Colors.red,
                        fontSize: 16,
                      ),
                    ),
                    // Eğer "Diğer" seçili ve yazı boşsa tıklanamaz (null)
                    onPressed:
                        (isOtherOption &&
                            _descriptionController.text.trim().isEmpty)
                        ? null
                        : () {
                            Navigator.pop(ctx);

                            String finalTitle = isOtherOption
                                ? "Diğer: ${_descriptionController.text}"
                                : title;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ManualAddressScreen(
                                  emergencyType: finalTitle,
                                ),
                              ),
                            );
                          },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _simulateSubmission(String type, String locationType) async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isLoading = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle, size: 60, color: Colors.green),
        title: const Text("İhbar İletildi!"),
        content: Text(
          "$type bildiriminiz konumunuzla birlikte ekiplere gönderildi.",
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("Tamam", style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ACİL DURUM BİLDİR"),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.red),
                  SizedBox(height: 20),
                  Text(
                    "Konumunuz Alınıyor...",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.red),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Lütfen sadece acil müdahale gerektiren durumları seçiniz.",
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      itemCount: _emergencyTypes.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 1.1,
                          ),
                      itemBuilder: (context, index) {
                        final item = _emergencyTypes[index];
                        return _buildEmergencyCard(
                          title: item['title'],
                          icon: item['icon'],
                          color: item['color'],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmergencyCard({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: () => _showLocationDialog(title),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 35, color: color),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
