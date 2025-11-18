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
  String _currentInput = '';
  String _sourceLanguage = 'en';
  String _targetLanguage = 'es';

  List<TranslationResult> get translationHistory => _translationHistory;
  TranslationResult? get currentTranslation => _currentTranslation;
  bool get isTranslating => _isTranslating;
  bool get isListening => _isListening;
  String get currentInput => _currentInput;
  String get sourceLanguage => _sourceLanguage;
  String get targetLanguage => _targetLanguage;

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
  Future<void> translateText(String text) async {
    if (text.trim().isEmpty) return;

    _isTranslating = true;
    _currentInput = text;
    notifyListeners();

    try {
      final result = await _translationService.translateText(
        text: text,
        sourceLanguage: _sourceLanguage,
        targetLanguage: _targetLanguage,
      );

      _currentTranslation = result;
      _translationHistory.insert(0, result);

      // Speak the translated text
      await _speechService.speak(
        text: result.translatedText,
        languageCode: _targetLanguage,
      );
    } catch (e) {
      print('Error translating: $e');
    } finally {
      _isTranslating = false;
      notifyListeners();
    }
  }

  // Start listening for speech
  Future<void> startListening() async {
    if (_isListening) return;

    _isListening = true;
    _currentInput = '';
    notifyListeners();

    await _speechService.startListening(
      languageCode: _sourceLanguage,
      onResult: (text) {
        _currentInput = text;
        notifyListeners();
      },
    );
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

  // Swap languages
  void swapLanguages() {
    final temp = _sourceLanguage;
    _sourceLanguage = _targetLanguage;
    _targetLanguage = temp;
    notifyListeners();
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
    await _speechService.speak(text: text, languageCode: languageCode);
  }

  // Stop speaking
  Future<void> stopSpeaking() async {
    await _speechService.stopSpeaking();
  }

  // Update current input
  void updateInput(String text) {
    _currentInput = text;
    notifyListeners();
  }

  @override
  void dispose() {
    _speechService.dispose();
    super.dispose();
  }
}
