import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _TranslationScreenState extends State<TranslationScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  String? _previousUserLanguage;
  late AnimationController _micAnimationController;

  @override
  void initState() {
    super.initState();
    _micAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

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
    _micAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final translationProvider = Provider.of<TranslationProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildModernAppBar(userProvider),
      drawer: _buildNavigationDrawer(context, userProvider),
      body: Column(
        children: [
          // Modern language selector bar
          _buildModernLanguageBar(translationProvider, userProvider),

          // Main translation area
          Expanded(
            child: Container(
              padding: EdgeInsets.all(isDesktop ? 24 : 16),
              child: isDesktop
                  ? _buildDesktopLayout(translationProvider)
                  : _buildMobileLayout(translationProvider),
            ),
          ),

          // Medical context section (if available)
          if (translationProvider.currentTranslation != null)
            _buildMedicalContextSection(translationProvider),
        ],
      ),
      // Floating microphone button
      floatingActionButton: _buildFloatingMicButton(translationProvider),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  PreferredSizeWidget _buildModernAppBar(UserProvider userProvider) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Medicus',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      actions: [
        // Role indicator chip
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                userProvider.currentUser?.role == AppConstants.roleDoctor
                    ? Icons.local_hospital_rounded
                    : Icons.person_rounded,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                userProvider.currentUser?.role == AppConstants.roleDoctor
                    ? 'Doctor'
                    : 'Patient',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.settings_rounded),
          onPressed: () {
            context.push('/settings');
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildModernLanguageBar(
    TranslationProvider translationProvider,
    UserProvider userProvider,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          // Source language
          Expanded(
            child: _buildModernLanguageDropdown(
              value: translationProvider.sourceLanguage,
              onChanged: (value) {
                if (value != null) {
                  translationProvider.setSourceLanguage(value);
                }
              },
            ),
          ),

          // Swap button with animation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  translationProvider.swapLanguages();
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.swap_horiz_rounded,
                    color: AppColors.accent,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),

          // Target language
          Expanded(
            child: _buildModernLanguageDropdown(
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

  Widget _buildModernLanguageDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    final selectedLanguage = AppConstants.supportedLanguages.firstWhere(
      (lang) => lang['code'] == value,
      orElse: () => AppConstants.supportedLanguages.first,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        onChanged: onChanged,
        items: AppConstants.supportedLanguages.map((lang) {
          return DropdownMenuItem<String>(
            value: lang['code'],
            child: Text(lang['nativeName'] ?? ''),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDesktopLayout(TranslationProvider translationProvider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input panel
        Expanded(child: _buildModernInputCard(translationProvider)),
        const SizedBox(width: 24),
        // Output panel
        Expanded(child: _buildModernOutputCard(translationProvider)),
      ],
    );
  }

  Widget _buildMobileLayout(TranslationProvider translationProvider) {
    return ListView(
      children: [
        _buildModernInputCard(translationProvider),
        const SizedBox(height: 16),
        _buildModernOutputCard(translationProvider),
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }

  Widget _buildModernInputCard(TranslationProvider translationProvider) {
    final characterCount = _inputController.text.length;

    return Container(
      constraints: const BoxConstraints(minHeight: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input text area
          Expanded(
            child: TextField(
              controller: _inputController,
              maxLines: null,
              expands: true,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Enter text to translate...',
                hintStyle: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(20),
              ),
              onChanged: (text) {
                setState(() {}); // Update character count
                translationProvider.updateInput(text);
              },
            ),
          ),

          // Bottom toolbar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Character counter
                Text(
                  '$characterCount characters',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),

                // Clear button
                if (_inputController.text.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      _inputController.clear();
                      translationProvider.clearInput();
                      setState(() {});
                    },
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Clear'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                    ),
                  ),

                const SizedBox(width: 8),

                // Translate button
                ElevatedButton.icon(
                  onPressed: translationProvider.isTranslating || _inputController.text.isEmpty
                      ? null
                      : () {
                          translationProvider.translateText(_inputController.text);
                        },
                  icon: translationProvider.isTranslating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.translate_rounded, size: 18),
                  label: const Text('Translate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernOutputCard(TranslationProvider translationProvider) {
    final currentTranslation = translationProvider.currentTranslation;

    return Container(
      constraints: const BoxConstraints(minHeight: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: currentTranslation == null
          ? _buildEmptyState()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Translation text
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: SelectableText(
                      currentTranslation.translatedText,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),

                // Bottom toolbar
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Word count
                      Text(
                        '${currentTranslation.translatedText.split(' ').length} words',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),

                      // Copy button
                      TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: currentTranslation.translatedText),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Translation copied to clipboard'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: AppColors.success,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: const Text('Copy'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.accent,
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Speak button
                      IconButton(
                        onPressed: () {
                          translationProvider.speakText(
                            currentTranslation.translatedText,
                            translationProvider.targetLanguage,
                          );
                        },
                        icon: const Icon(Icons.volume_up_rounded),
                        color: AppColors.accent,
                        tooltip: 'Listen',
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.translate_rounded,
                size: 64,
                color: AppColors.accent.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Translation will appear here',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Enter text above and click translate',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalContextSection(TranslationProvider translationProvider) {
    final currentTranslation = translationProvider.currentTranslation;
    if (currentTranslation == null) return const SizedBox();

    final hasMedicalTerms = currentTranslation.medicalTerms.isNotEmpty;
    final hasAnatomyImages = currentTranslation.anatomyImages.isNotEmpty;

    if (!hasMedicalTerms && !hasAnatomyImages) return const SizedBox();

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.medicalGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.medical_information_rounded,
                    color: AppColors.medicalGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Medical Context',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Medical terms
                if (hasMedicalTerms) ...[
                  Text(
                    'Medical Terms',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: currentTranslation.medicalTerms.map((term) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.medicalGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.medicalGreen.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          term,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.medicalGreen.withOpacity(0.9),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                // Anatomy visualization
                if (hasAnatomyImages) ...[
                  if (hasMedicalTerms) const SizedBox(height: 20),
                  Text(
                    'Anatomy Reference',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
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
        ],
      ),
    );
  }

  Widget _buildFloatingMicButton(TranslationProvider translationProvider) {
    return ScaleTransition(
      scale: translationProvider.isListening
          ? _micAnimationController.drive(
              Tween<double>(begin: 1.0, end: 1.1).chain(
                CurveTween(curve: Curves.easeInOut),
              ),
            )
          : AlwaysStoppedAnimation(1.0),
      child: GestureDetector(
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
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: translationProvider.isListening ? AppColors.error : AppColors.accent,
            boxShadow: [
              BoxShadow(
                color: translationProvider.isListening
                    ? AppColors.error.withOpacity(0.4)
                    : AppColors.accent.withOpacity(0.4),
                blurRadius: translationProvider.isListening ? 24 : 16,
                spreadRadius: translationProvider.isListening ? 4 : 0,
              ),
            ],
          ),
          child: Icon(
            translationProvider.isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
            size: 28,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationDrawer(
    BuildContext context,
    UserProvider userProvider,
  ) {
    return Drawer(
      child: Column(
        children: [
          // Modern drawer header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primaryLight,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    userProvider.currentUser?.role == AppConstants.roleDoctor
                        ? Icons.local_hospital_rounded
                        : Icons.person_rounded,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  userProvider.currentUser?.name ?? 'Guest User',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userProvider.currentUser?.email ??
                      (userProvider.currentUser?.isGuest == true
                          ? 'Guest Mode'
                          : 'No email'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDrawerItem(
                  context: context,
                  icon: Icons.translate_rounded,
                  title: 'Translation',
                  isSelected: true,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: userProvider.currentUser?.role == AppConstants.roleDoctor
                      ? Icons.badge_rounded
                      : Icons.person_outline_rounded,
                  title: userProvider.currentUser?.role == AppConstants.roleDoctor
                      ? 'Doctor Profile'
                      : 'User Profile',
                  onTap: () {
                    Navigator.pop(context);
                    if (userProvider.currentUser?.role == AppConstants.roleDoctor) {
                      context.push('/doctor-profile');
                    } else {
                      context.push('/profile');
                    }
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.settings_rounded,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/settings');
                  },
                ),
                const Divider(height: 32),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.swap_horiz_rounded,
                  title: 'Switch Role',
                  subtitle: 'Current: ${userProvider.currentUser?.role == AppConstants.roleDoctor ? "Doctor" : "Patient"}',
                  onTap: () {
                    final newRole = userProvider.currentUser?.role == AppConstants.roleDoctor
                        ? AppConstants.rolePatient
                        : AppConstants.roleDoctor;
                    userProvider.changeRole(newRole);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),

          // Bottom section
          Column(
            children: [
              const Divider(height: 1),
              _buildDrawerItem(
                context: context,
                icon: Icons.info_outline_rounded,
                title: 'About',
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
                _buildDrawerItem(
                  context: context,
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  onTap: () async {
                    Navigator.pop(context);
                    await userProvider.logout();
                    context.go('/');
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.accent : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? AppColors.accent : AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            )
          : null,
      selected: isSelected,
      selectedTileColor: AppColors.accent.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      onTap: onTap,
    );
  }
}
