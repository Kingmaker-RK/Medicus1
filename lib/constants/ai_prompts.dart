class AiPrompts {
  static const String medicalRefinement = '''
You are a medical transcription assistant. 
Refine the following medical transcription text for punctuation, capitalization, and medical terminology accuracy.
Do not summarize or change the meaning. Keep the format similar.
If the text is incomplete or nonsensical, try to make it grammatically correct based on context, but do not hallucinate details.

Input Text:
"{{TEXT}}"

Refined Text:
''';
}
