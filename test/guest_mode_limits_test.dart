import 'package:flutter_test/flutter_test.dart';
import 'package:ai_gris/providers/translation_provider.dart';
import 'package:ai_gris/services/translation_service.dart';
import 'package:ai_gris/services/speech_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:ai_gris/models/translation_result.dart';
import 'dart:typed_data';

class MockTranslationService extends Mock implements TranslationService {
  @override
  Future<TranslationResult> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    bool isMedicalContext = true,
  }) async {
    return TranslationResult(
      originalText: text,
      translatedText: 'Translated $text',
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      medicalTerms: [],
      anatomyImages: [],
    );
  }

  @override
  Future<String> extractTextFromImage(Uint8List imageBytes) async {
    return 'Extracted Text';
  }

  @override
  Future<String> recognizeHandwriting(Uint8List imageBytes) async {
    return 'Handwritten Text';
  }
}

class MockSpeechService extends Mock implements SpeechService {
  @override
  Future<bool> initialize() async {
    return true;
  }
}

void main() {
  group('Guest Mode Limits', () {
    late TranslationProvider provider;
    late MockTranslationService mockTranslationService;
    late MockSpeechService mockSpeechService;

    setUp(() {
      mockTranslationService = MockTranslationService();
      mockSpeechService = MockSpeechService();
      provider = TranslationProvider(
        translationService: mockTranslationService,
        speechService: mockSpeechService,
      );
    });

    test('Guest Translation Limit (Max 5)', () async {
      await provider.initialize(isGuest: true);

      // Perform 5 allowed translations
      for (int i = 0; i < 5; i++) {
        await provider.translateText('Hello $i');
        expect(provider.lastError, isNull, reason: 'Translation $i should succeed');
        expect(provider.translationHistory.length, i + 1);
      }

      // Perform 6th translation (should fail)
      await provider.translateText('Hello 6');
      expect(provider.lastError, contains('Guest limit reached'));
      expect(provider.translationHistory.length, 5, reason: 'History count should stay at 5');
    });

    test('Guest Conversation Limit (Max 10)', () async {
      await provider.initialize(isGuest: true);
      provider.setConversationMode(true);

      // Perform 10 allowed conversation exchanges
      for (int i = 0; i < 10; i++) {
        await provider.translateText('Hello $i');
        expect(provider.lastError, isNull, reason: 'Conversation $i should succeed');
        expect(provider.translationHistory.length, i + 1);
      }

      // Perform 11th conversation exchange (should fail)
      await provider.translateText('Hello 11');
      expect(provider.lastError, contains('Guest limit reached'));
      expect(provider.translationHistory.length, 10, reason: 'History count should stay at 10');
    });

    test('Limits are separate for Conversation and Normal mode', () async {
      await provider.initialize(isGuest: true);

      // 5 Normal translations
      for (int i = 0; i < 5; i++) {
        await provider.translateText('Normal $i');
      }
      expect(provider.lastError, isNull);

      // Switch to conversation mode
      provider.setConversationMode(true);

      // Should be able to do conversations even if normal limit reached
      await provider.translateText('Conversation 1');
      expect(provider.lastError, isNull);
    });

    test('Image Extraction counts towards limit', () async {
      await provider.initialize(isGuest: true);

      // 4 Normal translations
      for (int i = 0; i < 4; i++) {
        await provider.translateText('Normal $i');
      }

      // 1 Image extraction (should succeed)
      await provider.extractTextFromImage(Uint8List(0));
      expect(provider.lastError, isNull);
      
      // Next translation should fail (4 normal + 1 extraction = 5)
      await provider.translateText('Fail');
      expect(provider.lastError, contains('Guest limit reached'));
    });

    test('Handwriting Recognition counts towards limit', () async {
      await provider.initialize(isGuest: true);

      // 4 Normal translations
      for (int i = 0; i < 4; i++) {
        await provider.translateText('Normal $i');
      }

      // 1 Handwriting recognition (should succeed)
      await provider.recognizeHandwriting(Uint8List(0));
      expect(provider.lastError, isNull);

      // Next translation should fail
      await provider.translateText('Fail');
      expect(provider.lastError, contains('Guest limit reached'));
    });

    test('Authenticated users have no limits', () async {
      await provider.initialize(isGuest: false);

      // Perform > 5 translations
      for (int i = 0; i < 10; i++) {
        await provider.translateText('Hello $i');
      }
      expect(provider.lastError, isNull);
      expect(provider.translationHistory.length, 10);
    });
  });
}