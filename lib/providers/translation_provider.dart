import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../models/translation_result.dart';
import '../services/translation_service.dart';
import '../services/speech_service.dart';

class TranslationProvider with ChangeNotifier {
  final TranslationService _translationService;
  final SpeechService _speechService;

  TranslationProvider({
    TranslationService? translationService,
    SpeechService? speechService,
  })  : _translationService = translationService ?? TranslationService(),
        _speechService = speechService ?? SpeechService();

  List<TranslationResult> _translationHistory = [];
  TranslationResult? _currentTranslation;
  bool _isTranslating = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isRecognizingHandwriting = false;
  String _currentInput = '';
  String _sourceLanguage = 'en';
  String _targetLanguage = 'es';
  String? _lastError;

  // Guest Mode Limits
  bool _isGuest = false;
  bool _isInConversationMode = false;
  int _guestTranslationCount = 0;
  int _guestConversationCount = 0;
  static const int MAX_GUEST_TRANSLATIONS = 5;
  static const int MAX_GUEST_CONVERSATIONS = 10;

  List<TranslationResult> get translationHistory => _translationHistory;
  TranslationResult? get currentTranslation => _currentTranslation;
  bool get isTranslating => _isTranslating;
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  bool get isRecognizingHandwriting => _isRecognizingHandwriting;
  String get currentInput => _currentInput;
  String get sourceLanguage => _sourceLanguage;
  String get targetLanguage => _targetLanguage;
  String? get lastError => _lastError;

  void updateGuestStatus(bool isGuest) {
    _isGuest = isGuest;
    notifyListeners();
  }

  void setConversationMode(bool enabled) {
    _isInConversationMode = enabled;
    notifyListeners();
  }

  bool _checkGuestLimit() {
    if (!_isGuest) return true;

    if (_isInConversationMode) {
      if (_guestConversationCount >= MAX_GUEST_CONVERSATIONS) {
        _lastError = 'Guest limit reached: Max $MAX_GUEST_CONVERSATIONS conversation exchanges. Please register to continue.';
        notifyListeners();
        return false;
      }
    } else {
      if (_guestTranslationCount >= MAX_GUEST_TRANSLATIONS) {
        _lastError = 'Guest limit reached: Max $MAX_GUEST_TRANSLATIONS translations. Please register to continue.';
        notifyListeners();
        return false;
      }
    }
    return true;
  }

  void _incrementGuestUsage() {
    if (!_isGuest) return;

    if (_isInConversationMode) {
      _guestConversationCount++;
    } else {
      _guestTranslationCount++;
    }
  }

  // Extract text from image
  Future<String> extractTextFromImage(Uint8List imageBytes) async {
    if (!_checkGuestLimit()) return '';

    _isRecognizingHandwriting = true; // Reusing state for UI loading indicators
    _lastError = null;
    notifyListeners();

    try {
      final text = await _translationService.extractTextFromImage(imageBytes);
      
      if (text.isNotEmpty) {
        _currentInput = text;
        _incrementGuestUsage();
      }
      
      return text;
    } catch (e) {
      print('Error extracting text from image: $e');
      _lastError = 'Image text extraction failed: ${e.toString()}';
      return '';
    } finally {
      _isRecognizingHandwriting = false;
      notifyListeners();
    }
  }

  // Recognize handwriting
  Future<String> recognizeHandwriting(Uint8List imageBytes) async {
    if (!_checkGuestLimit()) return '';

    _isRecognizingHandwriting = true;
    _lastError = null;
    notifyListeners();

    try {
      final text = await _translationService.recognizeHandwriting(imageBytes);
      
      if (text.isNotEmpty) {
        _currentInput = text;
        _incrementGuestUsage();
      }
      
      return text;
    } catch (e) {
      print('Error recognizing handwriting: $e');
      _lastError = 'Handwriting recognition failed: ${e.toString()}';
      return '';
    } finally {
      _isRecognizingHandwriting = false;
      notifyListeners();
    }
  }

  // Initialize speech service with user's selected language
  Future<void> initialize({String? userLanguage, bool isGuest = false}) async {
    await _speechService.initialize();
    _isGuest = isGuest;

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

    if (!_checkGuestLimit()) return;

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
      _incrementGuestUsage();

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
