class EyeCareRecord {
  String id;
  String fileName;
  final DateTime timestamp;
  final String filePath;

  EyeCareRecord({
    required this.id,
    required this.fileName,
    required this.timestamp,
    required this.filePath,
  });
}
