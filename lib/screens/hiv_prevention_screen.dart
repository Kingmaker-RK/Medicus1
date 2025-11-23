import 'package:flutter/material.dart';
import '../widgets/translated_widget.dart';
import '../constants/colors.dart';
import 'package:url_launcher/url_launcher.dart';

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
          ],
        ),
      ),
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
