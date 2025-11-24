import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/report_generation_provider.dart';
import '../providers/doctor_profile_provider.dart';
import '../constants/colors.dart';
import '../l10n/app_localizations.dart';

class ReportGenerationScreen extends StatefulWidget {
  const ReportGenerationScreen({Key? key}) : super(key: key);

  @override
  State<ReportGenerationScreen> createState() => _ReportGenerationScreenState();
}

class _ReportGenerationScreenState extends State<ReportGenerationScreen> {
  final TextEditingController _textController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Initialize provider if needed, or check permissions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissions();
      final provider = Provider.of<ReportGenerationProvider>(context, listen: false);
      provider.initialize();
      _textController.text = provider.transcribedText;
    });
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required for transcription.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to provider updates to sync text controller if needed
    // Note: If user is typing, we might want to avoid overwriting their cursor position.
    // However, for STT dominant use case, we sync.
    
    return Consumer<ReportGenerationProvider>(
      builder: (context, provider, child) {
        // Sync controller with provider text if they differ and we are NOT manually editing
        // (This is a simplification; handling concurrent edits + STT is complex)
        // If recording, we force sync.
        if (provider.isRecording && _textController.text != provider.transcribedText) {
          _textController.text = provider.transcribedText;
          _textController.selection = TextSelection.fromPosition(
             TextPosition(offset: _textController.text.length)
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Report Generation'),
            backgroundColor: AppColors.doctorColor,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () async {
                  final doctorProvider = Provider.of<DoctorProfileProvider>(context, listen: false);
                  await provider.generateAndDownloadPdf(doctorProvider.profile);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Report generated and ready to share/print.')),
                    );
                  }
                },
                tooltip: 'Generate PDF',
              ),
            ],
          ),
          body: Column(
            children: [
              // Patient Info Header (Extracted)
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.surface,
                child: Row(
                  children: [
                    const Icon(Icons.person, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Patient Name: ${provider.patientName}', 
                               style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Age: ${provider.patientAge}'),
                        ],
                      ),
                    ),
                    // Language Selector (Mini)
                    DropdownButton<String>(
                      value: provider.currentLanguage,
                      underline: Container(),
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'es', child: Text('Spanish')),
                        DropdownMenuItem(value: 'de', child: Text('German')),
                        DropdownMenuItem(value: 'fr', child: Text('French')),
                        DropdownMenuItem(value: 'it', child: Text('Italian')),
                      ],
                      onChanged: (val) {
                        if (val != null) provider.setLanguage(val);
                      },
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1),

              // Transcription Area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _textController,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration(
                      hintText: 'Start recording to transcribe medical report...',
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 16, height: 1.5),
                    onChanged: (val) {
                      provider.updateTextManually(val);
                    },
                  ),
                ),
              ),

              // Controls
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (provider.isRecording)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          'Listening...',
                          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                        ),
                      ),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Clear/Stop Button
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => provider.stopAndClear(),
                          iconSize: 32,
                          color: AppColors.textSecondary,
                          tooltip: 'Clear All',
                        ),
                        const SizedBox(width: 32),
                        
                        // Record/Pause FAB
                        FloatingActionButton.large(
                          onPressed: () => provider.toggleRecording(),
                          backgroundColor: provider.isRecording ? AppColors.error : AppColors.doctorColor,
                          child: Icon(
                            provider.isRecording ? Icons.pause : Icons.mic,
                            size: 36,
                          ),
                        ),
                        
                        const SizedBox(width: 32),
                        
                        // Action Button (Generate) - Redundant with AppBar but good for UX
                        IconButton(
                          icon: const Icon(Icons.check_circle_outline),
                          onPressed: () async {
                             final doctorProvider = Provider.of<DoctorProfileProvider>(context, listen: false);
                             await provider.generateAndDownloadPdf(doctorProvider.profile);
                          },
                          iconSize: 32,
                          color: AppColors.success,
                          tooltip: 'Save Report',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
