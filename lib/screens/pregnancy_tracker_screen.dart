import 'package:flutter/material.dart';
import '../widgets/translated_widget.dart';
import '../constants/colors.dart';

class PregnancyTrackerScreen extends StatefulWidget {
  const PregnancyTrackerScreen({Key? key}) : super(key: key);

  @override
  State<PregnancyTrackerScreen> createState() => _PregnancyTrackerScreenState();
}

class _PregnancyTrackerScreenState extends State<PregnancyTrackerScreen> {
  int currentWeek = 24; // Example week
  int totalWeeks = 40;

  @override
  Widget build(BuildContext context) {
    final progress = currentWeek / totalWeeks;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const AutoTranslateText('Pregnancy Tracker'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pink.shade300, Colors.pink.shade400],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Week $currentWeek of $totalWeeks',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${(progress * 100).toInt()}% Complete',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Baby Development',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.child_care_rounded,
              title: 'Size This Week',
              description: 'Your baby is about the size of a cantaloupe',
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.straighten_rounded,
              title: 'Length',
              description: 'Approximately 30 cm (11.8 inches)',
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.monitor_weight_rounded,
              title: 'Weight',
              description: 'About 600 grams (1.3 pounds)',
              color: Colors.purple,
            ),
            const SizedBox(height: 24),
            Text(
              'Health Tips',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildTipCard(
              'Stay Hydrated',
              'Drink at least 8-10 glasses of water daily',
              Icons.water_drop_rounded,
              Colors.cyan,
            ),
            const SizedBox(height: 12),
            _buildTipCard(
              'Prenatal Vitamins',
              'Continue taking your daily prenatal supplements',
              Icons.medication_rounded,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildTipCard(
              'Gentle Exercise',
              'Walking and prenatal yoga are great options',
              Icons.fitness_center_rounded,
              Colors.teal,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded),
                label: const AutoTranslateText('Log Symptoms'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(
      String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
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
        ],
      ),
    );
  }
}
