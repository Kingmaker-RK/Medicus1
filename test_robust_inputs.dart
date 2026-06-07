import 'dart:io';
import 'lib/services/llm_translation_service.dart';
import 'lib/constants/app_constants.dart';

/// Robustness Test Script for Translation
/// Tests "Top Test Inputs" and simulates microphone flow.
/// Run with: dart test_robust_inputs.dart

void main() async {
  print('═══════════════════════════════════════════════════════');
  print('🛡️  AI-GRIS ROBUSTNESS & INPUT TEST');
  print('═══════════════════════════════════════════════════════\n');

  final llmService = LLMTranslationService();
  llmService.initialize();

  final hasValidKey = AppConstants.geminiApiKey.isNotEmpty &&
      AppConstants.geminiApiKey != 'YOUR_GEMINI_API_KEY';

  if (!hasValidKey) {
    print('⚠️  WARNING: Gemini API key is NOT configured.');
    print('   Running in SIMULATION MODE using internal mock engine.');
    print('   Results will be simulated but will verify input processing flow.\n');
    // exit(1); // Removed to allow simulation
  } else {
    print('✅ API Key Configured. Starting robust input testing...\n');
  }

  // 1. TOP TEST INPUTS
  // Categorized inputs to rigorously test the model's capability.
  final inputs = {
    'MEDICAL_CRITICAL': [
      'Myocardial infarction with ST elevation',
      'Administer 50mg of Diphenhydramine IV push',
      'Patient presents with acute abdominal pain in the right lower quadrant',
      'Chronic obstructive pulmonary disease exacerbation',
    ],
    'CONVERSATIONAL': [
      'How have you been feeling since the last visit?',
      'Does it hurt when I press here?',
      'Please take a deep breath and hold it.',
    ],
    'COMPLEX_IDIOMATIC': [
      'I feel a bit under the weather today.',
      'He kicked the bucket yesterday.', // To see if it translates literally or idiomatically
      'It costs an arm and a leg to get surgery here.',
    ],
    'MULTILINGUAL_SOURCE': [
      'Hola, tengo un dolor de cabeza muy fuerte.', // Spanish
      'Bonjour, je suis allergique à la pénicilline.', // French
      'Mein Bauch tut weh.', // German
    ],
    'EDGE_CASES': [
      '', // Empty string
      '   ', // Whitespace
      'Hello',
      'A' * 100, // Long repeated character
    ]
  };

  final targetLang = 'es'; // Testing primarily English -> Spanish for consistency
  final backTransLang = 'en'; // For multilingual checks

  print('📋 PHASE 1: TEXT INPUT STRESS TEST');
  print('   Target Language: Spanish ($targetLang)');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  for (var category in inputs.keys) {
    print('🔸 Category: $category');
    for (var text in inputs[category]!) {
      if (text.trim().isEmpty) {
        print('   [Empty Input Test] -> Skipped (Expected behavior)');
        continue;
      }
      
      // Special handling for Multilingual inputs - translate back to English
      String target = targetLang;
      if (category == 'MULTILINGUAL_SOURCE') {
        target = backTransLang;
        print('   Scanning source: "$text" (Detect -> $target)');
      } else {
        print('   Input: "$text"');
      }

      try {
        final stopwatch = Stopwatch()..start();
        final result = await llmService.translate(text, target);
        stopwatch.stop();

        print('   ➜ Result: "$result"');
        print('   ⏱️  ${stopwatch.elapsedMilliseconds}ms');
      } catch (e) {
        print('   ❌ ERROR: $e');
      }
      print('   ---');
    }
    print('');
  }

  // 2. MICROPHONE INPUT SIMULATION
  print('📋 PHASE 2: MICROPHONE INPUT SIMULATION');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  // Simulating the stream of text that comes from SpeechToText
  final micSimulationEvents = [
    ['D', 'Do', 'Doc', 'Doctor', 'Doctor I', 'Doctor I have', 'Doctor I have pain.'],
    ['W', 'Wh', 'Whe', 'Where', 'Where is', 'Where is the', 'Where is the pharmacy?'],
    ['E', 'Er', 'Err', 'Error...'], // Simulating a glitch/noise
  ];

  print('🎙️  Simulating User Speaking...');
  
  for (var i = 0; i < micSimulationEvents.length; i++) {
    final stream = micSimulationEvents[i];
    print('\n   🗣️  Session ${i + 1}:');
    
    // Simulate the stream
    String finalRecognizedText = "";
    for (var partial in stream) {
      stdout.write('\r      🎤 Listening: "$partial"   ');
      await Future.delayed(Duration(milliseconds: 50)); // Simulate typing/speaking speed
      finalRecognizedText = partial;
    }
    print('\n      ✅ Silence Detected. Processing final input: "$finalRecognizedText"');

    if (finalRecognizedText == 'Error...') {
       print('      ⚠️  Speech Recognition Confidence Low/Error. Skipping translation.');
       continue;
    }

    try {
        final stopwatch = Stopwatch()..start();
        final result = await llmService.translate(finalRecognizedText, 'fr'); // Translate to French
        stopwatch.stop();
        print('      ➜ 🇫🇷 French Translation: "$result"');
        print('      ⏱️  Latencies: Speech(~${stream.length * 50}ms) + Trans(${stopwatch.elapsedMilliseconds}ms)');
    } catch (e) {
        print('      ❌ Translation Failed: $e');
    }
  }

  print('\n═══════════════════════════════════════════════════════');
  print('✅ ROBUSTNESS TEST COMPLETE');
  print('═══════════════════════════════════════════════════════\n');
}
