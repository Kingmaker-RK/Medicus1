class PhysiotherapyRecord {
  String id;
  String fileName;
  final DateTime timestamp;
  final String filePath;

  PhysiotherapyRecord({
    required this.id,
    required this.fileName,
    required this.timestamp,
    required this.filePath,
  });
}
