import 'package:flutter/material.dart';
import '../widgets/translated_widget.dart';
import '../constants/colors.dart';

class HIVPreventionProgramsScreen extends StatelessWidget {
  const HIVPreventionProgramsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const AutoTranslateText('Prevention Programs'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationHeader(),
            const SizedBox(height: 20),
            _buildProgramSection(
              title: 'Near You (Local)',
              icon: Icons.near_me,
              programs: [
                {'name': 'City Outreach Program', 'desc': 'Free condom distribution and testing at community centers.'},
                {'name': 'Local Youth Initiative', 'desc': 'Workshops and peer education in local schools.'},
              ],
            ),
            _buildProgramSection(
              title: 'Regional / District',
              icon: Icons.map,
              programs: [
                {'name': 'State Health Department STI Drive', 'desc': 'Mobile clinics visiting rural districts monthly.'},
                {'name': 'Regional PrEP Access Project', 'desc': 'Subsidized PrEP medication for at-risk populations.'},
              ],
            ),
            _buildProgramSection(
              title: 'National (Country)',
              icon: Icons.flag,
              programs: [
                {'name': 'National HIV Control Program', 'desc': 'Federal guidelines and funding for treatment centers.'},
                {'name': 'Know Your Status Campaign', 'desc': 'Nationwide media campaign promoting regular testing.'},
              ],
            ),
            _buildProgramSection(
              title: 'International / Continental',
              icon: Icons.public,
              programs: [
                {'name': 'Stop TB & HIV Partnership (Europe)', 'desc': 'Cross-border collaboration for migrant health.'},
                {'name': 'Global Fund Initiatives (Africa/Asia)', 'desc': 'Large scale funding for prevention and ART access.'},
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: const [
          Icon(Icons.location_on, color: AppColors.primary),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoTranslateText(
                  'Programs filtered by your location',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                Text(
                  'Detected: Berlin, Germany (Europe)',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramSection({
    required String title,
    required IconData icon,
    required List<Map<String, String>> programs,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 24),
              const SizedBox(width: 8),
              AutoTranslateText(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...programs.map((program) => Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    program['name']!,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      program['desc']!,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
                  onTap: () {
                    // Navigate to details or external link
                  },
                ),
              )),
        ],
      ),
    );
  }
}
