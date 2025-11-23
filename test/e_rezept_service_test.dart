import 'package:flutter_test/flutter_test.dart';
import 'package:ai_gris/services/e_rezept_service.dart';
import 'package:ai_gris/models/upload_record_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('ERezeptService save and load history', () async {
    SharedPreferences.setMockInitialValues({});
    final service = ERezeptService();
    
    final record = UploadRecord(
      id: '1',
      timestamp: DateTime.now(),
      pharmacyName: 'Test Pharmacy',
      pharmacyAddress: 'Test Address',
      pdfPath: '/tmp/test.pdf',
      timeZone: 'CET',
    );
    
    await service.saveUploadRecord(record);
    
    final history = await service.getUploadHistory();
    expect(history.length, 1);
    expect(history.first.pharmacyName, 'Test Pharmacy');
    
    // Add another
    final record2 = UploadRecord(
      id: '2',
      timestamp: DateTime.now(),
      pharmacyName: 'Pharmacy 2',
      pdfPath: '/tmp/test2.pdf',
      timeZone: 'CET',
    );
    
    await service.saveUploadRecord(record2);
    final history2 = await service.getUploadHistory();
    expect(history2.length, 2);
    expect(history2.first.id, '2'); // Should be at the beginning
  });
}