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

  /// Fetch user profile from API
  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _userService.getProfile();
      _profile = UserModel.fromJson(response['user'] ?? response);
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
      
      _profile = UserModel.fromJson(response['user'] ?? response);
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
