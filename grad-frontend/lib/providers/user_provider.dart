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

  // A function that safely parses nested JSON objects received from the backend
  Map<String, dynamic> _extractUserData(dynamic response) {
    if (response is! Map<String, dynamic>) return {};

    // Case 1: If the backend returns { “success”: true, “data”: { ‘user’: {...}, “statistics”: {...} } }
    if (response.containsKey('data')) {
      final data = response['data'];
      
      // GetProfile request status
      if (data is Map<String, dynamic> && data.containsKey('user')) {
        return data['user'] as Map<String, dynamic>;
      }
      
      // UpdateProfile request status (returns the user directly)
      if (data is Map<String, dynamic>) {
        return data;
      }
    }

    // Case 2: If the ApiClient has already retrieved and sent the data
    if (response.containsKey('user')) {
      return response['user'] as Map<String, dynamic>;
    }

    // If none of the above, use the response itself
    return response;
  }

  /// Fetch user profile from API
  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _userService.getProfile();
      
      // Safely open the package and retrieve the user's actual data
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
      
      // Safely open the updated package
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