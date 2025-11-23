import 'package:flutter/material.dart';
import '../widgets/translated_widget.dart';
import '../constants/colors.dart';
import 'addiction_recovery_centers_screen.dart';

class AddictionRecoveryScreen extends StatelessWidget {
  const AddictionRecoveryScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> addictionTypes = const [
    {'name': 'Alcohol', 'icon': Icons.local_drink_rounded, 'color': Colors.amber},
    {'name': 'Tobacco/Nicotine', 'icon': Icons.smoke_free_rounded, 'color': Colors.grey},
    {'name': 'Drugs/Substance', 'icon': Icons.medication_rounded, 'color': Colors.red},
    {'name': 'Gambling', 'icon': Icons.casino_rounded, 'color': Colors.green},
    {'name': 'Gaming/Internet', 'icon': Icons.sports_esports_rounded, 'color': Colors.blue},
    {'name': 'Other', 'icon': Icons.more_horiz_rounded, 'color': Colors.purple},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const AutoTranslateText('Addiction Recovery'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: AutoTranslateText(
                'Select the type of support you need:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: addictionTypes.length,
                itemBuilder: (context, index) {
                  final type = addictionTypes[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddictionRecoveryCentersScreen(
                            addictionType: type['name'],
                          ),
                        ),
                      );
                    },
                    child: Container(
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: type['color'].withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              type['icon'],
                              size: 32,
                              color: type['color'],
                            ),
                          ),
                          const SizedBox(height: 12),
                          AutoTranslateText(
                            type['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
