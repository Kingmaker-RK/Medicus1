import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../constants/app_constants.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/localization_service.dart';
import '../services/llm_translation_service.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService;
  final DatabaseService _databaseService;
  final LocalizationService _localizationService = LocalizationService();

  UserProvider({AuthService? authService, DatabaseService? databaseService})
      : _authService = authService ?? AuthService(),
        _databaseService = databaseService ?? DatabaseService();

  UserModel? _currentUser;
  String _selectedLanguage = 'en';
  bool _isLoading = false;
  bool _sortServicesByUsage = false;
  Map<String, int> _serviceUsageCounts = {};

  UserModel? get currentUser => _currentUser;
  String get selectedLanguage => _selectedLanguage;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get sortServicesByUsage => _sortServicesByUsage;
  Map<String, int> get serviceUsageCounts => _serviceUsageCounts;

  // Initialize user from storage
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Initialize localization service
      _localizationService.initialize();

      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;

      if (isLoggedIn) {
        final userId = prefs.getString(AppConstants.keyUserId);
        
        if (userId != null) {
          // Try to fetch latest data from Firestore
          try {
             final userFromDb = await _databaseService.getUser(userId);
             if (userFromDb != null) {
               _currentUser = userFromDb;
               _selectedLanguage = userFromDb.languageCode;
             } else {
               // Fallback to local storage if not found in DB (shouldn't happen often)
               final role = prefs.getString(AppConstants.keyUserRole) ?? AppConstants.rolePatient;
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
          } catch (e) {
             print('Error fetching user from DB: $e');
             // Fallback to local storage on error
             final role = prefs.getString(AppConstants.keyUserRole) ?? AppConstants.rolePatient;
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
        }
      }

      final savedLanguage = prefs.getString(AppConstants.keyLanguage);
      if (savedLanguage != null) {
        _selectedLanguage = savedLanguage;
      }

      // Load service sorting preference
      _sortServicesByUsage = prefs.getBool(AppConstants.keySortServicesByUsage) ?? false;

      // Load service usage counts
      final usageCountsString = prefs.getString(AppConstants.keyServiceUsageCounts);
      if (usageCountsString != null) {
        try {
          final decoded = jsonDecode(usageCountsString) as Map<String, dynamic>;
          _serviceUsageCounts = decoded.map((key, value) => MapEntry(key, value as int));
        } catch (e) {
          print('Error loading service usage counts: $e');
        }
      }

      // Set initial language in localization service
      await _localizationService.setLanguage(_selectedLanguage);
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

      // Authenticate with Firebase
      final user = await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );

      if (user != null) {
        // Fetch user profile from Firestore
        UserModel? userModel = await _databaseService.getUser(user.uid);

        if (userModel == null) {
          // If user exists in Auth but not in Firestore, create a profile
          userModel = UserModel(
            id: user.uid,
            email: email,
            role: role,
            languageCode: _selectedLanguage,
          );
          await _databaseService.saveUser(userModel);
        }

        _currentUser = userModel;
        _selectedLanguage = userModel.languageCode;

        // Save to storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(AppConstants.keyIsLoggedIn, true);
        await prefs.setString(AppConstants.keyUserId, _currentUser!.id!);
        await prefs.setString(AppConstants.keyUserRole, _currentUser!.role);
        await prefs.remove(AppConstants.keyIsSignUp); // Clear sign-up flag
        
        // Update language preference if different
        await prefs.setString(AppConstants.keyLanguage, _currentUser!.languageCode);
        await _localizationService.setLanguage(_currentUser!.languageCode);

        // Save Remember Me preference
        await prefs.setBool('rememberMe', rememberMe);
        if (rememberMe) {
          await prefs.setString('savedEmail', email);
        } else {
          await prefs.remove('savedEmail');
        }
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
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    required String gender,
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
        emailGenerator: (code) async {
          return await LLMTranslationService().generateWelcomeEmail(
            userName: '$firstName $lastName',
            appName: 'AI-Gris',
            verificationCode: code,
            languageCode: _selectedLanguage,
          );
        },
      );

      if (user != null) {
        _currentUser = UserModel(
          id: user.uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
          dateOfBirth: dateOfBirth,
          gender: gender,
          role: role,
          languageCode: _selectedLanguage,
        );

        // Save user to Firestore
        await _databaseService.saveUser(_currentUser!);

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
    await _authService.signOut();
    notifyListeners();
  }

  // Change language with immediate UI update
  Future<void> changeLanguage(String languageCode) async {
    print('🎯 UserProvider.changeLanguage: Changing language to $languageCode');
    print('🎯 UserProvider.changeLanguage: Previous language was $_selectedLanguage');

    try {
      _selectedLanguage = languageCode;

      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(languageCode: languageCode);
        print('🎯 UserProvider.changeLanguage: Updated user model with new language');
        
        // Save to Firestore if user is not guest
        if (!_currentUser!.isGuest) {
          await _databaseService.saveUser(_currentUser!);
          print('🎯 UserProvider.changeLanguage: Saved language to Firestore');
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyLanguage, languageCode);
      print('🎯 UserProvider.changeLanguage: Saved language to SharedPreferences');

      // Update localization service for instant UI translation
      print('🎯 UserProvider.changeLanguage: Updating LocalizationService...');
      await _localizationService.setLanguage(languageCode);
      print('🎯 UserProvider.changeLanguage: LocalizationService updated');

      print('✅ UserProvider.changeLanguage: Language change complete!');
    } catch (e) {
      print('❌ UserProvider.changeLanguage: Error changing language - $e');
      // Still update the language even if some operations failed
      _selectedLanguage = languageCode;
    } finally {
      // Always notify listeners to ensure UI updates
      print('🎯 UserProvider.changeLanguage: Calling notifyListeners() to rebuild UI');
      notifyListeners();
    }
  }

  // Change role
  Future<void> changeRole(String role) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(role: role);
      notifyListeners();
      
      // Save to Firestore if user is not guest
      if (!_currentUser!.isGuest) {
        try {
          await _databaseService.saveUser(_currentUser!);
        } catch (e) {
          print('Error updating role in DB: $e');
        }
      }
    }
  }

  // Toggle service sorting preference
  Future<void> toggleServiceSorting() async {
    _sortServicesByUsage = !_sortServicesByUsage;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keySortServicesByUsage, _sortServicesByUsage);
  }

  // Increment usage count for a service
  Future<void> incrementServiceUsage(String serviceRoute) async {
    _serviceUsageCounts[serviceRoute] = (_serviceUsageCounts[serviceRoute] ?? 0) + 1;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.keyServiceUsageCounts,
      jsonEncode(_serviceUsageCounts),
    );
  }

  Future<String> getAILocationSuggestion() async {
    // In a real app, this would use AI to suggest a location based on user data.
    // For now, we'll return a hardcoded value.
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    return 'Munich';
  }
}
