import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../services/vision_service.dart';
import '../services/report_service.dart';
import '../providers/theme_provider.dart';
import 'confirmation_screen.dart';
import 'location_picker_screen.dart';
import 'package:latlong2/latlong.dart';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({Key? key}) : super(key: key);

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  // Servisler
  late VisionService _visionService;
  final ReportService _reportService = ReportService();

  // Kontrolcüler
  final TextEditingController _descriptionController = TextEditingController();

  // Durum Değişkenleri
  File? _selectedImage;
  String? _selectedCategory;
  bool _isAnalyzing = false;
  bool _isSending = false;

  // YENİ: Kontrol Değişkenleri
  bool _formSubmitted = false; // Gönder butonuna basıldı mı?
  bool _isAiSelected = false; // Kategori AI tarafından mı seçildi?

  // Konum Değişkenleri
  // Konum Değişkenleri
  String _currentAddress = 'Konum alınıyor...';
  Position? _currentPosition;
  LatLng? _manualPosition; // YENİ: Haritadan seçilen konum
  bool _gettingLocation = true;
  bool _isManualLocation = false; // YENİ: Manuel konum seçildi mi?
  
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

  // --- 1. GÜVENLİ KONUM ALMA ---
  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    setState(() => _gettingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setLocationError('Konum servisi kapalı.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setLocationError('Konum izni reddedildi.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _setLocationError('Konum izni kalıcı engelli.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      if (!mounted) return;
      setState(() {
        _currentPosition = position;
      });

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty && mounted) {
          Placemark place = placemarks[0];
          setState(() {
            _currentAddress =
                '${place.thoroughfare ?? ''} ${place.subLocality ?? ''}, ${place.administrativeArea ?? ''}';
            if (_currentAddress.trim().length < 5) {
              _currentAddress =
                  '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
            }
            _gettingLocation = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _currentAddress =
                '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
            _gettingLocation = false;
          });
        }
      }
    } catch (e) {
      _setLocationError('Konum alınamadı (GPS Sinyali Yok)');
    }
  }

  void _setLocationError(String message) {
    if (!mounted) return;
    setState(() {
      _currentAddress = message;
      _gettingLocation = false;
    });
  }

  // --- YENİ: HARİTADAN KONUM SEÇME ---
  Future<void> _pickLocationFromMap() async {
    // Başlangıç konumu için mevcut konumu veya Ankara merkez kullan
    LatLng startPos = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : const LatLng(39.9334, 32.8597); // Ankara
        
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

      // Seçilen konumu adrese çevirmeyi dene
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          newPos.latitude,
          newPos.longitude,
        );

        if (placemarks.isNotEmpty && mounted) {
          Placemark place = placemarks[0];
          setState(() {
            _currentAddress = '${place.thoroughfare ?? ''} ${place.subLocality ?? ''}, ${place.administrativeArea ?? ''}';
            
            // Eğer kullanıcı açıklama girdiyse sonuna ekle
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

  // --- 2. YAPAY ZEKA ETİKET EŞLEŞTİRME ---
  String _mapLabelToCategory(String label) {
    if (label.contains('pothole')) return 'CUKUR';
    if (label.contains('garbage')) return 'COPLUK';
    if (label.contains('bench')) return 'KIRIK_BANK';
    if (label.contains('traffic')) return 'TRAFIK';
    if (label.contains('panel') || label.contains('electric'))
      return 'ELEKTRIK';
    if (label.contains('scooter')) return 'SCOOTER';
    if (label.contains('poster') || label.contains('graffiti')) return 'POSTER';
    if (label.contains('tree')) return 'AGAC';

    return 'DIGER';
  }

  // --- 3. RAPORU SUNUCUYA GÖNDERME ---
  Future<void> _submitReport() async {
    // Butona basıldığını kaydet (Validasyon hatası göstermek için)
    setState(() {
      _formSubmitted = true;
    });

    // Validasyonlar
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen ihbar için bir fotoğraf ekleyiniz.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir sorun türü seçiniz.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konum bilgisi bekleniyor...'),
          backgroundColor: Colors.orange,
        ),
      );
      _getCurrentLocation();
      return;
    }

    setState(() => _isSending = true);

    try {
      await _reportService.createReport(
        category: _selectedCategory!,
        description: _descriptionController.text.isEmpty
            ? 'Açıklama girilmedi.'
            : _descriptionController.text,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        address: _currentAddress,
        imageUrls: [],
      );

      if (!mounted) return;

      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ConfirmationScreen()),
      );
    } catch (e) {
      if (!mounted) return;

      String errorMsg = e.toString();
      if (errorMsg.contains('DOCTYPE') || errorMsg.contains('html')) {
        errorMsg = "Sunucu bağlantı hatası. Lütfen API adresini kontrol edin.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $errorMsg'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  // --- 4. FOTOĞRAF ÇEKME VE ANALİZ ---
  Future<void> _pickAndAnalyzeImage(
    ImageSource source,
    ThemeProvider theme,
  ) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: source);
      if (image == null) return;

      setState(() {
        _selectedImage = File(image.path);
        _isAnalyzing = true;
        _selectedCategory = null;
        _isAiSelected = false; // Yeni resim seçilince sıfırla
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
          _isAiSelected = true; // YENİ: Sadece AI bulursa true yap
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${theme.translate('toast_ai_found')} $detectedLabel (%${(confidence * 100).toInt()})',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        setState(() {
          _selectedCategory = 'DIGER';
          _isAiSelected =
              true; // Nesne bulamayıp "Diğer" seçse bile AI kararıdır
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(theme.translate('toast_no_obj')),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Görsel analiz hatası: $e')));
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  void _showImageSourceSelection(BuildContext context, ThemeProvider theme) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  theme.translate('pick_source'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.blue),
                title: Text(theme.translate('camera')),
                onTap: () {
                  Navigator.pop(bc);
                  _pickAndAnalyzeImage(ImageSource.camera, theme);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: Text(theme.translate('gallery')),
                onTap: () {
                  Navigator.pop(bc);
                  _pickAndAnalyzeImage(ImageSource.gallery, theme);
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
    final theme = Provider.of<ThemeProvider>(context);

    // Kırmızı çerçeve gösterilecek mi?
    // Sadece "Gönder" butonuna basılmışsa VE resim yoksa kırmızı olsun.
    bool showImageError = _formSubmitted && _selectedImage == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(theme.translate('complaint_title')),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
            tooltip: 'Konumu Yenile',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FOTOĞRAF ALANI (ZORUNLU)
            Center(
              child: GestureDetector(
                onTap: () => _showImageSourceSelection(context, theme),
                child: Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      // Sadece hata varsa kırmızı, yoksa gri
                      color: showImageError
                          ? Colors.red.shade300
                          : Colors.grey.shade400,
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
                              // Sadece hata varsa kırmızı
                              color: showImageError
                                  ? Colors.red.shade300
                                  : Colors.grey[600],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              theme.translate('photo_label') +
                                  (showImageError ? " (Zorunlu!)" : ""),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                // Sadece hata varsa kırmızı
                                color: showImageError
                                    ? Colors.red
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              theme.translate('photo_ai_hint'),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      : _isAnalyzing
                      ? Container(
                          color: Colors.black45,
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(height: 10),
                                Text(
                                  "Yapay Zeka Analiz Ediyor...",
                                  style: TextStyle(color: Colors.white),
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

            // KONUM ALANI
            Text(
              theme.translate('location_auto'),
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
                          style: TextStyle(color: Colors.grey[700]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
                TextButton.icon(
                  onPressed: _pickLocationFromMap,
                  icon: const Icon(Icons.map, size: 18),
                  label: const Text("Haritadan Seç"),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )
              ],
            ),

            const Divider(height: 30),

            // KATEGORİ ALANI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  theme.translate('issue_type'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // YENİ: Sadece AI Seçimi (Resim kaynaklı) varsa Chip'i göster
                if (_selectedCategory != null &&
                    _selectedCategory != 'DIGER' &&
                    _isAiSelected)
                  Chip(
                    label: Text(
                      theme.translate('ai_selected'),
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
                fillColor: Colors.grey[50],
              ),
              hint: Text(theme.translate('issue_type')),
              value: _selectedCategory,
              items: [
                DropdownMenuItem(
                  value: 'CUKUR',
                  child: Text(theme.translate('cat_pothole')),
                ),
                DropdownMenuItem(
                  value: 'KIRIK_BANK',
                  child: Text(theme.translate('cat_bench')),
                ),
                DropdownMenuItem(
                  value: 'COPLUK',
                  child: Text(theme.translate('cat_garbage')),
                ),
                DropdownMenuItem(
                  value: 'ELEKTRIK',
                  child: Text(theme.translate('cat_electric')),
                ),
                DropdownMenuItem(
                  value: 'TRAFIK',
                  child: Text(theme.translate('cat_traffic')),
                ),
                DropdownMenuItem(
                  value: 'SCOOTER',
                  child: Text(theme.translate('cat_scooter')),
                ),
                DropdownMenuItem(
                  value: 'POSTER',
                  child: Text(theme.translate('cat_poster')),
                ),
                DropdownMenuItem(
                  value: 'AGAC',
                  child: Text(theme.translate('cat_tree')),
                ),
                DropdownMenuItem(
                  value: 'DIGER',
                  child: Text(theme.translate('cat_other')),
                ),
              ],
              onChanged: (String? newValue) {
                // Kullanıcı eliyle değiştirdiğinde AI seçimi bayrağını kaldır
                setState(() {
                  _selectedCategory = newValue;
                  _isAiSelected = false;
                });
              },
            ),

            const Divider(height: 30),

            // AÇIKLAMA ALANI (OPSİYONEL)
            Row(
              children: [
                Text(
                  theme.translate('desc_label'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  "(İsteğe Bağlı)",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: theme.translate('desc_hint'),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),

            const SizedBox(height: 30),

            // GÖNDER BUTONU
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
                      ? 'GÖNDERİLİYOR...'
                      : theme.translate('btn_submit'),
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
