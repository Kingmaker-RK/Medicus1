import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/user_provider.dart';
import '../services/permission_service.dart';
import '../constants/colors.dart';
import '../constants/app_constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PermissionService _permissionService = PermissionService();

  Map<String, bool> _permissions = {
    'microphone': false,
    'camera': false,
    'location': false,
    'notification': false,
  };

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() {
      _isLoading = true;
    });

    final microphone = await _permissionService.isMicrophoneGranted();
    final camera = await _permissionService.isCameraGranted();
    final location = await _permissionService.isLocationGranted();
    final notification = await _permissionService.isNotificationGranted();

    setState(() {
      _permissions = {
        'microphone': microphone,
        'camera': camera,
        'location': location,
        'notification': notification,
      };
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // User Section
                _buildSection(
                  title: 'Account',
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('User Role'),
                      subtitle: Text(
                        userProvider.currentUser?.role.toUpperCase() ?? 'Guest',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text('Email'),
                      subtitle: Text(
                        userProvider.currentUser?.email ?? 'Guest User',
                      ),
                    ),
                    if (userProvider.isLoggedIn)
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Logout'),
                        onTap: () async {
                          await userProvider.logout();
                          if (mounted) {
                            context.go('/');
                          }
                        },
                      ),
                  ],
                ),

                const Divider(),

                // Language Section
                _buildSection(
                  title: 'Language',
                  children: [
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: const Text('App Language'),
                      subtitle: Text(
                        _getLanguageName(userProvider.selectedLanguage),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        _showLanguageDialog(userProvider);
                      },
                    ),
                  ],
                ),

                const Divider(),

                // Permissions Section
                _buildSection(
                  title: 'Permissions',
                  children: [
                    _buildPermissionTile(
                      icon: Icons.mic,
                      title: 'Microphone',
                      subtitle: 'Required for voice translation',
                      granted: _permissions['microphone'] ?? false,
                      onTap: () async {
                        await _permissionService.requestMicrophonePermission();
                        await _checkPermissions();
                      },
                    ),
                    _buildPermissionTile(
                      icon: Icons.camera_alt,
                      title: 'Camera',
                      subtitle: 'Optional for visual assistance',
                      granted: _permissions['camera'] ?? false,
                      onTap: () async {
                        await _permissionService.requestCameraPermission();
                        await _checkPermissions();
                      },
                    ),
                    _buildPermissionTile(
                      icon: Icons.location_on,
                      title: 'Location',
                      subtitle: 'Optional for nearby facilities',
                      granted: _permissions['location'] ?? false,
                      onTap: () async {
                        await _permissionService.requestLocationPermission();
                        await _checkPermissions();
                      },
                    ),
                    _buildPermissionTile(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      subtitle: 'Get important updates',
                      granted: _permissions['notification'] ?? false,
                      onTap: () async {
                        await _permissionService
                            .requestNotificationPermission();
                        await _checkPermissions();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('Open System Settings'),
                      subtitle: const Text('Manage all permissions'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        await _permissionService.openAppSettings();
                      },
                    ),
                  ],
                ),

                const Divider(),

                // About Section
                _buildSection(
                  title: 'About',
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('App Version'),
                      subtitle: Text(AppConstants.appVersion),
                    ),
                    ListTile(
                      leading: const Icon(Icons.medical_services),
                      title: const Text('About Medicus'),
                      subtitle: const Text(
                        'Breaking language barriers in healthcare',
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.help),
                      title: const Text('Help & Support'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // TODO: Implement help screen
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip),
                      title: const Text('Privacy Policy'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // TODO: Implement privacy policy screen
                      },
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildPermissionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool granted,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: granted
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              granted ? 'Granted' : 'Denied',
              style: TextStyle(
                fontSize: 12,
                color: granted ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
      onTap: onTap,
    );
  }

  String _getLanguageName(String code) {
    final lang = AppConstants.supportedLanguages.firstWhere(
      (l) => l['code'] == code,
      orElse: () => {'name': 'Unknown', 'nativeName': 'Unknown'},
    );
    return '${lang['nativeName']} (${lang['name']})';
  }

  void _showLanguageDialog(UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: AppConstants.supportedLanguages.length,
            itemBuilder: (context, index) {
              final lang = AppConstants.supportedLanguages[index];
              final isSelected = lang['code'] == userProvider.selectedLanguage;

              return ListTile(
                title: Text(lang['nativeName'] ?? ''),
                subtitle: Text(lang['name'] ?? ''),
                trailing: isSelected
                    ? Icon(Icons.check, color: AppColors.primary)
                    : null,
                selected: isSelected,
                onTap: () {
                  userProvider.changeLanguage(lang['code']!);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
