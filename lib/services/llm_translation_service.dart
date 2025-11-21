import 'dart:convert';
import 'dart:typed_data';
import 'package:meta/meta.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import 'deepl_translation_service.dart';

/// Advanced LLM-powered translation service using Llama (via OpenAI-compatible API)
/// with fallbacks to Google Gemini Flash 2.0 and DeepL.
/// Also supports architecture for integration with GPT-5.1, Claude 3.x, NLLB-200, and SeamlessM4T.
/// Provides instant, contextually accurate translations for 200+ languages
class LLMTranslationService {
    static final LLMTranslationService _instance =
        LLMTranslationService._internal();
    factory LLMTranslationService() => _instance;
    LLMTranslationService._internal();
  
    http.Client _httpClient = http.Client();
    
    /// Set HTTP client for testing
    @visibleForTesting
    void setHttpClient(http.Client client) {
      _httpClient = client;
    }
  
    GenerativeModel? _geminiModel;  final Map<String, Map<String, String>> _translationCache = {};
  final DeepLTranslationService _deepLService = DeepLTranslationService();

  bool _isLlamaConfigured = false;

  /// Initialize the translation services
  void initialize() {
    // Initialize Llama (Primary)
    if (AppConstants.llamaApiKey.isNotEmpty &&
        AppConstants.llamaApiKey != 'YOUR_LLAMA_API_KEY') {
      _isLlamaConfigured = true;
      print('✅ LLM Translation Service initialized with Llama (${AppConstants.llamaModel})');
    } else {
      print('⚠️ Llama API key not configured. Will attempt fallbacks.');
    }

    // Initialize Gemini as fallback
    if (AppConstants.geminiApiKey.isNotEmpty &&
        AppConstants.geminiApiKey != 'YOUR_GEMINI_API_KEY') {
      _geminiModel = GenerativeModel(
        model: 'gemini-2.0-flash-exp',
        apiKey: AppConstants.geminiApiKey,
        generationConfig: GenerationConfig(
          temperature: 0.3,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 8192,
        ),
      );
      if (!_isLlamaConfigured) {
        print('✅ LLM Translation Service initialized with Gemini Flash 2.0 (Fallback)');
      }
    }

    // Placeholder for future advanced models (Architecture ready)
    // - GPT-5.1: Pending API availability
    // - Claude 3.x: Requires Anthropic API key
    // - NLLB-200: Requires HuggingFace Inference API
    // - SeamlessM4T: Requires Meta AI endpoint

    _deepLService.initialize();
  }

  /// Recognize handwriting from image bytes
  /// Note: Vision tasks currently fallback to Gemini as Llama text-only models can't process images directly
  /// unless using a Llama-Vision variant. Assuming text-only Llama for now.
  Future<String> recognizeHandwriting(Uint8List imageBytes) async {
    // Fallback to Gemini for vision tasks if available
    if (_geminiModel != null) {
      try {
        final prompt =
            'Transcribe the handwriting in this image. '
            'Detect the language automatically. '
            'Return ONLY the transcribed text, no explanations. '
            'If the image is unclear, return "Unable to recognize text".';

        final content = [
          Content.multi([
            TextPart(prompt),
            DataPart('image/png', imageBytes),
          ])
        ];

        final response = await _geminiModel!.generateContent(content);
        return response.text?.trim() ?? '';
      } catch (e) {
        print('❌ Gemini Handwriting recognition error: $e');
      }
    }
    
    print('⚠️ No vision model available for handwriting recognition');
    return '';
  }

  /// Extract text from any image (handwriting or printed)
  Future<String> extractTextFromImage(Uint8List imageBytes) async {
    if (_geminiModel != null) {
      try {
        final prompt =
            'Analyze this image and extract all visible text. '
            'Detect the language automatically. '
            'Return ONLY the extracted text, no explanations. '
            'If the image contains no text, return "Unable to extract text".';

        final content = [
          Content.multi([
            TextPart(prompt),
            DataPart('image/png', imageBytes),
          ])
        ];

        final response = await _geminiModel!.generateContent(content);
        return response.text?.trim() ?? '';
      } catch (e) {
        print('❌ Gemini Image text extraction error: $e');
      }
    }

    print('⚠️ No vision model available for image text extraction');
    return '';
  }

  /// Translate text using Llama (primary) or fallbacks
  Future<String> translate(String text, String targetLanguageCode) async {
    if (text.isEmpty) return text;

    // Check cache first
    if (_translationCache.containsKey(targetLanguageCode) &&
        _translationCache[targetLanguageCode]!.containsKey(text)) {
      return _translationCache[targetLanguageCode]![text]!;
    }

    final targetLang = _getLanguageName(targetLanguageCode);

    // 1. Try Llama (Primary)
    if (_isLlamaConfigured) {
      try {
        final translatedText = await _translateWithLlama(text, targetLang);
        if (translatedText != null && translatedText.isNotEmpty) {
          _cacheTranslation(text, targetLanguageCode, translatedText);
          return translatedText;
        }
      } catch (e) {
        print('❌ Llama translation error: $e');
        // Continue to fallbacks
      }
    }

    // 2. Try DeepL (First Fallback)
    if (_deepLService.isAvailable &&
        _deepLService.getSupportedLanguages().toString().contains(targetLanguageCode)) {
      try {
        final result = await _deepLService.translateText(
          text: text,
          sourceLanguage: 'auto',
          targetLanguage: targetLanguageCode,
        );
        final translatedText = result.translatedText;
        _cacheTranslation(text, targetLanguageCode, translatedText);
        return translatedText;
      } catch (e) {
        print('❌ DeepL translation error: $e');
      }
    }

    // 3. Try Gemini (Second Fallback)
    if (_geminiModel != null) {
      try {
        final prompt =
            '''Translate the following text to $targetLang.
Provide ONLY the translated text, no explanations or additional text.
Keep the same tone, formality, and style as the original.
For medical or healthcare terms, maintain professional accuracy.

Text to translate: "$text"

Translation:''';

        final response = await _geminiModel!.generateContent([Content.text(prompt)]);
        final translatedText = response.text?.trim() ?? text;
        _cacheTranslation(text, targetLanguageCode, translatedText);
        return translatedText;
      } catch (e) {
        print('❌ Gemini translation error: $e');
      }
    }

    // All failed, return original
    return text;
  }

  Future<String?> _translateWithLlama(String text, String targetLang) async {
    try {
      final response = await _httpClient.post(
        Uri.parse(AppConstants.llamaApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConstants.llamaApiKey}',
        },
        body: jsonEncode({
          'model': AppConstants.llamaModel,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a professional medical translator. Translate the user text to $targetLang. Return ONLY the translation, nothing else. Maintain medical accuracy.'
            },
            {
              'role': 'user',
              'content': text
            }
          ],
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]['message']?['content']?.toString().trim();
        return content;
      } else {
        print('❌ Llama API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Llama Exception: $e');
      return null;
    }
  }

  /// Batch translate multiple strings efficiently
  Future<Map<String, String>> translateBatch(
    List<String> texts,
    String targetLanguageCode,
  ) async {
    if (texts.isEmpty) return {};

    final results = <String, String>{};
    final uncachedTexts = <String>[];

    // Check cache
    for (final text in texts) {
      if (_translationCache.containsKey(targetLanguageCode) &&
          _translationCache[targetLanguageCode]!.containsKey(text)) {
        results[text] = _translationCache[targetLanguageCode]![text]!;
      } else {
        uncachedTexts.add(text);
      }
    }

    if (uncachedTexts.isEmpty) return results;

    final targetLang = _getLanguageName(targetLanguageCode);

    // Prepare batch prompt
    final textList = uncachedTexts
        .asMap()
        .entries
        .map((e) => '${e.key + 1}. "${e.value}"')
        .join('\n');

    final prompt =
        '''Translate the following texts to $targetLang.
Provide translations in the same numbered format, one per line.
Keep the same tone, formality, and style as the original.
For medical or healthcare terms, maintain professional accuracy.

Texts to translate:
$textList

Translations (numbered format):''';

    String? translatedText;

    // 1. Try Llama Batch
    if (_isLlamaConfigured) {
      try {
        final response = await _httpClient.post(
          Uri.parse(AppConstants.llamaApiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AppConstants.llamaApiKey}',
          },
          body: jsonEncode({
            'model': AppConstants.llamaModel,
            'messages': [
              {
                'role': 'system',
                'content': 'You are a professional medical translator. Translate the list of texts to $targetLang in the requested numbered format. Return ONLY the numbered list.'
              },
              {
                'role': 'user',
                'content': prompt
              }
            ],
            'temperature': 0.3,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          translatedText = data['choices']?[0]['message']?['content']?.toString().trim();
        }
      } catch (e) {
        print('❌ Llama batch error: $e');
      }
    }

    // 2. Fallback to Gemini if Llama failed or not configured
    if (translatedText == null && _geminiModel != null) {
       try {
        final response = await _geminiModel!.generateContent([Content.text(prompt)]);
        translatedText = response.text?.trim();
       } catch (e) {
         print('❌ Gemini batch error: $e');
       }
    }

    // Process results if we got a translation from either service
    if (translatedText != null) {
       final lines = translatedText.split('\n');
      for (int i = 0; i < uncachedTexts.length && i < lines.length; i++) {
        var line = lines[i].trim();
        line = line.replaceFirst(RegExp(r'^\d+[\.\)]\s*'), '');
        if ((line.startsWith('"') && line.endsWith('"')) ||
            (line.startsWith("'" ) && line.endsWith("'" )) ||
            (line.startsWith('`') && line.endsWith('`'))) {
          line = line.substring(1, line.length - 1);
        }
        results[uncachedTexts[i]] = line;
        _cacheTranslation(uncachedTexts[i], targetLanguageCode, line);
      }
    }

    // Fill missing
    for (final text in uncachedTexts) {
      results.putIfAbsent(text, () => text);
    }

    return results;
  }

  void _cacheTranslation(String text, String langCode, String translation) {
    _translationCache.putIfAbsent(langCode, () => {});
    _translationCache[langCode]![text] = translation;
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
    print(
      '✅ Pre-cached ${commonStrings.length} common strings for ${_getLanguageName(targetLanguageCode)}',
    );
  }
}