import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/medical_facility_model.dart';

class MedicalPlacesService {
  // Default location (Berlin) if GPS is unavailable
  static const double _defaultLat = 52.5200;
  static const double _defaultLon = 13.4050;

  Future<List<MedicalFacility>> fetchFacilities({
    required String queryType,
    double? lat,
    double? lon,
    int radius = 5000, // 5km radius
  }) async {
    final double searchLat = lat ?? _defaultLat;
    final double searchLon = lon ?? _defaultLon;

    String overpassQuery = _buildQuery(queryType, searchLat, searchLon, radius);

    try {
      final response = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        body: {'data': overpassQuery},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final elements = data['elements'] as List;

        return elements.map((element) {
          final tags = element['tags'] ?? {};
          final elementLat = element['lat'] as double;
          final elementLon = element['lon'] as double;
          
          return MedicalFacility(
            id: element['id'].toString(),
            name: tags['name'] ?? _getDefaultName(queryType),
            address: _formatAddress(tags),
            distance: _calculateDistance(searchLat, searchLon, elementLat, elementLon),
            phone: tags['phone'] ?? tags['contact:phone'],
            website: tags['website'] ?? tags['contact:website'],
            openingHours: tags['opening_hours'],
            latitude: elementLat,
            longitude: elementLon,
          );
        }).where((f) => f.name != 'Unknown Facility').toList(); // Filter out unnamed if preferred, but sometimes name is missing
      } else {
        print('Error fetching medical places: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception fetching medical places: $e');
      return [];
    }
  }

  String _buildQuery(String type, double lat, double lon, int radius) {
    String tagFilter = "";
    
    switch (type) {
      case 'dentist':
        tagFilter = '["amenity"="dentist"]';
        break;
      case 'blood_donation':
        tagFilter = '["healthcare"="blood_donation"]';
        break;
      case 'physiotherapy':
        tagFilter = '["healthcare"="physiotherapist"]';
        break;
      case 'chiropractor':
        tagFilter = '["healthcare"="chiropractor"]';
        break; // Also commonly alternative=chiropractor
      case 'ent':
        tagFilter = '["healthcare:speciality"="ear_nose_throat"]';
        break;
      case 'dermo':
        tagFilter = '["healthcare:speciality"="dermatology"]';
        break;
      case 'eye_care':
        tagFilter = '["healthcare:speciality"="ophthalmology"]';
        break; // Also amenity=doctors + speciality=ophthalmology
      case 'pulmonology':
        tagFilter = '["healthcare:speciality"="pulmonology"]';
        break;
      case 'podiatry':
        tagFilter = '["healthcare"="podiatrist"]';
        break;
      case 'hospital':
        tagFilter = '["amenity"="hospital"]';
        break;
      default:
        tagFilter = '["amenity"="doctors"]';
    }

    // Overpass QL
    return '''
      [out:json][timeout:25];
      (
        node$tagFilter(around:$radius,$lat,$lon);
        way$tagFilter(around:$radius,$lat,$lon);
        relation$tagFilter(around:$radius,$lat,$lon);
      );
      out center;
    ''';
  }

  String _getDefaultName(String type) {
    switch (type) {
      case 'dentist': return 'Unknown Dentist';
      case 'blood_donation': return 'Blood Donation Center';
      case 'physiotherapy': return 'Physiotherapy Center';
      default: return 'Medical Facility';
    }
  }

  String _formatAddress(Map<String, dynamic> tags) {
    final street = tags['addr:street'];
    final housenumber = tags['addr:housenumber'];
    final postcode = tags['addr:postcode'];
    final city = tags['addr:city'];

    if (street != null && housenumber != null && city != null) {
      return '$street $housenumber, $postcode $city';
    } else if (street != null) {
      return street;
    }
    return 'Address not available';
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 - cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }
}
