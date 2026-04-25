import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart'; 
import 'package:easy_localization/easy_localization.dart'; 
import 'package:geocoding/geocoding.dart'; 

import '../services/report_service.dart';

class ManualAddressScreen extends StatefulWidget {
  final String emergencyType; 
  final String description; // Önceki sayfadan gelen açıklamayı tutacak

  const ManualAddressScreen({Key? key, required this.emergencyType, required this.description}) : super(key: key);
  @override
  State<ManualAddressScreen> createState() => _ManualAddressScreenState();
}

class _ManualAddressScreenState extends State<ManualAddressScreen> {
  String _fetchedAddress = "";
  final TextEditingController _detailsController = TextEditingController();
  
  final ReportService _reportService = ReportService();

  bool _isLoading = false;
  bool _isFetchingAddress = false; 
  LatLng _selectedPoint = const LatLng(39.9334, 32.8597); 
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _onMapTap(TapPosition tapPosition, LatLng point) async {
    setState(() {
      _selectedPoint = point;
      _isFetchingAddress = true; 
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        point.latitude, 
        point.longitude
      ).timeout(const Duration(seconds: 5));

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String newAddress = '${place.thoroughfare ?? ''} ${place.subThoroughfare ?? ''}, ${place.subLocality ?? ''}, ${place.administrativeArea ?? ''}';
        newAddress = newAddress.replaceAll(' ,', ',').replaceAll(RegExp(r'^,|,$'), '').trim();

        if (mounted) {
          setState(() {
            _fetchedAddress = newAddress.isEmpty ? "manual_loc_not_found".tr() : newAddress; // Çeviri eklendi
          });
        }
      }
    } catch (e) {
      debugPrint("Adres metne çevrilemedi: $e");
      if (mounted) {
        setState(() {
          _fetchedAddress = "${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}";
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isFetchingAddress = false); 
      }
    }
  }

Future<void> _submitAddress() async {
    if (_fetchedAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('manual_loc_error'.tr()), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String finalAddressToSave = _fetchedAddress;
      if (_detailsController.text.trim().isNotEmpty) {
        finalAddressToSave += " | Ek Bilgi: ${_detailsController.text.trim()}";
      }

      await _reportService.createReport(
        category: widget.emergencyType,
        description: widget.description,
        latitude: _selectedPoint.latitude,
        longitude: _selectedPoint.longitude,
        address: finalAddressToSave, 
        isUrgent: true,
        imageUrls: [],
      );

      if (!mounted) return;
      Navigator.pop(context, finalAddressToSave); 
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('manual_loc_title'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), 
        backgroundColor: Colors.red.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedPoint,
                initialZoom: 15.0,
                onTap: _onMapTap, 
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.akillibelediye.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedPoint,
                      width: 50, height: 50,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 45),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_city, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text("manual_loc_selected".tr(), style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 13)), 
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // KİLİTLİ ADRES KUTUSU
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300)
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (_isFetchingAddress)
                          const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        else
                          Icon(Icons.lock, size: 16, color: Colors.grey.shade500),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _fetchedAddress.isEmpty ? 'manual_loc_hint'.tr() : _fetchedAddress, 
                            style: TextStyle(
                              fontSize: 14, 
                              color: _fetchedAddress.isEmpty ? Colors.grey : (isDark ? Colors.white70 : Colors.black87)
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Icon(Icons.edit_note, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text("manual_loc_extra".tr(), style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 13)), 
                    ],
                  ),
                  const SizedBox(height: 8),

                  // DÜZENLENEBİLİR AÇIKLAMA KUTUSU
                  TextField(
                    controller: _detailsController,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "manual_loc_extra_hint".tr(), 
                      hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.red.shade700, width: 2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700, 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                      ),
                      onPressed: _isLoading ? null : _submitAddress,
                      icon: _isLoading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                          : const Icon(Icons.send, color: Colors.white),
                      label: Text('manual_loc_btn'.tr(), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)), 
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}