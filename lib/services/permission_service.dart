import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  // Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  // Request camera permission
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Request location permission
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  // Request notification permission
  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  // Request storage permission
  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  // Request all necessary permissions
  Future<Map<String, bool>> requestAllPermissions() async {
    final permissions = await [
      Permission.microphone,
      Permission.camera,
      Permission.location,
      Permission.notification,
    ].request();

    return {
      'microphone': permissions[Permission.microphone]?.isGranted ?? false,
      'camera': permissions[Permission.camera]?.isGranted ?? false,
      'location': permissions[Permission.location]?.isGranted ?? false,
      'notification': permissions[Permission.notification]?.isGranted ?? false,
    };
  }

  // Check microphone permission status
  Future<bool> isMicrophoneGranted() async {
    return await Permission.microphone.isGranted;
  }

  // Check camera permission status
  Future<bool> isCameraGranted() async {
    return await Permission.camera.isGranted;
  }

  // Check location permission status
  Future<bool> isLocationGranted() async {
    return await Permission.location.isGranted;
  }

  // Check notification permission status
  Future<bool> isNotificationGranted() async {
    return await Permission.notification.isGranted;
  }

  // Open app settings
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  // Check permission status
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    return await permission.status;
  }
}
