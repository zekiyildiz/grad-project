import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';

/// Authentication state enum
enum AuthState { initial, loading, authenticated, unauthenticated, error }

/// Auth Provider for managing authentication state
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // The initial state should be ‘initial’ (we are not using direct authentication)
  AuthState _state = AuthState.initial;
  UserModel? _user;
  String? _errorMessage;

  // Getters
  AuthState get state => _state;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;

  // Role-based getters
  int? get userRoleId => _user?.roleId;
  bool get isAdmin => _user?.roleId == 0;
  bool get isEmployee => _user?.roleId == 2;

  /// Initialize auth state - check if user is already logged in
  /// Checks for invalid tokens
  Future<void> init() async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      // Is there a token in memory?
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        // If a token exists, attempt to retrieve the user's information from the server
        final userData = await _authService.getCurrentUser();

        // If empty data is received from the server or the data is corrupted, throw an error
        // This prevents the page from behaving as if a login has been made and opening a blank page
        if (userData == null ||
            (userData['user'] == null && userData['email'] == null)) {
          throw Exception("Kullanıcı verisi eksik/bozuk");
        }

        // Convert the data into a model
        _user = UserModel.fromJson(userData['user'] ?? userData);

        // Do not accept if the email is empty
        if (_user?.email == null || _user!.email!.isEmpty) {
          throw Exception("Kullanıcı profili hatalı");
        }

        // If everything is okay, consider the login successful
        _state = AuthState.authenticated;
      } else {
        // If there is no token, the user is considered not logged in
        _state = AuthState.unauthenticated;
      }
    } catch (e) {
      // ERROR: Token has expired, server is down, or data is corrupted
      print("⚠️ Auth Init Hatası (Bozuk Token Temizleniyor): $e");

      // Clear the invalid token so it doesn't get stuck in an infinite loop
      await _authService.logout();
      _user = null;

      // Redirect the user to the login screen
      _state = AuthState.unauthenticated;
      _errorMessage = null; // Do not display an error message at startup
    }

    notifyListeners();
  }

  /// Login with email and password
  Future<bool> login({required String email, required String password}) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      print('🟡 Login Response: $response');

      if (response['user'] != null) {
        print('🟡 User Data: ${response['user']}');
        _user = UserModel.fromJson(response['user']);
        print('🟡 Parsed User: name=${_user!.name}, email=${_user!.email}');
      } else {
        print('🔴 No user data in response');
        throw Exception("Kullanıcı verisi alınamadı");
      }

      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _state = AuthState.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'Giriş yapılırken bir hata oluştu';
      notifyListeners();
      return false;
    }
  }

  /// Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? district,
    String? neighborhood,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
        district: district,
        neighborhood: neighborhood,
      );

      if (response['user'] != null) {
        _user = UserModel.fromJson(response['user']);
      }

      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _state = AuthState.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'Kayıt yapılırken bir hata oluştu';
      notifyListeners();
      return false;
    }
  }

  /// Request password reset
  Future<bool> forgotPassword({required String email}) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.forgotPassword(email: email);
      // After resetting the password, we can redirect to the login screen or display a message
      // Here, we simply return “success” without changing the state
      _state = AuthState.unauthenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _state = AuthState.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'Şifre sıfırlama isteği gönderilemedi';
      notifyListeners();
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      print("Logout hatası: $e");
    }
    _user = null;
    _state = AuthState.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  /// Update current user data
  void updateUser(UserModel user) {
    _user = user;
    notifyListeners();
  }
}
