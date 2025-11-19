import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:medicus/screens/translation_screen.dart';
import 'package:medicus/providers/translation_provider.dart';
import 'package:medicus/providers/user_provider.dart';
import 'package:medicus/providers/user_profile_provider.dart';
import 'package:medicus/models/user_model.dart';
import 'package:medicus/models/translation_result.dart';
import 'package:medicus/models/user_profile_model.dart';
import 'package:medicus/constants/app_constants.dart';
import 'package:medicus/constants/colors.dart';

// Fake UserProfileProvider
class FakeUserProfileProvider extends ChangeNotifier implements UserProfileProvider {
  UserProfileModel _profile = UserProfileModel();

  @override
  UserProfileModel get profile => _profile;

  @override
  bool get isLoading => false;

  @override
  int get unreadMessageCount => 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> updatePersonalInfo({
    String? firstName,
    String? secondName,
    String? insuranceNumber,
    String? insuranceProvider,
    String? profilePicturePath,
  }) async {
    _profile = _profile.copyWith(
      firstName: firstName,
      secondName: secondName,
      insuranceNumber: insuranceNumber,
      insuranceProvider: insuranceProvider,
      profilePicturePath: profilePicturePath,
    );
    notifyListeners();
  }

  @override
  Future<void> updateProfilePicture(String path) async {
    _profile = _profile.copyWith(profilePicturePath: path);
    notifyListeners();
  }

  // Stubs for other methods
  @override
  Future<void> addCertificate(Certificate certificate) async {}
  @override
  Future<void> removeCertificate(String certificateId) async {}
  @override
  Future<void> submitSickNote(SickNote sickNote) async {}
  @override
  Future<void> updateSickNoteStatus(String sickNoteId, String status) async {}
  @override
  Future<void> addReimbursement(Reimbursement reimbursement) async {}
  @override
  Future<void> updateReimbursementStatus(String reimbursementId, String status) async {}
  @override
  Future<void> addMailboxMessage(MailboxMessage message) async {}
  @override
  Future<void> markMessageAsRead(String messageId) async {}
}

// Fake UserProvider
class FakeUserProvider extends ChangeNotifier implements UserProvider {
  UserModel? _currentUser = UserModel(
    id: 'test_user',
    role: AppConstants.rolePatient,
    languageCode: 'en',
    email: 'test@example.com',
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
    _currentUser = null;
    notifyListeners();
  }
  
  @override
  Future<void> changeLanguage(String languageCode) async {
    _selectedLanguage = languageCode;
    notifyListeners();
  }
  
  // Missing overrides (implementing stubs to satisfy interface)
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
  void setSourceLanguage(String languageCode) {
    _sourceLanguage = languageCode;
    notifyListeners();
  }

  @override
  void setTargetLanguage(String languageCode) {
    _targetLanguage = languageCode;
    notifyListeners();
  }

  @override
  void updateInput(String text) {
    _currentInput = text;
    notifyListeners();
  }

  @override
  Future<void> translateText(String text, {bool autoSpeak = false}) async {
    _isTranslating = true;
    notifyListeners();
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 50));
    
    _currentTranslation = TranslationResult(
      originalText: text,
      translatedText: 'Translated: $text', // Simple mock translation
      sourceLanguage: _sourceLanguage,
      targetLanguage: _targetLanguage,
      medicalTerms: [],
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
    final temp = _sourceLanguage;
    _sourceLanguage = _targetLanguage;
    _targetLanguage = temp;
    notifyListeners();
  }

  @override
  Future<void> initialize({String? userLanguage}) async {}

  @override
  void updateSourceLanguageFromUser(String userLanguageCode) {
    _sourceLanguage = userLanguageCode;
    notifyListeners();
  }
  
  @override
  void clearError() {
    _lastError = null;
    notifyListeners();
  }
  
  @override
  void clearHistory() {
    _translationHistory.clear();
    notifyListeners();
  }

  @override
  Future<String> recognizeHandwriting(Uint8List imageBytes) async {
    return 'Recognized Text';
  }

  @override
  Future<String> extractTextFromImage(Uint8List imageBytes) async {
    return 'Extracted Text';
  }

  // Stubs
  @override
  Future<void> speakText(String text, String languageCode) async {}
  @override
  Future<bool> startListening() async => true;
  @override
  Future<void> stopListening() async {}
  @override
  Future<void> stopSpeaking() async {}
  @override
  void dispose() {
    // No-op
    super.dispose();
  }
}

void main() {
  group('TranslationScreen Tests', () {
    late FakeUserProvider userProvider;
    late FakeTranslationProvider translationProvider;
    late FakeUserProfileProvider userProfileProvider;

    setUp(() {
      userProvider = FakeUserProvider();
      translationProvider = FakeTranslationProvider();
      userProfileProvider = FakeUserProfileProvider();
    });

    Widget createTestScreen() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<UserProvider>.value(value: userProvider),
          ChangeNotifierProvider<TranslationProvider>.value(value: translationProvider),
          ChangeNotifierProvider<UserProfileProvider>.value(value: userProfileProvider),
        ],
        child: MaterialApp(
          home: const TranslationScreen(),
        ),
      );
    }

    testWidgets('Verify Conversation Mode button exists and toggles', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      // Avoid pumpAndSettle due to infinite animation
      await tester.pump(); 
      await tester.pump(const Duration(milliseconds: 100));

      // Find the Conversation Mode Icon Button (Icons.record_voice_over_rounded)
      final iconFinder = find.byIcon(Icons.record_voice_over_rounded);
      expect(iconFinder, findsOneWidget);

      // Get the parent Container/Material of the icon to check color (optional, but good)
      // Note: We can just check if tapping it triggers the expected behavior.
      // But we can't easily check the internal state _isConversationMode of the private class.
      
      // However, we can check if the Provider's startListening was called if we add a spy.
      // For now, just verify interaction works without crashing.
      
      await tester.tap(iconFinder);
      await tester.pump();

      // After tapping, the icon color should change (it uses _isConversationMode).
      // In the code: color: _isConversationMode ? Colors.white : AppColors.accent
      // We can verify the icon color.
      Icon iconWidget = tester.widget(iconFinder);
      // Since we tapped it, _isConversationMode should be true.
      // So color should be Colors.white.
      expect(iconWidget.color, equals(Colors.white));

      // Tap again to toggle off
      await tester.tap(iconFinder);
      await tester.pump();

      iconWidget = tester.widget(iconFinder);
      // Should be AppColors.accent (default)
      expect(iconWidget.color, equals(AppColors.accent));
    });

    testWidgets('Verify Input Text Field properties (reduced size)', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Find the input text field (hint text: 'Enter text to translate...')
      final inputFieldFinder = find.widgetWithText(TextField, 'Enter text to translate...');
      expect(inputFieldFinder, findsOneWidget);

      // Get the TextField widget
      TextField inputTextField = tester.widget(inputFieldFinder);

      // Verify minLines is 3 (Input field size wasn't reduced, only output)
      expect(inputTextField.minLines, equals(3));
      expect(inputTextField.maxLines, isNull);
    });

    testWidgets('Verify Output Result is shown in a TextField', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Translate something to populate output
      final inputFieldFinder = find.widgetWithText(TextField, 'Enter text to translate...');
      await tester.enterText(inputFieldFinder, 'Hello');
      await tester.pump(); // Update state
      
      // Check if text 'Translate' is present
      final translateTextFinder = find.text('Translate');
      expect(translateTextFinder, findsOneWidget);
      
      // Tap the text "Translate" (which is inside the button)
      await tester.ensureVisible(translateTextFinder);
      await tester.tap(translateTextFinder);
      
      // Wait for async translation (simulated 50ms)
      await tester.pump(); // Start loading
      await tester.pump(const Duration(milliseconds: 100)); // Finish loading
      await tester.pump(); // Rebuild with result

      // Expected output text
      final expectedOutput = 'Translated: Hello';

      // Find the output text field. 
      // We verify there is a TextField containing the result.
      final outputFieldFinder = find.widgetWithText(TextField, expectedOutput);
      expect(outputFieldFinder, findsOneWidget);

      // Verify it is read-only
      TextField outputTextField = tester.widget(outputFieldFinder);
      expect(outputTextField.readOnly, isTrue);
      expect(outputTextField.minLines, equals(2));
    });

    testWidgets('Verify Image Upload and Handwriting icons exist', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.image_rounded), findsOneWidget);
      expect(find.byIcon(Icons.draw_rounded), findsOneWidget);
      expect(find.byTooltip('Upload Image'), findsOneWidget);
      expect(find.byTooltip('Handwriting Input'), findsOneWidget);
    });
  });
}