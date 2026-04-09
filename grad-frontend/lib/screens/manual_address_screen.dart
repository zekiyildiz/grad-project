import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart'; 
import 'package:easy_localization/easy_localization.dart'; 

class ManualAddressScreen extends StatefulWidget {
  final String emergencyType;

  const ManualAddressScreen({Key? key, required this.emergencyType}) : super(key: key);

  @override
  State<ManualAddressScreen> createState() => _ManualAddressScreenState();
}

class _ManualAddressScreenState extends State<ManualAddressScreen> {
  final _addressController = TextEditingController();
  bool _isLoading = false;

  LatLng _selectedPoint = const LatLng(39.9711, 32.8186); 

  void _submitAddress() async {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('manual_loc_err_empty'.tr())),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isLoading = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle, size: 60, color: Colors.green),
        title: Text('manual_loc_success_title'.tr()),
        content: Text(
          'manual_loc_success_desc'.tr(args: [
            widget.emergencyType,
            _selectedPoint.latitude.toStringAsFixed(4),
            _selectedPoint.longitude.toStringAsFixed(4)
          ]),
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); 
              Navigator.pop(context); 
            },
            child: Text('manual_loc_ok'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // KARANLIK MOD KONTROLÜ
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('manual_loc_title'.tr()),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 1. HARİTA ALANI
          Expanded(
            flex: 3, 
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: _selectedPoint,
                    initialZoom: 15.0,
                    onTap: (tapPosition, point) {
                      setState(() {
                        _selectedPoint = point; 
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.akilli_belediye.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedPoint,
                          width: 80,
                          height: 80,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 45,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      // Karanlık moddaysa siyahımsı, değilse beyazımsı arka plan
                      color: isDark ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'manual_loc_map_hint'.tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 12,
                        color: isDark ? Colors.white : Colors.black87, // Yazı rengi
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. ADRES GİRİŞ ALANI
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(20),
              // Sayfanın alt kısmı temanın kendi arka plan rengini alsın (sabit white sildik)
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('loc_picker_address_label'.tr(), 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'loc_picker_address_hint'.tr(),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        // Textfield içi karanlık/aydınlık mod ayarı
                        fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _isLoading ? null : _submitAddress,
                        icon: _isLoading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                          : const Icon(Icons.send, color: Colors.white),
                        label: Text('manual_loc_submit_btn'.tr(), 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}