import 'package:flutter/material.dart';
import 'llm_translation_service.dart';
import '../utils/logger.dart';

/// Localization service for instant UI translation
class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  final LLMTranslationService _llmService = LLMTranslationService();
  String _currentLanguageCode = 'en';

  /// Initialize the service
  void initialize() {
    _llmService.initialize();
  }

  /// Set current language
  Future<void> setLanguage(String languageCode) async {
    logger.d(
      '🌍 LocalizationService: Setting language from $_currentLanguageCode to $languageCode',
    );

    // Always update language and clear cache to ensure fresh state
    final previousLanguage = _currentLanguageCode;
    _currentLanguageCode = languageCode;

    // Clear cache completely to force fresh translations
    if (previousLanguage != languageCode) {
      logger.d(
        '🧹 LocalizationService: Clearing translation cache for language change',
      );
      _llmService.clearCache();
    }

    logger.d('✅ LocalizationService: Language changed to $_currentLanguageCode');

    // Pre-cache common strings for better performance
    if (languageCode != 'en') {
      try {
        logger.d(
          '🔄 LocalizationService: Pre-caching common strings for $languageCode...',
        );
        await _llmService.precacheCommonStrings(languageCode);
        logger.d('✅ LocalizationService: Pre-caching complete for $languageCode');
      } catch (e) {
        logger.w('⚠️ LocalizationService: Pre-caching failed - $e');
        // Continue even if pre-caching fails - translations will work on-demand
      }
    } else {
      logger.d('ℹ️ LocalizationService: English selected, skipping pre-cache');
    }
  }

  /// Get translated string
  Future<String> translate(String text) async {
    if (_currentLanguageCode == 'en' || text.isEmpty) {
      return text;
    }

    logger.d('🔤 Translating "$text" to $_currentLanguageCode...');
    final result = await _llmService.translate(text, _currentLanguageCode);
    logger.d('✅ Translation result: "$result"');
    return result;
  }

  /// Synchronous translation (uses cache, returns original if not cached)
  String translateSync(String text) {
    if (_currentLanguageCode == 'en' || text.isEmpty) {
      return text;
    }

    // Try to get from cache
    final cachedTranslation = _llmService.getCachedTranslation(
      text,
      _currentLanguageCode,
    );
    if (cachedTranslation != null) {
      return cachedTranslation;
    }

    // Not in cache, trigger async translation in background
    _llmService.translate(text, _currentLanguageCode);

    // Return original text for now
    return text;
  }

  /// Clear cache
  void clearCache() {
    _llmService.clearCache();
  }

  /// Get current language code
  String get currentLanguageCode => _currentLanguageCode;
}

/// Extension for easy translation in widgets
extension TranslationExtension on String {
  /// Translate this string
  Future<String> tr() async {
    return await LocalizationService().translate(this);
  }

  /// Synchronous translation (uses cache)
  String trSync() {
    return LocalizationService().translateSync(this);
  }
}

/// Translated text widget that rebuilds when language changes
class TranslatedText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool softWrap;

  const TranslatedText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  }) : super(key: key);

  @override
  State<TranslatedText> createState() => _TranslatedTextState();
}

class _TranslatedTextState extends State<TranslatedText> {
  String _translatedText = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTranslation();
  }

  @override
  void didUpdateWidget(TranslatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _loadTranslation();
    }
  }

  Future<void> _loadTranslation() async {
    setState(() {
      _isLoading = true;
    });

    final translated = await LocalizationService().translate(widget.text);

    if (mounted) {
      setState(() {
        _translatedText = translated;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Show original text while loading
      return Text(
        widget.text,
        style: widget.style,
        textAlign: widget.textAlign,
        maxLines: widget.maxLines,
        overflow: widget.overflow,
        softWrap: widget.softWrap,
      );
    }

    return Text(
      _translatedText,
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      softWrap: widget.softWrap,
    );
  }
}
