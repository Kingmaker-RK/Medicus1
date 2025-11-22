import 'package:flutter_test/flutter_test.dart';
import 'package:ai_gris/constants/app_constants.dart';
import 'package:ai_gris/services/llm_translation_service.dart';
import 'package:ai_gris/services/translation_service.dart';

void main() {
  group('Mock Mode Tests', () {
    test('AppConstants.useMockTranslation should be true', () {
      expect(AppConstants.useMockTranslation, isTrue);
    });

    test('LLMTranslationService returns mock translation', () async {
      final service = LLMTranslationService();
      final result = await service.translate('Hello', 'es');
      expect(result, contains('[Mock: Spanish]'));
      expect(result, contains('Hello'));
    });

    test('TranslationService returns mock translation with 3D models', () async {
      final service = TranslationService();
      final result = await service.translateText(
        text: 'I have a pain in my brain',
        sourceLanguage: 'en',
        targetLanguage: 'es',
      );

      expect(result.translatedText, contains('[Mock]'));
      expect(result.translatedText, contains('brain')); // or translated equivalent if mock logic does it
      
      // Verify 3D model URL for "brain"
      expect(result.anatomyImages, isNotEmpty);
      final has3DModel = result.anatomyImages.any((url) => url.endsWith('.glb'));
      expect(has3DModel, isTrue, reason: 'Should return a GLB model for "brain"');
    });
    
    test('TranslationService returns images for Heart', () async {
       final service = TranslationService();
      final result = await service.translateText(
        text: 'Heart attack',
        sourceLanguage: 'en',
        targetLanguage: 'es',
      );
       expect(result.anatomyImages, isNotEmpty);
       // Just check it returns something
    });
  });
}
