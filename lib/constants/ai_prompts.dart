class AiPrompts {
  /// The specific Gemini model version to use. 
  /// Keeping this up-to-date ensures we use the latest capabilities.
  static const String modelVersion = 'gemini-1.5-flash';

  static const String medicalRefinement = '''
You are a medical transcription assistant. 
Refine the following medical transcription text for punctuation, capitalization, and medical terminology accuracy.
Do not summarize or change the meaning. Keep the format similar.
If the text is incomplete or nonsensical, try to make it grammatically correct based on context, but do not hallucinate details.

{{CONTEXT_SECTION}}

Input Text:
"{{TEXT}}"

Refined Text:
''';
}
