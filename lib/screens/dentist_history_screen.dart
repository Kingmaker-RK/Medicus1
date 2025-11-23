import 'package:flutter/material.dart';
import '../models/dental_record_model.dart';
import '../constants/colors.dart';
import '../widgets/translated_widget.dart';
import '../widgets/upload_selector.dart';
import 'package:intl/intl.dart';

class DentistHistoryScreen extends StatefulWidget {
  const DentistHistoryScreen({Key? key}) : super(key: key);

  @override
  State<DentistHistoryScreen> createState() => _DentistHistoryScreenState();
}

class _DentistHistoryScreenState extends State<DentistHistoryScreen> {
  // Mock data source
  final List<DentalRecord> _records = [];

  Future<void> _uploadReport() async {
    final filePath = await UploadSelector.pick(context);
    if (filePath == null) return;

    setState(() {
      final now = DateTime.now();
      _records.insert(
        0,
        DentalRecord(
          id: now.millisecondsSinceEpoch.toString(),
          fileName: 'Doctor_Visit_Report_${DateFormat('MM_dd').format(now)}',
          timestamp: now,
          filePath: filePath,
        ),
      );
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: AutoTranslateText('Report uploaded successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _renameRecord(DentalRecord record, String newName) {
    setState(() {
      record.fileName = newName;
    });
  }

  void _showRenameDialog(DentalRecord record) {
    final TextEditingController controller = TextEditingController(text: record.fileName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const AutoTranslateText('Rename File'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'File Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AutoTranslateText('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _renameRecord(record, controller.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const AutoTranslateText('Save'),
          ),
        ],
      ),
    );
  }

  void _downloadRecord(DentalRecord record) {
    // Simulate download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AutoTranslateText('Downloading ${record.fileName}.pdf...'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const AutoTranslateText('Dental History'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_edu_rounded, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const AutoTranslateText(
                    'No records found',
                    style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  const AutoTranslateText(
                    'Upload your first report to get started',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.description_rounded, color: AppColors.primary),
                    ),
                    title: Text(
                      record.fileName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      DateFormat('MMM d, yyyy - h:mm a').format(record.timestamp),
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, size: 20),
                          onPressed: () => _showRenameDialog(record),
                          color: AppColors.textSecondary,
                        ),
                        IconButton(
                          icon: const Icon(Icons.download_rounded, size: 20),
                          onPressed: () => _downloadRecord(record),
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploadReport,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.upload_file_rounded),
        label: const AutoTranslateText('Upload Report'),
      ),
    );
  }
}
