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

      translationProvider.initialize(
        userLanguage: userProvider.selectedLanguage,
      );
      _previousUserLanguage = userProvider.selectedLanguage;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final translationProvider = Provider.of<TranslationProvider>(
      context,
      listen: false,
    );

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

    if (translationProvider.lastError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final errorMessage = translationProvider.lastError;
        if (errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          translationProvider.clearError();
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildGoogleStyleAppBar(context, userProvider),
      drawer: _buildNavigationDrawer(context, userProvider),
      body: Column(
        children: [
          // Google-style Language Selector
          _buildLanguageSelector(translationProvider),
          const Divider(height: 1, color: AppColors.border),

          // Main Content
          Expanded(
            child: Container(
              color: AppColors.surface, // Light grey background for content area
              child: ListView(
                padding: EdgeInsets.all(isDesktop ? 24 : 8),
                children: [
                  _buildTranslationCard(
                    context,
                    translationProvider,
                    isDesktop,
                  ),
                  if (translationProvider.currentTranslation != null)
                    _buildMedicalContextSection(translationProvider),
                  
                  const SizedBox(height: 100), // Space for the big mic
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildBigMicButton(translationProvider),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      endDrawer: _buildHistoryDrawer(translationProvider),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 0),
    );
  }

  PreferredSizeWidget _buildGoogleStyleAppBar(BuildContext context, UserProvider userProvider) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: AppColors.textSecondary),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: const Text(
        'Google Translate', // Or "Translate"
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      centerTitle: true,
      actions: [
         IconButton(
          icon: const Icon(Icons.history, color: AppColors.textSecondary),
          onPressed: () => Scaffold.of(context).openEndDrawer(),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: CircleAvatar(
            backgroundColor: AppColors.primary,
            radius: 16,
            child: Text(
              (userProvider.currentUser?.name?.isNotEmpty == true
                  ? userProvider.currentUser!.name!.substring(0, 1)
                  : 'U').toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector(TranslationProvider provider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLanguageTab(
            provider.sourceLanguage,
            () {
               // Logic to pick source language
               // Ideally open a modal or bottom sheet
            },
            isActive: true,
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz, color: AppColors.textSecondary),
            onPressed: () => provider.swapLanguages(),
          ),
          _buildLanguageTab(
            provider.targetLanguage,
            () {
               // Logic to pick target language
            },
            isActive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTab(String languageCode, VoidCallback onTap, {bool isActive = false}) {
    final languageName = AppConstants.supportedLanguages.firstWhere(
      (l) => l['code'] == languageCode,
      orElse: () => {'nativeName': languageCode},
    )['nativeName'];

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: isActive ? const Border(bottom: BorderSide(color: AppColors.primary, width: 2)) : null,
        ),
        child: Text(
          languageName ?? languageCode,
          style: TextStyle(
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildTranslationCard(BuildContext context, TranslationProvider provider, bool isDesktop) {
    return Column(
      children: [
        // Input Area
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
               BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _inputController,
                  maxLines: null,
                  minLines: isDesktop ? 5 : 3,
                  style: const TextStyle(fontSize: 24, color: AppColors.textPrimary, fontWeight: FontWeight.w400),
                  decoration: InputDecoration(
                    hintText: 'Enter text',
                    hintStyle: const TextStyle(fontSize: 24, color: AppColors.textHint),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    suffixIcon: _inputController.text.isNotEmpty 
                      ? IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textSecondary),
                          onPressed: () {
                            _inputController.clear();
                            provider.clearInput();
                            setState((){});
                          },
                        ) 
                      : null,
                  ),
                  onChanged: (text) {
                    setState(() {});
                    provider.updateInput(text);
                  },
                ),
              ),
              if (_inputController.text.isNotEmpty && !provider.isTranslating)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                       icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
                       onPressed: () => provider.translateText(_inputController.text),
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),

        // Output Area
        if (provider.currentTranslation != null)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F4), // Google Grey output
              borderRadius: BorderRadius.circular(8),
               boxShadow: const [
               BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2)),
            ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SelectableText(
                    provider.currentTranslation!.translatedText,
                    style: const TextStyle(fontSize: 24, color: AppColors.textPrimary),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(provider.isSpeaking ? Icons.stop : Icons.volume_up_rounded),
                        color: AppColors.textSecondary,
                        onPressed: () => provider.speakText(provider.currentTranslation!.translatedText, provider.targetLanguage),
                      ),
                      IconButton(
                        icon: const Icon(Icons.content_copy_rounded),
                         color: AppColors.textSecondary,
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: provider.currentTranslation!.translatedText));
                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Copied'), duration: Duration(seconds: 1)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBigMicButton(TranslationProvider provider) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!provider.isListening)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Conversation',
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        GestureDetector(
          onTapDown: (_) async {
             await provider.startListening();
          },
          onTapUp: (_) async {
             await provider.stopListening();
             if(provider.currentInput.isNotEmpty) {
                _inputController.text = provider.currentInput;
             }
          },
          onTapCancel: () async {
            await provider.stopListening();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: provider.isListening ? 96 : 80,
            width: provider.isListening ? 96 : 80,
            decoration: BoxDecoration(
              color: provider.isListening ? AppColors.error : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Icon(
              provider.isListening ? Icons.mic : Icons.mic_none_rounded,
              size: 40,
              color: provider.isListening ? Colors.white : AppColors.primary,
            ),
          ),
        ),
      ],
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
               BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: ExpansionTile(
        title: const Text('Medical Context', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 if (hasMedicalTerms) ...[
                    const Text('Terms:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8,
                      children: currentTranslation.medicalTerms.map((t) => Chip(label: Text(t), backgroundColor: AppColors.surface)).toList(),
                    ),
                 ],
                 if (hasAnatomyImages) ...[
                   const SizedBox(height: 16),
                   const Text('Anatomy:', style: TextStyle(fontWeight: FontWeight.bold)),
                   const SizedBox(height: 8),
                   SizedBox(height: 200, child: AnatomyViewer(imageUrls: currentTranslation.anatomyImages)),
                 ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationDrawer(BuildContext context, UserProvider userProvider) {
     // Minimal Drawer for context
    return Drawer(
      child: ListView(
        children: [
           DrawerHeader(
             decoration: const BoxDecoration(color: AppColors.primary),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               mainAxisAlignment: MainAxisAlignment.end,
               children: [
                 const Icon(Icons.translate, color: Colors.white, size: 48),
                 const SizedBox(height: 8),
                 Text(userProvider.currentUser?.email ?? 'User', style: const TextStyle(color: Colors.white, fontSize: 18)),
               ],
             ),
           ),
           ListTile(leading: const Icon(Icons.settings), title: const Text('Settings'), onTap: () => context.push('/settings')),
           ListTile(leading: const Icon(Icons.logout), title: const Text('Logout'), onTap: () => userProvider.logout()),
        ],
      ),
    );
  }
  
  Widget _buildHistoryDrawer(TranslationProvider provider) {
    return Drawer(
      child: ListView(
         children: [
           const Padding(padding: EdgeInsets.all(16), child: Text('History', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
           ...provider.translationHistory.map((h) => ListTile(
             title: Text(h.originalText, maxLines: 1, overflow: TextOverflow.ellipsis),
             subtitle: Text(h.translatedText, maxLines: 1, overflow: TextOverflow.ellipsis),
             onTap: () {
                _inputController.text = h.originalText;
                provider.updateInput(h.originalText);
                Navigator.pop(context);
             },
           )),
         ],
      ),
    );
  }
}
