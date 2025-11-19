import 'package:google_generative_ai/google_generative_ai.dart';
import '../constants/app_constants.dart';

/// Advanced LLM-powered translation service using Google Gemini Flash 2.0
/// Provides instant, contextually accurate translations for 200+ languages
class LLMTranslationService {
  static final LLMTranslationService _instance = LLMTranslationService._internal();
  factory LLMTranslationService() => _instance;
  LLMTranslationService._internal();

  GenerativeModel? _model;
  final Map<String, Map<String, String>> _translationCache = {};

  /// Initialize the Gemini model
  void initialize() {
    if (AppConstants.geminiApiKey.isNotEmpty &&
        AppConstants.geminiApiKey != 'YOUR_GEMINI_API_KEY') {
      _model = GenerativeModel(
        model: 'gemini-2.0-flash-exp',
        apiKey: AppConstants.geminiApiKey,
        generationConfig: GenerationConfig(
          temperature: 0.3,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 8192,
        ),
      );
      print('✅ LLM Translation Service initialized with Gemini Flash 2.0');
    } else {
      print('⚠️ Gemini API key not configured. Using fallback translations.');
    }
  }

  /// Translate text using advanced LLM
  Future<String> translate(String text, String targetLanguageCode) async {
    if (text.isEmpty) return text;

    // Check cache first
    final cacheKey = '${text}_$targetLanguageCode';
    if (_translationCache.containsKey(targetLanguageCode) &&
        _translationCache[targetLanguageCode]!.containsKey(text)) {
      return _translationCache[targetLanguageCode]![text]!;
    }

    // If model not available, return original text
    if (_model == null) {
      return text;
    }

    try {
      final targetLang = _getLanguageName(targetLanguageCode);

      final prompt = '''Translate the following text to $targetLang.
Provide ONLY the translated text, no explanations or additional text.
Keep the same tone, formality, and style as the original.
For medical or healthcare terms, maintain professional accuracy.

Text to translate: "$text"

Translation:''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      final translatedText = response.text?.trim() ?? text;

      // Cache the translation
      _translationCache.putIfAbsent(targetLanguageCode, () => {});
      _translationCache[targetLanguageCode]![text] = translatedText;

      return translatedText;
    } catch (e) {
      print('❌ Translation error: $e');
      return text;
    }
  }

  /// Batch translate multiple strings efficiently
  Future<Map<String, String>> translateBatch(
    List<String> texts,
    String targetLanguageCode
  ) async {
    if (texts.isEmpty) return {};

    final results = <String, String>{};

    // Check cache and separate cached vs uncached
    final uncachedTexts = <String>[];
    for (final text in texts) {
      if (_translationCache.containsKey(targetLanguageCode) &&
          _translationCache[targetLanguageCode]!.containsKey(text)) {
        results[text] = _translationCache[targetLanguageCode]![text]!;
      } else {
        uncachedTexts.add(text);
      }
    }

    // If all cached, return early
    if (uncachedTexts.isEmpty) return results;

    // If model not available, return original texts
    if (_model == null) {
      for (final text in uncachedTexts) {
        results[text] = text;
      }
      return results;
    }

    try {
      final targetLang = _getLanguageName(targetLanguageCode);

      // Create batch translation prompt
      final textList = uncachedTexts.asMap().entries
          .map((e) => '${e.key + 1}. "${e.value}"')
          .join('\n');

      final prompt = '''Translate the following texts to $targetLang.
Provide translations in the same numbered format, one per line.
Keep the same tone, formality, and style as the original.
For medical or healthcare terms, maintain professional accuracy.

Texts to translate:
$textList

Translations (numbered format):''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      final translatedText = response.text?.trim() ?? '';

      // Parse numbered responses
      final lines = translatedText.split('\n');
      for (int i = 0; i < uncachedTexts.length && i < lines.length; i++) {
        var line = lines[i].trim();
        // Remove number prefix like "1. " or "1) "
        line = line.replaceFirst(RegExp(r'^\d+[\.\)]\s*'), '');
        // Remove surrounding quotes if present
        if ((line.startsWith('"') && line.endsWith('"')) ||
            (line.startsWith("'") && line.endsWith("'")) ||
            (line.startsWith('`') && line.endsWith('`'))) {
          line = line.substring(1, line.length - 1);
        }

        results[uncachedTexts[i]] = line;

        // Cache the translation
        _translationCache.putIfAbsent(targetLanguageCode, () => {});
        _translationCache[targetLanguageCode]![uncachedTexts[i]] = line;
      }

      // Fill any missing translations with original text
      for (final text in uncachedTexts) {
        results.putIfAbsent(text, () => text);
      }
    } catch (e) {
      print('❌ Batch translation error: $e');
      // Return original texts for failed translations
      for (final text in uncachedTexts) {
        results[text] = text;
      }
    }

    return results;
  }

  /// Get full language name from code
  String _getLanguageName(String code) {
    final lang = AppConstants.supportedLanguages.firstWhere(
      (l) => l['code'] == code,
      orElse: () => {'name': 'English'},
    );
    return lang['name'] ?? 'English';
  }

  /// Get cached translation if available
  String? getCachedTranslation(String text, String targetLanguageCode) {
    if (_translationCache.containsKey(targetLanguageCode) &&
        _translationCache[targetLanguageCode]!.containsKey(text)) {
      return _translationCache[targetLanguageCode]![text];
    }
    return null;
  }

  /// Clear translation cache
  void clearCache() {
    _translationCache.clear();
  }

  /// Pre-cache common UI strings for a language
  Future<void> precacheCommonStrings(String targetLanguageCode) async {
    final commonStrings = [
      'Welcome to Medicus',
      'Breaking language barriers in healthcare',
      'Sign In',
      'Sign Up',
      'Email',
      'Password',
      'Remember me',
      'Forgot Password?',
      'Continue as Guest',
      'Patient',
      'Doctor',
      'Settings',
      'Account',
      'Language',
      'App Language',
      'Permissions',
      'Microphone',
      'Camera',
      'Location',
      'Notifications',
      'About',
      'App Version',
      'About Medicus',
      'Help & Support',
      'Privacy Policy',
      'Logout',
      'User Role',
      'Guest',
      'Guest User',
      'Required for voice translation',
      'Optional for visual assistance',
      'Optional for nearby facilities',
      'Get important updates',
      'Open System Settings',
      'Manage all permissions',
      'Granted',
      'Denied',
      'Select Language',
      'Cancel',
    ];

    await translateBatch(commonStrings, targetLanguageCode);
    print('✅ Pre-cached ${commonStrings.length} common strings for ${_getLanguageName(targetLanguageCode)}');
  }
}
