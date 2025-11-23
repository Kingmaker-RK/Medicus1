// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeTitle => 'Welcome to AI-Gris';

  @override
  String get welcomeSubtitle => 'Breaking language barriers in healthcare';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get agreeToTerms =>
      'I agree to the Terms & Conditions and Privacy Policy';

  @override
  String get pleaseAgreeToTerms =>
      'Please agree to the Terms & Conditions to continue.';

  @override
  String get loginFailed => 'Login failed. Please check your credentials.';

  @override
  String get signUpFailed => 'Sign up failed. Please try again.';

  @override
  String get continueAsGuest => 'Continue as Guest';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get guestTermsMessage =>
      'By continuing as a guest, you agree to our Terms & Conditions and Privacy Policy.';

  @override
  String get viewPolicy => 'View Policy';

  @override
  String get cancel => 'Cancel';

  @override
  String get iAgree => 'I Agree';

  @override
  String get rolePatient => 'Patient';

  @override
  String get roleDoctor => 'Doctor';
}
