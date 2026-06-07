import 'package:flutter/material.dart';
import '../widgets/translated_widget.dart';
import '../constants/colors.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:go_router/go_router.dart';
import '../constants/app_routes.dart';

class HIVPreventionScreen extends StatelessWidget {
  const HIVPreventionScreen({Key? key}) : super(key: key);

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const AutoTranslateText('HIV/STI Prevention'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildServicesGrid(context),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Key Prevention Methods',
              icon: Icons.shield_rounded,
              content: const [
                'Practice safe sex using condoms consistently.',
                'Get vaccinated for Hepatitis B and HPV.',
                'Consider Pre-exposure prophylaxis (PrEP) if you are at high risk.',
                'Limit the number of sexual partners.',
                'Get tested regularly for STIs.',
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Preventing Spread (If Affected)',
              icon: Icons.people_outline_rounded,
              content: const [
                'Seek prompt medical treatment and adhere to medication.',
                'Inform sexual partners about your status.',
                'Practice abstinence or use condoms consistently.',
                'Participate in contact tracing programs.',
              ],
            ),
            const SizedBox(height: 20),
            _buildResourceSection(context),
            const SizedBox(height: 20),
            _buildGlobalOrganizationsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesGrid(BuildContext context) {
    final services = [
      {
        'title': 'Clinics Near You',
        'icon': Icons.local_hospital_rounded,
        'color': Colors.redAccent,
        'route': AppRoutes.hivClinics,
      },
      {
        'title': 'Prevention Programs',
        'icon': Icons.health_and_safety_rounded,
        'color': Colors.blueAccent,
        'route': AppRoutes.hivPreventionPrograms,
      },
      {
        'title': 'Support Organizations',
        'icon': Icons.volunteer_activism_rounded,
        'color': Colors.orangeAccent,
        'route': AppRoutes.hivSupportOrganizations,
      },
      {
        'title': 'My Reports',
        'icon': Icons.folder_shared_rounded,
        'color': Colors.teal,
        'route': AppRoutes.hivHistory,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () => context.pushNamed(service['route'] as String),
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (service['color'] as Color).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(service['icon'] as IconData, size: 32, color: service['color'] as Color),
                ),
                const SizedBox(height: 8),
                AutoTranslateText(
                  service['title'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection({required String title, required IconData icon, required List<String> content}) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: AutoTranslateText(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...content.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: AutoTranslateText(
                        item,
                        style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildResourceSection(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.public_rounded, color: AppColors.primary, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: AutoTranslateText(
                  'Educational Resources',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLinkButton(
            context,
            'LIEBESLEBEN Initiative (Germany)',
            'https://www.liebesleben.de',
          ),
          const SizedBox(height: 12),
          _buildLinkButton(
            context,
            'World Health Organization (WHO)',
            'https://www.who.int/health-topics/hiv-aids',
          ),
          const SizedBox(height: 12),
          _buildLinkButton(
            context,
            'Zanzu (Sexual Health in 14 Languages)',
            'https://www.zanzu.de',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: AutoTranslateText('Downloading informational material...'),
                    backgroundColor: AppColors.info,
                  ),
                );
              },
              icon: const Icon(Icons.download_rounded),
              label: const AutoTranslateText('Download Info Material (PDF)'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalOrganizationsSection() {
    final List<Map<String, dynamic>> globalData = [
      {
        'category': 'International HIV & STI Prevention Organizations',
        'items': [
          {
            'name': 'UNAIDS – Joint United Nations Programme on HIV/AIDS',
            'details': [
              'The main global organization coordinating the HIV response.',
              'Works in 100+ countries.',
              'Focuses on prevention, testing access, treatment, and ending stigma.',
            ]
          },
          {
            'name': 'WHO – World Health Organization (HIV, Hepatitis & STI Programmes)',
            'details': [
              'Sets global guidelines for HIV and STI prevention.',
              'Supports countries with surveillance, treatment programs, PrEP guidelines, etc.',
            ]
          },
          {
            'name': 'UNFPA – United Nations Population Fund',
            'details': [
              'Works globally on sexual health, condom distribution, and STI/HIV prevention.',
              'Strong focus on youth and vulnerable populations.',
            ]
          },
          {
            'name': 'Global Fund to Fight AIDS, Tuberculosis and Malaria',
            'details': [
              'One of the largest funding bodies supporting HIV and STI programs internationally.',
              'Finances prevention, testing, and treatment programs in low- and middle-income countries.',
            ]
          },
        ]
      },
      {
        'category': 'International Civil-Society & Nonprofits',
        'items': [
          {
            'name': 'International Planned Parenthood Federation (IPPF)',
            'details': [
              'Provides sexual health services in 140+ countries.',
              'STI screening, HIV testing, PrEP counseling.',
            ]
          },
          {
            'name': 'AIDS Healthcare Foundation (AHF)',
            'details': [
              'The world’s largest nonprofit HIV medical provider.',
              'Clinics in 45+ countries.',
              'Offers free or low-cost HIV testing and STI treatment.',
            ]
          },
          {
            'name': 'Médecins Sans Frontières (MSF)',
            'details': [
              'Provides HIV testing, STI treatment, ARV medication, and prevention programs in crisis regions.',
            ]
          },
          {
            'name': 'International AIDS Society (IAS)',
            'details': [
              'Largest association of HIV health professionals.',
              'Hosts the International AIDS Conference.',
            ]
          },
          {
            'name': 'Population Services International (PSI)',
            'details': [
              'Global health NGO focusing on HIV/STI prevention, PrEP access, condoms, and sexual health services.',
            ]
          },
          {
            'name': 'Elizabeth Glaser Pediatric AIDS Foundation (EGPAF)',
            'details': [
              'Works to eliminate HIV transmission in children.',
              'Supports testing and maternal health programs worldwide.',
            ]
          },
        ]
      },
      {
        'category': 'Global Networks & Coalitions',
        'items': [
          {
            'name': 'AVAC (Global Advocacy for HIV Prevention)',
            'details': [
              'Advocates for global access to PrEP, PEP, and new prevention technologies.',
            ]
          },
          {
            'name': 'ICW – International Community of Women Living with HIV',
            'details': [
              'Global network supporting HIV-positive women with sexual health and STI prevention resources.',
            ]
          },
          {
            'name': 'GNP+ (Global Network of People Living with HIV)',
            'details': [
              'Worldwide community of people living with HIV.',
              'Provides prevention advocacy and community programs.',
            ]
          },
          {
            'name': 'IUSTI – International Union Against Sexually Transmitted Infections',
            'details': [
              'Medical and professional network focusing on STI prevention, guidelines, training, and research.',
            ]
          },
        ]
      },
      {
        'category': 'Global STI-Specific Centers/Networks',
        'items': [
          {
            'name': 'ASHA – American Sexual Health Association',
            'details': [
              'Provides education and prevention resources on HIV, HPV, chlamydia, gonorrhea, etc.',
            ]
          },
          {
            'name': 'WHO Collaborating Centres for STIs',
            'details': [
              'Research and training centers worldwide dedicated to STI surveillance and prevention.',
            ]
          },
        ]
      }
    ];

    return Column(
      children: globalData.map((section) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.public, color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AutoTranslateText(
                      section['category'] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...(section['items'] as List<Map<String, dynamic>>).map((org) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoTranslateText(
                        org['name'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...(org['details'] as List<String>).map((detail) => Padding(
                        padding: const EdgeInsets.only(left: 8, top: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: AppColors.textSecondary)),
                            Expanded(
                              child: AutoTranslateText(
                                detail,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLinkButton(BuildContext context, String label, String url) {
    return InkWell(
      onTap: () => _launchURL(url),
      child: Row(
        children: [
          const Icon(Icons.link_rounded, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
