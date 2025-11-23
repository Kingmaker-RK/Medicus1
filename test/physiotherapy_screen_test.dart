import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_gris/screens/physiotherapy_screen.dart';
import 'package:ai_gris/screens/physiotherapy_history_screen.dart';
import 'package:ai_gris/services/localization_service.dart';
import 'package:ai_gris/providers/user_provider.dart';
import 'package:ai_gris/models/user_model.dart';

// Mock LocalizationService
class MockLocalizationService implements LocalizationService {
  @override
  Future<String> translate(String text) async {
    return text; // Return text as is for testing
  }

  @override
  void initialize() {}

  @override
  Future<void> setLanguage(String languageCode) async {}

  @override
  String translateSync(String text) => text;

  @override
  void clearCache() {}

  @override
  String get currentLanguageCode => 'en';
}

// Mock UserProvider
class MockUserProvider extends ChangeNotifier implements UserProvider {
  @override
  String get selectedLanguage => 'en';

  @override
  UserModel? get currentUser => null;

  @override
  bool get isLoading => false;

  @override
  bool get isLoggedIn => false;

  @override
  Future<void> changeLanguage(String languageCode) async {
    notifyListeners();
  }
  
  @override
  Future<void> initialize() async {}
  @override
  Future<void> login({required String email, required String password, required String role, bool rememberMe = false}) async {}
  @override
  Future<void> logout() async {}
  @override
  Future<void> signUp({required String email, required String password, required String role, bool rememberMe = false}) async {}
  @override
  void changeRole(String role) {}
  @override
  Future<void> continueAsGuest(String role) async {}
  @override
  Future<void> resendVerificationCode(String email) async {}
  @override
  Future<void> resetPassword({required String email, required String code, required String newPassword}) async {}
  @override
  Future<void> sendPasswordResetCode(String email) async {}
  @override
  Future<void> verifyEmail({required String email, required String code}) async {}
  @override
  Future<bool> verifyPasswordResetCode({required String email, required String code}) async => true;
}

void main() {
  late MockLocalizationService mockLocalizationService;
  late MockUserProvider mockUserProvider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockLocalizationService = MockLocalizationService();
    mockUserProvider = MockUserProvider();
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
        Provider<LocalizationService>.value(value: mockLocalizationService),
      ],
      child: MaterialApp(
        home: const PhysiotherapyScreen(),
      ),
    );
  }

  testWidgets('PhysiotherapyScreen renders with default list', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Allow time for any initial builds
    await tester.pumpAndSettle();

    expect(find.text('Find Physiotherapy'), findsOneWidget);
    expect(find.text('Active Motion Physio'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('Search functionality filters the list', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Enter text in search
    await tester.enterText(find.byType(TextField), 'Rehab');
    await tester.pumpAndSettle();

    // Expect "Rehab & Recovery Center" to be present, others gone
    expect(find.text('Rehab & Recovery Center'), findsOneWidget);
    expect(find.text('Active Motion Physio'), findsNothing);
  });

  testWidgets('Call button shows dialog with phone number', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Find the text "Call" and tap the first occurrence
    final callTextFinder = find.text('Call');
    expect(callTextFinder, findsWidgets);
    
    await tester.tap(callTextFinder.first);
    await tester.pumpAndSettle();

    expect(find.text('Contact Reception'), findsOneWidget);
    expect(find.text('+49 30 22334455'), findsOneWidget); // Phone number of first item
  });

  testWidgets('Navigate to History Screen', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.history_edu_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(PhysiotherapyHistoryScreen), findsOneWidget);
    expect(find.text('Physiotherapy History'), findsOneWidget);
  });
}
