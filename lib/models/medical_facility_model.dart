class MedicalFacility {
  final String id;
  final String name;
  final String address;
  final double distance; // in km
  final String? phone;
  final String? website;
  final String? openingHours;
  final double latitude;
  final double longitude;

  MedicalFacility({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    this.phone,
    this.website,
    this.openingHours,
    required this.latitude,
    required this.longitude,
  });

  factory MedicalFacility.fromMap(Map<String, dynamic> map, double currentLat, double currentLon) {
    // Basic distance calculation (Haversine approximation or just Euclidean for short distances)
    // For now, let's trust the service to calculate it or do a simple calculation here.
    // We'll implement a simple distance calc in the service or helper.
    return MedicalFacility(
      id: map['id'].toString(),
      name: map['name'] ?? 'Unknown Facility',
      address: map['address'] ?? 'Address not available',
      distance: map['distance'] ?? 0.0,
      phone: map['phone'],
      website: map['website'],
      openingHours: map['opening_hours'],
      latitude: map['lat'] ?? 0.0,
      longitude: map['lon'] ?? 0.0,
    );
  }
}
