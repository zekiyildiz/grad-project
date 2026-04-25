import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/api_client.dart';

/// User Provider for profile management
class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  
  UserModel? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Backend'den gelen iç içe JSON paketlerini güvenle açan fonksiyon
  Map<String, dynamic> _extractUserData(dynamic response) {
    if (response is! Map<String, dynamic>) return {};

    // 1. Durum: Backend { "success": true, "data": { "user": {...}, "statistics": {...} } } dönüyorsa
    if (response.containsKey('data')) {
      final data = response['data'];
      
      // GetProfile isteği durumu
      if (data is Map<String, dynamic> && data.containsKey('user')) {
        return data['user'] as Map<String, dynamic>;
      }
      
      // UpdateProfile isteği durumu (direkt user döner)
      if (data is Map<String, dynamic>) {
        return data;
      }
    }

    // 2. Durum: Eğer ApiClient data'yı zaten dışarı çıkartıp gönderdiyse
    if (response.containsKey('user')) {
      return response['user'] as Map<String, dynamic>;
    }

    // Hiçbiri değilse response'un kendisini kullan
    return response;
  }

  /// Fetch user profile from API
  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _userService.getProfile();
      
      // Paketi güvenle aç ve kullanıcının gerçek verilerini al
      final userData = _extractUserData(response); 
      
      _profile = UserModel.fromJson(userData);
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Profil bilgileri yüklenemedi';
      notifyListeners();
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _userService.updateProfile(
        name: name,
        phone: phone,
        address: address,
      );
      
      // Güncellenmiş paketi güvenle aç
      final userData = _extractUserData(response);
      
      _profile = UserModel.fromJson(userData);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Profil güncellenemedi';
      notifyListeners();
      return false;
    }
  }

  /// Set profile from auth response
  void setProfile(UserModel user) {
    _profile = user;
    notifyListeners();
  }

  /// Clear profile data (on logout)
  void clearProfile() {
    _profile = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}