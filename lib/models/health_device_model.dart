enum DeviceType {
  smartWatch,
  fitnessTracker,
  healthApp, // e.g., Google Fit, Apple Health
  scale,
  bloodPressureMonitor,
  other,
}

enum ConnectionMethod {
  bluetooth,
  qrCode,
  pinCode,
  cloudSync, // For apps
}

enum DeviceStatus {
  connected,
  disconnected,
  scanning,
  pairing,
  error,
}

class ConnectedDevice {
  final String id;
  final String name;
  final DeviceType type;
  final ConnectionMethod connectionMethod;
  DeviceStatus status;
  DateTime? lastSync;
  final String? batteryLevel; // e.g., "85%"

  ConnectedDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.connectionMethod,
    this.status = DeviceStatus.disconnected,
    this.lastSync,
    this.batteryLevel,
  });

  ConnectedDevice copyWith({
    String? id,
    String? name,
    DeviceType? type,
    ConnectionMethod? connectionMethod,
    DeviceStatus? status,
    DateTime? lastSync,
    String? batteryLevel,
  }) {
    return ConnectedDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      connectionMethod: connectionMethod ?? this.connectionMethod,
      status: status ?? this.status,
      lastSync: lastSync ?? this.lastSync,
      batteryLevel: batteryLevel ?? this.batteryLevel,
    );
  }
}
