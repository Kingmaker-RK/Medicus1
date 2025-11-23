import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../constants/app_routes.dart';
import '../constants/colors.dart';
import '../data/services_data.dart';
import '../models/service_model.dart';
import '../providers/user_provider.dart';
import '../widgets/app_bottom_navigation_bar.dart';

class ServicesHubScreen extends StatelessWidget {
  const ServicesHubScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // Create a modifiable copy of the services list
        final sortedServices = List<ServiceModel>.from(services);

        // Sort the list
        sortedServices.sort((a, b) {
          // If "Most Used" is enabled, sort by usage count first
          if (userProvider.sortServicesByUsage) {
            final usageA = userProvider.serviceUsageCounts[a.route] ?? 0;
            final usageB = userProvider.serviceUsageCounts[b.route] ?? 0;
            // Sort by usage count descending
            if (usageA != usageB) {
              return usageB.compareTo(usageA);
            }
          }
          // Secondary sort (or primary if "Most Used" is disabled): Alphabetical
          return a.title.compareTo(b.title);
        });

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
            actions: [
              IconButton(
                icon: Icon(
                  userProvider.sortServicesByUsage
                      ? LucideIcons.trendingUp
                      : Icons.sort_by_alpha,
                ),
                tooltip: userProvider.sortServicesByUsage
                    ? 'Sort Alphabetically'
                    : 'Sort by Most Used',
                onPressed: () {
                  userProvider.toggleServiceSorting();
                },
              ),
            ],
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedServices.length,
            itemBuilder: (context, index) {
              final service = sortedServices[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildServiceCard(
                  context: context,
                  service: service,
                ),
              );
            },
          ),
          bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 4),
        );
      },
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required ServiceModel service,
  }) {
    return InkWell(
      onTap: () {
        context.read<UserProvider>().incrementServiceUsage(service.route);
        context.goNamed(service.route);
      },
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
                color: service.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(service.icon, color: service.color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.description,
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
