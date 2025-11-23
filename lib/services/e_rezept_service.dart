import 'dart:io';
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/pharmacy_model.dart';
import '../models/upload_record_model.dart';

class ERezeptService {
  static const String _historyKey = 'e_rezept_history';

  // Mock method to find nearby pharmacies
  Future<List<Pharmacy>> findNearbyPharmacies() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock data - in a real app, this would call an API with lat/long
    return [
      Pharmacy(
        name: 'Apotheke am Markt',
        address: 'Marktstraße 10, 10117 Berlin',
        distance: 0.3,
        hasMedication: true,
        openHours: '08:00 - 20:00',
      ),
      Pharmacy(
        name: 'City Apotheke',
        address: 'Friedrichstraße 200, 10117 Berlin',
        distance: 0.8,
        hasMedication: true,
        openHours: '09:00 - 19:00',
      ),
      Pharmacy(
        name: 'Gesundheit Center',
        address: 'Unter den Linden 50, 10117 Berlin',
        distance: 1.2,
        hasMedication: false, // Not available
        openHours: '08:30 - 18:30',
      ),
      Pharmacy(
        name: 'Nord Apotheke',
        address: 'Torstraße 15, 10119 Berlin',
        distance: 1.5,
        hasMedication: true,
        openHours: '08:00 - 20:00',
      ),
    ];
  }

  Future<File> generateAndSavePdf(String imagePath, {String? insuranceCardPath}) async {
    final pdf = pw.Document();
    
    final imageFile = File(imagePath);
    if (!imageFile.existsSync() || await imageFile.length() == 0) {
      throw Exception('Prescription image file is missing or empty');
    }

    pw.MemoryImage image;
    try {
      image = pw.MemoryImage(
        await imageFile.readAsBytes(),
      );
    } catch (e) {
      throw Exception('Invalid prescription image format');
    }

    pw.MemoryImage? insuranceImage;
    if (insuranceCardPath != null) {
      final insuranceFile = File(insuranceCardPath);
      if (insuranceFile.existsSync() && await insuranceFile.length() > 0) {
        try {
          insuranceImage = pw.MemoryImage(
            await insuranceFile.readAsBytes(),
          );
        } catch (e) {
           throw Exception('Invalid insurance card image format');
        }
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('E-Rezept Upload', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Date: ${DateTime.now().toString()}'),
              pw.SizedBox(height: 20),
              pw.Text('Prescription:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Expanded(child: pw.Image(image, fit: pw.BoxFit.contain)),
              if (insuranceImage != null) ...[
                pw.SizedBox(height: 20),
                pw.Text('Insurance Card:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Expanded(child: pw.Image(insuranceImage, fit: pw.BoxFit.contain)),
              ],
            ],
          );
        },
      ),
    );

    Directory output;
    try {
      output = await getApplicationDocumentsDirectory();
    } catch (e) {
      // Fallback to system temp if documents directory is unavailable (e.g. strict Linux sandbox or Web)
      output = await getTemporaryDirectory();
    }

    final file = File('${output.path}/prescription_${DateTime.now().millisecondsSinceEpoch}.pdf');
    
    try {
      await file.writeAsBytes(await pdf.save());
    } catch (e) {
      throw Exception('Failed to save PDF file: $e');
    }
    
    return file;
  }

  Future<void> saveUploadRecord(UploadRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getUploadHistory();
    history.insert(0, record); // Add to beginning
    
    final List<String> jsonList = history.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_historyKey, jsonList);
  }

  Future<List<UploadRecord>> getUploadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_historyKey);
    
    if (jsonList == null) return [];

    return jsonList.map((e) => UploadRecord.fromJson(jsonDecode(e))).toList();
  }
  
  // Helper to mock location based time zone
  String getCurrentTimeZone() {
    return DateTime.now().timeZoneName;
  }
}
