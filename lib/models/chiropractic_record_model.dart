class ChiropracticRecord {
  String id;
  String fileName;
  final DateTime timestamp;
  final String filePath;

  ChiropracticRecord({
    required this.id,
    required this.fileName,
    required this.timestamp,
    required this.filePath,
  });
}
