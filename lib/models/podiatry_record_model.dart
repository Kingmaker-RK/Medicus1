class PodiatryRecord {
  String id;
  String fileName;
  final DateTime timestamp;
  final String filePath;

  PodiatryRecord({
    required this.id,
    required this.fileName,
    required this.timestamp,
    required this.filePath,
  });
}
