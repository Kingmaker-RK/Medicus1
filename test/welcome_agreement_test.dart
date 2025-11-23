import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_gris/screens/welcome_screen.dart';
import 'package:ai_gris/providers/user_provider.dart';
import 'package:ai_gris/models/user_model.dart';
import 'package:ai_gris/providers/translation_provider.dart';
import 'package:ai_gris/providers/patient_profile_provider.dart';
import 'package:ai_gris/providers/doctor_profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'test_helpers.dart';

// Create a MockUserProvider to control auth state and avoid real network calls
class MockUserProvider extends ChangeNotifier implements UserProvider {
  bool _isLoading = false;
  bool _isLoggedIn = false;
  
  @override
  bool get isLoading => _isLoading;
  
  @override
  bool get isLoggedIn => _isLoggedIn;

  @override
  UserModel? get currentUser => null;

  @override
  String get selectedLanguage => 'en';

  @override
  Future<void> login({required String email, required String password, required String role, bool rememberMe = false}) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 100));
    _isLoading = false;
    _isLoggedIn = true;
    notifyListeners();
  }

  @override
  Future<void> signUp({required String email, required String password, required String role, bool rememberMe = false}) async {
     _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 100));
    _isLoading = false;
    _isLoggedIn = true;
    notifyListeners();
  }

  @override
  Future<void> continueAsGuest(String role) async {
     _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 100));
    _isLoading = false;
    notifyListeners();
  }
  
  @override
  Future<void> changeLanguage(String languageCode) async {}
  
  @override
  Future<void> logout() async {}
  
  // Add other required overrides with dummy implementations if needed
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget createTestAppWithRouter(UserProvider userProvider) {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: '/translation', builder: (_, __) => const Scaffold(body: Text('Translation Screen'))),
      GoRoute(path: '/privacy-policy', builder: (_, __) => const Scaffold(body: Text('Privacy Policy'))),
      GoRoute(path: '/verify-email', builder: (_, __) => const Scaffold(body: Text('Verify Email'))),
    ],
  );

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<UserProvider>.value(value: userProvider),
      ChangeNotifierProvider(create: (_) => TranslationProvider()),
      ChangeNotifierProvider(create: (_) => PatientProfileProvider()),
      ChangeNotifierProvider(create: (_) => DoctorProfileProvider()),
    ],
    child: MaterialApp.router(
      routerConfig: router,
    ),
  );
}

void main() {
  setUpAll(() {
    setupFirebaseMocks();
  });

  testWidgets('WelcomeScreen enforces agreement for Sign Up', (WidgetTester tester) async {
    final mockUserProvider = MockUserProvider();
    
    await tester.pumpWidget(createTestAppWithRouter(mockUserProvider));
    await tester.pumpAndSettle();

    // Switch to Sign Up mode
    await tester.tap(find.text('Sign Up'));
    await tester.pump();

    // Verify Checkbox is visible
    // We have two checkboxes (Remember Me and Terms). Identify Terms checkbox by its row content.
    final termsCheckboxFinder = find.descendant(
      of: find.ancestor(
        of: find.textContaining('I agree'),
        matching: find.byType(Row),
      ),
      matching: find.byType(Checkbox),
    );
    expect(termsCheckboxFinder, findsOneWidget);

    // Try to click Sign Up without checking box
    // Note: The button text changes based on mode
    final signUpButton = find.widgetWithText(ElevatedButton, 'Sign Up');
    await tester.ensureVisible(signUpButton);
    await tester.tap(signUpButton);
    await tester.pump();

    // Verify Error SnackBar
    expect(find.text('Please agree to the Terms & Conditions to continue.'), findsOneWidget);

    // Check the box
    await tester.tap(termsCheckboxFinder);
    await tester.pump();

    // Try again
    await tester.tap(signUpButton);
    // Pump long enough for the mock delay
    await tester.pump(const Duration(milliseconds: 200)); 
    await tester.pumpAndSettle();
    
    // Should navigate to verify email
    expect(find.text('Verify Email'), findsOneWidget);
  });

  testWidgets('WelcomeScreen enforces agreement for Guest', (WidgetTester tester) async {
    final mockUserProvider = MockUserProvider();

    await tester.pumpWidget(createTestAppWithRouter(mockUserProvider));
    await tester.pumpAndSettle();

    // Tap Continue as Guest
    final guestButton = find.text('Continue as Guest');
    await tester.ensureVisible(guestButton);
    await tester.tap(guestButton);
    await tester.pumpAndSettle();

    // Verify Dialog appears
    expect(find.text('Terms & Conditions'), findsOneWidget);
    expect(find.text('I Agree'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Tap Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Terms & Conditions'), findsNothing);

    // Tap Guest again
    await tester.tap(guestButton);
    await tester.pumpAndSettle();

    // Tap I Agree
    await tester.tap(find.text('I Agree'));
    // Pump to handle pop animation and mock async call
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
    
    // Should navigate to Translation Screen
    expect(find.text('Translation Screen'), findsOneWidget);
  });
}
