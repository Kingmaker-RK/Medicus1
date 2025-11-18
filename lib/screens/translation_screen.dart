import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/translation_provider.dart';
import '../providers/user_provider.dart';
import '../constants/colors.dart';
import '../constants/app_constants.dart';
import '../widgets/anatomy_viewer.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({Key? key}) : super(key: key);

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final TextEditingController _inputController = TextEditingController();
  String? _previousUserLanguage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final translationProvider = Provider.of<TranslationProvider>(
        context,
        listen: false,
      );

      // Initialize with the user's selected language
      translationProvider.initialize(
        userLanguage: userProvider.selectedLanguage,
      );
      _previousUserLanguage = userProvider.selectedLanguage;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Listen for changes in user's language preference
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final translationProvider = Provider.of<TranslationProvider>(
      context,
      listen: false,
    );

    // If user changed their language preference, update the translation provider
    if (_previousUserLanguage != null &&
        _previousUserLanguage != userProvider.selectedLanguage) {
      translationProvider.updateSourceLanguageFromUser(
        userProvider.selectedLanguage,
      );
      _previousUserLanguage = userProvider.selectedLanguage;
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final translationProvider = Provider.of<TranslationProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Medicus Translation'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          // Role switcher
          PopupMenuButton<String>(
            icon: Icon(
              userProvider.currentUser?.role == AppConstants.roleDoctor
                  ? Icons.local_hospital
                  : Icons.person,
            ),
            onSelected: (String role) {
              userProvider.changeRole(role);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: AppConstants.rolePatient,
                child: Row(
                  children: const [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Patient'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: AppConstants.roleDoctor,
                child: Row(
                  children: const [
                    Icon(Icons.local_hospital),
                    SizedBox(width: 8),
                    Text('Doctor'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      drawer: _buildNavigationDrawer(context, userProvider),
      body: Column(
        children: [
          // Language selector bar
          _buildLanguageBar(translationProvider, userProvider),

          // Main content area
          Expanded(
            child: Row(
              children: [
                // Left panel - Input
                Expanded(child: _buildInputPanel(translationProvider)),

                // Divider
                Container(width: 2, color: AppColors.primary.withOpacity(0.2)),

                // Right panel - Translation output
                Expanded(child: _buildOutputPanel(translationProvider)),
              ],
            ),
          ),

          // Bottom control bar
          _buildControlBar(translationProvider),
        ],
      ),
    );
  }

  Widget _buildLanguageBar(
    TranslationProvider translationProvider,
    UserProvider userProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          // Source language
          Expanded(
            child: _buildLanguageDropdown(
              label: 'From',
              value: translationProvider.sourceLanguage,
              onChanged: (value) {
                if (value != null) {
                  translationProvider.setSourceLanguage(value);
                }
              },
            ),
          ),

          // Swap button
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () {
              translationProvider.swapLanguages();
            },
            color: AppColors.primary,
          ),

          // Target language
          Expanded(
            child: _buildLanguageDropdown(
              label: 'To',
              value: translationProvider.targetLanguage,
              onChanged: (value) {
                if (value != null) {
                  translationProvider.setTargetLanguage(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown({
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        DropdownButton<String>(
          value: value,
          isExpanded: true,
          underline: Container(),
          onChanged: onChanged,
          items: AppConstants.supportedLanguages.map((lang) {
            return DropdownMenuItem<String>(
              value: lang['code'],
              child: Text(lang['nativeName'] ?? ''),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInputPanel(TranslationProvider translationProvider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Input',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TextField(
              controller: _inputController,
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                hintText: 'Type or speak your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
              onChanged: (text) {
                translationProvider.updateInput(text);
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_inputController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _inputController.clear();
                    translationProvider.clearInput();
                  },
                ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: translationProvider.isTranslating
                    ? null
                    : () {
                        if (_inputController.text.isNotEmpty) {
                          translationProvider.translateText(
                            _inputController.text,
                          );
                        }
                      },
                icon: translationProvider.isTranslating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.translate),
                label: const Text('Translate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutputPanel(TranslationProvider translationProvider) {
    final currentTranslation = translationProvider.currentTranslation;

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Translation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (currentTranslation != null)
                IconButton(
                  icon: const Icon(Icons.volume_up),
                  onPressed: () {
                    translationProvider.speakText(
                      currentTranslation.translatedText,
                      translationProvider.targetLanguage,
                    );
                  },
                  color: AppColors.primary,
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (currentTranslation == null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Doctor-Patient Image
                    Container(
                      width: 300,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/doctor_patient.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Translation will appear here',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Translated text
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        currentTranslation.translatedText,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Medical terms
                    if (currentTranslation.medicalTerms.isNotEmpty) ...[
                      Text(
                        'Medical Terms',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: currentTranslation.medicalTerms
                            .map(
                              (term) => Chip(
                                label: Text(term),
                                backgroundColor: AppColors.primary.withOpacity(
                                  0.1,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Anatomy visualization
                    if (currentTranslation.anatomyImages.isNotEmpty) ...[
                      Text(
                        'Anatomy Reference',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: AnatomyViewer(
                          imageUrls: currentTranslation.anatomyImages,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlBar(TranslationProvider translationProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Microphone button
          GestureDetector(
            onTapDown: (_) async {
              await translationProvider.startListening();
            },
            onTapUp: (_) async {
              await translationProvider.stopListening();
              if (translationProvider.currentInput.isNotEmpty) {
                _inputController.text = translationProvider.currentInput;
              }
            },
            onTapCancel: () async {
              await translationProvider.stopListening();
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: translationProvider.isListening
                    ? AppColors.error
                    : AppColors.primary,
                boxShadow: [
                  if (translationProvider.isListening)
                    BoxShadow(
                      color: AppColors.error.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                ],
              ),
              child: Icon(
                translationProvider.isListening ? Icons.mic : Icons.mic_none,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationDrawer(BuildContext context, UserProvider userProvider) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: AppColors.primary),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            accountName: Text(
              userProvider.currentUser?.name ?? 'Guest User',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              userProvider.currentUser?.email ??
              (userProvider.currentUser?.isGuest == true ? 'Guest Mode' : 'No email'),
            ),
          ),

          // Navigation Items
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('User Profile'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              context.push('/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.translate),
            title: const Text('Translation'),
            selected: true,
            selectedColor: AppColors.primary,
            onTap: () {
              Navigator.pop(context); // Close drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              context.push('/settings');
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              userProvider.currentUser?.role == AppConstants.roleDoctor
                  ? Icons.local_hospital
                  : Icons.person,
            ),
            title: Text(
              'Role: ${userProvider.currentUser?.role == AppConstants.roleDoctor ? "Doctor" : "Patient"}',
            ),
            subtitle: const Text('Tap to switch'),
            onTap: () {
              final newRole = userProvider.currentUser?.role == AppConstants.roleDoctor
                  ? AppConstants.rolePatient
                  : AppConstants.roleDoctor;
              userProvider.changeRole(newRole);
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: 'Medicus Translation',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2024 Medicus',
              );
            },
          ),
          if (userProvider.isLoggedIn)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context);
                await userProvider.logout();
                context.go('/');
              },
            ),
        ],
      ),
    );
  }
}
