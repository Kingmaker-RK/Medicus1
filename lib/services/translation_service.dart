import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../models/translation_result.dart';
import '../constants/app_constants.dart';
import 'deepl_translation_service.dart';
import 'llm_translation_service.dart';
import '../utils/logger.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  final Dio _dio = Dio();
  final DeepLTranslationService _deeplService = DeepLTranslationService();
  final LLMTranslationService _llmService = LLMTranslationService();
  bool _forceMockTranslation = AppConstants.useMockTranslation;

  void forceMockTranslation(bool force) {
    _forceMockTranslation = force;
  }


  /// Recognize handwriting from image bytes using LLM
  Future<String> recognizeHandwriting(Uint8List imageBytes) async {
    try {
      _llmService.initialize();
      return await _llmService.recognizeHandwriting(imageBytes);
    } catch (e) {
      logger.e('Error recognizing handwriting: $e');
      return '';
    }
  }

  /// Extract text from image bytes using LLM
  Future<String> extractTextFromImage(Uint8List imageBytes) async {
    try {
      _llmService.initialize();
      return await _llmService.extractTextFromImage(imageBytes);
    } catch (e) {
      logger.e('Error extracting text from image: $e');
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
      // 1. Try Advanced LLM (Llama/Gemini/GPT-5.1/Claude 3.x) - Priority #1
      // This service now handles Llama -> DeepL -> Gemini fallback internally
      // Architecture supports: Llama, GPT-5.1, DeepL, NLLB-200, SeamlessM4T, Claude 3.x
      logger.d('🔄 Attempting translation with Advanced LLM Service (Llama/Gemini/GPT/Claude)...');
      
      try {
        _llmService.initialize();
        
        // Use specialized medical translation if applicable
        if (isMedicalContext) {
           // Cycle through advanced models or pick one (for demo purposes we use BiMediX as default or rotate)
           // In a real app, this could be a user setting
           _llmService.setMedicalModel('BiMediX');
           
           final result = await _llmService.translateMedical(text, targetLanguage);
           
           final translatedText = result['translatedText'] as String? ?? text;
           
           // Only return if we actually got a translation
           if (translatedText != text) {
             var medicalTerms = List<String>.from(result['medicalTerms'] ?? []);
             final anatomyPart = result['anatomyPart'] as String?;

             // Fallback: If LLM didn't find terms, try simple keyword matching
             if (medicalTerms.isEmpty) {
               medicalTerms = _mockMedicalTerms('$text $translatedText');
             }
             
             // Map anatomy part to image
             List<String> anatomyImages = [];
             if (anatomyPart != null && 
                 anatomyPart.isNotEmpty && 
                 anatomyPart.toLowerCase() != 'null' && 
                 anatomyPart.toLowerCase() != 'none') {
               anatomyImages = await getAnatomyImages([anatomyPart]);
             } else if (medicalTerms.isNotEmpty) {
               anatomyImages = await getAnatomyImages(medicalTerms);
             }

             logger.d('✅ Medical Translation completed using Advanced LLM Service');
             return TranslationResult(
               originalText: text,
               translatedText: translatedText,
               sourceLanguage: sourceLanguage,
               targetLanguage: targetLanguage,
               medicalTerms: medicalTerms,
               anatomyImages: anatomyImages,
             );
           } else {
             logger.w('⚠️ Advanced LLM returned original text. Proceeding to fallbacks...');
           }
        }
        
        final llmTranslation = await _llmService.translate(
          text,
          targetLanguage,
        );

        if (llmTranslation.isNotEmpty && llmTranslation != text) {
           final medicalTerms = _mockMedicalTerms('$text $llmTranslation');
           final anatomyImages = await getAnatomyImages(medicalTerms);

           logger.d('✅ Translation completed using Advanced LLM Service');
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
        logger.e('⚠️ Advanced LLM translation failed: $e');
      }

      // 2. Try DeepL API (Direct fallback if LLM service completely fails)
      if (_deeplService.isAvailable) {
        try {
          final deeplResult = await _deeplService.translateText(
            text: text,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
          );
          logger.d('✅ Translation completed using DeepL (Direct)');
          return deeplResult;
        } catch (e) {
          logger.e('⚠️ DeepL translation failed: $e');
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
          final medicalTerms = _mockMedicalTerms('$text $googleResult');
          final anatomyImages = await getAnatomyImages(medicalTerms);

          logger.d('✅ Translation completed using Google Translate');
          return TranslationResult(
            originalText: text,
            translatedText: googleResult,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
            medicalTerms: medicalTerms,
            anatomyImages: anatomyImages,
          );
        } catch (e) {
          logger.e('⚠️ Google Translate failed: $e');
        }
      }

      // 4. Try MyMemory API (Free, no API key needed)
      try {
        final myMemoryResult = await _translateWithMyMemory(
          text,
          sourceLanguage,
          targetLanguage,
        );

        final medicalTerms = _mockMedicalTerms('$text $myMemoryResult');
        final anatomyImages = await getAnatomyImages(medicalTerms);

        logger.d('✅ Translation completed using MyMemory');
        return TranslationResult(
          originalText: text,
          translatedText: myMemoryResult,
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
          medicalTerms: medicalTerms,
          anatomyImages: anatomyImages,
        );
      } catch (e) {
        logger.e('⚠️ MyMemory translation failed: $e');
      }

      // 5. Try LibreTranslate (Free, no API key needed)
      try {
        final libreResult = await _translateWithLibreTranslate(
          text,
          sourceLanguage,
          targetLanguage,
        );

        final medicalTerms = _mockMedicalTerms('$text $libreResult');
        final anatomyImages = await getAnatomyImages(medicalTerms);

        logger.d('✅ Translation completed using LibreTranslate');
        return TranslationResult(
          originalText: text,
          translatedText: libreResult,
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
          medicalTerms: medicalTerms,
          anatomyImages: anatomyImages,
        );
      } catch (e) {
        logger.e('⚠️ LibreTranslate failed: $e');
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
          logger.e('OpenAI translation failed: $e');
        }
      }

      // 7. Fallback to mock translation for testing
      logger.w(
        '⚠️ All translation APIs failed or not configured. Please check API keys in .env or ApiConfig. Using mock translation as fallback.',
      );
      return _mockTranslation(text, sourceLanguage, targetLanguage);
    } catch (e) {
      logger.e('Error translating with GPT-4: $e');

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
      logger.e('Google Translate API error: $e');
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
      logger.e('LibreTranslate API error: $e');
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
      logger.e('MyMemory API error: $e');
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
        logger.w('Could not parse JSON from GPT-4 response: $e');
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
      logger.e('OpenAI API error: $e');
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
      final pattern = RegExp('"$key"\\s*:\s*"([^"]*)"');
      final match = pattern.firstMatch(json);
      return match?.group(1) ?? '';
    } catch (e) {
      return '';
    }
  }

  // Helper to extract JSON array
  List<String> _extractJsonArray(String json, String key) {
    try {
      final pattern = RegExp('"$key"\\s*:\s*\[([^\]]*)\]');
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
      logger.e('Error extracting medical terms: $e');
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
      logger.e('Error fetching anatomy images: $e');
      return _mockAnatomyImages(medicalTerms);
    }
  }

  // Mock translation for testing (replace with actual API call)
  TranslationResult _mockTranslation(
    String text,
    String sourceLanguage,
    String targetLanguage,
  ) {
    // Simple mock translation with basic keyword mapping for testing
    var translatedContent = text;
    if (targetLanguage == 'en') {
      if (translatedContent.contains('corazón')) {
        translatedContent = translatedContent.replaceAll('corazón', 'heart');
      }
      if (translatedContent.contains('dolor')) {
        translatedContent = translatedContent.replaceAll('dolor', 'pain');
      }
    }
    
    final translatedText = '[Mock] $translatedContent';
    // Use combined text to ensure we catch keywords in either language
    final medicalTerms = _mockMedicalTerms('$text $translatedText');
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

    // Comprehensive list of medical keywords
    final medicalKeywords = [
      // Organs & Systems
      'heart', 'lung', 'brain', 'liver', 'kidney', 'stomach', 'pancreas', 
      'spleen', 'bladder', 'intestine', 'colon', 'appendix', 'thyroid', 
      'esophagus', 'throat', 'nose', 'ear', 'eye', 'skin',
      
      // Bones & Skeleton
      'bone', 'skeleton', 'skull', 'spine', 'vertebra', 'rib', 'pelvis', 
      'femur', 'tibia', 'fibula', 'humerus', 'radius', 'ulna', 'knee', 
      'elbow', 'shoulder', 'hip', 'wrist', 'ankle', 'finger', 'toe', 'joint',
      
      // Muscles & Tissues
      'muscle', 'tendon', 'ligament', 'nerve', 'vein', 'artery', 'blood',
      
      // Conditions & Symptoms
      'pain', 'fever', 'infection', 'inflammation', 'swelling', 'fracture', 
      'break', 'sprain', 'strain', 'bruise', 'cut', 'wound', 'burn', 
      'rash', 'itch', 'cough', 'cold', 'flu', 'virus', 'bacteria', 
      'cancer', 'tumor', 'cyst', 'diabetes', 'pressure', 'hypertension', 
      'anemia', 'asthma', 'allergy', 'headache', 'migraine', 'nausea', 
      'vomit', 'diarrhea', 'constipation', 'surgery', 'operation', 
      'medicine', 'prescription', 'dose', 'pill', 'tablet', 'injection',
      'vaccine', 'therapy', 'treatment', 'diagnosis', 'symptom'
    ];

    for (final keyword in medicalKeywords) {
      // Check for whole words or significant parts
      if (lowerText.contains(keyword)) {
        terms.add(keyword);
      }
    }

    return terms;
  }

  // Mock anatomy images
  List<String> _mockAnatomyImages(List<String> terms) {
    if (terms.isEmpty) return [];

    final images = <String>[];
    final uniqueImages = <String>{}; // To prevent duplicates

    void addImage(String url) {
      if (uniqueImages.add(url)) {
        images.add(url);
      }
    }

    for (final term in terms) {
      final lowerTerm = term.toLowerCase();
      
      // 3D Models (GLB/GLTF)
      if (lowerTerm.contains('brain') || lowerTerm.contains('nerve') || 
          lowerTerm.contains('head') || lowerTerm.contains('migraine')) {
        // Official Khronos Sample BrainStem model
        addImage('https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/BrainStem/glTF-Binary/BrainStem.glb');
      }

      // Circulatory System
      if (lowerTerm.contains('heart') || lowerTerm.contains('cardio') || 
          lowerTerm.contains('blood') || lowerTerm.contains('artery') || 
          lowerTerm.contains('vein') || lowerTerm.contains('pressure')) {
        addImage('https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/Diagram_of_the_human_heart_%28cropped%29.svg/200px-Diagram_of_the_human_heart_%28cropped%29.svg.png');
      } 
      
      // Respiratory System
      else if (lowerTerm.contains('lung') || lowerTerm.contains('breath') || 
               lowerTerm.contains('cough') || lowerTerm.contains('asthma') ||
               lowerTerm.contains('respiratory')) {
        addImage('https://upload.wikimedia.org/wikipedia/commons/thumb/a/a1/Lungs_diagram_simple.svg/200px-Lungs_diagram_simple.svg.png');
      }
      
      // Digestive System
      else if (lowerTerm.contains('liver') || lowerTerm.contains('hepat')) {
        addImage('https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Liver_and_nearby_organs.svg/200px-Liver_and_nearby_organs.svg.png');
      }
      else if (lowerTerm.contains('stomach') || lowerTerm.contains('intestine') || 
               lowerTerm.contains('colon') || lowerTerm.contains('digest') || 
               lowerTerm.contains('belly') || lowerTerm.contains('abdomen') || 
               lowerTerm.contains('nausea')) {
        addImage('https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Digestive_system_diagram_en.svg/200px-Digestive_system_diagram_en.svg.png');
      }
      
      // Urinary/Renal
      else if (lowerTerm.contains('kidney') || lowerTerm.contains('renal') || 
               lowerTerm.contains('bladder') || lowerTerm.contains('urine')) {
        addImage('https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/Kidney_cross_section.svg/200px-Kidney_cross_section.svg.png');
      }
      
      // Skeletal System
      else if (lowerTerm.contains('bone') || lowerTerm.contains('skeleton') || 
               lowerTerm.contains('fracture') || lowerTerm.contains('break') || 
               lowerTerm.contains('rib') || lowerTerm.contains('skull') || 
               lowerTerm.contains('spine') || lowerTerm.contains('joint')) {
        addImage('https://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/Human_skeleton_front_en.svg/200px-Human_skeleton_front_en.svg.png');
      }
      
      // Limb specific (Legs/Arms)
      else if (lowerTerm.contains('leg') || lowerTerm.contains('knee') || 
               lowerTerm.contains('ankle') || lowerTerm.contains('foot') || 
               lowerTerm.contains('femur') || lowerTerm.contains('tibia')) {
        addImage('https://upload.wikimedia.org/wikipedia/commons/thumb/5/51/Human_leg_bones_labeled.svg/200px-Human_leg_bones_labeled.svg.png');
      }
      
      else if (lowerTerm.contains('arm') || lowerTerm.contains('elbow') || 
               lowerTerm.contains('wrist') || lowerTerm.contains('hand') || 
               lowerTerm.contains('humerus')) {
        addImage('https://upload.wikimedia.org/wikipedia/commons/thumb/f/f1/Human_arm_bones_diagram.svg/200px-Human_arm_bones_diagram.svg.png');
      }

      // Eye
      else if (lowerTerm.contains('eye') || lowerTerm.contains('vision') || 
               lowerTerm.contains('blind')) {
        addImage('https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Schematic_diagram_of_the_human_eye_en.svg/200px-Schematic_diagram_of_the_human_eye_en.svg.png');
      }
      
      // Ear
      else if (lowerTerm.contains('ear') || lowerTerm.contains('hear')) {
        addImage('https://upload.wikimedia.org/wikipedia/commons/thumb/d/d2/Anatomy_of_the_Human_Ear.svg/200px-Anatomy_of_the_Human_Ear.svg.png');
      }
      
      // Skin
      else if (lowerTerm.contains('skin') || lowerTerm.contains('derm') || 
               lowerTerm.contains('rash') || lowerTerm.contains('burn') || 
               lowerTerm.contains('cut') || lowerTerm.contains('wound')) {
        addImage('https://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/Skin_layers.svg/200px-Skin_layers.svg.png');
      }
    }

    // If we found nothing specific but have terms, return a generic human body image
    if (images.isEmpty && terms.isNotEmpty) {
       images.add('https://upload.wikimedia.org/wikipedia/commons/thumb/4/4b/Human_body_features.jpg/200px-Human_body_features.jpg');
    }

    return images;
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
