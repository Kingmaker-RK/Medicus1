import 'package:flutter/material.dart';
import '../widgets/translated_widget.dart';
import '../constants/colors.dart';

class HIVSupportOrganizationsScreen extends StatelessWidget {
  const HIVSupportOrganizationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const AutoTranslateText('Support Organizations'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AutoTranslateText(
              'Find support tailored to your needs based on your location.',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            _buildCategoryGroup(
              title: 'Youth & Adolescents',
              icon: Icons.face_rounded,
              color: Colors.orange,
              organizations: [
                {'name': 'Local Youth Center', 'scope': 'Near You', 'desc': 'Safe space for counseling and peer support.'},
                {'name': 'National Youth HIV Network', 'scope': 'National', 'desc': 'Advocacy and educational resources for young people.'},
                {'name': 'StaySafe Global Youth', 'scope': 'Global', 'desc': 'Online community and information portal.'},
              ],
            ),
            _buildCategoryGroup(
              title: 'Migrants & Refugees',
              icon: Icons.public,
              color: Colors.blue,
              organizations: [
                {'name': 'Refugee Health Aid', 'scope': 'Regional', 'desc': 'Multilingual support and navigation for healthcare systems.'},
                {'name': 'Migrant Rights Network', 'scope': 'National', 'desc': 'Legal and health support for undocumented migrants.'},
              ],
            ),
            _buildCategoryGroup(
              title: 'Vulnerable Groups',
              icon: Icons.diversity_3,
              color: Colors.purple,
              organizations: [
                {'name': 'Community Outreach', 'scope': 'Near You', 'desc': 'Harm reduction services and immediate assistance.'},
                {'name': 'Global Equality Alliance', 'scope': 'International', 'desc': 'Fighting stigma and discrimination worldwide.'},
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGroup({
    required String title,
    required IconData icon,
    required Color color,
    required List<Map<String, String>> organizations,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AutoTranslateText(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...organizations.map((org) => Card(
                elevation: 0,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.shadowLight),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          org['name']!,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          org['scope']!,
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      org['desc']!,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  onTap: () {},
                ),
              )),
        ],
      ),
    );
  }
}
