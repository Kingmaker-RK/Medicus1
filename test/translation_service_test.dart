import 'package:flutter_test/flutter_test.dart';
import 'package:medicus/services/localization_service.dart';
import 'package:medicus/constants/app_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final LocalizationService localizationService = LocalizationService();

  setUpAll(() {
    localizationService.initialize();
  });

  test('Translation service translates to all supported languages', () async {
    const String textToTranslate = 'Hello, how are you?';

    for (var lang in AppConstants.supportedLanguages) {
      final langCode = lang['code']!;
      if (langCode == 'en') continue;

      await localizationService.setLanguage(langCode);
      final translatedText = await localizationService.translate(textToTranslate);

      print('Original: $textToTranslate, Language: $langCode, Translated: $translatedText');

      expect(translatedText, isNotEmpty, reason: 'Failed to translate to $langCode');
      expect(translatedText, isNot(equals(textToTranslate)), reason: 'Translation for $langCode is the same as original');
    }
  });
}
