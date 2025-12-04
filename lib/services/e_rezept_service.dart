import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/pharmacy_model.dart';
import '../models/upload_record_model.dart';
import '../utils/logger.dart';

import 'database_service.dart';

class ERezeptService {
  static const String _historyKey = 'e_rezept_history';

  // Find nearby pharmacies using Overpass API (Real-time data)
  Future<List<Pharmacy>> findNearbyPharmacies() async {
    try {
      // Default location: Berlin TV Tower (52.5208, 13.4094)
      // In a production app, we would use geolocator to get the user's current position
      const double userLat = 52.5208;
      const double userLon = 13.4094;
      const int radius = 2000; // 2km radius

      final dio = Dio();
      // Overpass QL query for pharmacies
      final query = '[out:json];node["amenity"="pharmacy"](around:$radius,$userLat,$userLon);out;';
      
      final response = await dio.get(
        'https://overpass-api.de/api/interpreter',
        queryParameters: {'data': query},
      );

      if (response.statusCode == 200 && response.data != null) {
        final elements = response.data['elements'] as List;
        
        final pharmacies = elements.take(15).map<Pharmacy>((e) {
          final tags = e['tags'] ?? {};
          final lat = e['lat'] as double;
          final lon = e['lon'] as double;
          
          final name = tags['name'] ?? 'Pharmacy';
          final street = tags['addr:street'] ?? '';
          final houseNumber = tags['addr:housenumber'] ?? '';
          final postcode = tags['addr:postcode'] ?? '';
          final city = tags['addr:city'] ?? '';
          
          String address = '$street $houseNumber, $postcode $city'.trim();
          if (address.isEmpty || address == ',') {
             address = 'Unknown Address';
          }

          final phone = tags['phone'] ?? tags['contact:phone'] ?? '+49 30 98765432';
          final website = tags['website'] ?? tags['contact:website'] ?? '';

          final distance = _calculateDistance(userLat, userLon, lat, lon);
          
          return Pharmacy(
            name: name,
            address: address,
            distance: double.parse(distance.toStringAsFixed(2)),
            hasMedication: true, // Assuming availability for found pharmacies
            openHours: tags['opening_hours'] ?? '09:00 - 18:00',
            phone: phone,
            website: website,
          );
        }).toList();

        // Sort by distance
        pharmacies.sort((a, b) => a.distance.compareTo(b.distance));
        
        return pharmacies;
      }
    } catch (e) {
      logger.e('Error fetching real pharmacy data: $e');
    }

    // Fallback to mock data if API fails or network is down
    logger.w('Falling back to mock pharmacy data');
    return [
      Pharmacy(
        name: 'Apotheke am Markt (Mock)',
        address: 'Marktstraße 10, 10117 Berlin',
        distance: 0.3,
        hasMedication: true,
        openHours: '08:00 - 20:00',
        phone: '+49 30 123456',
        website: 'https://example.com',
      ),
      Pharmacy(
        name: 'City Apotheke (Mock)',
        address: 'Friedrichstraße 200, 10117 Berlin',
        distance: 0.8,
        hasMedication: true,
        openHours: '09:00 - 19:00',
        phone: '+49 30 654321',
        website: 'https://example.com',
      ),
    ];
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = math.cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 + 
          c(lat1 * p) * c(lat2 * p) * 
          (1 - c((lon2 - lon1) * p))/2;
    return 12742 * math.asin(math.sqrt(a));
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
                child: pw.Text('E-Receipt Upload', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
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

  Future<String> uploadPrescriptionPdf(File file, String userId, DatabaseService dbService) async {
    try {
      final url = await dbService.uploadDocument(userId, file, 'prescriptions');
      logger.i('Prescription PDF uploaded: $url');
      return url;
    } catch (e) {
      logger.e('Failed to upload prescription PDF: $e');
      // We might want to rethrow or just return empty string depending on requirement
      // For now rethrow to let UI handle it
      rethrow;
    }
  }
}
