import 'package:dio/dio.dart';
import '../models/translation_result.dart';
import '../constants/app_constants.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  final Dio _dio = Dio();

  // Translate text using advanced LLM (OpenAI GPT-4)
  Future<TranslationResult> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    bool isMedicalContext = true,
  }) async {
    try {
      // Use OpenAI GPT-4 for high-quality medical translation
      // Get API key from environment or constants
      final apiKey = AppConstants.openaiApiKey;

      if (apiKey.isEmpty || apiKey == 'YOUR_OPENAI_API_KEY') {
        print('OpenAI API key not configured, using fallback translation');
        return _mockTranslation(text, sourceLanguage, targetLanguage);
      }

      // Build a medical-context aware prompt for GPT-4
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
          'temperature':
              0.3, // Lower temperature for more consistent translations
          'max_tokens': 1000,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
        ),
      );

      // Parse GPT-4 response
      final content =
          response.data['choices'][0]['message']['content'] as String;

      // Try to parse as JSON
      try {
        final jsonStart = content.indexOf('{');
        final jsonEnd = content.lastIndexOf('}') + 1;
        if (jsonStart != -1 && jsonEnd > jsonStart) {
          final jsonStr = content.substring(jsonStart, jsonEnd);
          // Parse manually using regex helpers
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
      print('Error translating with GPT-4: $e');

      // Fallback: Return a mock translation for testing
      return _mockTranslation(text, sourceLanguage, targetLanguage);
    }
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
