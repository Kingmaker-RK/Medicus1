import 'dart:convert';

class UploadRecord {
  final String id;
  final DateTime timestamp;
  final String? pharmacyName;
  final String? pharmacyAddress;
  final String pdfPath;
  final String timeZone;

  UploadRecord({
    required this.id,
    required this.timestamp,
    this.pharmacyName,
    this.pharmacyAddress,
    required this.pdfPath,
    required this.timeZone,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'pharmacyName': pharmacyName,
      'pharmacyAddress': pharmacyAddress,
      'pdfPath': pdfPath,
      'timeZone': timeZone,
    };
  }

  factory UploadRecord.fromJson(Map<String, dynamic> json) {
    return UploadRecord(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      pharmacyName: json['pharmacyName'],
      pharmacyAddress: json['pharmacyAddress'],
      pdfPath: json['pdfPath'],
      timeZone: json['timeZone'],
    );
  }
}
