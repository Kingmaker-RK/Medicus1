import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../utils/logger.dart';

class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  GenerativeModel? _model;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        _model = GenerativeModel(
          model: 'gemini-1.5-flash', 
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            temperature: 0.2, // Low temperature for factual transcription correction
          ),
        );
        _isInitialized = true;
      } catch (e) {
        logger.e('Error initializing Gemini model: $e');
      }
    } else {
      logger.w('Gemini API Key not found in .env');
    }
  }

  Future<String> refineTranscription(String text) async {
    if (text.trim().isEmpty) return text;
    
    if (!_isInitialized || _model == null) {
      // Fallback: Basic heuristic cleanup if AI is not available
      logger.i('AI not initialized, performing basic cleanup.');
      return _basicCleanup(text);
    }

    try {
      final prompt = '''
      You are a medical transcription assistant. 
      Refine the following medical transcription text for punctuation, capitalization, and medical terminology accuracy.
      Do not summarize or change the meaning. Keep the format similar.
      If the text is incomplete or nonsensical, try to make it grammatically correct based on context, but do not hallucinate details.
      
      Input Text:
      "$text"
      
      Refined Text:
      ''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      
      if (response.text != null && response.text!.isNotEmpty) {
        return response.text!;
      }
      return text;
    } catch (e) {
      logger.e('Error refining transcription with AI: $e');
      return text; // Return original if error
    }
  }

  String _basicCleanup(String text) {
    // Basic capitalization
    if (text.isEmpty) return text;
    
    var result = text.trim();
    // Capitalize first letter
    if (result.isNotEmpty) {
      result = result[0].toUpperCase() + result.substring(1);
    }
    
    // Replace multiple spaces
    result = result.replaceAll(RegExp(r'\s+'), ' ');
    
    // Add period at end if missing
    if (!result.endsWith('.') && !result.endsWith('!') && !result.endsWith('?')) {
      result += '.';
    }
    
    return result;
  }
}
