import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_gris/providers/user_provider.dart';
import 'package:ai_gris/providers/translation_provider.dart';
import 'package:ai_gris/providers/patient_profile_provider.dart';
import 'package:ai_gris/providers/doctor_profile_provider.dart';
import 'package:ai_gris/config/router.dart';
import 'package:ai_gris/constants/colors.dart';
import 'package:ai_gris/constants/app_constants.dart';
import 'package:google_fonts/google_fonts.dart';

/// Helper function to setup Firebase mocks for testing
/// This prevents the "Undefined is not an object" Firebase error
void setupFirebaseMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences with mock values
  SharedPreferences.setMockInitialValues({});

  // Firebase mocks are now set up automatically via firebase_auth_mocks
}

/// Creates a mock Firebase Auth instance for testing
MockFirebaseAuth createMockFirebaseAuth({
  bool signedIn = false,
  MockUser? mockUser,
}) {
  final user = mockUser ??
      MockUser(
        uid: 'test-user-id',
        email: 'test@example.com',
        displayName: 'Test User',
        isEmailVerified: true,
      );

  return MockFirebaseAuth(
    signedIn: signedIn,
    mockUser: user,
  );
}

/// Wraps a widget with all necessary providers for testing
/// This ensures the widget tree has access to all app providers
Widget createTestApp({
  required Widget child,
  UserProvider? userProvider,
  TranslationProvider? translationProvider,
  PatientProfileProvider? userProfileProvider,
  DoctorProfileProvider? doctorProfileProvider,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<UserProvider>(
        create: (_) => userProvider ?? UserProvider(),
      ),
      ChangeNotifierProvider<TranslationProvider>(
        create: (_) => translationProvider ?? TranslationProvider(),
      ),
      ChangeNotifierProvider<PatientProfileProvider>(
        create: (_) => userProfileProvider ?? PatientProfileProvider(),
      ),
      ChangeNotifierProvider<DoctorProfileProvider>(
        create: (_) => doctorProfileProvider ?? DoctorProfileProvider(),
      ),
    ],
    child: MaterialApp(
      home: child,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
        ),
        textTheme: GoogleFonts.interTextTheme(),
      ),
    ),
  );
}

/// Creates the full AiGrisApp for integration testing
Widget createAiGrisAppForTest() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => UserProvider()),
      ChangeNotifierProvider(create: (_) => TranslationProvider()),
      ChangeNotifierProvider(create: (_) => PatientProfileProvider()),
      ChangeNotifierProvider(create: (_) => DoctorProfileProvider()),
    ],
    child: MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: AppColors.background,
      ),
      routerConfig: AppRouter.router,
    ),
  );
}

/// Pumps and settles the widget tree with a longer timeout for complex UIs
Future<void> pumpAndSettleSafely(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  await tester.pumpAndSettle(timeout);
}
