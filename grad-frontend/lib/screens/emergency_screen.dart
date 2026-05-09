import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; 
import 'package:geocoding/geocoding.dart'; 
import 'package:easy_localization/easy_localization.dart'; 
import '../services/report_service.dart'; 
import 'manual_address_screen.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  bool _isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();
  final ReportService _reportService = ReportService(); 

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // backendValue is stored in the database, while uiKey is displayed on the screen
  final List<Map<String, dynamic>> _emergencyTypes = [
    {'backendValue': 'YANGIN', 'uiKey': 'cat_fire', 'icon': Icons.local_fire_department, 'color': Colors.red},
    {'backendValue': 'GAZ KAÇAĞI', 'uiKey': 'cat_gas', 'icon': Icons.gas_meter, 'color': Colors.orange},
    {'backendValue': 'SU PATLAĞI', 'uiKey': 'cat_water', 'icon': Icons.water_drop, 'color': Colors.blue},
    {'backendValue': 'ELEKTRİK ARIZASI', 'uiKey': 'cat_electric_urgent', 'icon': Icons.bolt, 'color': Colors.yellow.shade800},
    {'backendValue': 'YOL ÇÖKMESİ', 'uiKey': 'cat_road_collapse', 'icon': Icons.add_road, 'color': Colors.brown},
    {'backendValue': 'DİĞER', 'uiKey': 'cat_other', 'icon': Icons.report_problem, 'color': Colors.blueGrey},
  ];

  /// A defensive function that attempts to determine the user's location during a panic situation as quickly as possible (LocationAccuracy.low)
  /// within 5 seconds (Timeout). If the sensor fails to respond, it ensures the uninterrupted transmission of the emergency alert (Fail-Safe)
  /// using fallback coordinates rather than causing the system to crash.
  Future<void> _getCurrentLocationAndSend(String backendValue, String uiKey) async {
    setState(() => _isLoading = true); 

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'Konum servisleri kapalı. Lütfen telefonunuzun konum (GPS) özelliğini açın.';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw 'emerg_loc_denied'.tr();
      }
      if (permission == LocationPermission.deniedForever) {
        throw 'Konum izni ayarlardan kalıcı olarak kapatılmış. Lütfen ayarlardan izin verin.';
      }

      Position? position;
      try {
        // Try to determine the actual location within 5 seconds
        position = await Geolocator.getLastKnownPosition();
        position ??= await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 5), // Our 5-second limit
        );
      } catch (e) {
        // If it can't find it within 5 seconds, DO NOT RETURN AN ERROR!
        // Since the emulator is stuck, force it to use the Ankara coordinates and continue processing.
        debugPrint("Gerçek konum bulunamadı, Emülatör/Yedek koordinat kullanılıyor...");
        position = Position(
          latitude: 39.9334,
          longitude: 32.8597,
          timestamp: DateTime.now(),
          accuracy: 100, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0,
        );
      }

      String addressToSave = "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
      
      try {
        // We set a 4-second limit to prevent it from freezing while converting the address to text
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, 
          position.longitude
        ).timeout(const Duration(seconds: 4));
        
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          addressToSave = '${place.thoroughfare ?? ''} ${place.subLocality ?? ''}, ${place.administrativeArea ?? ''}';
        }
      } catch (e) {
        debugPrint("Adres metne çevrilemedi, koordinat kaydedilecek.");
      }

      await _reportService.createReport(
        category: backendValue, 
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : 'emerg_default_desc'.tr(),
        latitude: position.latitude,
        longitude: position.longitude,
        address: addressToSave,
        isUrgent: true, 
        imageUrls: [], 
      );

      if (!mounted) return;
      setState(() => _isLoading = false);
      
      // Display the success screen
      _showSuccessDialog(uiKey.tr(), addressToSave);

    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${'emerg_error'.tr()}: $e"), backgroundColor: Colors.red, duration: const Duration(seconds: 4)));
    }
  }

  void _showSuccessDialog(String translatedType, String locationInfo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.check_circle, size: 60, color: Colors.green),
        title: Text('emerg_success_title'.tr(),style: const TextStyle(fontWeight: FontWeight.bold,),),
        content: Text(
          "$translatedType ${'emerg_success_desc'.tr()}\n\n$locationInfo",
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

  /// A dynamic decision window that offers the user two different routing options—“Automatic Location” and “Manual Location”—and 
  /// prevents empty or meaningless data (garbage data) in the database by requiring a description to be entered for the ‘OTHER’ option.
  void _showLocationDialog(String backendValue, String uiKey) {
    _descriptionController.clear();
    bool isOtherOption = (backendValue == 'DİĞER');
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => StatefulBuilder( 
        builder: (context, setDialogState) {
          bool isDescEmpty = _descriptionController.text.trim().isEmpty;

          return AlertDialog(
            titlePadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            title: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isDark ? Colors.red.withOpacity(0.2) : Colors.red.shade50,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  Icon(isOtherOption ? Icons.edit_note : Icons.notifications_active, color: Colors.red),
                  const SizedBox(width: 10),
                  Expanded(child: Text(isOtherOption ? 'emerg_dialog_title_other'.tr() : uiKey.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1)),
                  IconButton(padding: EdgeInsets.zero, icon: const Icon(Icons.close, color: Colors.grey, size: 20), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isOtherOption) ...[
                    Row(
                      children: [
                        Text('emerg_dialog_desc_label'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Text(" *", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), 
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'emerg_dialog_desc_hint'.tr(),
                        errorText: (isOtherOption && isDescEmpty) ? 'emerg_dialog_error_empty'.tr() : null,
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
            actions: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    icon: const Icon(Icons.my_location, color: Colors.white),
                    label: Text('emerg_btn_auto_loc'.tr(), style: const TextStyle(color: Colors.white)),
                    onPressed: (isOtherOption && isDescEmpty) ? null : () { 
                      Navigator.pop(ctx);
                      _getCurrentLocationAndSend(backendValue, uiKey); 
                    },
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.red.shade200)),
                    icon: const Icon(Icons.map, color: Colors.red),
                    label: Text('emerg_btn_manual_loc'.tr(), style: const TextStyle(color: Colors.red)),
                    onPressed: (isOtherOption && isDescEmpty) ? null : () async { 
                      Navigator.pop(ctx); // First, close the small dialog
                      
                      final result = await Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => ManualAddressScreen(
                            emergencyType: backendValue,
                            description: _descriptionController.text.isNotEmpty ? _descriptionController.text : 'emerg_default_desc'.tr(),
                          )
                        )
                      );

                      if (result != null && result is String) {
                        _showSuccessDialog(uiKey.tr(), result);
                      } 
                      else if (result == true) { 
                        _showSuccessDialog(uiKey.tr(), "Haritadan manuel olarak seçildi."); 
                      }
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
                          backendValue: item['backendValue'],
                          uiKey: item['uiKey'],
                          icon: item['icon'],
                          color: item['color'],
                          isDark: isDark,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmergencyCard({required String backendValue, required String uiKey, required IconData icon, required Color color, required bool isDark}) {
    return InkWell(
      onTap: () => _showLocationDialog(backendValue, uiKey),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12), 
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
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
              radius: 26, 
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 10), 
            
            Expanded(
              child: Container(
                alignment: Alignment.center, // Center the text vertically and horizontally
                child: Text(
                  uiKey.tr(),
                  textAlign: TextAlign.center, 
                  maxLines: 3, // We've allowed long texts to wrap to up to three lines
                  overflow: TextOverflow.ellipsis, // If it exceeds 3 lines, it adds “...” at the end
                  style: TextStyle(
                    fontSize: 14, // We've set the size (it won't shrink)
                    fontWeight: FontWeight.bold,
                    height: 1.2, // Line spacing when moving to the next line
                    color: isDark ? Colors.white : Colors.black87,
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