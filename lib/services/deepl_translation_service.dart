import 'package:deepl_dart/deepl_dart.dart';
import '../models/translation_result.dart';
import '../constants/app_constants.dart';

/// Professional DeepL translation service
/// Provides high-quality neural machine translation for 30+ languages
class DeepLTranslationService {
  static final DeepLTranslationService _instance =
      DeepLTranslationService._internal();
  factory DeepLTranslationService() => _instance;
  DeepLTranslationService._internal();

  Translator? _translator;
  bool _isInitialized = false;

  /// Initialize the DeepL translator
  /// API key can be obtained from: https://www.deepl.com/pro-api
  Future<void> initialize() async {
    try {
      final deeplApiKey = AppConstants.deeplApiKey;

      if (deeplApiKey.isNotEmpty && deeplApiKey != 'YOUR_DEEPL_API_KEY') {
        _translator = Translator(authKey: deeplApiKey);
        _isInitialized = true;
        print('✅ DeepL Translation Service initialized successfully');
      } else {
        print(
          '⚠️ DeepL API key not configured. Please set DEEPL_API_KEY in app_constants.dart',
        );
      }
    } catch (e) {
      print('❌ Failed to initialize DeepL: $e');
      _isInitialized = false;
    }
  }

  /// Check if DeepL is available and initialized
  bool get isAvailable => _isInitialized && _translator != null;

  /// Translate text using DeepL
  Future<TranslationResult> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    if (!isAvailable) {
      throw Exception(
        'DeepL translation service not initialized. Please configure DEEPL_API_KEY.',
      );
    }

    try {
      // Convert language codes to DeepL format
      final sourceLang = _convertToDeepLLanguageCode(sourceLanguage);
      final targetLang = _convertToDeepLLanguageCode(targetLanguage);

      // Perform translation
      final result = await _translator!.translateTextSingular(
        text,
        targetLang,
        sourceLang: sourceLang,
      );

      // Extract medical terms if applicable
      final medicalTerms = _extractMedicalTerms(text);

      return TranslationResult(
        originalText: text,
        translatedText: result.text,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        medicalTerms: medicalTerms,
        anatomyImages: [],
      );
    } catch (e) {
      print('❌ DeepL translation error: $e');
      rethrow;
    }
  }

  /// Convert app language codes to DeepL language codes
  String _convertToDeepLLanguageCode(String code) {
    // DeepL language code mapping
    final deeplMap = {
      'en': 'EN-US',
      'en-US': 'EN-US',
      'en-GB': 'EN-GB',
      'de': 'DE',
      'fr': 'FR',
      'es': 'ES',
      'it': 'IT',
      'nl': 'NL',
      'pl': 'PL',
      'pt': 'PT-PT',
      'pt-PT': 'PT-PT',
      'pt-BR': 'PT-BR',
      'ru': 'RU',
      'ja': 'JA',
      'zh': 'ZH',
      'zh-CN': 'ZH',
      'zh-TW': 'ZH',
      'bg': 'BG',
      'cs': 'CS',
      'da': 'DA',
      'el': 'EL',
      'et': 'ET',
      'fi': 'FI',
      'hu': 'HU',
      'id': 'ID',
      'ko': 'KO',
      'lt': 'LT',
      'lv': 'LV',
      'nb': 'NB',
      'no': 'NB',
      'ro': 'RO',
      'sk': 'SK',
      'sl': 'SL',
      'sv': 'SV',
      'tr': 'TR',
      'uk': 'UK',
    };

    return deeplMap[code] ?? 'EN-US';
  }

  /// Extract medical terms from text
  List<String> _extractMedicalTerms(String text) {
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
      'diagnosis',
      'treatment',
      'symptom',
      'disease',
      'condition',
      'therapy',
      'medication',
      'patient',
      'doctor',
      'hospital',
      'clinic',
      'emergency',
      'chronic',
      'acute',
      'fracture',
      'wound',
      'injury',
    ];

    for (final keyword in medicalKeywords) {
      if (lowerText.contains(keyword)) {
        terms.add(keyword);
      }
    }

    return terms;
  }

  /// Get usage statistics from DeepL
  Future<Map<String, dynamic>?> getUsageStatistics() async {
    if (!isAvailable) return null;

    try {
      final usage = await _translator!.getUsage();
      return {
        'characterCount': usage.characterCount,
        'characterLimit': usage.characterLimit,
        'percentageUsed': ((usage.characterCount / usage.characterLimit) * 100)
            .toStringAsFixed(2),
      };
    } catch (e) {
      print('❌ Failed to get DeepL usage statistics: $e');
      return null;
    }
  }

  /// Get list of supported languages
  Future<List<String>> getSupportedLanguages() async {
    if (!isAvailable) return [];

    try {
      final languages = await _translator!.getSourceLanguages();
      return languages.map((lang) => lang.languageCode).toList();
    } catch (e) {
      print('❌ Failed to get supported languages: $e');
      return [];
    }
  }
}
