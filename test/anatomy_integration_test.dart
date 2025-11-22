import 'package:flutter_test/flutter_test.dart';
import 'package:ai_gris/services/translation_service.dart';

void main() {
  group('Anatomy Integration Tests', () {
    late TranslationService translationService;

    setUp(() {
      translationService = TranslationService();
      translationService.forceMockTranslation(true); // Force mock for consistent testing
    });

    test('Translating "heart" returns heart anatomy image', () async {
      final result = await translationService.translateText(
        text: 'I have pain in my heart',
        sourceLanguage: 'en',
        targetLanguage: 'es',
      );

      expect(result.medicalTerms, contains('heart'));
      expect(result.anatomyImages, isNotEmpty);
      // Check for part of the URL used in _mockAnatomyImages
      expect(result.anatomyImages.first, contains('heart')); 
    });

    test('Translating "brain" returns brain anatomy image', () async {
      final result = await translationService.translateText(
        text: 'Brain surgery',
        sourceLanguage: 'en',
        targetLanguage: 'es',
      );

      expect(result.medicalTerms, contains('brain'));
      expect(result.anatomyImages, isNotEmpty);
      expect(result.anatomyImages.first, contains('Brain'));
    });
    
    test('Translating "lung" returns lung anatomy image', () async {
      final result = await translationService.translateText(
        text: 'Lung infection',
        sourceLanguage: 'en',
        targetLanguage: 'es',
      );

      expect(result.medicalTerms, contains('lung'));
      expect(result.anatomyImages, isNotEmpty);
      expect(result.anatomyImages.first, contains('Lungs'));
    });

    test('Non-medical text returns no images', () async {
      final result = await translationService.translateText(
        text: 'Hello world',
        sourceLanguage: 'en',
        targetLanguage: 'es',
      );

      expect(result.medicalTerms, isEmpty);
      expect(result.anatomyImages, isEmpty);
    });

    test('Real (fallback) path: Translating "heart" returns heart anatomy image even without mock forced', () async {
      translationService.forceMockTranslation(false);
      
      final result = await translationService.translateText(
        text: 'I have pain in my heart',
        sourceLanguage: 'en',
        targetLanguage: 'es',
      );

      // Even if LLM fails/returns empty, our new fallback should catch 'heart'
      expect(result.medicalTerms, contains('heart'));
      expect(result.anatomyImages, isNotEmpty);
      expect(result.anatomyImages.first, contains('heart'));
    });
  });
}
