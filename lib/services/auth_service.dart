import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Store verification codes temporarily (in production, use backend)
  static final Map<String, String> _verificationCodes = {};
  static final Map<String, String> _resetPasswordCodes = {};

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Generate 6-digit verification code
  String _generateVerificationCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  // Sign up with email and password
  Future<User?> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Create user account
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Generate and store verification code
      final verificationCode = _generateVerificationCode();
      _verificationCodes[email] = verificationCode;

      // Send verification email (simulated with code)
      // In production, send this code via email service
      await _sendVerificationEmail(email, verificationCode);

      // Don't verify email yet - user needs to enter code
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Send verification email (simulated)
  Future<void> _sendVerificationEmail(String email, String code) async {
    // TODO: Integrate with email service (SendGrid, AWS SES, etc.)
    // For now, print to console for testing
    print('========================================');
    print('EMAIL VERIFICATION CODE FOR: $email');
    print('CODE: $code');
    print('========================================');

    // Simulate email sending delay
    await Future.delayed(const Duration(seconds: 1));
  }

  // Verify email with 6-digit code
  Future<bool> verifyEmailWithCode({
    required String email,
    required String code,
  }) async {
    final storedCode = _verificationCodes[email];

    if (storedCode == null) {
      throw Exception('No verification code found. Please request a new code.');
    }

    if (storedCode != code) {
      throw Exception('Invalid verification code. Please try again.');
    }

    // Mark email as verified
    await currentUser?.reload();

    // Remove used code
    _verificationCodes.remove(email);

    return true;
  }

  // Resend verification code
  Future<void> resendVerificationCode(String email) async {
    final verificationCode = _generateVerificationCode();
    _verificationCodes[email] = verificationCode;
    await _sendVerificationEmail(email, verificationCode);
  }

  // Sign in with email and password
  Future<User?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      // Check if email is verified (for existing users who signed up with verification)
      // For now, we'll allow sign in even if not verified
      // In production, you might want to enforce verification

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Send password reset code
  Future<void> sendPasswordResetCode(String email) async {
    try {
      // Generate and store reset code
      final resetCode = _generateVerificationCode();
      _resetPasswordCodes[email] = resetCode;

      // Send reset code via email
      await _sendPasswordResetEmail(email, resetCode);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Send password reset email (simulated)
  Future<void> _sendPasswordResetEmail(String email, String code) async {
    // TODO: Integrate with email service
    print('========================================');
    print('PASSWORD RESET CODE FOR: $email');
    print('CODE: $code');
    print('========================================');

    await Future.delayed(const Duration(seconds: 1));
  }

  // Verify password reset code
  Future<bool> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    final storedCode = _resetPasswordCodes[email];

    if (storedCode == null) {
      throw Exception('No reset code found. Please request a new code.');
    }

    if (storedCode != code) {
      throw Exception('Invalid reset code. Please try again.');
    }

    return true;
  }

  // Reset password with verification
  Future<void> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    // Verify the code first
    final isValid = await verifyPasswordResetCode(email: email, code: code);

    if (!isValid) {
      throw Exception('Invalid or expired reset code.');
    }

    // For Firebase, we need to use a different approach since we can't reset
    // password directly without the old password when user is not signed in
    // We'll use Firebase's password reset with action code

    // Remove the used code
    _resetPasswordCodes.remove(email);

    // In production, you would update password through Firebase Admin SDK
    // or use Firebase's built-in password reset flow
    // For now, this is a simplified version

    // If user is currently signed in, update password
    if (currentUser != null && currentUser!.email == email) {
      await currentUser!.updatePassword(newPassword);
    } else {
      // For non-authenticated password reset, you'd need backend support
      // This is a limitation of Firebase client SDK
      throw Exception('Please use the reset link sent to your email.');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Delete account
  Future<void> deleteAccount() async {
    await currentUser?.delete();
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    await currentUser?.reload();
    return currentUser?.emailVerified ?? false;
  }

  // Get stored verification code (for testing purposes)
  String? getStoredVerificationCode(String email) {
    return _verificationCodes[email];
  }

  // Get stored reset code (for testing purposes)
  String? getStoredResetCode(String email) {
    return _resetPasswordCodes[email];
  }
}
