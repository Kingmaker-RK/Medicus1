import 'package:flutter/material.dart';
import '../widgets/translated_widget.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/colors.dart';
import '../services/e_rezept_service.dart';
import '../models/pharmacy_model.dart';
import '../models/upload_record_model.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'dart:io';
import '../utils/logger.dart';

class ERezeptScreen extends StatefulWidget {
  const ERezeptScreen({Key? key}) : super(key: key);

  @override
  State<ERezeptScreen> createState() => _ERezeptScreenState();
}

class _ERezeptScreenState extends State<ERezeptScreen> {
  String? _prescriptionImagePath;
  String? _insuranceCardImagePath;
  final ImagePicker _picker = ImagePicker();
  final ERezeptService _service = ERezeptService();
  List<UploadRecord> _history = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _service.getUploadHistory();
    setState(() {
      _history = history;
    });
  }

  Future<void> _takePicture(String type) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          if (type == 'prescription') {
            _prescriptionImagePath = photo.path;
          } else {
            _insuranceCardImagePath = photo.path;
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AutoTranslateText('${type == 'prescription' ? 'Prescription' : 'Insurance card'} photo captured'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AutoTranslateText('Error capturing photo: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _processSubmission() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Find nearby pharmacies
      final pharmacies = await _service.findNearbyPharmacies();

      if (mounted) {
        // 2. Show selection dialog
        _showPharmaciesDialog(pharmacies);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error finding pharmacies: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showPharmaciesDialog(List<Pharmacy> pharmacies) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nearby Pharmacies',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Based on your current location',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: pharmacies.length,
                separatorBuilder: (ctx, i) => const Divider(),
                itemBuilder: (ctx, i) {
                  final pharmacy = pharmacies[i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: pharmacy.hasMedication ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.local_pharmacy_rounded,
                        color: pharmacy.hasMedication ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(
                      pharmacy.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pharmacy.address),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(pharmacy.openHours, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            const SizedBox(width: 12),
                            Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text('${pharmacy.distance} km', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: pharmacy.hasMedication
                          ? () {
                              Navigator.pop(context);
                              _handlePharmacySelection(pharmacy);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Select'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePharmacySelection(Pharmacy pharmacy) async {
    setState(() => _isLoading = true);
    try {
      // 1. Generate PDF
      File pdfFile;
      try {
        pdfFile = await _service.generateAndSavePdf(
          _prescriptionImagePath!,
          insuranceCardPath: _insuranceCardImagePath,
        );
      } catch (e) {
        // Check for specific error types if needed
        throw Exception('PDF Generation Error: $e');
      }

      // 2. Create Record
      final record = UploadRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        pharmacyName: pharmacy.name,
        pharmacyAddress: pharmacy.address,
        pdfPath: pdfFile.path,
        timeZone: _service.getCurrentTimeZone(),
      );

      // 3. Save Record
      try {
        await _service.saveUploadRecord(record);
      } catch (e) {
        logger.e('Error saving record: $e'); // Log it but allow flow to continue if possible? 
        // Or throw. Let's throw to be safe, but distinguishing it.
        throw Exception('Storage Error: $e');
      }

      // 4. Refresh List
      await _loadHistory();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order sent to ${pharmacy.name}! PDF Saved.'),
            backgroundColor: AppColors.success,
          ),
        );
        // Clear selection
        setState(() {
          _prescriptionImagePath = null;
          _insuranceCardImagePath = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openPdf(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await Printing.sharePdf(bytes: await file.readAsBytes(), filename: path.split('/').last);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF file not found')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const AutoTranslateText('E-Rezept'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Upload your prescription and insurance card to order medication',
                      style: TextStyle(color: Colors.blue[900]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Prescription',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildUploadCard(
              title: 'Upload Prescription',
              subtitle: 'Take a clear photo of your prescription',
              icon: Icons.receipt_long_rounded,
              hasImage: _prescriptionImagePath != null,
              onTap: () => _takePicture('prescription'),
            ),
            const SizedBox(height: 24),
            Text(
              'Insurance Card',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildUploadCard(
              title: 'Upload Insurance Card',
              subtitle: 'Front and back of your insurance card',
              icon: Icons.credit_card_rounded,
              hasImage: _insuranceCardImagePath != null,
              onTap: () => _takePicture('insurance'),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _prescriptionImagePath != null &&
                        _insuranceCardImagePath != null &&
                        !_isLoading
                    ? _processSubmission
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: AppColors.textSecondary.withValues(alpha: 0.3),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Submit Prescription',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your prescription will be verified and processed within 24 hours. You will receive a notification when your medication is ready for pickup or delivery.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Previous Uploads',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            if (_history.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No history available'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _history.length,
                separatorBuilder: (ctx, i) => const Divider(),
                itemBuilder: (context, index) {
                  final record = _history[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.history_edu_rounded, color: Colors.blueGrey),
                    ),
                    title: Text(
                      record.pharmacyName ?? 'Search Only',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('MMM dd, yyyy • HH:mm').format(record.timestamp)),
                        Text(
                          '${record.timeZone} • ${record.pharmacyAddress ?? "No pharmacy selected"}',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.red),
                      onPressed: () => _openPdf(record.pdfPath),
                    ),
                  );
                },
              ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool hasImage,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasImage
                ? AppColors.success
                : AppColors.textSecondary.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hasImage
                    ? AppColors.success.withValues(alpha: 0.1)
                    : Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                hasImage ? Icons.check_circle_rounded : icon,
                color: hasImage ? AppColors.success : Colors.blue,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasImage ? 'Photo captured' : subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: hasImage
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              hasImage ? Icons.edit_rounded : Icons.camera_alt_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
