import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_routes.dart';

class FertilityHomeScreen extends StatelessWidget {
  const FertilityHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD), // Clean white background
      appBar: AppBar(
        title: Text(
          'Fertility & Child Care',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3142),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF2D3142)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDailyInsightCard(),
              const SizedBox(height: 24),
              _buildSectionHeader('Fertility Journey'),
              _buildGridMenu(context, [
                _MenuOption(
                  title: 'Cycle Tracking',
                  icon: Icons.calendar_month_rounded,
                  color: const Color(0xFFE91E63),
                  route: AppRoutes.fertilityTracking,
                  subtitle: 'Log symptoms & BBT',
                ),
                _MenuOption(
                  title: 'Pregnancy Planning',
                  icon: Icons.favorite_rounded,
                  color: const Color(0xFF9C27B0),
                  route: AppRoutes.pregnancyPlanning,
                  subtitle: 'Fertile window & tips',
                ),
                _MenuOption(
                  title: 'Medical Data',
                  icon: Icons.medical_services_rounded,
                  color: const Color(0xFF2196F3),
                  route: AppRoutes.medicalData,
                  subtitle: 'History & hormones',
                ),
              ]),
              const SizedBox(height: 24),
              _buildSectionHeader('Mother & Child'),
              _buildGridMenu(context, [
                _MenuOption(
                  title: 'Pregnancy Tracking',
                  icon: Icons.pregnant_woman_rounded,
                  color: const Color(0xFFFF9800),
                  route: AppRoutes.pregnancyTracking,
                  subtitle: 'Weeks, kicks & timer',
                ),
                _MenuOption(
                  title: 'Baby Care',
                  icon: Icons.child_care_rounded,
                  color: const Color(0xFF4CAF50),
                  route: AppRoutes.newbornChildCare,
                  subtitle: 'Feeding, sleep & growth',
                ),
                _MenuOption(
                  title: 'Mother\'s Health',
                  icon: Icons.spa_rounded,
                  color: const Color(0xFF009688),
                  route: AppRoutes.mothersHealth,
                  subtitle: 'Recovery & wellness',
                ),
              ]),
              const SizedBox(height: 24),
              _buildAIAssistantCard(context),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF4F5E7B),
        ),
      ),
    );
  }

  Widget _buildDailyInsightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFF48FB1).withOpacity(0.2), const Color(0xFFF8BBD0).withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF48FB1).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E63).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.wb_sunny_rounded, color: Color(0xFFE91E63)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Daily Insight',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF880E4F),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Your fertile window is approaching. Stay hydrated and track your BBT tomorrow morning.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF2D3142),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridMenu(BuildContext context, List<_MenuOption> options) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1, // Slightly wider cards
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        return InkWell(
          onTap: () => context.push(option.route),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: option.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(option.icon, color: option.color, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  option.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  option.subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAIAssistantCard(BuildContext context) {
    return InkWell(
      onTap: () {
         // Implement Chat Navigation or Logic
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF673AB7),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF673AB7).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ask Fertility AI',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Instant medical insights & support',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}

class _MenuOption {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  _MenuOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}