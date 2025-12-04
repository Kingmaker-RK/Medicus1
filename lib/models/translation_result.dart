class TranslationResult {
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final List<String> medicalTerms;
  final List<String> anatomyImages;
  final DateTime timestamp;
  final String? aiFeedback;
  final String? optimizedTranslation;
  final bool isVerifiedByAI;

  TranslationResult({
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.medicalTerms = const [],
    this.anatomyImages = const [],
    DateTime? timestamp,
    this.aiFeedback,
    this.optimizedTranslation,
    this.isVerifiedByAI = false,
  }) : timestamp = timestamp ?? DateTime.now();

  factory TranslationResult.fromJson(Map<String, dynamic> json) {
    return TranslationResult(
      originalText: json['originalText'] as String? ?? '',
      translatedText: json['translatedText'] as String? ?? '',
      sourceLanguage: json['sourceLanguage'] as String? ?? '',
      targetLanguage: json['targetLanguage'] as String? ?? '',
      medicalTerms:
          (json['medicalTerms'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      anatomyImages:
          (json['anatomyImages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      aiFeedback: json['aiFeedback'] as String?,
      optimizedTranslation: json['optimizedTranslation'] as String?,
      isVerifiedByAI: json['isVerifiedByAI'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originalText': originalText,
      'translatedText': translatedText,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'medicalTerms': medicalTerms,
      'anatomyImages': anatomyImages,
      'timestamp': timestamp.toIso8601String(),
      'aiFeedback': aiFeedback,
      'optimizedTranslation': optimizedTranslation,
      'isVerifiedByAI': isVerifiedByAI,
    };
  }
}
