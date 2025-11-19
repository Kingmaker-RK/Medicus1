import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../constants/app_constants.dart';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

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
        final role =
            prefs.getString(AppConstants.keyUserRole) ??
            AppConstants.rolePatient;
        final languageCode = prefs.getString(AppConstants.keyLanguage) ?? 'en';
        final savedEmail = prefs.getString('savedEmail');
        final rememberMe = prefs.getBool('rememberMe') ?? false;

        _currentUser = UserModel(
          id: userId,
          role: role,
          languageCode: languageCode,
          email: rememberMe && savedEmail != null ? savedEmail : null,
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

  // Login user (existing user)
  Future<void> login({
    required String email,
    required String password,
    required String role,
    bool rememberMe = false,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Validation for testing forgot password flow
      if (email.isEmpty || !email.contains('@')) {
        throw Exception('Invalid email');
      }
      if (password.isEmpty || password.length < 6) {
        throw Exception('Invalid password');
      }

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
      await prefs.remove(AppConstants.keyIsSignUp); // Clear sign-up flag

      // Save Remember Me preference
      await prefs.setBool('rememberMe', rememberMe);
      if (rememberMe) {
        await prefs.setString('savedEmail', email);
      } else {
        await prefs.remove('savedEmail');
      }
    } catch (e) {
      print('Error logging in: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign up new user
  Future<void> signUp({
    required String email,
    required String password,
    required String role,
    bool rememberMe = false,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Validation
      if (email.isEmpty || !email.contains('@')) {
        throw Exception('Invalid email');
      }
      if (password.isEmpty || password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Sign up with Firebase
      final user = await _authService.signUpWithEmailPassword(
        email: email,
        password: password,
      );

      if (user != null) {
        _currentUser = UserModel(
          id: user.uid,
          email: email,
          role: role,
          languageCode: _selectedLanguage,
        );

        // Save to storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(AppConstants.keyIsLoggedIn, true);
        await prefs.setString(AppConstants.keyUserId, user.uid);
        await prefs.setString(AppConstants.keyUserRole, role);
        await prefs.setBool(AppConstants.keyIsSignUp, true); // Mark as sign-up

        // Save Remember Me preference
        await prefs.setBool('rememberMe', rememberMe);
        if (rememberMe) {
          await prefs.setString('savedEmail', email);
        } else {
          await prefs.remove('savedEmail');
        }
      }
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Verify email with 6-digit code
  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.verifyEmailWithCode(
        email: email,
        code: code,
      );
    } catch (e) {
      print('Error verifying email: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Resend verification code
  Future<void> resendVerificationCode(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.resendVerificationCode(email);
    } catch (e) {
      print('Error resending verification code: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send password reset code
  Future<void> sendPasswordResetCode(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.sendPasswordResetCode(email);
    } catch (e) {
      print('Error sending password reset code: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Verify password reset code
  Future<bool> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      return await _authService.verifyPasswordResetCode(
        email: email,
        code: code,
      );
    } catch (e) {
      print('Error verifying password reset code: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset password
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.resetPasswordWithCode(
        email: email,
        code: code,
        newPassword: newPassword,
      );
    } catch (e) {
      print('Error resetting password: $e');
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

    // Clear remember me data
    final shouldKeepEmail = prefs.getBool('rememberMe') ?? false;
    if (!shouldKeepEmail) {
      await prefs.remove('savedEmail');
    }

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
