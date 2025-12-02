import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_gris/screens/chiropractic_screen.dart';
import 'package:ai_gris/screens/chiropractic_history_screen.dart';
import 'package:ai_gris/services/localization_service.dart';
import 'package:ai_gris/providers/user_provider.dart';
import 'package:ai_gris/models/user_model.dart';
import 'package:ai_gris/services/medical_places_service.dart';
import 'package:ai_gris/models/medical_facility_model.dart';

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
  Map<String, int> get serviceUsageCounts => {};

  @override
  bool get sortServicesByUsage => false;

  @override
  Future<void> changeLanguage(String languageCode) async {
    notifyListeners();
  }
  
  // Implement other methods as no-ops or throws if not used
  @override
  Future<void> initialize() async {}
  @override
  Future<void> login({required String email, required String password, required String role, bool rememberMe = false}) async {}
  @override
  Future<void> logout() async {}
  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String role,
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    required String gender,
    bool rememberMe = false,
  }) async {}

  @override
  Future<void> changeRole(String role) async {}
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
  @override
  Future<void> incrementServiceUsage(String serviceRoute) async {}
  @override
  Future<void> toggleServiceSorting() async {}
  @override
  Future<String> getAILocationSuggestion() async => 'Munich';
}

// Mock MedicalPlacesService
class MockMedicalPlacesService implements MedicalPlacesService {
  @override
  Future<List<MedicalFacility>> fetchFacilities({
    required String queryType,
    double? lat,
    double? lon,
    int radius = 5000,
    String? searchQuery,
    String? searchType,
  }) async {
    // Return mock data similar to what the test expects
    final mockData = [
      MedicalFacility(
        id: '1',
        name: 'Spine Health Center',
        address: 'Mittestraße 22, Berlin',
        distance: 1.3,
        phone: '+49 30 11122233',
        latitude: 52.5,
        longitude: 13.4,
      ),
      MedicalFacility(
        id: '2',
        name: 'Chiropractic Wellness',
        address: 'Prenzlauer Allee 50, Berlin',
        distance: 2.5,
        phone: '+49 30 44455566',
        latitude: 52.51,
        longitude: 13.41,
      ),
    ];

    if (searchQuery != null && searchQuery.isNotEmpty) {
      if (searchType == 'name') {
        return mockData
            .where((f) => f.name.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();
      }
    }
    return mockData;
  }
}

void main() {
  late MockLocalizationService mockLocalizationService;
  late MockUserProvider mockUserProvider;
  late MockMedicalPlacesService mockMedicalPlacesService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockLocalizationService = MockLocalizationService();
    mockUserProvider = MockUserProvider();
    mockMedicalPlacesService = MockMedicalPlacesService();
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
        Provider<LocalizationService>.value(value: mockLocalizationService),
        Provider<MedicalPlacesService>.value(value: mockMedicalPlacesService),
      ],
      child: MaterialApp(
        home: const ChiropracticScreen(),
      ),
    );
  }

  testWidgets('ChiropracticScreen renders with default list', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Allow time for any initial builds (future builder / init state fetch)
    await tester.pumpAndSettle();

    expect(find.text('Find a Chiropractor'), findsOneWidget);
    expect(find.text('Spine Health Center'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('Search functionality filters the list', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Enter text in search
    await tester.enterText(find.byType(TextField), 'Wellness');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // Expect "Chiropractic Wellness" to be present, others gone
    expect(find.text('Chiropractic Wellness'), findsOneWidget);
    expect(find.text('Spine Health Center'), findsNothing);
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
    expect(find.text('+49 30 11122233'), findsOneWidget); // Phone number of first item
  });

  testWidgets('Navigate to History Screen', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.history_edu_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(ChiropracticHistoryScreen), findsOneWidget);
    expect(find.text('Chiropractic History'), findsOneWidget);
  });
}