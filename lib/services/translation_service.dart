import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../models/translation_result.dart';
import '../constants/app_constants.dart';
import 'deepl_translation_service.dart';
import 'llm_translation_service.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  final Dio _dio = Dio();
  final DeepLTranslationService _deeplService = DeepLTranslationService();
  final LLMTranslationService _llmService = LLMTranslationService();
  bool _forceMockTranslation = false;

  void forceMockTranslation(bool force) {
    _forceMockTranslation = force;
  }


  /// Recognize handwriting from image bytes using LLM
  Future<String> recognizeHandwriting(Uint8List imageBytes) async {
    try {
      _llmService.initialize();
      return await _llmService.recognizeHandwriting(imageBytes);
    } catch (e) {
      print('Error recognizing handwriting: $e');
      return '';
    }
  }

  /// Extract text from image bytes using LLM
  Future<String> extractTextFromImage(Uint8List imageBytes) async {
    try {
      _llmService.initialize();
      return await _llmService.extractTextFromImage(imageBytes);
    } catch (e) {
      print('Error extracting text from image: $e');
      return '';
    }
  }

  // Translate text using multiple translation services with fallback chain
  Future<TranslationResult> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    bool isMedicalContext = true,
  }) async {
    if (_forceMockTranslation) {
      return _mockTranslation(text, sourceLanguage, targetLanguage);
    }
    try {
      // 1. Try Advanced LLM (Llama/Gemini) - Priority #1
      // This service now handles Llama -> DeepL -> Gemini fallback internally
      try {
        _llmService.initialize();
        final llmTranslation = await _llmService.translate(
          text,
          targetLanguage,
        );

        if (llmTranslation.isNotEmpty && llmTranslation != text) {
           final medicalTerms = _mockMedicalTerms(text);
           final anatomyImages = await getAnatomyImages(medicalTerms);

           print('✅ Translation completed using Advanced LLM Service');
           return TranslationResult(
             originalText: text,
             translatedText: llmTranslation,
             sourceLanguage: sourceLanguage,
             targetLanguage: targetLanguage,
             medicalTerms: medicalTerms,
             anatomyImages: anatomyImages,
           );
        }
      } catch (e) {
        print('⚠️ Advanced LLM translation failed: $e');
      }

      // 2. Try DeepL API (Direct fallback if LLM service completely fails)
      if (_deeplService.isAvailable) {
        try {
          final deeplResult = await _deeplService.translateText(
            text: text,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
          );
          print('✅ Translation completed using DeepL (Direct)');
          return deeplResult;
        } catch (e) {
          print('⚠️ DeepL translation failed: $e');
        }
      }

      // 3. Try Google Translate API (if configured)
      final googleApiKey = AppConstants.googleTranslateApiKey;
      if (googleApiKey.isNotEmpty &&
          googleApiKey != 'YOUR_GOOGLE_TRANSLATE_API_KEY') {
        try {
          final googleResult = await _translateWithGoogle(
            text,
            sourceLanguage,
            targetLanguage,
          );

          // Extract medical terms and get anatomy images
          final medicalTerms = _mockMedicalTerms(text);
          final anatomyImages = await getAnatomyImages(medicalTerms);

          print('✅ Translation completed using Google Translate');
          return TranslationResult(
            originalText: text,
            translatedText: googleResult,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
            medicalTerms: medicalTerms,
            anatomyImages: anatomyImages,
          );
        } catch (e) {
          print('⚠️ Google Translate failed: $e');
        }
      }

      // 4. Try LibreTranslate (Free, no API key needed)
      try {
        final libreResult = await _translateWithLibreTranslate(
          text,
          sourceLanguage,
          targetLanguage,
        );

        final medicalTerms = _mockMedicalTerms(text);
        final anatomyImages = await getAnatomyImages(medicalTerms);

        print('✅ Translation completed using LibreTranslate');
        return TranslationResult(
          originalText: text,
          translatedText: libreResult,
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
          medicalTerms: medicalTerms,
          anatomyImages: anatomyImages,
        );
      } catch (e) {
        print('⚠️ LibreTranslate failed: $e');
      }

      // 5. Try MyMemory API (Free, no API key needed)
      try {
        final myMemoryResult = await _translateWithMyMemory(
          text,
          sourceLanguage,
          targetLanguage,
        );

        final medicalTerms = _mockMedicalTerms(text);
        final anatomyImages = await getAnatomyImages(medicalTerms);

        print('✅ Translation completed using MyMemory');
        return TranslationResult(
          originalText: text,
          translatedText: myMemoryResult,
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
          medicalTerms: medicalTerms,
          anatomyImages: anatomyImages,
        );
      } catch (e) {
        print('⚠️ MyMemory translation failed: $e');
      }

      // 6. Try OpenAI GPT-4 (if configured)
      final apiKey = AppConstants.openaiApiKey;
      if (apiKey.isNotEmpty && apiKey != 'YOUR_OPENAI_API_KEY') {
        try {
          final openAIResult = await _translateWithOpenAI(
            text,
            sourceLanguage,
            targetLanguage,
            apiKey,
          );
          return openAIResult;
        } catch (e) {
          print('OpenAI translation failed: $e');
        }
      }

      // 7. Fallback to mock translation for testing
      print(
        '⚠️ All translation APIs failed or not configured, using mock translation',
      );
      return _mockTranslation(text, sourceLanguage, targetLanguage);
    } catch (e) {
      print('Error translating with GPT-4: $e');

      // Fallback: Return a mock translation for testing
      return _mockTranslation(text, sourceLanguage, targetLanguage);
    }
  }

  // Google Translate API integration for 200+ languages
  Future<String> _translateWithGoogle(
    String text,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    try {
      final apiKey = AppConstants.googleTranslateApiKey;
      final url = '${AppConstants.googleTranslateApiUrl}?key=$apiKey';

      // Convert language codes to Google Translate format
      final sourceLang = _normalizeLanguageCode(sourceLanguage);
      final targetLang = _normalizeLanguageCode(targetLanguage);

      final response = await _dio.post(
        url,
        data: {
          'q': text,
          'source': sourceLang,
          'target': targetLang,
          'format': 'text',
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final translations = response.data['data']['translations'] as List;
        if (translations.isNotEmpty) {
          return translations[0]['translatedText'] as String;
        }
      }

      throw Exception('Translation failed: Invalid response');
    } catch (e) {
      print('Google Translate API error: $e');
      rethrow;
    }
  }

  // LibreTranslate API - Free, open-source translation (no API key required)
  Future<String> _translateWithLibreTranslate(
    String text,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    try {
      // Using public LibreTranslate instance
      final url = 'https://libretranslate.com/translate';

      final sourceLang = _normalizeLanguageCodeForLibre(sourceLanguage);
      final targetLang = _normalizeLanguageCodeForLibre(targetLanguage);

      final response = await _dio.post(
        url,
        data: {
          'q': text,
          'source': sourceLang,
          'target': targetLang,
          'format': 'text',
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200 &&
          response.data['translatedText'] != null) {
        return response.data['translatedText'] as String;
      }

      throw Exception('LibreTranslate failed: Invalid response');
    } catch (e) {
      print('LibreTranslate API error: $e');
      rethrow;
    }
  }

  // MyMemory API - Free translation with good quality (no API key required)
  Future<String> _translateWithMyMemory(
    String text,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    try {
      final sourceLang = _normalizeLanguageCode(sourceLanguage);
      final targetLang = _normalizeLanguageCode(targetLanguage);

      final langPair = '$sourceLang|$targetLang';
      final encodedText = Uri.encodeComponent(text);
      final url =
          'https://api.mymemory.translated.net/get?q=$encodedText&langpair=$langPair';

      final response = await _dio.get(
        url,
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data['responseData'];
        if (responseData != null && responseData['translatedText'] != null) {
          return responseData['translatedText'] as String;
        }
      }

      throw Exception('MyMemory translation failed: Invalid response');
    } catch (e) {
      print('MyMemory API error: $e');
      rethrow;
    }
  }

  // OpenAI GPT-4 translation with medical context
  Future<TranslationResult> _translateWithOpenAI(
    String text,
    String sourceLanguage,
    String targetLanguage,
    String apiKey,
  ) async {
    try {
      final systemPrompt =
          '''You are a professional medical translator specializing in healthcare communication.
Your task is to translate medical texts accurately while preserving medical terminology and context.
Provide translations that are culturally appropriate and medically accurate.
Extract any medical terms mentioned in the text.
Identify relevant anatomy parts that should be visualized.''';

      final userPrompt =
          '''Translate the following medical text from $sourceLanguage to $targetLanguage.
Provide the response in JSON format with these fields:
- "translatedText": the translated text
- "medicalTerms": array of medical terms found in the text
- "anatomyParts": array of anatomy parts mentioned that should be visualized

Text to translate: "$text"''';

      final response = await _dio.post(
        'https://api.openai.com/v1/chat/completions',
        data: {
          'model': 'gpt-4',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'temperature': 0.3,
          'max_tokens': 1000,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
        ),
      );

      final content =
          response.data['choices'][0]['message']['content'] as String;

      // Try to parse as JSON
      try {
        final jsonStart = content.indexOf('{');
        final jsonEnd = content.lastIndexOf('}') + 1;
        if (jsonStart != -1 && jsonEnd > jsonStart) {
          final jsonStr = content.substring(jsonStart, jsonEnd);
          final translatedText = _extractJsonValue(jsonStr, 'translatedText');
          final medicalTerms = _extractJsonArray(jsonStr, 'medicalTerms');
          final anatomyParts = _extractJsonArray(jsonStr, 'anatomyParts');
          final anatomyImages = await getAnatomyImages(anatomyParts);

          return TranslationResult(
            originalText: text,
            translatedText: translatedText.isNotEmpty
                ? translatedText
                : content,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
            medicalTerms: medicalTerms,
            anatomyImages: anatomyImages,
          );
        }
      } catch (e) {
        print('Could not parse JSON from GPT-4 response: $e');
      }

      // If JSON parsing fails, use the raw content as translation
      return TranslationResult(
        originalText: text,
        translatedText: content,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        medicalTerms: _mockMedicalTerms(text),
        anatomyImages: [],
      );
    } catch (e) {
      print('OpenAI API error: $e');
      rethrow;
    }
  }

  // Normalize language codes for Google Translate API
  String _normalizeLanguageCode(String code) {
    // Google Translate uses simplified codes for some languages
    final codeMap = {
      'zh-CN': 'zh-CN',
      'zh-TW': 'zh-TW',
      'zh-HK': 'zh-TW',
      'pt-BR': 'pt',
      'pt-PT': 'pt',
      'es-MX': 'es',
      'es-AR': 'es',
      'fr-CA': 'fr',
      'en-GB': 'en',
      'en-US': 'en',
      'en-AU': 'en',
      'fil': 'tl', // Filipino -> Tagalog
      'iw': 'he', // Hebrew old code
      'jw': 'jv', // Javanese old code
      'pus': 'ps', // Pashto
      'kok': 'gom', // Konkani
      'mni': 'mni-Mtei', // Manipuri
      'doi': 'doi', // Dogri
      'sat': 'sat', // Santali
      'mai': 'mai', // Maithili
    };

    // Return mapped code or original
    return codeMap[code] ?? code;
  }

  // Normalize language codes for LibreTranslate API
  String _normalizeLanguageCodeForLibre(String code) {
    // LibreTranslate uses simplified codes
    final codeMap = {
      'zh-CN': 'zh',
      'zh-TW': 'zh',
      'zh-HK': 'zh',
      'pt-BR': 'pt',
      'pt-PT': 'pt',
      'es-MX': 'es',
      'es-AR': 'es',
      'fr-CA': 'fr',
      'en-GB': 'en',
      'en-US': 'en',
      'en-AU': 'en',
      'fil': 'tl',
      'iw': 'he',
      'jw': 'jv',
      'pus': 'ps',
      'kok': 'hi', // Konkani -> Hindi fallback
      'mni': 'hi', // Manipuri -> Hindi fallback
      'doi': 'hi', // Dogri -> Hindi fallback
      'sat': 'hi', // Santali -> Hindi fallback
      'mai': 'hi', // Maithili -> Hindi fallback
    };

    // Return mapped code or extract base language code (e.g., 'en' from 'en-US')
    String normalized = codeMap[code] ?? code;
    if (normalized.contains('-')) {
      normalized = normalized.split('-')[0];
    }
    return normalized;
  }

  // Helper to extract JSON string value
  String _extractJsonValue(String json, String key) {
    try {
      final pattern = RegExp('"$key"\\s*:\\s*"([^"]*)"');
      final match = pattern.firstMatch(json);
      return match?.group(1) ?? '';
    } catch (e) {
      return '';
    }
  }

  // Helper to extract JSON array
  List<String> _extractJsonArray(String json, String key) {
    try {
      final pattern = RegExp('"$key"\\s*:\\s*\\[([^\\]]*)\\]');
      final match = pattern.firstMatch(json);
      if (match != null) {
        final arrayContent = match.group(1) ?? '';
        return arrayContent
            .split(',')
            .map((e) => e.trim().replaceAll('"', ''))
            .where((e) => e.isNotEmpty)
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Extract medical terms from text
  Future<List<String>> extractMedicalTerms(String text) async {
    try {
      final response = await _dio.post(
        AppConstants.medicalTermsApiUrl,
        data: {'text': text},
      );

      return List<String>.from(response.data['terms'] ?? []);
    } catch (e) {
      print('Error extracting medical terms: $e');
      return _mockMedicalTerms(text);
    }
  }

  // Get anatomy images based on medical terms
  Future<List<String>> getAnatomyImages(List<String> medicalTerms) async {
    try {
      final response = await _dio.post(
        AppConstants.anatomyImagesApiUrl,
        data: {'terms': medicalTerms},
      );

      return List<String>.from(response.data['images'] ?? []);
    } catch (e) {
      print('Error fetching anatomy images: $e');
      return _mockAnatomyImages(medicalTerms);
    }
  }

  // Mock translation for testing (replace with actual API call)
  TranslationResult _mockTranslation(
    String text,
    String sourceLanguage,
    String targetLanguage,
  ) {
    // Simple mock translation
    final translatedText = '[Translated: $text]';
    final medicalTerms = _mockMedicalTerms(text);
    final anatomyImages = _mockAnatomyImages(medicalTerms);

    return TranslationResult(
      originalText: text,
      translatedText: translatedText,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      medicalTerms: medicalTerms,
      anatomyImages: anatomyImages,
    );
  }

  // Mock medical terms extraction
  List<String> _mockMedicalTerms(String text) {
    final terms = <String>[];
    final lowerText = text.toLowerCase();

    // Common medical terms
    final medicalKeywords = [
      'heart',
      'lung',
      'brain',
      'liver',
      'kidney',
      'stomach',
      'pain',
      'fever',
      'blood',
      'pressure',
      'diabetes',
      'infection',
      'surgery',
      'medicine',
      'prescription',
    ];

    for (final keyword in medicalKeywords) {
      if (lowerText.contains(keyword)) {
        terms.add(keyword);
      }
    }

    return terms;
  }

  // Mock anatomy images
  List<String> _mockAnatomyImages(List<String> terms) {
    // In production, this would return actual 3D model URLs or image URLs
    return terms
        .map((term) => 'https://via.placeholder.com/300?text=$term')
        .toList();
  }

  // Batch translation for conversation history
  Future<List<TranslationResult>> batchTranslate(
    List<String> texts,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    final results = <TranslationResult>[];

    for (final text in texts) {
      final result = await translateText(
        text: text,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );
      results.add(result);
    }

    return results;
  }
}
