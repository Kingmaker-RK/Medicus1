class ENTRecord {
  String id;
  String fileName;
  final DateTime timestamp;
  final String filePath;

  ENTRecord({
    required this.id,
    required this.fileName,
    required this.timestamp,
    required this.filePath,
  });
}
