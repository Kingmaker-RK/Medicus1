import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/doctor_profile_model.dart';
import '../services/speech_service.dart';
import '../services/pdf_report_service.dart';
import '../services/ai_service.dart';

class ReportGenerationProvider with ChangeNotifier {
  final SpeechService _speechService;
  final PdfReportService _pdfReportService;
  final AiService _aiService;
  
  // Audio Recording & Playback
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _recordedFilePath;
  bool _isPlaying = false;
  Duration _playbackDuration = Duration.zero;
  Duration _playbackPosition = Duration.zero;

  ReportGenerationProvider({
    SpeechService? speechService,
    PdfReportService? pdfReportService,
    AiService? aiService,
  })  : _speechService = speechService ?? SpeechService(),
        _pdfReportService = pdfReportService ?? PdfReportService(),
        _aiService = aiService ?? AiService() {
    
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });

    _audioPlayer.onDurationChanged.listen((d) {
      _playbackDuration = d;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((p) {
      _playbackPosition = p;
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      _isPlaying = false;
      _playbackPosition = Duration.zero;
      notifyListeners();
    });
  }

  bool _isRecording = false;
  bool _isPaused = false;
  String _fullTranscribedText = '';
  String _currentSegmentText = '';
  String _currentLanguage = 'en';
  bool _isAiRefining = false;
  
  // Extracted Data
  String _patientName = 'Unknown';
  String _patientAge = 'Unknown';

  bool get isRecording => _isRecording;
  bool get isPaused => _isPaused;
  bool get isPlaying => _isPlaying;
  bool get isAiRefining => _isAiRefining;
  bool get hasRecording => _recordedFilePath != null;
  String? get recordedFilePath => _recordedFilePath;
  Duration get playbackDuration => _playbackDuration;
  Duration get playbackPosition => _playbackPosition;
  
  String get transcribedText => _fullTranscribedText + (_currentSegmentText.isNotEmpty ? ' ' + _currentSegmentText : '');
  String get currentLanguage => _currentLanguage;
  String get patientName => _patientName;
  String get patientAge => _patientAge;

  Future<void> initialize() async {
    await _speechService.initialize();
    await _aiService.initialize();
  }

  void setLanguage(String languageCode) {
    _currentLanguage = languageCode;
    notifyListeners();
  }

  Future<void> toggleRecording() async {
    if (_isRecording) {
      await stopRecording(); // "Pause" logic usually implies stopping the stream for STT
    } else {
      await startRecording();
    }
  }

  Future<void> startRecording() async {
    if (_isRecording) return;
    
    // Clear previous recording if new session starts from scratch
    // But if we want "Pause/Resume", we need to append. 
    // Complexity: Appending audio files is hard without ffmpeg.
    // Complexity: STT append is easy.
    // Decision: For this prototype, "Pause" stops recording. "Resume" starts a NEW recording file?
    // User requirement: "pause and continue like a classic recording application".
    // "Classic" usually appends.
    // 'record' package does not support appending easily on all platforms.
    // Compromise: We will overwrite audio for now, or just keep the text.
    // Let's try to just record one session. If they pause, we stop recorder. If they resume, we overwrite audio?
    // Better: If they "Pause", we just pause the UI state but keep recorder open?
    // 'record' has pause().
    
    try {
      if (_isPaused && await _audioRecorder.isPaused()) {
         await _audioRecorder.resume();
         // STT needs to restart usually
      } else {
        // New recording
        final dir = await getTemporaryDirectory();
        _recordedFilePath = '${dir.path}/medical_report_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        // Start Audio Recorder
        await _audioRecorder.start(
          const RecordConfig(),
          path: _recordedFilePath!,
        );
      }

      // Start STT
      await _speechService.startListening(
        languageCode: _currentLanguage,
        onResult: (text) {
          _currentSegmentText = text;
          _extractPatientData(transcribedText);
          notifyListeners();
        },
      );
      
      _isRecording = true;
      _isPaused = false;
      notifyListeners();

    } catch (e) {
      print("Error starting recording: $e");
      // If STT fails but Recorder works, or vice versa.
      // Try to ensure at least STT works as it's the core feature
      if (!_isRecording) {
         // Fallback: Try just STT if Recorder failed
         try {
           await _speechService.startListening(
            languageCode: _currentLanguage,
            onResult: (text) {
              _currentSegmentText = text;
              notifyListeners();
            },
          );
          _isRecording = true;
          _recordedFilePath = null; // Indicate no audio available
          notifyListeners();
         } catch (e2) {
           print("STT also failed: $e2");
         }
      }
    }
  }

  Future<void> pauseRecording() async {
    if (!_isRecording) return;

    await _speechService.stopListening();
    try {
      await _audioRecorder.pause();
    } catch (e) {
      print("Error pausing recorder: $e");
    }
    
    // Commit current segment to full text
    if (_currentSegmentText.isNotEmpty) {
      _fullTranscribedText += (_fullTranscribedText.isEmpty ? '' : ' ') + _currentSegmentText;
      _currentSegmentText = '';
    }

    _isRecording = false; // UI State
    _isPaused = true;
    notifyListeners();
  }
  
  Future<void> stopRecording() async {
     // This is "Pause" effectively in current logic, or "Stop" to finish?
     // User said "Pause and Continue".
     // My toggle calls this.
     await pauseRecording();
  }

  Future<void> stopAndClear() async {
    await _speechService.stopListening();
    try {
      await _audioRecorder.stop();
    } catch (e) {}
    
    _isRecording = false;
    _isPaused = false;
    _fullTranscribedText = '';
    _currentSegmentText = '';
    _recordedFilePath = null;
    _patientName = 'Unknown';
    _patientAge = 'Unknown';
    notifyListeners();
  }
  
  // Audio Playback
  Future<void> playRecording() async {
    if (_recordedFilePath != null && !_isPlaying) {
      await _audioPlayer.play(DeviceFileSource(_recordedFilePath!));
    } else if (_isPlaying) {
      await _audioPlayer.pause();
    }
  }
  
  // TTS Read Back
  Future<void> readBackTranscript() async {
    if (_isPlaying) await _audioPlayer.stop(); // Stop audio if playing
    
    final text = transcribedText;
    if (text.isNotEmpty) {
      await _speechService.speak(text: text, languageCode: _currentLanguage);
    }
  }

  // AI Refine
  Future<void> refineWithAi() async {
    if (_fullTranscribedText.isEmpty && _currentSegmentText.isEmpty) return;
    
    _isAiRefining = true;
    notifyListeners();

    // Commit any pending text
    if (_currentSegmentText.isNotEmpty) {
      _fullTranscribedText += (_fullTranscribedText.isEmpty ? '' : ' ') + _currentSegmentText;
      _currentSegmentText = '';
    }

    final refined = await _aiService.refineTranscription(_fullTranscribedText);
    
    _fullTranscribedText = refined;
    _extractPatientData(refined); // Re-extract data from better text
    
    _isAiRefining = false;
    notifyListeners();
  }
  
  void updateTextManually(String newText) {
    _fullTranscribedText = newText;
    _currentSegmentText = '';
    _extractPatientData(newText);
    notifyListeners();
  }

  void _extractPatientData(String text) {
    final lowerText = text.toLowerCase();
    
    final ageRegex = RegExp(r'(\d+)\s*(?:years|yrs)\s*old|age\s*(?:is|:)?\s*(\d+)');
    final ageMatch = ageRegex.firstMatch(lowerText);
    if (ageMatch != null) {
      _patientAge = (ageMatch.group(1) ?? ageMatch.group(2))!;
    }

    final nameRegex = RegExp(r'patient\s+(?:name\s+(?:is|:)\s+)?([a-zA-Z\s]+?)(?:\.|,|\s+is|\s+age|\s+years)');
    final nameMatch = nameRegex.firstMatch(text);
    
    if (nameMatch != null) {
      String rawName = nameMatch.group(1)!.trim();
      if (rawName.length > 20) {
        rawName = rawName.substring(0, 20);
      }
      _patientName = rawName;
    }
  }

  Future<void> generateAndDownloadPdf(DoctorProfileModel doctor) async {
    if (_currentSegmentText.isNotEmpty) {
       _fullTranscribedText += (_fullTranscribedText.isEmpty ? '' : ' ') + _currentSegmentText;
       _currentSegmentText = '';
    }

    final pdfBytes = await _pdfReportService.generateReport(
      doctor: doctor,
      transcribedText: _fullTranscribedText,
      patientName: _patientName,
      patientAge: _patientAge,
    );

    final fileName = 'medical_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
    await _pdfReportService.saveAndLaunchReport(pdfBytes, fileName);
  }
  
  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}