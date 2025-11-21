import 'package:flutter/material.dart';
import '../widgets/translated_widget.dart';
import '../constants/colors.dart';

class OrthopedicScreen extends StatefulWidget {
  const OrthopedicScreen({Key? key}) : super(key: key);

  @override
  State<OrthopedicScreen> createState() => _OrthopedicScreenState();
}

class _OrthopedicScreenState extends State<OrthopedicScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const AutoTranslateText('Orthopedic Examination'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Spine'),
            Tab(text: 'Upper Limb'),
            Tab(text: 'Lower Limb'),
            Tab(text: 'Tests'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSpineTab(),
          _buildUpperLimbTab(),
          _buildLowerLimbTab(),
          _buildTestsTab(),
        ],
      ),
    );
  }

  Widget _buildSpineTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spine Examination',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildExaminationCard(
            'Cervical Spine',
            'Range of motion, tenderness, alignment',
            Icons.account_circle_rounded,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildExaminationCard(
            'Thoracic Spine',
            'Posture, mobility, rib cage movement',
            Icons.accessibility_rounded,
            Colors.teal,
          ),
          const SizedBox(height: 12),
          _buildExaminationCard(
            'Lumbar Spine',
            'Flexion, extension, lateral bending',
            Icons.airline_seat_recline_normal_rounded,
            Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildExaminationCard(
            'Sacroiliac Joint',
            'Pain assessment, stability tests',
            Icons.circle_outlined,
            Colors.purple,
          ),
          const SizedBox(height: 24),
          Text(
            'Special Tests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildTestCard('Spurling Test', 'Cervical radiculopathy'),
          const SizedBox(height: 8),
          _buildTestCard('Straight Leg Raise', 'Lumbar nerve root compression'),
          const SizedBox(height: 8),
          _buildTestCard('FABER Test', 'Hip and sacroiliac pathology'),
        ],
      ),
    );
  }

  Widget _buildUpperLimbTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upper Limb Examination',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildExaminationCard(
            'Shoulder',
            'Rotation, abduction, impingement tests',
            Icons.sports_handball_rounded,
            Colors.indigo,
          ),
          const SizedBox(height: 12),
          _buildExaminationCard(
            'Elbow',
            'Flexion, extension, stability',
            Icons.back_hand_rounded,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildExaminationCard(
            'Wrist',
            'Range of motion, carpal tunnel signs',
            Icons.waving_hand_rounded,
            Colors.cyan,
          ),
          const SizedBox(height: 12),
          _buildExaminationCard(
            'Hand & Fingers',
            'Grip strength, fine motor skills',
            Icons.pan_tool_rounded,
            Colors.amber,
          ),
          const SizedBox(height: 24),
          Text(
            'Specific Tests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildTestCard('Neer Test', 'Shoulder impingement'),
          const SizedBox(height: 8),
          _buildTestCard('Cozen\'s Test', 'Lateral epicondylitis'),
          const SizedBox(height: 8),
          _buildTestCard('Phalen Test', 'Carpal tunnel syndrome'),
          const SizedBox(height: 8),
          _buildTestCard('Finkelstein Test', 'De Quervain\'s tenosynovitis'),
        ],
      ),
    );
  }

  Widget _buildLowerLimbTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lower Limb Examination',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildExaminationCard(
            'Hip',
            'Flexion, rotation, impingement tests',
            Icons.directions_walk_rounded,
            Colors.red,
          ),
          const SizedBox(height: 12),
          _buildExaminationCard(
            'Knee',
            'Stability, meniscus, ligament tests',
            Icons.skateboarding_rounded,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildExaminationCard(
            'Ankle',
            'Range of motion, stability assessment',
            Icons.run_circle_rounded,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildExaminationCard(
            'Foot',
            'Arch assessment, toe mobility',
            Icons.front_hand_rounded,
            Colors.purple,
          ),
          const SizedBox(height: 24),
          Text(
            'Specific Tests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildTestCard('Thomas Test', 'Hip flexor contracture'),
          const SizedBox(height: 8),
          _buildTestCard('McMurray Test', 'Meniscal tears'),
          const SizedBox(height: 8),
          _buildTestCard('Lachman Test', 'ACL integrity'),
          const SizedBox(height: 8),
          _buildTestCard('Anterior Drawer', 'Ankle ligament stability'),
        ],
      ),
    );
  }

  Widget _buildTestsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Examination Protocol',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildProtocolCard(
            '1. Observation',
            'Posture, gait, deformities, muscle wasting',
            Icons.visibility_rounded,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildProtocolCard(
            '2. Palpation',
            'Tenderness, swelling, temperature, crepitus',
            Icons.touch_app_rounded,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildProtocolCard(
            '3. Range of Motion',
            'Active and passive movements in all planes',
            Icons.rotate_right_rounded,
            Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildProtocolCard(
            '4. Strength Testing',
            'Muscle power grading (0-5 scale)',
            Icons.fitness_center_rounded,
            Colors.red,
          ),
          const SizedBox(height: 12),
          _buildProtocolCard(
            '5. Special Tests',
            'Specific maneuvers for diagnosis',
            Icons.medical_services_rounded,
            Colors.purple,
          ),
          const SizedBox(height: 12),
          _buildProtocolCard(
            '6. Neurovascular',
            'Sensation, reflexes, pulses',
            Icons.psychology_rounded,
            Colors.indigo,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const AutoTranslateText('Starting new examination'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              icon: const Icon(Icons.add_rounded),
              label: const AutoTranslateText('Start New Examination'),
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
    );
  }

  Widget _buildExaminationCard(
      String title, String description, IconData icon, Color color) {
    return InkWell(
      onTap: () {},
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
              padding: const EdgeInsets.all(12),
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
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard(String testName, String indication) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  testName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  indication,
                  style: TextStyle(
                    fontSize: 12,
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

  Widget _buildProtocolCard(
      String step, String description, IconData icon, Color color) {
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step,
                  style: TextStyle(
                    fontSize: 15,
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
        ],
      ),
    );
  }
}
