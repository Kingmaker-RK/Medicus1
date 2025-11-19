import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/translation_provider.dart';
import '../providers/user_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/doctor_profile_provider.dart';
import '../constants/colors.dart';
import '../constants/app_constants.dart';
import '../widgets/anatomy_viewer.dart';
import '../widgets/app_bottom_navigation_bar.dart';
import '../widgets/handwriting_input_widget.dart';
import '../services/permission_service.dart';
import '../services/pdf_export_service.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({Key? key}) : super(key: key);

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  bool _isConversationMode = false;
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
    _outputController.dispose();
    _micAnimationController.dispose();
    super.dispose();
  }

  void _showHandwritingInput() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HandwritingInputWidget(
        onHandwritingCaptured: (imageBytes) async {
          Navigator.pop(context);
          final provider = Provider.of<TranslationProvider>(context, listen: false);

          // Show simple loading dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(child: CircularProgressIndicator()),
          );

          final text = await provider.recognizeHandwriting(imageBytes);

          // Pop loading
          if (mounted) Navigator.pop(context);

          if (text.isNotEmpty && mounted) {
            _inputController.text = text;
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not recognize handwriting')),
            );
          }
        },
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: const Text(
          'Please enable camera access in settings to take photos for translation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              PermissionService().openSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndExtractImage({ImageSource source = ImageSource.gallery}) async {
    if (source == ImageSource.camera) {
      final permissionService = PermissionService();
      final hasPermission = await permissionService.isCameraGranted();
      if (!hasPermission) {
        final granted = await permissionService.requestCameraPermission();
        if (!granted) {
          if (!mounted) return;
          _showPermissionDialog();
          return;
        }
      }
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      final bytes = await image.readAsBytes();
      if (!mounted) return;

      final provider = Provider.of<TranslationProvider>(context, listen: false);

      // Show simple loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final text = await provider.extractTextFromImage(bytes);

      // Pop loading
      if (mounted) Navigator.pop(context);

      if (text.isNotEmpty && mounted) {
        _inputController.text = text;
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not extract text from image')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final translationProvider = Provider.of<TranslationProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    // Sync input controller with provider during listening
    if (translationProvider.isListening &&
        translationProvider.currentInput != _inputController.text) {
      _inputController.text = translationProvider.currentInput;
      _inputController.selection = TextSelection.fromPosition(
        TextPosition(offset: _inputController.text.length),
      );
    }

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
      backgroundColor: AppColors.background,
      appBar: _buildModernAppBar(userProvider),
      drawer: _buildNavigationDrawer(context, userProvider),
      body: Column(
        children: [
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

          // Unified Control Panel (Merged Language Bar + Actions)
          _buildUnifiedControlPanel(translationProvider, userProvider),
            
          // Small spacing at bottom (Reduced by 50% from previous FAB margin)
          const SizedBox(height: 2),
        ],
      ),
      endDrawer: _buildHistoryDrawer(translationProvider),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 0),
    );
  }

  PreferredSizeWidget _buildModernAppBar(UserProvider userProvider) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Medicus',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          fontFamily: 'serif',
          shadows: [
            Shadow(
              color: Color.fromRGBO(0, 0, 0, 0.15),
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      leadingWidth: 100,
      leading: Builder(
        builder: (context) {
          final isDoctor =
              userProvider.currentUser?.role == AppConstants.roleDoctor;
          ImageProvider? backgroundImage;
          bool hasProfilePicture = false;

          if (isDoctor) {
            final doctorProfileProvider = Provider.of<DoctorProfileProvider>(
              context,
            );
            final profile = doctorProfileProvider.profile;
            if (profile.profilePictureUrl != null &&
                profile.profilePictureUrl!.isNotEmpty) {
              hasProfilePicture = true;
              if (profile.profilePictureUrl!.startsWith('http')) {
                backgroundImage = NetworkImage(profile.profilePictureUrl!);
              } else {
                backgroundImage = FileImage(File(profile.profilePictureUrl!));
              }
            }
          } else {
            final userProfileProvider = Provider.of<UserProfileProvider>(
              context,
            );
            final profile = userProfileProvider.profile;
            if (profile.profilePicturePath.isNotEmpty) {
              hasProfilePicture = true;
              backgroundImage = FileImage(File(profile.profilePicturePath));
            }
          }

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () {
                  if (isDoctor) {
                    context.push('/doctor-profile');
                  } else {
                    context.push('/profile');
                  }
                },
                customBorder: const CircleBorder(),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  backgroundImage: backgroundImage,
                  child: !hasProfilePicture
                      ? const Icon(
                          Icons.person_rounded,
                          size: 20,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
            ],
          );
        },
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

  Widget _buildUnifiedControlPanel(
    TranslationProvider translationProvider,
    UserProvider userProvider,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Language Selectors
          Row(
            children: [
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Tooltip(
                  message: 'Swap languages',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
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
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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

          const SizedBox(height: 16), // Reduced spacing between sections

          // Action Buttons (Merged from FAB)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Conversation Mode
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isConversationMode ? AppColors.accent : Colors.grey[50],
                  border: Border.all(
                    color: _isConversationMode ? AppColors.accent : AppColors.borderLight,
                  ),
                ),
                child: IconButton(
                  onPressed: () async {
                    setState(() {
                      _isConversationMode = !_isConversationMode;
                    });
                    if (_isConversationMode) {
                      await translationProvider.startListening();
                    } else {
                      await translationProvider.stopListening();
                    }
                  },
                  icon: Icon(
                    Icons.record_voice_over_rounded,
                    color: _isConversationMode ? Colors.white : AppColors.accent,
                    size: 20,
                  ),
                  tooltip: 'Conversation Mode',
                ),
              ),

              const SizedBox(width: 72),

              // Microphone (Middle)
              _buildFloatingMicButton(translationProvider),

              const SizedBox(width: 72),

              // Camera
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[50],
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: IconButton(
                  onPressed: () => _pickAndExtractImage(source: ImageSource.camera),
                  icon: Icon(Icons.camera_alt_rounded, color: AppColors.accent),
                  iconSize: 22,
                  tooltip: 'Take Photo',
                ),
              ),
            ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.textSecondary,
        ),
        style: TextStyle(
          fontSize: 14,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Input text area with floating icons
          Stack(
            children: [
              TextField(
                controller: _inputController,
                maxLines: null,
                minLines: 3,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter text to translate...',
                  hintStyle: TextStyle(color: AppColors.textHint, fontSize: 16),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
                ),
                onChanged: (text) {
                  setState(() {}); // Update character count
                  translationProvider.updateInput(text);
                },
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.image_rounded),
                      color: AppColors.textSecondary,
                      tooltip: 'Upload Image',
                      onPressed: _pickAndExtractImage,
                    ),
                    IconButton(
                      icon: const Icon(Icons.draw_rounded),
                      color: AppColors.textSecondary,
                      tooltip: 'Handwriting Input',
                      onPressed: _showHandwritingInput,
                    ),
                  ],
                ),
              ),
            ],
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
                  onPressed:
                      translationProvider.isTranslating ||
                          _inputController.text.isEmpty
                      ? null
                      : () {
                          translationProvider.translateText(
                            _inputController.text,
                          );
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
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

    if (currentTranslation != null &&
        _outputController.text != currentTranslation.translatedText) {
      _outputController.text = currentTranslation.translatedText;
    }

    return Container(
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
              mainAxisSize: MainAxisSize.min,
              children: [
                // Translation text
                TextField(
                  controller: _outputController,
                  readOnly: true,
                  maxLines: null,
                  minLines: 2,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
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
                            ClipboardData(
                              text: currentTranslation.translatedText,
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Translation copied to clipboard',
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
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: const Text('Copy'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.accent,
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Speak button with loading state
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
                        color: translationProvider.isSpeaking
                            ? AppColors.error
                            : AppColors.accent,
                        tooltip: translationProvider.isSpeaking
                            ? 'Stop'
                            : 'Listen',
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
              style: TextStyle(fontSize: 14, color: AppColors.textHint),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
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
    return Tooltip(
      message: translationProvider.isListening
          ? 'Listening... Tap to stop'
          : 'Hold to speak',
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
                  content: Row(
                    children: [
                      const Icon(Icons.mic_off, color: Colors.white),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Microphone permission required. Please enable in settings.',
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  action: SnackBarAction(
                    label: 'Settings',
                    textColor: Colors.white,
                    onPressed: () {
                      // Open app settings
                      // This would require permission_handler package
                    },
                  ),
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
            width: 51,
            height: 51,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: translationProvider.isListening
                  ? AppColors.error
                  : AppColors.accent,
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
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  translationProvider.isListening
                      ? Icons.mic_rounded
                      : Icons.mic_none_rounded,
                  size: 22,
                  color: Colors.white,
                ),
                if (translationProvider.isListening)
                  Positioned(
                    bottom: 8,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
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

  Widget _buildHistoryDrawer(TranslationProvider translationProvider) {
    return Drawer(
      child: Column(
        children: [
          // History drawer header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.accent, AppColors.accent.withOpacity(0.8)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.history_rounded,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    if (translationProvider.translationHistory.isNotEmpty) ...[
                      IconButton(
                        icon: const Icon(
                          Icons.picture_as_pdf_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          await PdfExportService().exportHistory(
                            translationProvider.translationHistory,
                          );
                        },
                        tooltip: 'Export History as PDF',
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
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
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Translation History',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${translationProvider.translationHistory.length} translations',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
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
                            color: AppColors.inputBackground,
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
                                    color: AppColors.accent,
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
                                        color: AppColors.accent,
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
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${translation.sourceLanguage} → ${translation.targetLanguage}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.copy_rounded,
                                      size: 16,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(
                                          text: translation.translatedText,
                                        ),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            'Translation copied',
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          duration: const Duration(seconds: 1),
                                          backgroundColor: AppColors.success,
                                        ),
                                      );
                                    },
                                    tooltip: 'Copy translation',
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