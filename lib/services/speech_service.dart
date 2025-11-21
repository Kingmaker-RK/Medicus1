import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _isInitialized = false;
  bool _isListening = false;
  String _recognizedText = '';

  bool get isListening => _isListening;
  String get recognizedText => _recognizedText;

  // Initialize Speech Recognition
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speechToText.initialize(
        onStatus: (status) {
          print('Speech status: $status');
        },
        onError: (error) {
          print('Speech error: $error');
        },
      );

      // Configure TTS
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setPitch(1.0);

      return _isInitialized;
    } catch (e) {
      print('Error initializing speech services: $e');
      return false;
    }
  }

  // Start listening to speech
  Future<void> startListening({
    required String languageCode,
    required Function(String) onResult,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isInitialized && !_isListening) {
      _recognizedText = '';
      _isListening = true;

      await _speechToText.listen(
        localeId: languageCode,
        onResult: (result) {
          _recognizedText = result.recognizedWords;
          onResult(_recognizedText);
        },
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.confirmation,
          cancelOnError: true,
          partialResults: true,
        ),
      );
    }
  }

  // Stop listening
  Future<void> stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
    }
  }

  // Text to Speech
  Future<void> speak({
    required String text,
    required String languageCode,
  }) async {
    try {
      String code = _normalizeLanguageCode(languageCode);
      
      // Check if language is available
      var isAvailable = await _flutterTts.isLanguageAvailable(code);
      
      // If not available, try base language (e.g. "es-MX" -> "es")
      if (isAvailable != true && code.contains('-')) {
        code = code.split('-')[0];
        isAvailable = await _flutterTts.isLanguageAvailable(code);
      }
      
      if (isAvailable == true) {
        await _flutterTts.setLanguage(code);
        await _flutterTts.speak(text);
      } else {
        print('TTS language not available: $languageCode (normalized: $code)');
        // Fallback: Try English as a last resort for specific system messages, 
        // but for translation output, it's better to notify the user.
        // For now, we throw so the UI can handle it.
        throw Exception('Voice output not available for this language ($languageCode)');
      }
    } catch (e) {
      print('Error speaking text: $e');
      rethrow; // Allow provider to handle the error
    }
  }

  // Normalize language codes for TTS (Android legacy support)
  String _normalizeLanguageCode(String code) {
    final codeMap = {
      'fil': 'tl', // Filipino -> Tagalog
      'iw': 'he', // Hebrew old code
      'jw': 'jv', // Javanese old code
      'pus': 'ps', // Pashto
      'kok': 'gom', // Konkani
      // Add more mappings as needed for TTS engines
    };

    return codeMap[code] ?? code;
  }

  // Stop speaking
  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }

  // Check if speech recognition is available
  Future<bool> isAvailable() async {
    return await _speechToText.initialize();
  }

  // Get available locales
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) {
      await initialize();
    }
    return await _speechToText.locales();
  }

  // Dispose
  void dispose() {
    _speechToText.stop();
    _flutterTts.stop();
  }
}
