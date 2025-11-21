import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicus/providers/translation_provider.dart';
import 'package:medicus/services/translation_service.dart';
import 'package:medicus/services/speech_service.dart';
import 'package:medicus/models/translation_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

// --- Custom Fakes/Spies ---

class FakeTranslationService implements TranslationService {
  // Spy logs
  final List<String> log = [];
  
  // Configuration for response
  TranslationResult? mockResult;
  Exception? mockException;

  @override
  Future<TranslationResult> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    bool isMedicalContext = true,
  }) async {
    log.add('translateText($text, $sourceLanguage, $targetLanguage)');
    
    if (mockException != null) throw mockException!;
    
    return mockResult ?? TranslationResult(
      originalText: text,
      translatedText: 'Translated $text',
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      medicalTerms: [],
      anatomyImages: [],
    );
  }

  // Unused methods for this test suite (stubs)
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSpeechService implements SpeechService {
  // Spy logs
  final List<String> log = [];
  
  // Configuration
  Function(String)? _onResultCallback;
  bool _isListening = false;
  Exception? mockStartError;

  @override
  bool get isListening => _isListening;

  @override
  String get recognizedText => '';

  @override
  Future<bool> initialize() async {
    log.add('initialize');
    return true;
  }

  @override
  Future<void> startListening({
    required String languageCode,
    required Function(String) onResult,
  }) async {
    log.add('startListening($languageCode)');
    if (mockStartError != null) throw mockStartError!;
    
    _isListening = true;
    _onResultCallback = onResult;
  }

  @override
  Future<void> stopListening() async {
    log.add('stopListening');
    _isListening = false;
  }

  @override
  Future<void> speak({required String text, required String languageCode}) async {
    log.add('speak($text, $languageCode)');
  }

  @override
  Future<void> stopSpeaking() async {
    log.add('stopSpeaking');
  }

  @override
  void dispose() {
    log.add('dispose');
  }

  // Helper to simulate speech input
  void simulateSpeech(String text) {
    if (_onResultCallback != null) {
      _onResultCallback!(text);
    }
  }
  
  // Stubs for unused
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late TranslationProvider provider;
  late FakeTranslationService fakeTranslationService;
  late FakeSpeechService fakeSpeechService;

  setUp(() {
    fakeTranslationService = FakeTranslationService();
    fakeSpeechService = FakeSpeechService();
    provider = TranslationProvider(
      translationService: fakeTranslationService,
      speechService: fakeSpeechService,
    );
  });

  group('TranslationProvider - Robustness & Flow Tests', () {
    
    test('Test 1: Initialization sets correct languages', () async {
      await provider.initialize(userLanguage: 'es');
      
      expect(provider.sourceLanguage, 'es');
      expect(provider.targetLanguage, 'en'); // Logic check
      expect(fakeSpeechService.log, contains('initialize'));
    });

    test('Test 2: Text Input Translation Flow (Happy Path)', () async {
      const inputText = 'Hello World';
      
      // Configure expected result
      fakeTranslationService.mockResult = TranslationResult(
        originalText: inputText,
        translatedText: 'Hola Mundo',
        sourceLanguage: 'en',
        targetLanguage: 'es',
      );

      await provider.translateText(inputText);

      // Verify service call
      expect(fakeTranslationService.log.first, contains('translateText(Hello World, en, es)'));

      // Verify state updates
      expect(provider.isTranslating, false);
      expect(provider.currentTranslation?.translatedText, 'Hola Mundo');
      expect(provider.translationHistory.length, 1);
      expect(provider.lastError, null);
    });

    test('Test 3: Microphone Input Flow (Simulation)', () async {
      // 1. Start Listening
      await provider.startListening();
      
      expect(fakeSpeechService.log, contains('startListening(en)'));
      expect(provider.isListening, true);

      // 2. Simulate Speech Stream
      fakeSpeechService.simulateSpeech('Doctor');
      expect(provider.currentInput, 'Doctor');
      
      fakeSpeechService.simulateSpeech('Doctor I have');
      expect(provider.currentInput, 'Doctor I have');

      // 3. Stop Listening (Triggers Translation)
      // Configure translation mock first
      fakeTranslationService.mockResult = TranslationResult(
        originalText: 'Doctor I have',
        translatedText: 'Docteur j\'ai',
        sourceLanguage: 'en',
        targetLanguage: 'es',
      );

      await provider.stopListening();

      expect(fakeSpeechService.log, contains('stopListening'));
      expect(provider.isListening, false);

      // Verify automatic translation
      expect(fakeTranslationService.log.last, contains('translateText(Doctor I have'));
      expect(provider.currentTranslation?.translatedText, 'Docteur j\'ai');
    });

    test('Test 4: Text-to-Speech (Output Listen Functionality)', () async {
      const translatedText = 'Bonjour';
      const targetLang = 'fr';

      await provider.speakText(translatedText, targetLang);

      expect(fakeSpeechService.log, contains('speak(Bonjour, fr)'));
      expect(provider.isSpeaking, false);
    });

    test('Test 5: Robustness - Error Handling in Translation', () async {
      fakeTranslationService.mockException = Exception('Network Error');

      await provider.translateText('Error Trigger');

      expect(provider.lastError, contains('Translation failed'));
      expect(provider.isTranslating, false);
      expect(provider.currentTranslation, null);
    });

     test('Test 6: Robustness - Error Handling in Speech', () async {
      fakeSpeechService.mockStartError = Exception('Mic Permission Denied');

      final result = await provider.startListening();

      expect(result, false);
      expect(provider.lastError, contains('Speech recognition failed'));
      expect(provider.isListening, false);
    });
    
    test('Test 7: Empty Input Safety', () async {
      await provider.translateText('   '); 
      
      // Log should be empty as service shouldn't be called
      expect(fakeTranslationService.log, isEmpty);
    });
  });
}
