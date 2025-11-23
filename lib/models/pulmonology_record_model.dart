class PulmonologyRecord {
  String id;
  String fileName;
  final DateTime timestamp;
  final String filePath;

  PulmonologyRecord({
    required this.id,
    required this.fileName,
    required this.timestamp,
    required this.filePath,
  });
}
