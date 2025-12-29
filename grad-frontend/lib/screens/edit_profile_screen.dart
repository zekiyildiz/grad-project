import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Sadece rakam girişi için gerekli kütüphane

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Formun geçerliliğini kontrol etmek için anahtar
  final _formKey = GlobalKey<FormState>();

  // Kutucukların içindeki yazıları kontrol eden araçlar
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Sayfa açıldığında kutucuklarda varsayılan olarak ne yazsın?
    _nameController = TextEditingController(text: 'AHMET YILMAZ');
    _emailController = TextEditingController(text: 'ahmet@mail.com');
    _phoneController = TextEditingController(
      text: '5555555555',
    ); // Başında 0 olmadan
    _addressController = TextEditingController(text: 'Çankaya, Ankara');
  }

  @override
  void dispose() {
    // Sayfa kapanınca hafızayı temizle
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Kaydet Butonuna Basılınca Çalışacak Fonksiyon
  Future<void> _saveProfile() async {
    // 1. ADIM: Form kurallarına uyulmuş mu kontrol et?
    if (!_formKey.currentState!.validate()) {
      // Eğer hata varsa (mesela telefon 9 haneyse) işlemi durdur.
      return;
    }

    setState(() => _isLoading = true);

    // Sanki sunucuya kaydediyormuş gibi 1.5 saniye bekle (Görsel efekt)
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    setState(() => _isLoading = false);

    // Başarı mesajı göster
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Değişiklikler şimdilik yerel olarak doğrulandı! ✅ (Backend bekleniyor)',
        ),
        backgroundColor: Colors.green,
      ),
    );

    // Bir önceki sayfaya dön
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profili Düzenle'),
        backgroundColor: const Color(0xFF4094FF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey, // Form anahtarını buraya bağlıyoruz
          child: Column(
            children: [
              // --- PROFİL FOTOĞRAFI (Görsel) ---
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade200,
                      child: const Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Fotoğrafı Değiştir',
                style: TextStyle(color: Colors.blue.shade700),
              ),

              const SizedBox(height: 30),

              // --- 1. İSİM ALANI ---
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Ad Soyad', Icons.person),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen adınızı giriniz';
                  }
                  return null; // Hata yok
                },
              ),
              const SizedBox(height: 15),

              // --- 2. E-POSTA ALANI ---
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration('E-posta', Icons.email),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'E-posta boş olamaz';
                  if (!value.contains('@'))
                    return 'Geçerli bir mail adresi giriniz';
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // --- 3. TELEFON ALANI (ÖZEL KURALLI) ---
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.number, // Klavye sadece sayı açar
                maxLength: 10, // En fazla 10 karakter yazılabilir
                // Sadece ve sadece rakam girilmesine izin verir (Harf, virgül vb. engeller)
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],

                decoration: InputDecoration(
                  labelText: 'Telefon Numarası',
                  prefixText: '+90 ', // Başında otomatik +90 yazar, silinemez
                  prefixIcon: const Icon(Icons.phone, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  counterText: "", // Sağ alttaki 10/10 yazısını gizler
                ),

                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Telefon numarası giriniz';
                  if (value.startsWith('0'))
                    return 'Lütfen başında 0 olmadan giriniz';
                  if (value.length != 10)
                    return 'Numara 10 haneli olmalı (Örn: 5XX...)';
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // --- 4. ADRES ALANI ---
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: _inputDecoration('Adres', Icons.home),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Adres boş bırakılamaz';
                  return null;
                },
              ),

              const SizedBox(height: 40),

              // --- KAYDET BUTONU ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C27B0), // Mor renk
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Değişiklikleri Kaydet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tasarım tekrarı olmasın diye yardımcı bir stil fonksiyonu
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blue),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}
