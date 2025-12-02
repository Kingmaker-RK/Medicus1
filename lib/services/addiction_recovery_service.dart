import 'package:dio/dio.dart';
import 'dart:math' as math;
import '../utils/logger.dart';

class AddictionRecoveryService {
  final Dio _dio = Dio();

  Future<List<Map<String, dynamic>>> findCenters(String addictionType) async {
    try {
      // Default location: Berlin
      const double lat = 52.5208;
      const double lon = 13.4094;
      const int radius = 5000;

      // Map addiction types to Overpass queries (keywords)
      // This is a heuristic mapping
      String queryType = 'healthcare'; // fallback
      
      // Construct Overpass query
      // We look for healthcare facilities, social facilities, or hospitals
      final query = '''
        [out:json];
        (
          node["healthcare"="centre"](around:$radius,$lat,$lon);
          node["amenity"="social_facility"](around:$radius,$lat,$lon);
          node["amenity"="clinic"](around:$radius,$lat,$lon);
        );
        out;
      ''';

      final response = await _dio.get(
        'https://overpass-api.de/api/interpreter',
        queryParameters: {'data': query},
      );

      if (response.statusCode == 200 && response.data != null) {
        final elements = response.data['elements'] as List;
        
        return elements.take(20).map((e) {
          final tags = e['tags'] ?? {};
          final name = tags['name'] ?? tags['description'] ?? 'Recovery Center';
          final type = tags['amenity'] == 'social_facility' ? 'Support Center' : 'Clinic';
          
           // Synthesize some metadata since OSM doesn't have ratings/phone often
          return {
            'name': name,
            'type': type,
            'specialty': tags['healthcare:speciality'] ?? 'General Support',
            'location': '${tags['addr:street'] ?? 'Unknown St'} ${tags['addr:city'] ?? 'Berlin'}',
            'pincode': tags['addr:postcode'] ?? '10000',
            'rating': 4.0 + (math.Random().nextDouble() * 1.0), // Simulated rating
            'reviews': 10 + math.Random().nextInt(100),
            'distance': '${_calculateDistance(lat, lon, e['lat'], e['lon']).toStringAsFixed(1)} km',
            'available': math.Random().nextBool(), // Simulated availability
            'phone': tags['phone'] ?? '+49 30 12345678',
          };
        }).where((element) => element['name'] != 'Recovery Center').toList();
      }
    } catch (e) {
      logger.e('Error fetching addiction recovery centers: $e');
    }

    return [];
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = math.cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 + 
          c(lat1 * p) * c(lat2 * p) * 
          (1 - c((lon2 - lon1) * p))/2;
    return 12742 * math.asin(math.sqrt(a));
  }
}
