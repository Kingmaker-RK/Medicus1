import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/translation_provider.dart';
import '../providers/user_provider.dart';
import '../constants/colors.dart';
import '../constants/app_constants.dart';
import '../widgets/anatomy_viewer.dart';
import '../widgets/app_bottom_navigation_bar.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({Key? key}) : super(key: key);

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen>
    with SingleTickerProviderStateMixin {
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

    // Show error snackbar if there's an error
    if (translationProvider.lastError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final errorMessage = translationProvider.lastError;
        if (errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(errorMessage)),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
          // Clear the error after displaying to prevent repeated displays
          translationProvider.clearError();
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Google-like light background
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
      endDrawer: _buildHistoryDrawer(translationProvider),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 0),
    );
  }

  PreferredSizeWidget _buildModernAppBar(UserProvider userProvider) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.g_translate_rounded, color: AppColors.primary, size: 24),
          const SizedBox(width: 8),
          const Text(
            'Translate',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
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
        // History button
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Translation History',
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
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
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
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
            child: Tooltip(
              message: 'Swap languages',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    // Ask user if they want to re-translate
                    if (translationProvider.currentTranslation != null) {
                      final shouldRetranslate = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Swap Languages'),
                          content: const Text(
                            'Would you like to re-translate the text with swapped languages?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Just Swap'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                              ),
                              child: const Text('Swap & Translate'),
                            ),
                          ],
                        ),
                      );

                      if (shouldRetranslate != null) {
                        await translationProvider.swapLanguages(
                          retranslate: shouldRetranslate,
                        );
                        if (shouldRetranslate &&
                            translationProvider.currentTranslation != null) {
                          _inputController.text =
                              translationProvider.currentInput;
                        }
                      }
                    } else {
                      await translationProvider.swapLanguages();
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.background,
                    ),
                    child: Icon(
                      Icons.swap_horiz_rounded,
                      color: AppColors.textSecondary,
                      size: 24,
                    ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(
          Icons.arrow_drop_down_rounded,
          color: AppColors.textSecondary,
        ),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
        onChanged: onChanged,
        items: AppConstants.supportedLanguages.map((lang) {
          return DropdownMenuItem<String>(
            value: lang['code'],
            child: Text(
              lang['nativeName'] ?? '',
              overflow: TextOverflow.ellipsis,
            ),
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
        const SizedBox(height: 8),
        if (translationProvider.currentTranslation != null)
          _buildModernOutputCard(translationProvider),
        const SizedBox(height: 100), // Space for FAB
      ],
    );
  }

  Widget _buildModernInputCard(TranslationProvider translationProvider) {
    final characterCount = _inputController.text.length;

    return Container(
      constraints: const BoxConstraints(minHeight: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input text area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _inputController,
              maxLines: null,
              minLines: 5,
              style: const TextStyle(
                fontSize: 22,
                height: 1.4,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: 'Enter text',
                hintStyle: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
              ),
              onChanged: (text) {
                setState(() {}); // Update character count
                translationProvider.updateInput(text);
              },
            ),
          ),

          // Bottom toolbar
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Clear button
                if (_inputController.text.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      _inputController.clear();
                      translationProvider.clearInput();
                      setState(() {});
                    },
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.textSecondary,
                    tooltip: 'Clear',
                  ),
                
                const Spacer(),
                
                // Character counter
                Text(
                  '$characterCount/5000',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(width: 8),

                // Translate button
                if (_inputController.text.isNotEmpty && !translationProvider.isTranslating)
                   IconButton(
                      onPressed: () {
                          translationProvider.translateText(
                            _inputController.text,
                          );
                      },
                      icon: const Icon(Icons.arrow_forward_rounded),
                      color: AppColors.primary,
                      tooltip: 'Translate',
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

    if (currentTranslation == null) return const SizedBox();

    return Container(
      constraints: const BoxConstraints(minHeight: 200),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE), // Google blue-ish tint
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Translation text
          Padding(
             padding: const EdgeInsets.all(20),
             child: SelectableText(
                currentTranslation.translatedText,
                style: const TextStyle(
                  fontSize: 22,
                  height: 1.4,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w400,
                ),
             ),
          ),

          // Bottom toolbar
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Speak button
                IconButton(
                  onPressed: () {
                    translationProvider.speakText(
                      currentTranslation.translatedText,
                      translationProvider.targetLanguage,
                    );
                  },
                  icon: Icon(
                    translationProvider.isSpeaking
                        ? Icons.stop_circle_outlined
                        : Icons.volume_up_rounded,
                  ),
                  color: AppColors.primary,
                  tooltip: translationProvider.isSpeaking
                      ? 'Stop'
                      : 'Listen',
                ),

                // Copy button
                IconButton(
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(
                        text: currentTranslation.translatedText,
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Translation copied',
                        ),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: AppColors.success,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.content_copy_rounded),
                  color: AppColors.primary,
                  tooltip: 'Copy',
                ),
                
                const Spacer(),
                
                // Share or other actions could go here
              ],
            ),
          ),
        ],
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
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Row(
            children: [
              Icon(
                Icons.medical_services_outlined,
                color: AppColors.medicalGreen,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Medical Context',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Medical terms
                  if (hasMedicalTerms) ...[
                    Text(
                      'Detected Terms',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: currentTranslation.medicalTerms.map((term) {
                        return Chip(
                          label: Text(
                             term,
                             style: TextStyle(
                               fontSize: 12,
                               color: AppColors.medicalGreen.withOpacity(0.9),
                             ),
                          ),
                          backgroundColor: AppColors.medicalGreen.withOpacity(0.1),
                          side: BorderSide.none,
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
                  ],

                  // Anatomy visualization
                  if (hasAnatomyImages) ...[
                    if (hasMedicalTerms) const SizedBox(height: 16),
                    Text(
                      'Anatomy',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingMicButton(TranslationProvider translationProvider) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Conversation Mode Label
        if (!translationProvider.isListening)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Conversation',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        
        Tooltip(
          message: translationProvider.isListening
              ? 'Listening... Tap to stop'
              : 'Conversation Mode',
          child: ScaleTransition(
            scale: translationProvider.isListening
                ? _micAnimationController.drive(
                    Tween<double>(
                      begin: 1.0,
                      end: 1.1,
                    ).chain(CurveTween(curve: Curves.easeInOut)),
                  )
                : AlwaysStoppedAnimation(1.0),
            child: GestureDetector(
              onTapDown: (_) async {
                final success = await translationProvider.startListening();
                if (!success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                          'Microphone permission required.',
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              onTapUp: (_) async {
                await translationProvider.stopListening();
                if (mounted && translationProvider.currentInput.isNotEmpty) {
                  _inputController.text = translationProvider.currentInput;
                }
              },
              onTapCancel: () async {
                await translationProvider.stopListening();
              },
              child: Container(
                width: 80, // Big microphone
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: translationProvider.isListening
                      ? AppColors.error
                      : Colors.white, // White for Google style or Blue? Google uses Blue or White with shadow
                  boxShadow: [
                     BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                     )
                  ],
                  border: Border.all(
                     color: translationProvider.isListening ? Colors.transparent : AppColors.borderLight,
                     width: 1,
                  ),
                ),
                child: Icon(
                  translationProvider.isListening
                      ? Icons.mic_rounded
                      : Icons.mic_none_rounded,
                  size: 36,
                  color: translationProvider.isListening
                      ? Colors.white
                      : AppColors.primary, // Dark blue icon
                ),
              ),
            ),
          ),
        ),
      ],
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
              color: Colors.white,
              border: const Border(bottom: BorderSide(color: AppColors.borderLight)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    userProvider.currentUser?.role == AppConstants.roleDoctor
                        ? Icons.local_hospital_rounded
                        : Icons.person_rounded,
                    size: 32,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  userProvider.currentUser?.name ?? 'Guest User',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
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
                    color: AppColors.textSecondary,
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
                  icon:
                      userProvider.currentUser?.role == AppConstants.roleDoctor
                      ? Icons.badge_rounded
                      : Icons.person_outline_rounded,
                  title:
                      userProvider.currentUser?.role == AppConstants.roleDoctor
                      ? 'Doctor Profile'
                      : 'User Profile',
                  onTap: () {
                    Navigator.pop(context);
                    if (userProvider.currentUser?.role ==
                        AppConstants.roleDoctor) {
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
                  subtitle:
                      'Current: ${userProvider.currentUser?.role == AppConstants.roleDoctor ? "Doctor" : "Patient"}',
                  onTap: () {
                    final newRole =
                        userProvider.currentUser?.role ==
                            AppConstants.roleDoctor
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
                    if (context.mounted) {
                      context.go('/');
                    }
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
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            )
          : null,
      selected: isSelected,
      selectedTileColor: AppColors.primary.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      onTap: onTap,
    );
  }

  Widget _buildHistoryDrawer(TranslationProvider translationProvider) {
    return Drawer(
      child: Column(
        children: [
          // History drawer header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            decoration: BoxDecoration(
               color: Colors.white,
               border: const Border(bottom: BorderSide(color: AppColors.borderLight)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.history_rounded,
                      size: 28,
                      color: AppColors.textPrimary,
                    ),
                    const Spacer(),
                    if (translationProvider.translationHistory.isNotEmpty)
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Clear History'),
                              content: const Text(
                                'Are you sure you want to clear all translation history?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    translationProvider.clearHistory();
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                  ),
                                  child: const Text('Clear All'),
                                ),
                              ],
                            ),
                          );
                        },
                        tooltip: 'Clear history',
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Translation History',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${translationProvider.translationHistory.length} translations',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // History list
          Expanded(
            child: translationProvider.translationHistory.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 64,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No translation history',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your translations will appear here',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: translationProvider.translationHistory.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 24),
                    itemBuilder: (context, index) {
                      final translation =
                          translationProvider.translationHistory[index];
                      return InkWell(
                        onTap: () {
                          // Load this translation
                          _inputController.text = translation.originalText;
                          translationProvider.updateInput(
                            translation.originalText,
                          );
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Original text
                              Row(
                                children: [
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      translation.originalText,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Translated text
                              Row(
                                children: [
                                  Icon(
                                    Icons.arrow_back,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      translation.translatedText,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Language info
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${translation.sourceLanguage} → ${translation.targetLanguage}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}