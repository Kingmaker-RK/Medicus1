import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_routes.dart';
import '../constants/colors.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavigationBar({Key? key, required this.currentIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                context: context,
                icon: LucideIcons.home,
                label: 'Home',
                index: 0,
                isSelected: currentIndex == 0,
                onTap: () => context.goNamed(AppRoutes.translation),
              ),
              _buildNavItem(
                context: context,
                icon: LucideIcons.calendar,
                label: 'Appointments',
                index: 1,
                isSelected: currentIndex == 1,
                onTap: () => context.goNamed(AppRoutes.appointments),
              ),
              _buildNavItem(
                context: context,
                icon: LucideIcons.stethoscope,
                label: 'Services',
                index: 4,
                isSelected: currentIndex == 4,
                onTap: () => context.goNamed(AppRoutes.services),
              ),
              _buildNavItem(
                context: context,
                icon: LucideIcons.heart,
                label: 'Health',
                index: 2,
                isSelected: currentIndex == 2,
                onTap: () => context.goNamed(AppRoutes.health),
              ),
              _buildNavItem(
                context: context,
                icon: LucideIcons.bell,
                label: 'Reminders',
                index: 3,
                isSelected: currentIndex == 3,
                onTap: () => context.goNamed(AppRoutes.reminders),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 25,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
