import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:easy_localization/easy_localization.dart'; 

class LocationPickerScreen extends StatefulWidget {
  final LatLng initialPosition;
  
  const LocationPickerScreen({Key? key, required this.initialPosition}) : super(key: key);

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late LatLng _selectedPoint;
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedPoint = widget.initialPosition;
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  /// A data transfer function that securely transfers the precise coordinates selected from the map and the address description 
  /// manually entered by the user to a single Map object and displays it on the form.
  void _confirmLocation() {
    Navigator.pop(context, {
      'position': _selectedPoint,
      'address': _addressController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. DARK MODE CONTROL
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('loc_picker_title'.tr()),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 1. MAP AREA
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                // By using the open-source flutter_map instead of the paid Google Maps API, the project's external dependencies have been reduced to zero.
                FlutterMap(
                  options: MapOptions(
                    initialCenter: _selectedPoint,
                    initialZoom: 15.0,
                    onTap: (tapPosition, point) {
                      setState(() {
                        _selectedPoint = point; // Move the pin to the touched location
                      });
                    },
                  ),
                  children: [
                    // Map tiles are fetched from CartoDB Voyager servers.
                    TileLayer(
                      urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c', 'd'], // CartoDB's subdomains (for faster loading)
                      userAgentPackageName: 'com.team29.akillibelediye', 
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
                      // 2. HINT BOX BACKGROUND
                      color: isDark ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'loc_picker_hint'.tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 12,
                        // 3. HINT TEXT COLOR
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. APPROVAL SECTION
          Container(
            padding: const EdgeInsets.all(20),
            // 4. SUB-SECTION'S GENERAL BACKGROUND (Automatically retrieved from the theme)
            color: Theme.of(context).scaffoldBackgroundColor,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, 
                children: [
                  Text('loc_picker_address_label'.tr(), 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 10),
                  // A text field that maximizes the speed at which field teams (Employees) can locate an address by not relying 
                  // solely on GPS coordinates, but allowing citizens to manually enter a street/building description (Fallback).
                  TextField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'loc_picker_address_hint'.tr(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      // 5. Text Field Background Color
                      fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _confirmLocation,
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: Text('loc_picker_confirm_btn'.tr(), 
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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