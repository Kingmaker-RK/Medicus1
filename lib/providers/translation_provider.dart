import 'package:flutter/foundation.dart';
import '../models/translation_result.dart';
import '../services/translation_service.dart';
import '../services/speech_service.dart';

class TranslationProvider with ChangeNotifier {
  final TranslationService _translationService = TranslationService();
  final SpeechService _speechService = SpeechService();

  List<TranslationResult> _translationHistory = [];
  TranslationResult? _currentTranslation;
  bool _isTranslating = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  String _currentInput = '';
  String _sourceLanguage = 'en';
  String _targetLanguage = 'es';
  String? _lastError;

  List<TranslationResult> get translationHistory => _translationHistory;
  TranslationResult? get currentTranslation => _currentTranslation;
  bool get isTranslating => _isTranslating;
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  String get currentInput => _currentInput;
  String get sourceLanguage => _sourceLanguage;
  String get targetLanguage => _targetLanguage;
  String? get lastError => _lastError;

  // Initialize speech service with user's selected language
  Future<void> initialize({String? userLanguage}) async {
    await _speechService.initialize();

    // If user has selected a language, set it as the source language
    if (userLanguage != null && userLanguage.isNotEmpty) {
      _sourceLanguage = userLanguage;

      // Set target language to a different language (not the same as source)
      // Default to English if source is not English, otherwise Spanish
      if (userLanguage != 'en') {
        _targetLanguage = 'en';
      } else {
        _targetLanguage = 'es';
      }

      notifyListeners();
    }
  }

  // Translate text
  Future<void> translateText(String text, {bool autoSpeak = false}) async {
    if (text.trim().isEmpty) return;

    _isTranslating = true;
    _currentInput = text;
    _lastError = null;
    notifyListeners();

    try {
      final result = await _translationService.translateText(
        text: text,
        sourceLanguage: _sourceLanguage,
        targetLanguage: _targetLanguage,
      );

      _currentTranslation = result;
      _translationHistory.insert(0, result);

      // Optionally speak the translated text
      if (autoSpeak) {
        await speakText(result.translatedText, _targetLanguage);
      }

      _lastError = null;
    } catch (e) {
      print('Error translating: $e');
      _lastError = 'Translation failed: ${e.toString()}';
    } finally {
      _isTranslating = false;
      notifyListeners();
    }
  }

  // Start listening for speech
  Future<bool> startListening() async {
    if (_isListening) return false;

    _lastError = null;
    _isListening = true;
    _currentInput = '';
    notifyListeners();

    try {
      await _speechService.startListening(
        languageCode: _sourceLanguage,
        onResult: (text) {
          _currentInput = text;
          notifyListeners();
        },
      );
      return true;
    } catch (e) {
      print('Error starting speech recognition: $e');
      _lastError = 'Speech recognition failed: ${e.toString()}';
      _isListening = false;
      notifyListeners();
      return false;
    }
  }

  // Stop listening
  Future<void> stopListening() async {
    if (!_isListening) return;

    await _speechService.stopListening();
    _isListening = false;
    notifyListeners();

    // Automatically translate the recognized text
    if (_currentInput.isNotEmpty) {
      await translateText(_currentInput);
    }
  }

  // Swap languages and optionally re-translate
  Future<void> swapLanguages({bool retranslate = false}) async {
    final temp = _sourceLanguage;
    _sourceLanguage = _targetLanguage;
    _targetLanguage = temp;

    // Swap input and output text if translation exists
    if (_currentTranslation != null && retranslate) {
      final oldTranslatedText = _currentTranslation!.translatedText;
      _currentInput = oldTranslatedText;
      notifyListeners();

      // Re-translate with swapped languages
      await translateText(oldTranslatedText);
    } else {
      notifyListeners();
    }
  }

  // Set source language
  void setSourceLanguage(String languageCode) {
    _sourceLanguage = languageCode;
    notifyListeners();
  }

  // Update source language based on user preference (from welcome screen)
  void updateSourceLanguageFromUser(String userLanguageCode) {
    // Only update if it's different
    if (_sourceLanguage != userLanguageCode) {
      _sourceLanguage = userLanguageCode;

      // If target is the same as source, swap it to a different language
      if (_targetLanguage == userLanguageCode) {
        _targetLanguage = userLanguageCode != 'en' ? 'en' : 'es';
      }

      notifyListeners();
    }
  }

  // Set target language
  void setTargetLanguage(String languageCode) {
    _targetLanguage = languageCode;
    notifyListeners();
  }

  // Clear current input
  void clearInput() {
    _currentInput = '';
    _currentTranslation = null;
    notifyListeners();
  }

  // Clear history
  void clearHistory() {
    _translationHistory.clear();
    notifyListeners();
  }

  // Speak text
  Future<void> speakText(String text, String languageCode) async {
    if (_isSpeaking) {
      await stopSpeaking();
      return;
    }

    _isSpeaking = true;
    _lastError = null;
    notifyListeners();

    try {
      await _speechService.speak(text: text, languageCode: languageCode);
    } catch (e) {
      print('Error speaking text: $e');
      _lastError = 'Text-to-speech failed: ${e.toString()}';
    } finally {
      _isSpeaking = false;
      notifyListeners();
    }
  }

  // Stop speaking
  Future<void> stopSpeaking() async {
    if (_isSpeaking) {
      await _speechService.stopSpeaking();
      _isSpeaking = false;
      notifyListeners();
    }
  }

  // Update current input
  void updateInput(String text) {
    _currentInput = text;
    notifyListeners();
  }

  // Clear last error
  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _speechService.dispose();
    super.dispose();
  }
}
