import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ai_gris/screens/ent_screen.dart';
import 'package:ai_gris/screens/eye_care_screen.dart';
import 'package:ai_gris/screens/addiction_recovery_screen.dart';
import 'package:ai_gris/screens/hiv_prevention_screen.dart';
import 'package:ai_gris/providers/translation_provider.dart';
import 'package:ai_gris/providers/user_provider.dart';
import 'package:ai_gris/models/translation_result.dart';
import 'package:ai_gris/models/user_model.dart';
import 'package:ai_gris/constants/app_constants.dart';
import 'dart:typed_data';

// Fake UserProvider
class FakeUserProvider extends ChangeNotifier implements UserProvider {
  UserModel? _currentUser = UserModel(
    id: 'test_user',
    role: AppConstants.rolePatient,
    languageCode: 'en',
    email: 'test@example.com',
  );
  String _selectedLanguage = 'en';

  @override
  UserModel? get currentUser => _currentUser;

  @override
  String get selectedLanguage => _selectedLanguage;

  @override
  bool get isLoggedIn => true;

  @override
  bool get isLoading => false;

  @override
  Future<void> initialize() async {}

  @override
  void changeRole(String role) {}

  @override
  Future<void> logout() async {}
  
  @override
  Future<void> changeLanguage(String languageCode) async {
    _selectedLanguage = languageCode;
    notifyListeners();
  }
  
  // Stubs
  @override
  Future<void> continueAsGuest(String role) async {}
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

// Fake TranslationProvider
class FakeTranslationProvider extends ChangeNotifier implements TranslationProvider {
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
  void setSourceLanguage(String languageCode) {}
  @override
  void setTargetLanguage(String languageCode) {}
  @override
  void updateGuestStatus(bool isGuest) {}
  @override
  void setConversationMode(bool enabled) {}
  @override
  void updateInput(String text) {}
  @override
  Future<void> translateText(String text, {bool autoSpeak = false}) async {}
  @override
  void clearInput() {}
  @override
  Future<void> swapLanguages({bool retranslate = false}) async {}
  @override
  Future<void> initialize({String? userLanguage, bool isGuest = false}) async {}
  @override
  void updateSourceLanguageFromUser(String userLanguageCode) {}
  @override
  void clearError() {}
  @override
  void clearHistory() {}
  @override
  Future<String> recognizeHandwriting(Uint8List imageBytes) async => '';
  @override
  Future<String> extractTextFromImage(Uint8List imageBytes) async => '';
  @override
  Future<void> speakText(String text, String languageCode) async {}
  @override
  Future<bool> startListening() async => true;
  @override
  Future<void> stopListening() async {}
  @override
  Future<void> stopSpeaking() async {}
  @override
  void dispose() { super.dispose(); }
}

void main() {
  late FakeTranslationProvider translationProvider;
  late FakeUserProvider userProvider;

  setUp(() {
    translationProvider = FakeTranslationProvider();
    userProvider = FakeUserProvider();
  });

  Widget createScreen(Widget screen) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TranslationProvider>.value(value: translationProvider),
        ChangeNotifierProvider<UserProvider>.value(value: userProvider),
      ],
      child: MaterialApp(
        home: screen,
      ),
    );
  }

  testWidgets('ENT Screen renders and searches', (WidgetTester tester) async {
    await tester.pumpWidget(createScreen(const ENTScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Find an ENT Specialist'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Berlin ENT Specialist'), findsOneWidget);

    // Test Search
    await tester.enterText(find.byType(TextField), 'Hearing');
    await tester.pump();
    expect(find.text('Hearing & Balance Center'), findsOneWidget);
    expect(find.text('Berlin ENT Specialist'), findsNothing);
  });

  testWidgets('Eye Care Screen renders and searches', (WidgetTester tester) async {
    await tester.pumpWidget(createScreen(const EyeCareScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Eye Care'), findsOneWidget);
    expect(find.text('Vision Plus Clinic'), findsOneWidget);
  });

  testWidgets('Addiction Recovery Screen renders categories', (WidgetTester tester) async {
    await tester.pumpWidget(createScreen(const AddictionRecoveryScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Addiction Recovery'), findsOneWidget);
    expect(find.text('Alcohol'), findsOneWidget);
    expect(find.text('Drugs/Substance'), findsOneWidget);
  });

  testWidgets('HIV Prevention Screen renders content', (WidgetTester tester) async {
    await tester.pumpWidget(createScreen(const HIVPreventionScreen()));
    await tester.pumpAndSettle();

    expect(find.text('HIV/STI Prevention'), findsOneWidget);
    expect(find.text('Key Prevention Methods'), findsOneWidget);
    expect(find.text('Educational Resources'), findsOneWidget);
  });
}