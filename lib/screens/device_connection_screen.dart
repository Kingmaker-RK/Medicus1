import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/health_provider.dart';
import '../models/health_device_model.dart';
import '../widgets/translated_widget.dart';

class DeviceConnectionScreen extends StatefulWidget {
  const DeviceConnectionScreen({Key? key}) : super(key: key);

  @override
  State<DeviceConnectionScreen> createState() => _DeviceConnectionScreenState();
}

class _DeviceConnectionScreenState extends State<DeviceConnectionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const AutoTranslateText(
          'Connect Devices',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.bluetooth), text: "Bluetooth"),
            Tab(icon: Icon(Icons.qr_code), text: "QR Code"),
            Tab(icon: Icon(Icons.pin), text: "Code"),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBluetoothTab(),
                _buildQrTab(),
                _buildPinTab(),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildConnectedDevicesList(),
        ],
      ),
    );
  }

  Widget _buildBluetoothTab() {
    return Consumer<HealthProvider>(
      builder: (context, provider, _) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bluetooth_searching, size: 80, color: AppColors.primary.withOpacity(0.5)),
              const SizedBox(height: 20),
              if (provider.isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: () => _showScanResults(context, provider),
                  icon: const Icon(Icons.search),
                  label: const AutoTranslateText('Scan for Devices'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              const SizedBox(height: 10),
              const AutoTranslateText(
                'Make sure your device is in pairing mode',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showScanResults(BuildContext context, HealthProvider provider) async {
    final devices = await provider.scanForDevices();
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const AutoTranslateText(
              'Available Devices',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (devices.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: AutoTranslateText('No devices found')),
              )
            else
              ...devices.map((device) => ListTile(
                leading: Icon(_getIconForDeviceType(device.type)),
                title: Text(device.name),
                subtitle: const Text('Bluetooth'),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    provider.connectDevice(device);
                  },
                  child: const AutoTranslateText('Connect'),
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildQrTab() {
    return Consumer<HealthProvider>(
       builder: (context, provider, _) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_scanner, size: 80, color: AppColors.primary.withOpacity(0.5)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  // Simulate QR Scan
                  await Future.delayed(const Duration(seconds: 1));
                  // In real app, launch camera
                  if(context.mounted) {
                     provider.connectViaQr("mock_qr_data");
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: AutoTranslateText('Simulated QR Scan: Device Connected!')),
                     );
                  }
                },
                icon: const Icon(Icons.camera_alt),
                label: const AutoTranslateText('Scan QR Code'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
               const SizedBox(height: 10),
              const AutoTranslateText(
                'Scan the code on your device screen',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        );
       }
    );
  }

  Widget _buildPinTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AutoTranslateText(
            'Enter the pairing code displayed on your device',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, letterSpacing: 8),
            decoration: InputDecoration(
              hintText: '0000',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              counterText: "",
            ),
          ),
          const SizedBox(height: 24),
          Consumer<HealthProvider>(
             builder: (context, provider, _) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                       await provider.connectViaPin(_pinController.text);
                       if(context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(backgroundColor: AppColors.success, content: AutoTranslateText('Device Connected!')),
                          );
                          _pinController.clear();
                       }
                    } catch (e) {
                       if(context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(backgroundColor: AppColors.error, content: Text(e.toString())),
                          );
                       }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const AutoTranslateText('Pair Device'),
                ),
              );
             }
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedDevicesList() {
    return Consumer<HealthProvider>(
      builder: (context, provider, _) {
        if (provider.connectedDevices.isEmpty) return const SizedBox.shrink();
        
        return Container(
          color: AppColors.surface,
          constraints: const BoxConstraints(maxHeight: 250),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Connected Devices (${provider.connectedDevices.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: provider.connectedDevices.length,
                  itemBuilder: (context, index) {
                    final device = provider.connectedDevices[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Icon(_getIconForDeviceType(device.type), color: AppColors.primary, size: 20),
                      ),
                      title: Text(device.name),
                      subtitle: Text(
                        '${device.status.name.toUpperCase()} • ${device.batteryLevel ?? "--%"}',
                         style: const TextStyle(fontSize: 12),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        onPressed: () => provider.disconnectDevice(device.id),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconForDeviceType(DeviceType type) {
    switch (type) {
      case DeviceType.smartWatch: return Icons.watch;
      case DeviceType.fitnessTracker: return Icons.directions_run;
      case DeviceType.scale: return Icons.monitor_weight;
      case DeviceType.bloodPressureMonitor: return Icons.favorite_border;
      case DeviceType.healthApp: return Icons.apps;
      default: return Icons.device_unknown;
    }
  }
}
