import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/user_provider.dart';
import '../services/permission_service.dart';
import '../widgets/translated_widget.dart';
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
        title: const AutoTranslateText('Settings'),
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
                // User Section with translation
                LanguageBuilder(
                  builder: (context, _) => _buildSection(
                    title: 'Account',
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const AutoTranslateText('User Role'),
                        subtitle: AutoTranslateText(
                          userProvider.currentUser?.role.toUpperCase() ??
                              'Guest',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                      ListTile(
                        leading: const Icon(Icons.email),
                        title: const AutoTranslateText('Email'),
                        subtitle: AutoTranslateText(
                          userProvider.currentUser?.email ?? 'Guest User',
                        ),
                      ),
                      if (userProvider.isLoggedIn)
                        ListTile(
                          leading: const Icon(Icons.logout),
                          title: const AutoTranslateText('Logout'),
                          onTap: () async {
                            await userProvider.logout();
                            if (mounted) {
                              context.go('/');
                            }
                          },
                        ),
                    ],
                  ),
                ),

                const Divider(),

                // Language Section with translation
                LanguageBuilder(
                  builder: (context, _) => _buildSection(
                    title: 'Language',
                    children: [
                      ListTile(
                        leading: const Icon(Icons.language),
                        title: const AutoTranslateText('App Language'),
                        subtitle: AutoTranslateText(
                          _getLanguageName(userProvider.selectedLanguage),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          _showLanguageDialog(userProvider);
                        },
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // Permissions Section with translation
                LanguageBuilder(
                  builder: (context, _) => _buildSection(
                    title: 'Permissions',
                    children: [
                      _buildPermissionTile(
                        icon: Icons.mic,
                        title: 'Microphone',
                        subtitle: 'Required for voice translation',
                        granted: _permissions['microphone'] ?? false,
                        onTap: () async {
                          await _permissionService
                              .requestMicrophonePermission();
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
                        title: const AutoTranslateText('Open System Settings'),
                        subtitle: const AutoTranslateText(
                          'Manage all permissions',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () async {
                          await _permissionService.openSettings();
                        },
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // About Section with translation
                LanguageBuilder(
                  builder: (context, _) => _buildSection(
                    title: 'About',
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info),
                        title: const AutoTranslateText('App Version'),
                        subtitle: AutoTranslateText(AppConstants.appVersion),
                      ),
                      ListTile(
                        leading: const Icon(Icons.medical_services),
                        title: const AutoTranslateText('About AI-Gris'),
                        subtitle: const AutoTranslateText(
                          'Breaking language barriers in healthcare',
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.help),
                        title: const AutoTranslateText('Help & Support'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // TODO: Implement help screen
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.privacy_tip),
                        title: const AutoTranslateText('Privacy Policy'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // TODO: Implement privacy policy screen
                        },
                      ),
                    ],
                  ),
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
          child: AutoTranslateText(
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
      title: AutoTranslateText(title),
      subtitle: AutoTranslateText(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: granted
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: AutoTranslateText(
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
        title: const AutoTranslateText('Select Language'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: AppConstants.supportedLanguages.length,
            itemBuilder: (context, index) {
              final lang = AppConstants.supportedLanguages[index];
              final isSelected = lang['code'] == userProvider.selectedLanguage;

              return ListTile(
                title: AutoTranslateText(lang['nativeName'] ?? ''),
                subtitle: AutoTranslateText(lang['name'] ?? ''),
                trailing: isSelected
                    ? Icon(Icons.check, color: AppColors.primary)
                    : null,
                selected: isSelected,
                onTap: () async {
                  // Close dialog first to ensure proper context
                  Navigator.pop(context);

                  // Then change language with a slight delay to ensure dialog is closed
                  await Future.delayed(const Duration(milliseconds: 100));
                  await userProvider.changeLanguage(lang['code']!);
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
            child: const AutoTranslateText('Cancel'),
          ),
        ],
      ),
    );
  }
}
