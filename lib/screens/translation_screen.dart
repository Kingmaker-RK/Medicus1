import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/translation_provider.dart';
import '../providers/user_provider.dart';
import '../constants/colors.dart';
import '../constants/app_constants.dart';
import '../widgets/app_bottom_navigation_bar.dart';

/// Professional DeepL-inspired Translation Screen
/// Features: Clean UI, Split-panel layout, Copy/Paste/Speak, Character counter
class TranslationScreen extends StatefulWidget {
  const TranslationScreen({Key? key}) : super(key: key);

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
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

      translationProvider.initialize(
        userLanguage: userProvider.selectedLanguage,
      );
      _previousUserLanguage = userProvider.selectedLanguage;
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocusNode.dispose();
    _micAnimationController.dispose();
    super.dispose();
  }

  // Paste from clipboard
  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData != null && clipboardData.text != null) {
      _inputController.text = clipboardData.text!;
      setState(() {});

      if (mounted) {
        final translationProvider = Provider.of<TranslationProvider>(
          context,
          listen: false,
        );
        translationProvider.updateInput(clipboardData.text!);
      }
    }
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
          translationProvider.clearError();
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, userProvider),
      drawer: _buildNavigationDrawer(context, userProvider),
      body: Column(
        children: [
          // Language selector bar
          _buildLanguageBar(translationProvider, userProvider),

          // Main translation area
          Expanded(
            child: Container(
              padding: EdgeInsets.all(isDesktop ? 32 : 16),
              child: isDesktop
                  ? _buildDesktopLayout(translationProvider)
                  : _buildMobileLayout(translationProvider),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 0),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    UserProvider userProvider,
  ) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textPrimary,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
        statusBarBrightness: Brightness.light, // For iOS (dark icons)
      ),
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.translate_rounded,
              color: AppColors.accent,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Medicus Translate',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history_rounded, color: AppColors.textPrimary),
          tooltip: 'Translation History',
          onPressed: () {
            // Show history dialog
            _showHistoryDialog(context);
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_rounded, color: AppColors.textPrimary),
          onPressed: () {
            context.push('/settings');
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildLanguageBar(
    TranslationProvider translationProvider,
    UserProvider userProvider,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
            child: _buildLanguageDropdown(
              value: translationProvider.sourceLanguage,
              onChanged: (value) {
                if (value != null) {
                  translationProvider.setSourceLanguage(value);
                }
              },
            ),
          ),

          // Swap button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  await translationProvider.swapLanguages();
                  if (translationProvider.currentTranslation != null) {
                    _inputController.text = translationProvider.currentInput;
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(10),
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
            child: _buildLanguageDropdown(
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
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.textSecondary,
          size: 20,
        ),
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Input panel
        Expanded(child: _buildInputPanel(translationProvider)),
        const SizedBox(width: 24),
        // Output panel
        Expanded(child: _buildOutputPanel(translationProvider)),
      ],
    );
  }

  Widget _buildMobileLayout(TranslationProvider translationProvider) {
    return ListView(
      children: [
        _buildInputPanel(translationProvider),
        const SizedBox(height: 16),
        _buildOutputPanel(translationProvider),
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }

  Widget _buildInputPanel(TranslationProvider translationProvider) {
    final characterCount = _inputController.text.length;
    final wordCount = _inputController.text.trim().isEmpty
        ? 0
        : _inputController.text.trim().split(RegExp(r'\s+')).length;

    return Container(
      constraints: const BoxConstraints(minHeight: 400),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Input text area
          Expanded(
            child: TextField(
              controller: _inputController,
              focusNode: _inputFocusNode,
              maxLines: null,
              expands: true,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
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
                setState(() {});
                translationProvider.updateInput(text);
              },
            ),
          ),

          // Bottom toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: const Border(
                top: BorderSide(color: AppColors.borderLight, width: 1),
              ),
            ),
            child: Row(
              children: [
                // Character and word count
                Text(
                  '$characterCount / 5000',
                  style: TextStyle(
                    fontSize: 12,
                    color: characterCount > 5000
                        ? AppColors.error
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 1,
                  height: 16,
                  color: AppColors.border,
                ),
                const SizedBox(width: 12),
                Text(
                  '$wordCount words',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),

                // Paste button
                IconButton(
                  onPressed: _pasteFromClipboard,
                  icon: const Icon(Icons.content_paste_rounded, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'Paste',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),

                const SizedBox(width: 12),

                // Microphone button
                IconButton(
                  onPressed: () async {
                    if (translationProvider.isListening) {
                      await translationProvider.stopListening();
                      if (translationProvider.currentInput.isNotEmpty) {
                        _inputController.text = translationProvider.currentInput;
                      }
                    } else {
                      await translationProvider.startListening();
                    }
                  },
                  icon: Icon(
                    translationProvider.isListening
                        ? Icons.mic_rounded
                        : Icons.mic_none_rounded,
                    size: 20,
                  ),
                  color: translationProvider.isListening
                      ? AppColors.error
                      : AppColors.textSecondary,
                  tooltip: translationProvider.isListening
                      ? 'Stop listening'
                      : 'Speak',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),

                const SizedBox(width: 12),

                // Clear button
                if (_inputController.text.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      _inputController.clear();
                      translationProvider.clearInput();
                      setState(() {});
                    },
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: AppColors.textSecondary,
                    tooltip: 'Clear',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),

                const SizedBox(width: 16),

                // Translate button
                ElevatedButton(
                  onPressed: translationProvider.isTranslating ||
                          _inputController.text.isEmpty
                      ? null
                      : () {
                          translationProvider.translateText(
                            _inputController.text,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: translationProvider.isTranslating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Translate',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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

  Widget _buildOutputPanel(TranslationProvider translationProvider) {
    final currentTranslation = translationProvider.currentTranslation;

    return Container(
      constraints: const BoxConstraints(minHeight: 400),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: currentTranslation == null
          ? _buildEmptyState()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Translation text
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: SelectableText(
                      currentTranslation.translatedText,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),

                // Bottom toolbar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    border: Border(
                      top: BorderSide(color: AppColors.borderLight, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Word count
                      Text(
                        '${currentTranslation.translatedText.trim().split(RegExp(r'\s+')).length} words',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),

                      // Copy button
                      TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(
                              text: currentTranslation.translatedText,
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text('Copied to clipboard'),
                                ],
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.success,
                              duration: const Duration(seconds: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: const Text('Copy'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.accent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
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
                        icon: Icon(
                          translationProvider.isSpeaking
                              ? Icons.stop_circle_outlined
                              : Icons.volume_up_rounded,
                          size: 20,
                        ),
                        color: translationProvider.isSpeaking
                            ? AppColors.error
                            : AppColors.accent,
                        tooltip: translationProvider.isSpeaking
                            ? 'Stop'
                            : 'Listen',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
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
                size: 48,
                color: AppColors.accent.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Translation will appear here',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter text and click translate',
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

  void _showHistoryDialog(BuildContext context) {
    final translationProvider = Provider.of<TranslationProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 600,
          height: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history_rounded,
                    color: AppColors.accent,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Translation History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
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
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: translationProvider.translationHistory.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final translation =
                              translationProvider.translationHistory[index];
                          return ListTile(
                            title: Text(
                              translation.originalText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              translation.translatedText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.arrow_forward_rounded),
                              onPressed: () {
                                _inputController.text = translation.originalText;
                                translationProvider.updateInput(
                                  translation.originalText,
                                );
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
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
                colors: [AppColors.primary, AppColors.primaryLight],
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
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            )
          : null,
      selected: isSelected,
      selectedTileColor: AppColors.accent.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      onTap: onTap,
    );
  }
}