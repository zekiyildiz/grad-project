import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:easy_localization/easy_localization.dart'; 
import '../services/vision_service.dart';
import '../services/report_service.dart';
import '../providers/theme_provider.dart';
import 'confirmation_screen.dart';
import 'location_picker_screen.dart';
import 'package:latlong2/latlong.dart';
import 'login_screen.dart'; 

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({Key? key}) : super(key: key);

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  late VisionService _visionService;
  final ReportService _reportService = ReportService();

  final TextEditingController _descriptionController = TextEditingController();

  File? _selectedImage;
  String? _selectedCategory;
  bool _isAnalyzing = false;
  bool _isSending = false;

  bool _formSubmitted = false; 
  bool _isAiSelected = false; 

  String _currentAddress = 'complaint_loc_getting'.tr();
  Position? _currentPosition;
  LatLng? _manualPosition; 
  bool _gettingLocation = true;
  bool _isManualLocation = false; 
  
  @override
  void initState() {
    super.initState();
    _visionService = VisionService();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _visionService.loadModel();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _visionService.closeModel();
    _descriptionController.dispose();
    super.dispose();
  }

  /// A defensive location function that retrieves location data from the device's GPS sensor, but if the sensor is turned off 
  /// or the Geocoding API times out, it ensures the system remains operational by using raw coordinates (Lat/Lng) 
  /// instead of causing the app to crash.
  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    setState(() => _gettingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setLocationError('complaint_loc_disabled'.tr());
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setLocationError('complaint_loc_denied'.tr());
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _setLocationError('complaint_loc_denied_forever'.tr());
        return;
      }

      // First, get the last known location
      Position? position = await Geolocator.getLastKnownPosition();
      
      // If there is no last location, request a new location with low accuracy (quickly) and set a 5-second limit
      position ??= await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low, 
        timeLimit: const Duration(seconds: 5),
      );

      if (!mounted) return;
      setState(() {
        _currentPosition = position;
      });

      try {
        // We've also added a 5-second timeout to the geocoding process
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 5));

        if (placemarks.isNotEmpty && mounted) {
          Placemark place = placemarks[0];
          setState(() {
            _currentAddress = '${place.thoroughfare ?? ''} ${place.subLocality ?? ''}, ${place.administrativeArea ?? ''}';
            if (_currentAddress.trim().length < 5) {
              _currentAddress = '${position!.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
            }
            _gettingLocation = false;
          });
        }
      } catch (e) {
        // If it cannot find the address or times out, it writes the coordinates instead of crashing
        if (mounted) {
          setState(() {
            _currentAddress = '${position!.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
            _gettingLocation = false;
          });
        }
      }
    } catch (e) {
      _setLocationError('complaint_loc_error'.tr());
    }
  }

  void _setLocationError(String message) {
    if (!mounted) return;
    setState(() {
      _currentAddress = message;
      _gettingLocation = false;
    });
  }

  Future<void> _pickLocationFromMap() async {
    LatLng startPos = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : const LatLng(39.9334, 32.8597); 
        
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(initialPosition: startPos),
      ),
    );

    if (result != null && result is Map) {
      LatLng newPos = result['position'];
      String addressDesc = result['address'];
      
      setState(() {
        _gettingLocation = true;
        _isManualLocation = true;
        _manualPosition = newPos;
        _currentPosition = Position(
          longitude: newPos.longitude,
          latitude: newPos.latitude,
          timestamp: DateTime.now(),
          accuracy: 100,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      });

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          newPos.latitude,
          newPos.longitude,
        );

        if (placemarks.isNotEmpty && mounted) {
          Placemark place = placemarks[0];
          setState(() {
            _currentAddress = '${place.thoroughfare ?? ''} ${place.subLocality ?? ''}, ${place.administrativeArea ?? ''}';
            
            if (addressDesc.isNotEmpty) {
              _currentAddress += ' ($addressDesc)';
            }
            
            if (_currentAddress.trim().length < 5 && addressDesc.isEmpty) {
              _currentAddress = '${newPos.latitude.toStringAsFixed(4)}, ${newPos.longitude.toStringAsFixed(4)}';
            } else if (_currentAddress.trim().length < 5 && addressDesc.isNotEmpty) {
               _currentAddress = addressDesc;
            }
            _gettingLocation = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _currentAddress = addressDesc.isNotEmpty 
                ? addressDesc 
                : '${newPos.latitude.toStringAsFixed(4)}, ${newPos.longitude.toStringAsFixed(4)}';
            _gettingLocation = false;
          });
        }
      }
    }
  }

  String _mapLabelToCategory(String label) {
    if (label.contains('pothole')) return 'CUKUR';
    if (label.contains('garbage')) return 'COPLUK';
    if (label.contains('bench')) return 'KIRIK_BANK';
    if (label.contains('traffic')) return 'TRAFIK';
    if (label.contains('panel') || label.contains('electric')) return 'ELEKTRIK';
    if (label.contains('scooter')) return 'SCOOTER';
    if (label.contains('poster') || label.contains('graffiti')) return 'POSTER';
    if (label.contains('tree')) return 'AGAC';

    return 'DIGER';
  }

  /// The main asynchronous function that uploads the photo to the server as form data and then
  /// writes the complaint to the database. If a 401 (Unauthorized)
  /// error is returned during the request, it automatically terminates the user's session and
  /// safely redirects them to the login screen.
  Future<void> _submitReport() async {
    setState(() {
      _formSubmitted = true;
    });

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('complaint_err_no_photo'.tr()), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('complaint_err_no_cat'.tr()), backgroundColor: Colors.orange));
      return;
    }

    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('complaint_err_no_loc'.tr()), backgroundColor: Colors.orange));
      _getCurrentLocation();
      return;
    }

    setState(() => _isSending = true);

    try {
      // FIRST, WE UPLOAD THE PHOTO TO THE SERVER 
      List<String> finalImages = [];
      try {
        String? uploadedUrl = await _reportService.uploadImage(_selectedImage!);
        if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
          finalImages.add(uploadedUrl);
        }
      } catch (e) {
        debugPrint("Fotoğraf yükleme hatası: $e");
      }

      // SUBMIT THE COMPLAINT
      await _reportService.createReport(
        category: _selectedCategory!,
        description: _descriptionController.text.isEmpty ? 'complaint_no_desc'.tr() : _descriptionController.text,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        address: _currentAddress,
        isUrgent: false, 
        imageUrls: finalImages,
      );

      if (!mounted) return;
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ConfirmationScreen()));
      
    } catch (e) {
      if (!mounted) return;

      String errorMsg = e.toString();

      if (errorMsg.contains('401') || errorMsg.contains('Unauthorized') || errorMsg.contains('No token provided')) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Row(
              children: [
                const Icon(Icons.lock_outline, color: Colors.orange),
                const SizedBox(width: 10),
                Text('complaint_auth_title'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text('complaint_err_auth'.tr()), 
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('cancel'.tr(), style: const TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () {
                  Navigator.pop(ctx); 
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                },
                child: Text('btn_login_now'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
        return; 
      }

      if (errorMsg.contains('DOCTYPE') || errorMsg.contains('html')) {
        errorMsg = 'complaint_err_server'.tr();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${'complaint_err_general'.tr()} $errorMsg'), backgroundColor: Colors.red),
      );
      
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  /// A function that performs object detection by feeding the image matrix captured by the camera (TFLite)
  /// into the local (on-device) YOLOv8 Nano model. By mapping the detected label (e.g., ‘pothole’)
  /// to the system category (‘PIT’) (Autonomous Classification), it minimizes the user's form-filling burden.
  Future<void> _pickAndAnalyzeImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: source);
      if (image == null) return;

      setState(() {
        _selectedImage = File(image.path);
        _isAnalyzing = true;
        _selectedCategory = null;
        _isAiSelected = false; 
      });

      final results = await _visionService.runInference(image);

      if (!mounted) return;

      if (results.isNotEmpty) {
        final firstDetection = results.first;
        final String detectedLabel = firstDetection['tag'];
        final double confidence = firstDetection['box'][4] ?? 0.0;

        String matchedCategory = _mapLabelToCategory(detectedLabel);

        setState(() {
          _selectedCategory = matchedCategory;
          _isAiSelected = true; 
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${'toast_ai_found'.tr()} $detectedLabel', 
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        setState(() {
          _selectedCategory = 'DIGER';
          _isAiSelected = true; 
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('toast_no_obj'.tr()),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${'complaint_err_vision'.tr()} $e'))
      );
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  void _showImageSourceSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'pick_source'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.blue),
                title: Text('camera'.tr()),
                onTap: () {
                  Navigator.pop(bc);
                  _pickAndAnalyzeImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: Text('gallery'.tr()),
                onTap: () {
                  Navigator.pop(bc);
                  _pickAndAnalyzeImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    bool showImageError = _formSubmitted && _selectedImage == null;

    return Scaffold(
      appBar: AppBar(
        title: Text('complaint_title'.tr()),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
            tooltip: 'complaint_refresh_loc'.tr(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: () => _showImageSourceSelection(context),
                child: Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade900 : Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: showImageError
                          ? Colors.red.shade300
                          : (isDark ? Colors.grey.shade700 : Colors.grey.shade400),
                      width: showImageError ? 2 : 1,
                    ),
                    image: _selectedImage != null
                        ? DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _selectedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_camera,
                              size: 40,
                              color: showImageError
                                  ? Colors.red.shade300
                                  : (isDark ? Colors.grey.shade400 : Colors.grey[600]),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'photo_label'.tr() +
                                  (showImageError ? 'complaint_mandatory'.tr() : ""),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: showImageError
                                    ? Colors.red
                                    : (isDark ? Colors.white : Colors.black87),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'photo_ai_hint'.tr(),
                              style: TextStyle(
                                color: isDark ? Colors.grey.shade400 : Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      : _isAnalyzing
                      ? Container(
                          color: Colors.black45,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(color: Colors.white),
                                const SizedBox(height: 10),
                                Text(
                                  'complaint_ai_analyzing'.tr(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'location_auto'.tr(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: _gettingLocation
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: LinearProgressIndicator(),
                        )
                      : Text(
                          _currentAddress,
                          style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.grey[700]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
                TextButton.icon(
                  onPressed: _pickLocationFromMap,
                  icon: const Icon(Icons.map, size: 18),
                  label: Text('complaint_map_select'.tr()),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )
              ],
            ),

            const Divider(height: 30),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'issue_type'.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (_selectedCategory != null &&
                    _selectedCategory != 'DIGER' &&
                    _isAiSelected)
                  Chip(
                    label: Text(
                      'ai_selected'.tr(),
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                    backgroundColor: Colors.purple,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey[50],
              ),
              hint: Text('issue_type'.tr()),
              value: _selectedCategory,
              items: [
                DropdownMenuItem(value: 'CUKUR', child: Text('cat_pothole'.tr())),
                DropdownMenuItem(value: 'KIRIK_BANK', child: Text('cat_bench'.tr())),
                DropdownMenuItem(value: 'COPLUK', child: Text('cat_garbage'.tr())),
                DropdownMenuItem(value: 'ELEKTRIK', child: Text('cat_electric'.tr())),
                DropdownMenuItem(value: 'TRAFIK', child: Text('cat_traffic'.tr())),
                DropdownMenuItem(value: 'SCOOTER', child: Text('cat_scooter'.tr())),
                DropdownMenuItem(value: 'POSTER', child: Text('cat_poster'.tr())),
                DropdownMenuItem(value: 'AGAC', child: Text('cat_tree'.tr())),
                DropdownMenuItem(value: 'DIGER', child: Text('cat_other'.tr())),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                  _isAiSelected = false;
                });
              },
            ),

            const Divider(height: 30),

            Row(
              children: [
                Text(
                  'desc_label'.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'complaint_optional'.tr(),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'desc_hint'.tr(),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey[50],
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSending ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  _isSending
                      ? 'complaint_sending'.tr()
                      : 'btn_submit'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
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