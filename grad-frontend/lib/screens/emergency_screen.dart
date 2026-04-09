import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; 
import 'package:easy_localization/easy_localization.dart'; 
import 'manual_address_screen.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  bool _isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _emergencyTypes = [
    {'titleKey': 'emerg_type_fire', 'icon': Icons.local_fire_department, 'color': Colors.red},
    {'titleKey': 'emerg_type_gas', 'icon': Icons.gas_meter, 'color': Colors.orange},
    {'titleKey': 'emerg_type_water', 'icon': Icons.water_drop, 'color': Colors.blue},
    {'titleKey': 'emerg_type_elec', 'icon': Icons.bolt, 'color': Colors.yellow.shade800},
    {'titleKey': 'emerg_type_road', 'icon': Icons.add_road, 'color': Colors.brown},
    {'titleKey': 'emerg_type_other', 'icon': Icons.report_problem, 'color': Colors.blueGrey},
  ];

  Future<void> _getCurrentLocationAndSend(String title) async {
    setState(() => _isLoading = true); 

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'emerg_loc_denied'.tr();
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String coords = "${'emerg_lat'.tr()}: ${position.latitude.toStringAsFixed(4)}, ${'emerg_lng'.tr()}: ${position.longitude.toStringAsFixed(4)}";

      _simulateSubmission(title, coords);

    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${'emerg_error'.tr()}: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _simulateSubmission(String type, String locationInfo) async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isLoading = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.check_circle, size: 60, color: Colors.green),
        title: Text('emerg_success_title'.tr()),
        content: Text(
          "$type ${'emerg_success_desc'.tr()}\n\n$locationInfo",
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); 
              Navigator.pop(context); 
            },
            child: Text('emerg_ok_btn'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showLocationDialog(String titleKey) {
    _descriptionController.clear();
    bool isOtherOption = (titleKey == 'emerg_type_other');
    String translatedTitle = titleKey.tr();
    
    // Dialog içi karanlık mod kontrolü
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            titlePadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            title: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isDark ? Colors.red.withOpacity(0.2) : Colors.red.shade50,
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
                      Icon(isOtherOption ? Icons.edit_note : Icons.notifications_active, color: Colors.red),
                      const SizedBox(width: 10),
                      Text(isOtherOption ? 'emerg_dialog_title_other'.tr() : translatedTitle,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isOtherOption) ...[
                    Text('emerg_dialog_desc_label'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'emerg_dialog_desc_hint'.tr(),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                      ),
                      onChanged: (val) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 15),
                    const Divider(),
                  ],
                  Text('emerg_dialog_loc_label'.tr()),
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
            actions: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.my_location, color: Colors.white),
                    label: Text('emerg_btn_auto_loc'.tr(), style: const TextStyle(color: Colors.white, fontSize: 16)),
                    onPressed: (isOtherOption && _descriptionController.text.trim().isEmpty)
                        ? null
                        : () {
                            Navigator.pop(ctx);
                            String finalTitle = isOtherOption ? "$translatedTitle: ${_descriptionController.text}" : translatedTitle;
                            _getCurrentLocationAndSend(finalTitle);
                          },
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.red.shade200),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.map, color: Colors.red),
                    label: Text('emerg_btn_manual_loc'.tr(), style: const TextStyle(color: Colors.red, fontSize: 16)),
                    onPressed: (isOtherOption && _descriptionController.text.trim().isEmpty)
                        ? null
                        : () {
                            Navigator.pop(ctx);
                            String finalTitle = isOtherOption ? "$translatedTitle: ${_descriptionController.text}" : translatedTitle;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ManualAddressScreen(emergencyType: finalTitle),
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

  @override
  Widget build(BuildContext context) {
    // SAYFA İÇİN KARANLIK MOD KONTROLÜ
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('emerg_title'.tr()),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.red),
                  const SizedBox(height: 20),
                  Text('emerg_loc_getting'.tr(),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                      color: isDark ? Colors.red.withOpacity(0.1) : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(child: Text('emerg_warning_text'.tr())),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      itemCount: _emergencyTypes.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 1.1,
                      ),
                      itemBuilder: (context, index) {
                        final item = _emergencyTypes[index];
                        return _buildEmergencyCard(
                          titleKey: item['titleKey'],
                          icon: item['icon'],
                          color: item['color'],
                          isDark: isDark, // Karanlık mod bilgisini karta gönderiyoruz
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmergencyCard({required String titleKey, required IconData icon, required Color color, required bool isDark}) {
    return InkWell(
      onTap: () => _showLocationDialog(titleKey),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white, // KART ARKA PLANI DÜZELTİLDİ
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3)),
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
            Text(titleKey.tr(),
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87, // KART YAZI RENGİ DÜZELTİLDİ
                ),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}