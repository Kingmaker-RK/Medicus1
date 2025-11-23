import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_gris/screens/translation_screen.dart';
import 'package:ai_gris/providers/translation_provider.dart';
import 'package:ai_gris/providers/user_provider.dart';
import 'package:ai_gris/providers/patient_profile_provider.dart';
import 'package:ai_gris/providers/doctor_profile_provider.dart';
import 'package:ai_gris/models/patient_profile_model.dart';
import 'package:ai_gris/models/doctor_profile_model.dart';
import 'package:ai_gris/models/user_model.dart';
import 'package:ai_gris/models/translation_result.dart';
import 'package:ai_gris/constants/app_constants.dart';

// --- Mocks ---

class MockUserProvider extends ChangeNotifier implements UserProvider {
  UserModel? _currentUser = UserModel(
    id: 'test_user',
    role: AppConstants.rolePatient,
    languageCode: 'en',
    email: 'test@example.com',
    name: 'Test User',
  );
  String _selectedLanguage = 'en';
  bool _isLoggedIn = true;

  @override
  UserModel? get currentUser => _currentUser;
  @override
  String get selectedLanguage => _selectedLanguage;
  @override
  bool get isLoggedIn => _isLoggedIn;
  @override
  bool get isLoading => false;

  @override
  Future<void> initialize() async {}
  
  @override
  void changeRole(String role) {
    _currentUser = _currentUser?.copyWith(role: role);
    notifyListeners();
  }
  
  @override
  Future<void> logout() async {
    _isLoggedIn = false;
    notifyListeners();
  }

  // Stubs
  @override
  Future<void> changeLanguage(String l) async { _selectedLanguage = l; notifyListeners(); }
  @override
  Future<void> continueAsGuest(String r) async {}
  @override
  Future<void> login({required String email, required String password, required String role, bool rememberMe = false}) async {}
  @override
  Future<void> resetPassword({required String email, required String code, required String newPassword}) async {}
  @override
  Future<void> sendPasswordResetCode(String email) async {}
  @override
  Future<void> signUp({required String email, required String password, required String role, bool rememberMe = false}) async {}
  @override
  Future<bool> verifyPasswordResetCode({required String email, required String code}) async => true;
  @override
  Future<void> verifyEmail({required String email, required String code}) async {}
  @override
  Future<void> resendVerificationCode(String email) async {}
}

class MockTranslationProvider extends ChangeNotifier implements TranslationProvider {
  String _sourceLanguage = 'en';
  String _targetLanguage = 'es';
  String _currentInput = '';
  TranslationResult? _currentTranslation;
  List<TranslationResult> _translationHistory = [];
  bool _isTranslating = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isRecognizingHandwriting = false;
  String? _lastError;
  
  // Test spies
  bool speakCalled = false;
  bool swapCalled = false;
  bool listenCalled = false;

  @override
  String get sourceLanguage => _sourceLanguage;
  @override
  String get targetLanguage => _targetLanguage;
  @override
  String get currentInput => _currentInput;
  @override
  TranslationResult? get currentTranslation => _currentTranslation;
  @override
  List<TranslationResult> get translationHistory => _translationHistory;
  @override
  bool get isTranslating => _isTranslating;
  @override
  bool get isListening => _isListening;
  @override
  bool get isSpeaking => _isSpeaking;
  @override
  bool get isRecognizingHandwriting => _isRecognizingHandwriting;
  @override
  String? get lastError => _lastError;

  @override
  void setSourceLanguage(String val) { _sourceLanguage = val; notifyListeners(); }
  @override
  void setTargetLanguage(String val) { _targetLanguage = val; notifyListeners(); }
  @override
  void updateInput(String val) { _currentInput = val; notifyListeners(); }

  @override
  Future<void> translateText(String text, {bool autoSpeak = false}) async {
    _isTranslating = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 10)); // tiny delay
    _currentTranslation = TranslationResult(
      originalText: text,
      translatedText: 'Translated: $text',
      sourceLanguage: _sourceLanguage,
      targetLanguage: _targetLanguage,
      medicalTerms: text.contains('heart') ? ['Cardiology'] : [],
      anatomyImages: [],
    );
    _translationHistory.add(_currentTranslation!);
    _isTranslating = false;
    notifyListeners();
  }

  @override
  void clearInput() {
    _currentInput = '';
    _currentTranslation = null;
    notifyListeners();
  }

  @override
  Future<void> swapLanguages({bool retranslate = false}) async {
    swapCalled = true;
    final temp = _sourceLanguage;
    _sourceLanguage = _targetLanguage;
    _targetLanguage = temp;
    notifyListeners();
  }

  @override
  Future<void> speakText(String text, String languageCode) async {
    speakCalled = true;
    _isSpeaking = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 50));
    _isSpeaking = false;
    notifyListeners();
  }

  @override
  Future<bool> startListening() async {
    listenCalled = true;
    _isListening = true;
    notifyListeners();
    return true;
  }

  @override
  Future<void> stopListening() async {
    _isListening = false;
    notifyListeners();
  }
  
  @override
  void clearHistory() {
    _translationHistory.clear();
    notifyListeners();
  }

  // Stubs
  @override
  Future<void> initialize({String? userLanguage}) async {}
  @override
  void updateSourceLanguageFromUser(String l) {}
  @override
  void clearError() {}
  @override
  Future<String> recognizeHandwriting(Uint8List bytes) async => "Handwriting";
  @override
  Future<String> extractTextFromImage(Uint8List bytes) async => "OCR Text";
  @override
  Future<void> stopSpeaking() async {}
}

class MockPatientProfileProvider extends ChangeNotifier implements PatientProfileProvider {
  @override
  PatientProfileModel get profile => PatientProfileModel(profilePicturePath: '');
  // ... implement stubs for others if needed ...
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockDoctorProfileProvider extends ChangeNotifier implements DoctorProfileProvider {
  @override
  DoctorProfileModel get profile => DoctorProfileModel();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockUserProvider userProvider;
  late MockTranslationProvider translationProvider;
  late MockPatientProfileProvider patientProvider;
  late MockDoctorProfileProvider doctorProvider;

  setUp(() {
    userProvider = MockUserProvider();
    translationProvider = MockTranslationProvider();
    patientProvider = MockPatientProfileProvider();
    doctorProvider = MockDoctorProfileProvider();
  });

  Widget createTestApp() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const TranslationScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => Scaffold(appBar: AppBar(title: const Text('Settings'))),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => Scaffold(appBar: AppBar(title: const Text('Profile'))),
        ),
        GoRoute(
          path: '/doctor-profile',
          builder: (context, state) => Scaffold(appBar: AppBar(title: const Text('Doctor Profile'))),
        ),
      ],
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>.value(value: userProvider),
        ChangeNotifierProvider<TranslationProvider>.value(value: translationProvider),
        ChangeNotifierProvider<PatientProfileProvider>.value(value: patientProvider),
        ChangeNotifierProvider<DoctorProfileProvider>.value(value: doctorProvider),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  testWidgets('Rigorous Test: Full Translation Flow', (WidgetTester tester) async {
    // 1. Load Screen
    await tester.pumpWidget(createTestApp());
    await tester.pump(); // Initial frame
    await tester.pump(const Duration(milliseconds: 100)); // Animation settle

    // 2. Verify Initial State
    expect(find.text('AI-Gris'), findsOneWidget); // AppBar title
    expect(find.text('Enter text to translate...'), findsOneWidget); // Placeholder
    expect(find.text('Translation will appear here'), findsOneWidget); // Empty state

    // 3. Enter Text
    await tester.enterText(find.byType(TextField).first, 'Hello World');
    await tester.pump(); // process input
    await tester.pump(const Duration(milliseconds: 100)); // allow debounce/updates
    
    // Verify provider updated
    expect(translationProvider.currentInput, 'Hello World');

    // 4. Tap Translate Button
    // Find the specific icon used in the button (size 18) to distinguish from empty state (size 64)
    final translateIcon = find.byWidgetPredicate(
      (widget) => widget is Icon && 
                  widget.icon == Icons.translate_rounded && 
                  widget.size == 18
    );
    expect(translateIcon, findsOneWidget);
    await tester.ensureVisible(translateIcon);
    await tester.tap(translateIcon);
    await tester.pump(); // Start loading
    await tester.pump(const Duration(milliseconds: 50)); // Finish loading (mock delay 10ms)
    await tester.pump(); // Rebuild

    // 5. Verify Output
    expect(find.text('Translated: Hello World'), findsOneWidget);
    expect(find.text('Translation will appear here'), findsNothing);

    // 6. Verify Speak Button functionality
    final volumeIcon = find.byIcon(Icons.volume_up_rounded);
    expect(volumeIcon, findsOneWidget);
    await tester.ensureVisible(volumeIcon);
    await tester.tap(volumeIcon);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(translationProvider.speakCalled, isTrue);

    // 7. Verify Copy Button functionality
    // Use Icon finder
    final copyIcon = find.byIcon(Icons.copy_rounded);
    // There are 2 copy icons (one in output, one in history list item if any). 
    // But history is empty/closed. Actually, history list item might be in memory?
    // The drawer is closed. So only 1 should be visible.
    // However, find.byIcon finds offstage widgets too unless skipOffstage is true (default).
    // Let's be specific: The one in the output card.
    // We can just tap the first one or ensure visible.
    expect(copyIcon, findsOneWidget);
    await tester.ensureVisible(copyIcon);
    await tester.tap(copyIcon);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1)); // SnackBar duration
    expect(find.text('Translation copied to clipboard'), findsOneWidget);

    // 8. Verify Clear Button functionality
    final clearIcon = find.byIcon(Icons.close_rounded);
    expect(clearIcon, findsOneWidget);
    await tester.ensureVisible(clearIcon);
    await tester.tap(clearIcon);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    
    expect(find.text('Enter text to translate...'), findsOneWidget);
    expect(translationProvider.currentInput, isEmpty);
    expect(translationProvider.currentTranslation, isNull);
  });

  testWidgets('Rigorous Test: Toolbar and Drawer interactions', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // 1. Swap Languages
    expect(translationProvider.sourceLanguage, 'en');
    expect(translationProvider.targetLanguage, 'es');
    
    final swapIcon = find.byIcon(Icons.swap_horiz_rounded).first; 
    await tester.tap(swapIcon);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    
    expect(translationProvider.swapCalled, isTrue);
    expect(translationProvider.sourceLanguage, 'es');
    expect(translationProvider.targetLanguage, 'en');

    // 2. Open History Drawer (End Drawer)
    final historyIcon = find.byIcon(Icons.history_rounded);
    expect(historyIcon, findsOneWidget);
    await tester.tap(historyIcon);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500)); // Drawer animation
    
    expect(find.text('Translation History'), findsOneWidget);
    
    // Close drawer
    await tester.tapAt(const Offset(10, 10)); // Tap outside
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // 3. Open Navigation Drawer (Start Drawer)
    final menuIcon = find.byIcon(Icons.menu_rounded);
    expect(menuIcon, findsOneWidget);
    await tester.tap(menuIcon);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500)); // Drawer animation
    
    expect(find.text('Test User'), findsOneWidget); 
    
    // 4. Test Navigation to Settings
    final settingsItem = find.widgetWithText(ListTile, 'Settings');
    await tester.ensureVisible(settingsItem);
    await tester.tap(settingsItem);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150)); // Navigation transition
    
    expect(find.text('Settings'), findsWidgets); // Might match title and drawer item if drawer still open?
    // Check for AppBar title specifically
    expect(find.descendant(of: find.byType(AppBar), matching: find.text('Settings')), findsOneWidget);
  });

  testWidgets('Rigorous Test: Conversation & Camera Modes', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // 1. Conversation Mode
    final convIcon = find.byIcon(Icons.record_voice_over_rounded);
    await tester.tap(convIcon);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    
    expect(translationProvider.listenCalled, isTrue);
    
    // 2. Camera Button
    final camIcon = find.byIcon(Icons.camera_alt_rounded);
    await tester.tap(camIcon);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    
    // Verified it doesn't crash
  });
}
