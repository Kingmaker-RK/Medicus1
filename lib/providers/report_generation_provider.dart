import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/doctor_profile_model.dart';
import '../models/modification_log.dart';
import '../services/speech_service.dart';
import '../services/pdf_report_service.dart';
import '../services/ai_service.dart';

class ReportGenerationProvider with ChangeNotifier {
  final SpeechService _speechService;
  final PdfReportService _pdfReportService;
  final AiService _aiService;
  
  // Audio Recording & Playback
  final AudioRecorder _audioRecorder;
  final AudioPlayer _audioPlayer;
  String? _recordedFilePath;
  bool _isPlaying = false;
  Duration _playbackDuration = Duration.zero;
  Duration _playbackPosition = Duration.zero;

  // Edit History
  final List<ModificationLog> _modificationHistory = [];

  ReportGenerationProvider({
    SpeechService? speechService,
    PdfReportService? pdfReportService,
    AiService? aiService,
    AudioRecorder? audioRecorder,
    AudioPlayer? audioPlayer,
  })  : _speechService = speechService ?? SpeechService(),
        _pdfReportService = pdfReportService ?? PdfReportService(),
        _aiService = aiService ?? AiService(),
        _audioRecorder = audioRecorder ?? AudioRecorder(),
        _audioPlayer = audioPlayer ?? AudioPlayer() {
    
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
  String _currentLanguage = 'en_US'; // Default to US English
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
  List<ModificationLog> get modificationHistory => List.unmodifiable(_modificationHistory);

  Future<void> initialize() async {
    await _speechService.initialize();
    await _aiService.initialize();
  }

  void setLanguage(String languageCode) {
    _currentLanguage = languageCode;
    notifyListeners();
  }
  
  String get _effectiveLocale {
    if (_currentLanguage == 'de_DE_BAV') return 'de_DE';
    return _currentLanguage;
  }

  void _logModification(String action) {
    _modificationHistory.add(ModificationLog(DateTime.now(), action));
    // We don't notify here to avoid excessive rebuilds during typing, 
    // but usually we want to see the "Last Saved" update.
  }

  Future<void> toggleRecording() async {
    if (_isRecording) {
      await stopRecording(); 
    } else {
      await startRecording();
    }
  }

  Future<void> startRecording() async {
    if (_isRecording) return;
    
    try {
      if (_isPaused && await _audioRecorder.isPaused()) {
         await _audioRecorder.resume();
         _logModification("Resumed Recording");
      } else {
        // New recording
        final dir = await getTemporaryDirectory();
        _recordedFilePath = '${dir.path}/medical_report_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _audioRecorder.start(
          const RecordConfig(),
          path: _recordedFilePath!,
        );
        _modificationHistory.clear(); // Clear history for new report? Or keep? Let's clear for fresh start.
        _logModification("Started Recording");
      }

      // Start STT
      await _speechService.startListening(
        languageCode: _effectiveLocale,
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
      if (!_isRecording) {
         try {
           await _speechService.startListening(
            languageCode: _effectiveLocale,
            onResult: (text) {
              _currentSegmentText = text;
              _extractPatientData(transcribedText); // Added extraction here
              notifyListeners();
            },
          );
          _isRecording = true;
          _recordedFilePath = null; 
          _logModification("Started Recording (STT Only)");
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
    
    if (_currentSegmentText.isNotEmpty) {
      _fullTranscribedText += (_fullTranscribedText.isEmpty ? '' : ' ') + _currentSegmentText;
      _currentSegmentText = '';
    }

    _isRecording = false; 
    _isPaused = true;
    _logModification("Paused Recording");
    notifyListeners();
  }
  
  Future<void> stopRecording() async {
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
    _modificationHistory.clear();
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
    if (_isPlaying) await _audioPlayer.stop(); 
    
    final text = transcribedText;
    if (text.isNotEmpty) {
      await _speechService.speak(text: text, languageCode: _effectiveLocale);
    }
  }

  // AI Refine
  Future<void> refineWithAi() async {
    if (_fullTranscribedText.isEmpty && _currentSegmentText.isEmpty) return;
    
    _isAiRefining = true;
    notifyListeners();

    if (_currentSegmentText.isNotEmpty) {
      _fullTranscribedText += (_fullTranscribedText.isEmpty ? '' : ' ') + _currentSegmentText;
      _currentSegmentText = '';
    }

    final refined = await _aiService.refineTranscription(_fullTranscribedText);
    
    _fullTranscribedText = refined;
    _extractPatientData(refined); 
    _logModification("AI Refinement Applied");
    
    _isAiRefining = false;
    notifyListeners();
  }

  void submitFeedback(bool isPositive) {
    _aiService.logFeedback(isPositive, _fullTranscribedText);
    _logModification("Feedback: ${isPositive ? 'Positive' : 'Negative'}");
    // We could also notifyListeners() if we want to show a "Thank you" state in UI
  }
  
  void updateTextManually(String newText) {
    // Only log if meaningful change or debounced?
    // For simplicity, we log if it differs from current. 
    // But text changes on every keystroke. 
    // We should probably rely on a "save" or "blur" event, but Provider doesn't know that.
    // Instead, we will log "Manual Edit" periodically or just once per session?
    // Let's just update text here. We'll rely on the UI calling a separate 'finalizeEdit' or similar if we want precise logs.
    // OR: We check if the last log was "Manual Edit" and timestamp is recent (< 2 sec), we update timestamp.
    // This debounces the log entries.
    
    if (_fullTranscribedText != newText) {
       _fullTranscribedText = newText;
       _currentSegmentText = '';
       _extractPatientData(newText);
       
       // Debounce log
       if (_modificationHistory.isNotEmpty && 
           _modificationHistory.last.action == "Manual Edit" &&
           DateTime.now().difference(_modificationHistory.last.timestamp).inSeconds < 5) {
           // update last timestamp? Immutable log. Just don't add new one.
       } else {
          _logModification("Manual Edit");
       }
       // We assume the user is typing, so we don't notifyListeners heavily if not needed
    }
  }

  void _extractPatientData(String text) {
    final lowerText = text.toLowerCase();
    
    final ageRegex = RegExp(r'(\d+)\s*(?:years|yrs)\s*old|age\s*(?:is|:)?\s*(\d+)');
    final ageMatch = ageRegex.firstMatch(lowerText);
    if (ageMatch != null) {
      _patientAge = (ageMatch.group(1) ?? ageMatch.group(2))!;
    }

    final nameRegex = RegExp(r'patient\s+(?:name\s+(?:is|:)\s+)?([a-zA-Z\s]+?)(?:\.|,|\s+is|\s+age|\s+years)', caseSensitive: false);
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
      modificationHistory: _modificationHistory,
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