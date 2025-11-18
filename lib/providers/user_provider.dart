import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../constants/app_constants.dart';

class UserProvider with ChangeNotifier {
  UserModel? _currentUser;
  String _selectedLanguage = 'en';
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  String get selectedLanguage => _selectedLanguage;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  // Initialize user from storage
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;

      if (isLoggedIn) {
        final userId = prefs.getString(AppConstants.keyUserId);
        final role = prefs.getString(AppConstants.keyUserRole) ?? AppConstants.rolePatient;
        final languageCode = prefs.getString(AppConstants.keyLanguage) ?? 'en';

        _currentUser = UserModel(
          id: userId,
          role: role,
          languageCode: languageCode,
        );
        _selectedLanguage = languageCode;
      }

      final savedLanguage = prefs.getString(AppConstants.keyLanguage);
      if (savedLanguage != null) {
        _selectedLanguage = savedLanguage;
      }
    } catch (e) {
      print('Error initializing user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login user
  Future<void> login({
    required String email,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement actual authentication with Firebase or your backend
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      _currentUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        role: role,
        languageCode: _selectedLanguage,
      );

      // Save to storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyIsLoggedIn, true);
      await prefs.setString(AppConstants.keyUserId, _currentUser!.id!);
      await prefs.setString(AppConstants.keyUserRole, role);
    } catch (e) {
      print('Error logging in: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Continue as guest
  Future<void> continueAsGuest(String role) async {
    _currentUser = UserModel(
      role: role,
      languageCode: _selectedLanguage,
      isGuest: true,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserRole, role);

    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyIsLoggedIn);
    await prefs.remove(AppConstants.keyUserId);

    _currentUser = null;
    notifyListeners();
  }

  // Change language
  Future<void> changeLanguage(String languageCode) async {
    _selectedLanguage = languageCode;

    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(languageCode: languageCode);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyLanguage, languageCode);

    notifyListeners();
  }

  // Change role
  void changeRole(String role) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(role: role);
      notifyListeners();
    }
  }
}
