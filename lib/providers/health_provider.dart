import 'package:flutter/material.dart';
import '../models/health_device_model.dart';
import '../services/health_device_service.dart';

class HealthProvider with ChangeNotifier {
  final HealthDeviceService _service = HealthDeviceService();
  
  List<ConnectedDevice> _connectedDevices = [];
  Map<String, dynamic> _healthData = {};
  bool _isLoading = false;
  String? _error;

  List<ConnectedDevice> get connectedDevices => _connectedDevices;
  Map<String, dynamic> get healthData => _healthData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  HealthProvider() {
    // Initial fetch
    refreshHealthData();
    // Listen to device changes
    _service.connectedDevicesStream.listen((devices) {
      _connectedDevices = devices;
      refreshHealthData(); // Refresh data when devices change
      notifyListeners();
    });
  }

  Future<void> refreshHealthData() async {
    _healthData = _service.getAggregatedHealthData();
    notifyListeners();
  }

  Future<List<ConnectedDevice>> scanForDevices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final devices = await _service.scanForDevices();
      _isLoading = false;
      notifyListeners();
      return devices;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<void> connectDevice(ConnectedDevice device) async {
    try {
      await _service.connectToDevice(device);
      // Data refresh happens via stream listener
    } catch (e) {
      _error = "Failed to connect: ${e.toString()}";
      notifyListeners();
    }
  }

  Future<void> connectViaQr(String qrData) async {
    try {
      final device = await _service.connectViaQrCode(qrData);
      if (device == null) {
        _error = "Invalid QR Code";
        notifyListeners();
      }
    } catch (e) {
      _error = "QR Connection failed: ${e.toString()}";
      notifyListeners();
    }
  }

  Future<void> connectViaPin(String pin) async {
    try {
      await _service.connectViaPin(pin);
    } catch (e) {
      _error = e.toString(); // "Invalid PIN Code"
      notifyListeners();
      rethrow; 
    }
  }
  
  Future<void> disconnectDevice(String id) async {
    await _service.disconnectDevice(id);
  }
}
