class Pharmacy {
  final String name;
  final String address;
  final double distance; // in km
  final bool hasMedication;
  final String openHours;

  Pharmacy({
    required this.name,
    required this.address,
    required this.distance,
    required this.hasMedication,
    required this.openHours,
  });
}
