import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../models/doctor_profile_model.dart';
import '../services/speech_service.dart';
import '../services/pdf_report_service.dart';

class ReportGenerationProvider with ChangeNotifier {
  final SpeechService _speechService;
  final PdfReportService _pdfReportService;

  ReportGenerationProvider({
    SpeechService? speechService,
    PdfReportService? pdfReportService,
  })  : _speechService = speechService ?? SpeechService(),
        _pdfReportService = pdfReportService ?? PdfReportService();

  bool _isRecording = false;
  bool _isPaused = false;
  String _fullTranscribedText = '';
  String _currentSegmentText = '';
  String _currentLanguage = 'en';
  
  // Extracted Data
  String _patientName = 'Unknown';
  String _patientAge = 'Unknown';

  bool get isRecording => _isRecording;
  bool get isPaused => _isPaused;
  String get transcribedText => _fullTranscribedText + (_currentSegmentText.isNotEmpty ? ' ' + _currentSegmentText : '');
  String get currentLanguage => _currentLanguage;
  String get patientName => _patientName;
  String get patientAge => _patientAge;

  Future<void> initialize() async {
    await _speechService.initialize();
  }

  void setLanguage(String languageCode) {
    _currentLanguage = languageCode;
    notifyListeners();
  }

  Future<void> toggleRecording() async {
    if (_isRecording) {
      await pauseRecording();
    } else {
      await startRecording();
    }
  }

  Future<void> startRecording() async {
    if (_isRecording) return;
    
    _isRecording = true;
    _isPaused = false;
    notifyListeners();

    await _speechService.startListening(
      languageCode: _currentLanguage,
      onResult: (text) {
        _currentSegmentText = text;
        _extractPatientData(transcribedText);
        notifyListeners();
      },
    );
  }

  Future<void> pauseRecording() async {
    if (!_isRecording) return;

    await _speechService.stopListening();
    
    // Commit current segment to full text
    if (_currentSegmentText.isNotEmpty) {
      _fullTranscribedText += (_fullTranscribedText.isEmpty ? '' : ' ') + _currentSegmentText;
      _currentSegmentText = '';
    }

    _isRecording = false;
    _isPaused = true;
    notifyListeners();
  }

  Future<void> stopAndClear() async {
    await _speechService.stopListening();
    _isRecording = false;
    _isPaused = false;
    _fullTranscribedText = '';
    _currentSegmentText = '';
    _patientName = 'Unknown';
    _patientAge = 'Unknown';
    notifyListeners();
  }
  
  void updateTextManually(String newText) {
    _fullTranscribedText = newText;
    _currentSegmentText = '';
    _extractPatientData(newText);
    notifyListeners();
  }

  void _extractPatientData(String text) {
    // Simple heuristic extraction
    // Regex for "Patient Name: [Name]" or "Patient [Name]"
    // Regex for "Age: [Age]" or "[Age] years old"
    
    final lowerText = text.toLowerCase();
    
    // Age
    final ageRegex = RegExp(r'(\d+)\s*(?:years|yrs)\s*old|age\s*(?:is|:)?\s*(\d+)');
    final ageMatch = ageRegex.firstMatch(lowerText);
    if (ageMatch != null) {
      _patientAge = (ageMatch.group(1) ?? ageMatch.group(2))!;
    }

    // Name - tricky without NLP, assuming "Patient [Name]" pattern
    // Looking for 2-3 words capitalized after "Patient" or "Name is"
    // Since we only have lowercase here, we might just look for words after keywords
    
    // Attempt with original case text if available, but STT might return lowercase depending on model. 
    // SpeechService returns what STT gives. usually sentence case.
    
    final nameRegex = RegExp(r'patient\s+(?:name\s+(?:is|:)\s+)?([a-zA-Z\s]+?)(?:\.|,|\s+is|\s+age|\s+years)');
    final nameMatch = nameRegex.firstMatch(text); // Use original text for case if possible
    
    if (nameMatch != null) {
      String rawName = nameMatch.group(1)!.trim();
      // Filter out common stop words if captured
      if (rawName.length > 20) {
        rawName = rawName.substring(0, 20); // Truncate if too long (likely captured sentence)
      }
      _patientName = rawName;
    }
  }

  Future<void> generateAndDownloadPdf(DoctorProfileModel doctor) async {
    // Ensure any pending text is committed
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
}
