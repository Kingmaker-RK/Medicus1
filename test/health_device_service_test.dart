import 'package:flutter_test/flutter_test.dart';
import 'package:ai_gris/services/health_device_service.dart';
import 'package:ai_gris/models/health_device_model.dart';

void main() {
  group('HealthDeviceService Tests', () {
    late HealthDeviceService service;

    setUp(() {
      service = HealthDeviceService();
    });

    test('Initial scan returns devices', () async {
      final devices = await service.scanForDevices();
      expect(devices, isNotEmpty);
      expect(devices.length, lessThanOrEqualTo(2));
    });

    test('Connect to device updates status', () async {
      final devices = await service.scanForDevices();
      final deviceToConnect = devices.first;
      
      final connectedDevice = await service.connectToDevice(deviceToConnect);
      
      expect(connectedDevice.status, DeviceStatus.connected);
      expect(connectedDevice.id, deviceToConnect.id);
    });

    test('QR Code connection returns valid device', () async {
      final device = await service.connectViaQrCode("valid_qr");
      expect(device, isNotNull);
      expect(device!.connectionMethod, ConnectionMethod.qrCode);
      expect(device.status, DeviceStatus.connected);
    });

    test('Pin connection with correct pin works', () async {
      final device = await service.connectViaPin("1234");
      expect(device, isNotNull);
      expect(device!.connectionMethod, ConnectionMethod.pinCode);
    });

    test('Pin connection with incorrect pin throws', () async {
      expect(() => service.connectViaPin("0000"), throwsException);
    });

    test('Aggregated data increases with connected devices', () async {
      // Clear any existing connections (since singleton)
      // Note: This test relies on internal state of singleton, which might be dirty from previous tests.
      // Ideally we'd reset the singleton but for this mock service it's fine.
      
      final initialData = service.getAggregatedHealthData();
      final initialSteps = initialData['steps']['value'] as int;

      // Connect a mock watch
      await service.connectToDevice(ConnectedDevice(
        id: 'test_watch',
        name: 'Test Watch',
        type: DeviceType.smartWatch,
        connectionMethod: ConnectionMethod.bluetooth,
      ));

      final newData = service.getAggregatedHealthData();
      final newSteps = newData['steps']['value'] as int;

      expect(newSteps, greaterThan(initialSteps));
    });
  });
}
