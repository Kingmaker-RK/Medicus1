import 'package:dio/dio.dart';
import '../models/translation_result.dart';
import '../constants/app_constants.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  final Dio _dio = Dio();

  // Translate text using LLM API
  Future<TranslationResult> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    bool isMedicalContext = true,
  }) async {
    try {
      // TODO: Replace with your actual LLM API endpoint
      // This is a placeholder implementation
      // You should integrate with services like:
      // - OpenAI GPT-4
      // - Google Cloud Translation API
      // - Azure Translator
      // - Custom medical translation LLM

      final response = await _dio.post(
        AppConstants.translationApiUrl,
        data: {
          'text': text,
          'source_language': sourceLanguage,
          'target_language': targetLanguage,
          'context': 'medical',
          'include_medical_terms': true,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            // Add your API key here
            // 'Authorization': 'Bearer YOUR_API_KEY',
          },
        ),
      );

      return TranslationResult.fromJson(response.data);
    } catch (e) {
      print('Error translating text: $e');

      // Fallback: Return a mock translation for testing
      return _mockTranslation(text, sourceLanguage, targetLanguage);
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
