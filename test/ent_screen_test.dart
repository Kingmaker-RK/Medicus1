import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_gris/screens/ent_screen.dart';
import 'package:ai_gris/screens/ent_history_screen.dart';
import 'package:ai_gris/services/localization_service.dart';
import 'package:ai_gris/providers/user_provider.dart';
import 'package:ai_gris/models/user_model.dart';
import 'package:ai_gris/services/medical_places_service.dart';
import 'package:ai_gris/models/medical_facility_model.dart';

class MockMedicalPlacesService extends Mock implements MedicalPlacesService {}

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

void main() {
  late MockLocalizationService mockLocalizationService;
  late MockUserProvider mockUserProvider;
  late MockMedicalPlacesService mockMedicalPlacesService;

  final mockData = [
    MedicalFacility(
      id: '1',
      name: 'Berlin ENT Specialist',
      address: 'Mitte, Berlin',
      distance: 1.0,
      phone: '+49 30 11112222',
      latitude: 52.5,
      longitude: 13.4,
    ),
    MedicalFacility(
      id: '2',
      name: 'Hearing & Balance Center',
      address: 'Kreuzberg, Berlin',
      distance: 3.2,
      phone: '+49 30 33334444',
      latitude: 52.51,
      longitude: 13.41,
    ),
  ];

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
        home: const ENTScreen(),
      ),
    );
  }

  testWidgets('ENTScreen renders with default list', (WidgetTester tester) async {
    when(mockMedicalPlacesService.fetchFacilities(queryType: 'ent')).thenAnswer((_) async => mockData);

    await tester.pumpWidget(createWidgetUnderTest());

    // Allow time for any initial builds (future builder / init state fetch)
    await tester.pumpAndSettle();

    expect(find.text('Find an ENT Specialist'), findsOneWidget);
    expect(find.text('Berlin ENT Specialist'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('Search functionality filters the list', (WidgetTester tester) async {
    when(mockMedicalPlacesService.fetchFacilities(queryType: 'ent', searchQuery: 'Hearing', searchType: 'name')).thenAnswer((_) async => [mockData[1]]);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Enter text in search
    await tester.enterText(find.byType(TextField), 'Hearing');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // Expect "Hearing & Balance Center" to be present, others gone
    expect(find.text('Hearing & Balance Center'), findsOneWidget);
    expect(find.text('Berlin ENT Specialist'), findsNothing);
  });

  testWidgets('Call button shows dialog with phone number', (WidgetTester tester) async {
    when(mockMedicalPlacesService.fetchFacilities(queryType: 'ent')).thenAnswer((_) async => mockData);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Find the text "Call" and tap the first occurrence
    final callTextFinder = find.text('Call');
    expect(callTextFinder, findsWidgets);
    
    await tester.tap(callTextFinder.first);
    await tester.pumpAndSettle();

    expect(find.text('Contact Reception'), findsOneWidget);
    expect(find.text('+49 30 11112222'), findsOneWidget); // Phone number of first item
  });

  testWidgets('Navigate to History Screen', (WidgetTester tester) async {
    when(mockMedicalPlacesService.fetchFacilities(queryType: 'ent')).thenAnswer((_) async => mockData);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.history_edu_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(ENTHistoryScreen), findsOneWidget);
    expect(find.text('ENT History'), findsOneWidget);
  });
}
