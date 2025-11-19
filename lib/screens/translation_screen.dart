import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_bottom_navigation_bar.dart';
import '../constants/colors.dart';

class TranslationScreen extends StatelessWidget {
  const TranslationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.textPrimary),
          onPressed: () {
            // Menu action placeholder
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppColors.textPrimary),
            onPressed: () {
              // History action placeholder
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: AppColors.textPrimary),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Expanded(child: SizedBox()), // Placeholder for content
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter text...',
                      hintStyle: const TextStyle(color: AppColors.textHint),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.inputBackground,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.mic, color: Colors.white),
                    onPressed: () {
                      // Microphone action placeholder
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 0),
    );
  }
}
