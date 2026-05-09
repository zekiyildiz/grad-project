import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; 
import 'package:latlong2/latlong.dart'; 
import 'package:geocoding/geocoding.dart'; 
import '../providers/user_provider.dart';
import 'location_picker_screen.dart'; 

/// A defensive session cache manager that stores user profile data statically in device memory (RAM),
/// thereby preventing unnecessary API calls and UI flickering during page transitions.
class ProfileSessionCache {
  static String? userEmail;
  static String? name;
  static String? phone;
  static String? address;

  static void update(String email, String n, String p, String a) {
    userEmail = email.trim().toLowerCase(); 
    name = n.trim();
    phone = p.trim();
    address = a.trim();
  }

  static void checkUser(String currentEmail) {
    String safeEmail = currentEmail.trim().toLowerCase();
    if (safeEmail.isEmpty) return; // Prevents it from being deleted upon loading
    
    if (userEmail == null) {
      userEmail = safeEmail;
      return;
    }

    if (userEmail != safeEmail) {
      userEmail = safeEmail;
      name = null;
      phone = null;
      address = null;
    }
  }
}

class EditProfileScreen extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String initialPhone;
  final String initialAddress;

  const EditProfileScreen({
    Key? key,
    required this.initialName,
    required this.initialEmail,
    required this.initialPhone,
    required this.initialAddress,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  String _selectedCountryCode = '+90';
  
  final Map<String, int> _phoneLengths = {
    '+90': 10 // To avoid any issues on the backend, only +90 for now
  };

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // An algorithm that parses phone numbers of unknown format retrieved from the database;
    // identifies the country code, removes leading zeros, and standardizes the data to meet UI formatting requirements.
    String rawPhone = widget.initialPhone.trim();
    String parsedNumber = rawPhone;

    for (var code in _phoneLengths.keys) {
      if (rawPhone.startsWith(code)) {
        _selectedCountryCode = code;
        parsedNumber = rawPhone.substring(code.length).trim();
        break;
      }
    }
    
    if (parsedNumber.startsWith('0')) parsedNumber = parsedNumber.substring(1).trim();

    int maxLen = _phoneLengths[_selectedCountryCode] ?? 10;
    if (parsedNumber.length > maxLen) parsedNumber = parsedNumber.substring(0, maxLen);

    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _phoneController = TextEditingController(text: parsedNumber); 
    
    String addr = widget.initialAddress;
    if (addr.toLowerCase().contains('belirtilmemiş') || addr.toLowerCase().contains('unknown') || addr.toLowerCase().contains('not specified')) addr = '';
    _addressController = TextEditingController(text: addr);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _showInfoPopup(String message) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(width: 8),
            Text('edit_prof_info_title'.tr(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 14, height: 1.4, color: isDark ? Colors.grey.shade300 : Colors.grey.shade800),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('ok_btn'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  /// A module that converts raw GPS coordinates from a map into meaningful street addresses. It includes a 5-second timeout protection 
  /// against network delays; if the service does not respond, it uses the raw coordinates as a fallback instead of locking up the system.
  Future<void> _pickLocationFromMap() async {
    final startPos = const LatLng(39.9334, 32.8597); 
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LocationPickerScreen(initialPosition: startPos)),
    );

    if (result != null && result is Map) {
      LatLng newPos = result['position'];
      String addressDesc = result['address'] ?? '';

      setState(() => _isLoading = true); 

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(newPos.latitude, newPos.longitude).timeout(const Duration(seconds: 5));
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          String newAddress = '${place.thoroughfare ?? ''} ${place.subThoroughfare ?? ''}, ${place.subLocality ?? ''}, ${place.administrativeArea ?? ''}';
          newAddress = newAddress.replaceAll(' ,', ',').replaceAll(RegExp(r'^,|,$'), '').trim();

          if (mounted) {
            setState(() {
              _addressController.text = newAddress.isEmpty ? addressDesc : newAddress;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _addressController.text = addressDesc.isNotEmpty ? addressDesc : "${newPos.latitude.toStringAsFixed(4)}, ${newPos.longitude.toStringAsFixed(4)}";
          });
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      String finalPhone = "$_selectedCountryCode${_phoneController.text.trim()}";

      await userProvider.updateProfile(
        name: _nameController.text.trim(), 
        phone: finalPhone, 
        address: _addressController.text.trim()
      );

      // Update the memory in the safest way possible
      ProfileSessionCache.update(
        _emailController.text, 
        _nameController.text, 
        finalPhone, 
        _addressController.text
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil başarıyla güncellendi!'), backgroundColor: Colors.green));
      Navigator.pop(context, true); 
      
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    int maxDigits = _phoneLengths[_selectedCountryCode] ?? 10; 

    return Scaffold(
      appBar: AppBar(title: Text('edit_prof_title'.tr(),style: const TextStyle(
      fontWeight: FontWeight.bold,),), backgroundColor: const Color(0xFF4094FF), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey, 
          child: Column(
            children: [
              const Center(child: CircleAvatar(radius: 50, backgroundColor: Colors.blue, child: Icon(Icons.person, size: 60, color: Colors.white))),
              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.blue.withOpacity(0.3))),
                child: Row(
                  children: [
                    const Icon(Icons.security, color: Colors.blue, size: 28),
                    const SizedBox(width: 12),
                    Expanded(child: Text('edit_prof_security_notice'.tr(), style: TextStyle(color: isDark ? Colors.blue.shade200 : Colors.blue.shade800, fontSize: 13, fontWeight: FontWeight.w500))),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              TextFormField(
                controller: _nameController,
                readOnly: true, 
                decoration: _inputDecoration('prof_name'.tr(), Icons.person, isDark).copyWith(
                  fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  suffixIcon: IconButton(icon: Icon(Icons.info_outline, color: Colors.blue.shade400, size: 24), onPressed: () => _showInfoPopup('edit_prof_name_tooltip'.tr())),
                ),
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _emailController,
                readOnly: true, 
                decoration: _inputDecoration('prof_email'.tr(), Icons.email, isDark).copyWith(
                  fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  suffixIcon: IconButton(icon: Icon(Icons.info_outline, color: Colors.blue.shade400, size: 24), onPressed: () => _showInfoPopup('edit_prof_email_tooltip'.tr())),
                ),
              ),
              const SizedBox(height: 15),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(color: isDark ? Colors.grey.shade900 : Colors.grey.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCountryCode,
                        isExpanded: true,
                        dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
                        items: _phoneLengths.keys.map((code) => DropdownMenuItem(value: code, child: Text(code, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                        onChanged: (val) => setState(() {
                           _selectedCountryCode = val!;
                           int newMax = _phoneLengths[val] ?? 10;
                           if (_phoneController.text.length > newMax) _phoneController.text = _phoneController.text.substring(0, newMax);
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone, 
                      maxLength: maxDigits, 
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'prof_phone'.tr(),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true, fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50, counterText: "${_phoneController.text.length} / $maxDigits", 
                      ),
                      onChanged: (value) {
                        if (value.startsWith('0')) {
                          _phoneController.text = value.substring(1);
                          _phoneController.selection = TextSelection.fromPosition(TextPosition(offset: _phoneController.text.length));
                        }
                        setState(() {}); 
                      }, 
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'edit_prof_err_required'.tr();
                        if (value.length != maxDigits) return 'edit_prof_phone_err_length'.tr(args: [maxDigits.toString()]);
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'prof_address'.tr(),
                  prefixIcon: const Icon(Icons.home, color: Colors.blue),
                  suffixIcon: IconButton(icon: const Icon(Icons.map, color: Colors.red, size: 30), onPressed: _pickLocationFromMap, tooltip: 'Haritadan Konum Seç'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true, fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'edit_prof_err_required_map'.tr() : null,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9C27B0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text('prof_save'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, bool isDark) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blue),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
    );
  }
}