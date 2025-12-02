class Pharmacy {
  final String name;
  final String address;
  final double distance; // in km
  final bool hasMedication;
  final String openHours;
  final String? phone;
  final String? website;

  Pharmacy({
    required this.name,
    required this.address,
    required this.distance,
    required this.hasMedication,
    required this.openHours,
    this.phone,
    this.website,
  });
}
