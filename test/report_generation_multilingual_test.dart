import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:ai_gris/providers/report_generation_provider.dart';
import 'package:ai_gris/services/speech_service.dart';
import 'package:ai_gris/services/pdf_report_service.dart';
import 'package:ai_gris/services/ai_service.dart';
import 'package:ai_gris/models/doctor_profile_model.dart';
import 'package:ai_gris/models/modification_log.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

// Manual Mocks
class MockSpeechService extends Mock implements SpeechService {
  @override
  Future<bool> initialize() async => true;
  
  @override
  Future<void> startListening({required String languageCode, required Function(String) onResult}) async {
    onResult("Patient name is Hans Muller, age 45. Patient has severe headache.");
  }
  
  @override
  Future<void> stopListening() async {}
}

class MockPdfReportService extends Mock implements PdfReportService {
  @override
  Future<Uint8List> generateReport({
    required DoctorProfileModel doctor,
    required String transcribedText,
    required String patientName,
    required String patientAge,
    List<ModificationLog>? modificationHistory,
  }) async {
    return Uint8List.fromList([1, 2, 3]);
  }
  
  @override
  Future<void> saveAndLaunchReport(Uint8List bytes, String fileName) async {}
}

class MockAiService extends AiService {
  MockAiService() : super.testing();

  @override
  Future<void> initialize() async {}

  @override
  Future<String> refineTranscription(String text, {String? context}) async {
    // Determine language from the text content
    if (text.contains('Guten Tag')) {
      return 'Guten Tag, hier ist ein medizinischer Bericht. Patient Hans Muller, 45 Jahre alt.';
    } else if (text.contains('Bonjour')) {
      return 'Bonjour, ceci est un rapport médical. Patient Jean Dupont, 50 ans.';
    } else if (text.contains('Hola')) {
      return 'Hola, este es un informe médico. Paciente Carlos Gomez, 60 años.';
    }
    return 'Refined: $text';
  }
}

class MockAudioRecorder extends Mock implements AudioRecorder {
  @override
  Future<void> start(RecordConfig config, {required String path}) async {}
  
  @override
  Future<String?> stop() async { return "path/to/file.m4a"; }
  
  @override
  Future<bool> isPaused() async => false;
  
  @override
  Future<void> pause() async {}
  
  @override
  Future<void> resume() async {}
  
  @override
  Future<void> dispose() async {}
}

class MockAudioPlayer extends Mock implements AudioPlayer {
  final _stateController = StreamController<PlayerState>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();
  final _positionController = StreamController<Duration>.broadcast();
  final _completeController = StreamController<void>.broadcast();

  @override
  Stream<PlayerState> get onPlayerStateChanged => _stateController.stream;

  @override
  Stream<Duration> get onDurationChanged => _durationController.stream;

  @override
  Stream<Duration> get onPositionChanged => _positionController.stream;

  @override
  Stream<void> get onPlayerComplete => _completeController.stream;
  
  @override
  Future<void> play(Source source, {double? volume, double? balance, AudioContext? ctx, Duration? position, PlayerMode? mode}) async {
    _stateController.add(PlayerState.playing);
  }
  
  @override
  Future<void> pause() async {
    _stateController.add(PlayerState.paused);
  }

  @override
  Future<void> stop() async {
     _stateController.add(PlayerState.stopped);
  }
  
  @override
  Future<void> dispose() async {
    _stateController.close();
    _durationController.close();
    _positionController.close();
    _completeController.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReportGenerationProvider Multilingual & Audit Trail Test', () {
    late ReportGenerationProvider provider;
    late MockSpeechService mockSpeechService;
    late MockPdfReportService mockPdfReportService;
    late MockAiService mockAiService;
    late MockAudioRecorder mockAudioRecorder;
    late MockAudioPlayer mockAudioPlayer;

    setUp(() {
      const MethodChannel('plugins.flutter.io/path_provider')
          .setMockMethodCallHandler((MethodCall methodCall) async {
        return '.';
      });

      mockSpeechService = MockSpeechService();
      mockPdfReportService = MockPdfReportService();
      mockAiService = MockAiService();
      mockAudioRecorder = MockAudioRecorder();
      mockAudioPlayer = MockAudioPlayer();
      
      provider = ReportGenerationProvider(
        speechService: mockSpeechService,
        pdfReportService: mockPdfReportService,
        aiService: mockAiService,
        audioRecorder: mockAudioRecorder,
        audioPlayer: mockAudioPlayer,
      );
    });

    test('Initial state is clean', () {
      expect(provider.isRecording, false);
      expect(provider.transcribedText, '');
      expect(provider.modificationHistory, isEmpty);
    });

    test('Language selection updates state', () {
      provider.setLanguage('de_DE');
      expect(provider.currentLanguage, 'de_DE');
      
      provider.setLanguage('ru_RU');
      expect(provider.currentLanguage, 'ru_RU');
      
      provider.setLanguage('ta_IN');
      expect(provider.currentLanguage, 'ta_IN');
    });

    test('Recording logs event and extracts data', () async {
      await provider.startRecording();
      
      // Verify state
      expect(provider.isRecording, true);
      expect(provider.patientName, 'Hans Muller');
      expect(provider.patientAge, '45');
      
      expect(provider.modificationHistory.isNotEmpty, true);
      expect(provider.modificationHistory.first.action, contains('Started Recording'));
    });

    test('Manual Edit logs event', () {
      provider.updateTextManually("New manual text");
      
      expect(provider.transcribedText, "New manual text");
      expect(provider.modificationHistory.last.action, "Manual Edit");
    });
    
    test('AI Polish logs event and updates text', () async {
      provider.updateTextManually("Bad text");
      await provider.refineWithAi();
      
      expect(provider.transcribedText, contains("Refined: Bad text"));
      expect(provider.modificationHistory.last.action, "AI Refinement Applied");
    });

    test('PDF Generation accepts history', () async {
      final doctor = DoctorProfileModel(
        name: 'Dr. Test', 
        speciality: 'Cardio', 
        idNumber: '123',
        clinicAddress: '123 Test St'
      );
      
      provider.updateTextManually("Final Report");
      await provider.generateAndDownloadPdf(doctor);
    });
  });
}
