import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:medicus/screens/translation_screen.dart';
import 'package:medicus/providers/translation_provider.dart';
import 'package:medicus/providers/user_provider.dart';
import 'package:medicus/models/translation_result.dart';
import 'package:medicus/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';

// Mock classes
class MockTranslationProvider extends ChangeNotifier implements TranslationProvider {
  @override
  bool get isTranslating => false;
  @override
  bool get isListening => false;
  @override
  bool get isSpeaking => false;
  @override
  bool get isRecognizingHandwriting => false;
  @override
  String get currentInput => '';
  @override
  String get sourceLanguage => 'en';
  @override
  String get targetLanguage => 'es';
  @override
  List<TranslationResult> get translationHistory => [];
  @override
  TranslationResult? get currentTranslation => null;
  @override
  String? get lastError => null;

  @override
  Future<void> initialize({String? userLanguage}) async {}
  @override
  void updateSourceLanguageFromUser(String userLanguageCode) {}
  
  @override
  Future<String> extractTextFromImage(Uint8List imageBytes) async {
    return "Extracted text";
  }

  @override
  Future<String> recognizeHandwriting(Uint8List imageBytes) async {
    return "Recognized handwriting";
  }
  
  @override
  void setSourceLanguage(String languageCode) {}
  @override
  void setTargetLanguage(String languageCode) {}
  
  @override
  Future<void> translateText(String text, {bool autoSpeak = false}) async {}
  @override
  Future<bool> startListening() async => true;
  @override
  Future<void> stopListening() async {}
  @override
  Future<void> swapLanguages({bool retranslate = false}) async {}
  @override
  void clearInput() {}
  @override
  void clearHistory() {}
  @override
  Future<void> speakText(String text, String languageCode) async {}
  @override
  Future<void> stopSpeaking() async {}
  @override
  void updateInput(String text) {}
  @override
  void clearError() {}
  
  @override
  void dispose() {
    super.dispose();
  }
}

class MockUserProvider extends ChangeNotifier implements UserProvider {
  @override
  String get selectedLanguage => 'en';
  @override
  UserModel? get currentUser => null;
  @override
  bool get isLoggedIn => false;
  @override
  bool get isLoading => false;

  @override
  Future<void> changeLanguage(String languageCode) async {}
  @override
  void changeRole(String role) {}
  @override
  Future<void> continueAsGuest(String role) async {}
  @override
  Future<void> initialize() async {}
  @override
  Future<void> login({required String email, required String password, required String role, bool rememberMe = false}) async {}
  @override
  Future<void> logout() async {}
  @override
  Future<void> resendVerificationCode(String email) async {}
  @override
  Future<void> resetPassword({required String email, required String code, required String newPassword}) async {}
  @override
  Future<void> sendPasswordResetCode(String email) async {}
  @override
  Future<void> signUp({required String email, required String password, required String role, bool rememberMe = false}) async {}
  @override
  Future<void> verifyEmail({required String email, required String code}) async {}
  @override
  Future<bool> verifyPasswordResetCode({required String email, required String code}) async => true;
  
  @override
  void dispose() {
    super.dispose();
  }
}

// Mock ImagePicker
class MockImagePicker extends ImagePickerPlatform {
  bool cameraCalled = false;

  @override
  Future<PickedFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    if (source == ImageSource.camera) {
      cameraCalled = true;
      return PickedFile(''); // Return empty file to simulate success
    }
    return null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockImagePicker mockImagePicker;
  
  // Channel for permission_handler
  const MethodChannel permissionChannel = MethodChannel('flutter.baseflow.com/permissions/methods');

  setUp(() {
    mockImagePicker = MockImagePicker();
    ImagePickerPlatform.instance = mockImagePicker;

    // Mock permission channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, (MethodCall methodCall) async {
      if (methodCall.method == 'checkPermissionStatus') {
        return 0; // PermissionStatus.denied
      } else if (methodCall.method == 'requestPermissions') {
        return {1: 0}; // PermissionStatus.denied for camera (1 is camera)
      } else if (methodCall.method == 'openAppSettings') {
        return true;
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, null);
  });

  testWidgets('Camera icon tapping requesting permission and showing dialog on denial', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserProvider>(create: (_) => MockUserProvider()),
          ChangeNotifierProvider<TranslationProvider>(create: (_) => MockTranslationProvider()),
        ],
        child: MaterialApp(
          home: const TranslationScreen(),
        ),
      ),
    );

    // Wait for initial build and animations (mic animation is indefinite)
    await tester.pump(); 
    await tester.pump(const Duration(seconds: 1));

    // Find camera icon
    final cameraIcon = find.byIcon(Icons.camera_alt_rounded);
    expect(cameraIcon, findsOneWidget);

    // Tap camera icon
    await tester.tap(cameraIcon);
    
    // Wait for async permission check and dialog to show
    // We pump a few times to allow the async logic in _pickAndExtractImage to resolve
    await tester.pump(); 
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    // Expect permission dialog
    expect(find.text('Camera Permission Required'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Tap settings (which calls openSettings)
    await tester.tap(find.text('Settings'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1)); // Wait for dialog close animation
    
    // Verify dialog closed
    expect(find.text('Camera Permission Required'), findsNothing);
  });
}
