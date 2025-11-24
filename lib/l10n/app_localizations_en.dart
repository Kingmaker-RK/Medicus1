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
  String get signIn => 'Login';

  @override
  String get signUp => 'Register';

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
  String get signUpFailed => 'Register failed. Please try again.';

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

  @override
  String get registrationTitle => 'Registration';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get dob => 'Date of Birth';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get other => 'Other';

  @override
  String get accountSetup => 'Account Setup';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get verifyHuman => 'Verify you are human';

  @override
  String get continueText => 'Continue';

  @override
  String get done => 'Done';

  @override
  String get requiredField => 'This field is required';

  @override
  String get invalidDate => 'Invalid date';

  @override
  String get selectDate => 'Select Date';
}
