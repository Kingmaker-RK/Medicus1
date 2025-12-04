import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_gris/providers/user_provider.dart';
import 'package:ai_gris/providers/translation_provider.dart';
import 'package:ai_gris/providers/patient_profile_provider.dart';
import 'package:ai_gris/providers/doctor_profile_provider.dart';
import 'package:ai_gris/services/auth_service.dart';
import 'package:ai_gris/services/database_service.dart';
import 'package:ai_gris/config/router.dart';
import 'package:ai_gris/constants/colors.dart';
import 'package:ai_gris/constants/app_constants.dart';
import 'package:google_fonts/google_fonts.dart';

// Mocks
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockSupabaseStorageClient extends Mock implements SupabaseStorageClient {}
class MockStorageFileApi extends Mock implements StorageFileApi {}
// ignore: must_be_immutable
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder {}

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

/// Helper to create a UserProvider with mocks
UserProvider createMockUserProvider({
  bool signedIn = false,
  MockUser? mockUser,
  FakeFirebaseFirestore? firestore,
  SupabaseClient? supabaseClient,
}) {
  final auth = createMockFirebaseAuth(signedIn: signedIn, mockUser: mockUser);
  final authService = AuthService(auth: auth);
  
  final mockSupabase = supabaseClient ?? MockSupabaseClient();
  
  // Setup basic stubs for Supabase to avoid NPEs if tests touch it
  if (supabaseClient == null) {
      // Return a query builder when .from() is called
      final queryBuilder = MockSupabaseQueryBuilder();
      when(() => mockSupabase.from(any())).thenReturn(queryBuilder);
      // Stub generic select/insert/update to avoid errors
      when(() => queryBuilder.select(any())).thenAnswer((_) => MockPostgrestFilterBuilder());
      when(() => queryBuilder.insert(any())).thenAnswer((_) => MockPostgrestFilterBuilder());
      when(() => queryBuilder.upsert(any())).thenAnswer((_) => MockPostgrestFilterBuilder());
      
      // Return a storage client
      final storage = MockSupabaseStorageClient();
      final storageFileApi = MockStorageFileApi();
      when(() => mockSupabase.storage).thenReturn(storage);
      when(() => storage.from(any())).thenReturn(storageFileApi);
      
      // Stub upload and getPublicUrl
      when(() => storageFileApi.upload(any(), any(), fileOptions: any(named: 'fileOptions')))
          .thenAnswer((_) async => 'path/to/file');
      when(() => storageFileApi.getPublicUrl(any())).thenReturn('https://mock.supabase.co/storage/v1/object/public/bucket/file');
  }

  final databaseService = DatabaseService(
      firestore: firestore ?? FakeFirebaseFirestore(),
      client: mockSupabase,
  );
  
  return UserProvider(
    authService: authService,
    databaseService: databaseService,
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
  final firestore = FakeFirebaseFirestore();
  final mockDbService = DatabaseService(firestore: firestore, client: MockSupabaseClient());

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<UserProvider>(
        create: (_) => userProvider ?? createMockUserProvider(firestore: firestore),
      ),
      ChangeNotifierProvider<TranslationProvider>(
        create: (_) => translationProvider ?? TranslationProvider(),
      ),
      ChangeNotifierProvider<PatientProfileProvider>(
        create: (_) => userProfileProvider ?? PatientProfileProvider(databaseService: mockDbService),
      ),
      ChangeNotifierProvider<DoctorProfileProvider>(
        create: (_) => doctorProfileProvider ?? DoctorProfileProvider(databaseService: mockDbService),
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
  final firestore = FakeFirebaseFirestore();
  final mockDbService = DatabaseService(firestore: firestore, client: MockSupabaseClient());

  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => createMockUserProvider(firestore: firestore)),
      ChangeNotifierProvider(create: (_) => TranslationProvider()),
      ChangeNotifierProvider(create: (_) => PatientProfileProvider(databaseService: mockDbService)),
      ChangeNotifierProvider(create: (_) => DoctorProfileProvider(databaseService: mockDbService)),
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
