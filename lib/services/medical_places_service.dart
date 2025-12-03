import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import '../models/medical_facility_model.dart';

class MedicalPlacesService {
  // Default location (Berlin) if GPS is unavailable
  static const double _defaultLat = 52.5200;
  static const double _defaultLon = 13.4050;

  Future<List<MedicalFacility>> fetchFacilities({
    required String queryType,
    double? lat,
    double? lon,
    int radius = 5000, // 5km radius for nearby search
    String? searchQuery,
    String? searchType, // 'name', 'pincode', or 'location'
  }) async {
    double searchLat = lat ?? _defaultLat;
    double searchLon = lon ?? _defaultLon;
    int searchRadius = radius;

    if (searchType == 'location' && searchQuery != null && searchQuery.isNotEmpty) {
      try {
        List<Location> locations = await locationFromAddress(searchQuery);
        if (locations.isNotEmpty) {
          searchLat = locations.first.latitude;
          searchLon = locations.first.longitude;
          searchRadius = 20000; // 20km radius for city search
        }
      } catch (e) {
        print('Error geocoding location: $e');
        // Keep default coordinates
      }
    } else if ((searchType == 'name' || searchType == 'pincode') && radius == 5000) {
      // Expand radius for specific name/pincode searches if default radius is used
      searchRadius = 50000; // 50km
    }

    String overpassQuery = _buildQuery(queryType, searchLat, searchLon, searchRadius, searchQuery, searchType);
    print('Overpass Query: $overpassQuery');

    try {
      final response = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        body: {'data': overpassQuery},
      );

      if (response.statusCode == 200) {
        print('Overpass API Response: ${response.body}');
        final data = json.decode(utf8.decode(response.bodyBytes));
        final elements = data['elements'] as List;

        return elements.map((element) {
          final tags = element['tags'] ?? {};
          final center = element['center'] ?? {};
          final elementLat = center['lat'] ?? element['lat'] ?? 0.0;
          final elementLon = center['lon'] ?? element['lon'] ?? 0.0;

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
        }).where((f) => f.name != 'Unknown Facility').toList();
      } else {
        print('Error fetching medical places: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception fetching medical places: $e');
      return [];
    }
  }

  String _buildQuery(String type, double lat, double lon, int radius, String? searchQuery, String? searchType) {
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
        break;
      case 'ent':
        tagFilter = '["healthcare:speciality"="ear_nose_throat"]';
        break;
      case 'dermo':
        tagFilter = '["healthcare:speciality"="dermatology"]';
        break;
      case 'eye_care':
        tagFilter = '["healthcare:speciality"="ophthalmology"]';
        break;
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
    
    String searchFilter = "";
    if (searchQuery != null && searchQuery.isNotEmpty) {
        if (searchType == 'name') {
            searchFilter = '["name"~"$searchQuery",i]';
        } else if (searchType == 'pincode') {
            searchFilter = '["addr:postcode"="$searchQuery"]';
        }
    }


    return '''
      [out:json][timeout:25];
      (
        node$tagFilter$searchFilter(around:$radius,$lat,$lon);
        way$tagFilter$searchFilter(around:$radius,$lat,$lon);
        relation$tagFilter$searchFilter(around:$radius,$lat,$lon);
      );
      out center;
    ''';
  }

  String _getDefaultName(String type) {
    switch (type) {
      case 'dentist':
        return 'Unknown Dentist';
      case 'blood_donation':
        return 'Blood Donation Center';
      case 'physiotherapy':
        return 'Physiotherapy Center';
      default:
        return 'Medical Facility';
    }
  }

  String _formatAddress(Map<String, dynamic> tags) {
    final street = tags['addr:street'];
    final housenumber = tags['addr:housenumber'];
    final postcode = tags['addr:postcode'];
    final city = tags['addr:city'];

    if (street != null && housenumber != null && city != null) {
      return '$street $housenumber, $postcode $city';
    } else if (street != null && city != null) {
      return '$street, $postcode $city';
    } else if (street != null) {
      return street;
    }
    return 'Address not available';
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 - cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) *
            cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p)) /
            2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }
}

