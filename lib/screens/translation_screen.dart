import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_bottom_navigation_bar.dart';
import '../constants/colors.dart';

class TranslationScreen extends StatelessWidget {
  const TranslationScreen({Key? key}) : super(key: key);

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
      body: Container(),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 0),
    );
  }
}
