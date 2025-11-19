import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Mock AuthService for testing that doesn't require Firebase initialization
class MockAuthService {
  final MockFirebaseAuth _mockAuth;

  MockAuthService({MockFirebaseAuth? mockAuth})
      : _mockAuth = mockAuth ?? MockFirebaseAuth();

  User? get currentUser => _mockAuth.currentUser;

  Future<User?> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final userCredential = await _mockAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  Future<User?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final userCredential = await _mockAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  Future<void> signOut() async {
    await _mockAuth.signOut();
  }

  Future<void> sendPasswordResetCode(String email) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<bool> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 100));
    return code == '123456'; // Mock verification
  }

  Future<void> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> verifyEmailWithCode({
    required String email,
    required String code,
  }) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> resendVerificationCode(String email) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 100));
  }

  String? getStoredVerificationCode(String email) {
    return '123456'; // Mock code
  }

  String? getStoredResetCode(String email) {
    return '123456'; // Mock code
  }
}
