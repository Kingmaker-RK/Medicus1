class DentalRecord {
  String id;
  String fileName;
  final DateTime timestamp;
  final String filePath;

  DentalRecord({
    required this.id,
    required this.fileName,
    required this.timestamp,
    required this.filePath,
  });
}
