import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart'; 
import 'package:easy_localization/easy_localization.dart'; 
import 'package:geocoding/geocoding.dart'; // 🌟 Koordinatı adrese çevirmek için eklendi

import '../services/report_service.dart';
import 'login_screen.dart';

class ManualAddressScreen extends StatefulWidget {
  final String emergencyType;
  const ManualAddressScreen({Key? key, required this.emergencyType}) : super(key: key);

  @override
  State<ManualAddressScreen> createState() => _ManualAddressScreenState();
}

class _ManualAddressScreenState extends State<ManualAddressScreen> {
  final _addressController = TextEditingController();
  final ReportService _reportService = ReportService();

  bool _isLoading = false;
  LatLng _selectedPoint = const LatLng(39.9711, 32.8186); // Varsayılan: Ankara

  // --- 🌟 AKILLI GÖNDERİM FONKSİYONU ---
  void _submitAddress() async {
    setState(() => _isLoading = true);

    try {
      String finalAddress = _addressController.text.trim();

      // 1. Eğer kullanıcı tarif yazmadıysa, koordinattan adres bulalım
      if (finalAddress.isEmpty || finalAddress.toLowerCase() == "xx") {
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            _selectedPoint.latitude,
            _selectedPoint.longitude,
          );
          if (placemarks.isNotEmpty) {
            Placemark p = placemarks.first;
            finalAddress = "${p.thoroughfare ?? ''} ${p.subLocality ?? ''}, ${p.administrativeArea ?? ''}";
          }
        } catch (e) {
          // Adres çözülemezse koordinatı metin olarak yaz
          finalAddress = "${_selectedPoint.latitude.toStringAsFixed(4)}, ${_selectedPoint.longitude.toStringAsFixed(4)}";
        }
      }

      // 2. Raporu Gönder (Hem koordinatlar hem de oluşturulan adres gidiyor)
      await _reportService.createReport(
        category: widget.emergencyType,
        description: 'emerg_default_desc'.tr(),
        latitude: _selectedPoint.latitude,
        longitude: _selectedPoint.longitude,
        address: finalAddress, // 🌟 Artık asla "Bilinmeyen Konum" olmayacak
        isUrgent: true,
        imageUrls: [],
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Başarı Diyaloğu
      _showSuccess(finalAddress);

    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _handleError(e.toString());
    }
  }

  void _showSuccess(String address) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.check_circle, size: 60, color: Colors.green),
        title: Text('manual_loc_success_title'.tr()),
        content: Text(
          "${widget.emergencyType} ihbarınız şu konuma iletildi:\n\n$address",
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text('manual_loc_ok'.tr()),
          ),
        ],
      ),
    );
  }

  void _handleError(String errorMsg) {
    if (errorMsg.contains('401')) {
       // Giriş yap diyalogu (Mevcut kodundaki gibi kalabilir)
    } else {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('manual_loc_title'.tr()),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 1. HARİTA ALANI (Tıklanan yeri seçer)
          Expanded(
            flex: 3, 
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: _selectedPoint,
                    initialZoom: 15.0,
                    onTap: (tapPosition, point) => setState(() => _selectedPoint = point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c', 'd'], // CartoDB'nin alt sunucuları 
                      userAgentPackageName: 'com.merve.akillibelediye', 
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedPoint,
                          width: 80, height: 80,
                          child: const Icon(Icons.location_on, color: Colors.red, size: 45),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 10, left: 10,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: isDark ? Colors.black87 : Colors.white, borderRadius: BorderRadius.circular(10)),
                    child: Text('manual_loc_map_hint'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),

          // 2. TARİF ALANI (İsteğe Bağlı Hale Geldi)
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(20),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Açık Adres / Tarif (İsteğe Bağlı):', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: "Haritadan yer seçtiyseniz burayı boş bırakabilirsiniz.",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        onPressed: _isLoading ? null : _submitAddress,
                        icon: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.send, color: Colors.white),
                        label: Text('KONUMU ONAYLA VE GÖNDER', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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