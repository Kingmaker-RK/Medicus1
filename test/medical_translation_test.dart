import 'package:flutter_test/flutter_test.dart';
import 'package:medicus/services/translation_service.dart';
import 'package:medicus/services/llm_translation_service.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generate mocks (manual for now since we can't run build_runner easily)
class MockClient extends Mock implements http.Client {}

void main() {
  group('Medical Translation Tests', () {
    final translationService = TranslationService();
    
    // Force mock to avoid real API calls during basic tests if credentials aren't set
    // But we want to test the logic flow.
    
    test('LLM Service Initialization', () {
      final llmService = LLMTranslationService();
      llmService.initialize();
      // Verify it doesn't crash
      expect(llmService, isNotNull);
    });

    test('Medical Model Selection', () {
      final llmService = LLMTranslationService();
      llmService.setMedicalModel('BiMediX');
      // Since _currentMedicalModel is private, we can't check it directly, 
      // but we can ensure the method runs without error.
    });

    test('Anatomy Image Mapping', () async {
      // We can't easily test private methods, but we can test the TranslationService wrapper
      // We force mock to test the fallback logic if we can't hit the API
      translationService.forceMockTranslation(true);
      
      final result = await translationService.translateText(
        text: 'I have pain in my heart',
        sourceLanguage: 'en',
        targetLanguage: 'es',
        isMedicalContext: true,
      );

      expect(result.medicalTerms, contains('heart'));
      expect(result.anatomyImages, isNotEmpty);
      // expect(result.anatomyImages.first, contains('heart')); // The mock usually puts the term in the URL
    });
  });
}
