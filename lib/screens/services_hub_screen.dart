import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/colors.dart';
import '../widgets/app_bottom_navigation_bar.dart';

class ServicesHubScreen extends StatelessWidget {
  const ServicesHubScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Medical Services',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explore Our Services',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Access comprehensive medical services at your fingertips',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            _buildServiceCard(
              context: context,
              icon: LucideIcons.pill,
              title: 'E-Rezept',
              description:
                  'Buy medication as per prescription. Upload prescription and insurance card photos.',
              color: Colors.blue,
              route: '/e-rezept',
            ),
            const SizedBox(height: 12),
            _buildServiceCard(
              context: context,
              icon: LucideIcons.userPlus,
              title: 'Pregnancy Tracker',
              description:
                  'Track your pregnancy journey with weekly updates and health tips.',
              color: Colors.pink,
              route: '/pregnancy-tracker',
            ),
            const SizedBox(height: 12),
            _buildServiceCard(
              context: context,
              icon: LucideIcons.droplet,
              title: 'Blood Donation',
              description:
                  'Find blood donation centers and schedule appointments.',
              color: Colors.red,
              route: '/blood-donation',
            ),
            const SizedBox(height: 12),
            _buildServiceCard(
              context: context,
              icon: LucideIcons.smile,
              title: 'Dentist',
              description:
                  'Find dentists in your area by name, location, or pincode.',
              color: Colors.teal,
              route: '/dentist',
            ),
            const SizedBox(height: 12),
            _buildServiceCard(
              context: context,
              icon: LucideIcons.scanFace,
              title: 'Dermo',
              description:
                  'Dermatologist treatment. Upload pictures, ask questions, get diagnosis and aftercare.',
              color: Colors.orange,
              route: '/dermo',
            ),
            const SizedBox(height: 12),
            _buildServiceCard(
              context: context,
              icon: LucideIcons.baby,
              title: 'Baby Tracker',
              description: 'Track your newborn\'s feeding, sleep, and growth.',
              color: Colors.purple,
              route: '/baby-tracker',
            ),
            const SizedBox(height: 12),
            _buildServiceCard(
              context: context,
              icon: LucideIcons.bone,
              title: 'Orthopedic',
              description:
                  'Orthopedic examination tools for doctors. Similar to Orthoexamine.',
              color: Colors.brown,
              route: '/orthopedic',
            ),
            const SizedBox(height: 12),
            _buildServiceCard(
              context: context,
              icon: LucideIcons.dumbbell,
              title: 'FitPhysic',
              description:
                  'Personal guide for successful rehab with training videos.',
              color: Colors.green,
              route: '/fitphysic',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 4),
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required String route,
  }) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
