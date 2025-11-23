import 'dart:async';
import 'dart:math';
import '../models/health_device_model.dart';

class HealthDeviceService {
  // Singleton pattern
  static final HealthDeviceService _instance = HealthDeviceService._internal();
  factory HealthDeviceService() => _instance;
  HealthDeviceService._internal();

  final List<ConnectedDevice> _connectedDevices = [];
  final _deviceStreamController = StreamController<List<ConnectedDevice>>.broadcast();

  Stream<List<ConnectedDevice>> get connectedDevicesStream => _deviceStreamController.stream;

  // Mock available devices for scanning
  final List<ConnectedDevice> _mockAvailableDevices = [
    ConnectedDevice(
      id: 'dev_001',
      name: 'FitWatch Series 5',
      type: DeviceType.smartWatch,
      connectionMethod: ConnectionMethod.bluetooth,
    ),
    ConnectedDevice(
      id: 'dev_002',
      name: 'HealthBand X',
      type: DeviceType.fitnessTracker,
      connectionMethod: ConnectionMethod.bluetooth,
    ),
    ConnectedDevice(
      id: 'dev_003',
      name: 'Smart Scale Pro',
      type: DeviceType.scale,
      connectionMethod: ConnectionMethod.bluetooth,
    ),
  ];

  Future<List<ConnectedDevice>> scanForDevices() async {
    // Simulate scanning delay
    await Future.delayed(const Duration(seconds: 3));
    // Return a random subset of devices to simulate real-world scanning
    _mockAvailableDevices.shuffle();
    return _mockAvailableDevices.take(2).toList();
  }

  Future<ConnectedDevice> connectToDevice(ConnectedDevice device) async {
    // Simulate connection delay
    await Future.delayed(const Duration(seconds: 2));
    
    final newDevice = device.copyWith(
      status: DeviceStatus.connected,
      lastSync: DateTime.now(),
      batteryLevel: '${Random().nextInt(100)}%',
    );
    
    _connectedDevices.add(newDevice);
    _deviceStreamController.add(_connectedDevices);
    return newDevice;
  }
  
  Future<ConnectedDevice?> connectViaQrCode(String qrData) async {
     // Simulate validating QR code and connecting
    await Future.delayed(const Duration(seconds: 2));
    
    // In a real app, we'd parse the QR data.
    // Here we just return a mock device.
    if (qrData.isNotEmpty) {
       final newDevice = ConnectedDevice(
        id: 'qr_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Medical Monitor QR',
        type: DeviceType.bloodPressureMonitor,
        connectionMethod: ConnectionMethod.qrCode,
        status: DeviceStatus.connected,
        lastSync: DateTime.now(),
        batteryLevel: '100%',
      );
      _connectedDevices.add(newDevice);
      _deviceStreamController.add(_connectedDevices);
      return newDevice;
    }
    return null;
  }

  Future<ConnectedDevice?> connectViaPin(String pin) async {
     // Simulate pin verification
    await Future.delayed(const Duration(seconds: 1));
    
    if (pin == "1234") { // Mock valid pin
       final newDevice = ConnectedDevice(
        id: 'pin_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Secure Health Pod',
        type: DeviceType.other,
        connectionMethod: ConnectionMethod.pinCode,
        status: DeviceStatus.connected,
        lastSync: DateTime.now(),
        batteryLevel: '90%',
      );
      _connectedDevices.add(newDevice);
      _deviceStreamController.add(_connectedDevices);
      return newDevice;
    }
    throw Exception("Invalid PIN Code");
  }
  
  Future<void> disconnectDevice(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _connectedDevices.removeWhere((d) => d.id == id);
    _deviceStreamController.add(_connectedDevices);
  }

  // Mock Data Aggregation
  Map<String, dynamic> getAggregatedHealthData() {
    // Base data
    int steps = 2000;
    int calories = 500;
    int heartRate = 70;
    
    // Add data based on connected devices
    for (var device in _connectedDevices) {
      if (device.type == DeviceType.smartWatch) {
        steps += 5000;
        calories += 800;
      } else if (device.type == DeviceType.fitnessTracker) {
        steps += 3000;
        calories += 400;
        heartRate += 2; // slight variation
      }
    }
    
    return {
      'steps': {'value': steps, 'goal': 10000, 'unit': 'steps'},
      'heartRate': {'value': heartRate, 'min': 60, 'max': 100, 'unit': 'bpm'},
      'calories': {'value': calories, 'goal': 2500, 'unit': 'kcal'},
      'sleep': {'value': 7.5, 'goal': 8.0, 'unit': 'hours'}, // Static for now
      'water': {'value': 6, 'goal': 8, 'unit': 'glasses'},
      'bloodPressure': {'systolic': 120, 'diastolic': 80, 'unit': 'mmHg'},
      'weight': {'value': 70.5, 'unit': 'kg'},
      'bloodOxygen': {'value': 98, 'unit': '%'},
    };
  }
}
