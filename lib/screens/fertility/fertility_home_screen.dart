import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_routes.dart';

class FertilityHomeScreen extends StatelessWidget {
  const FertilityHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fertility & Child Care'),
        backgroundColor: Colors.pink.shade50,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader('Fertility'),
              _buildNavButton(context, 'Fertility Tracking', AppRoutes.fertilityTracking, Icons.calendar_today),
              _buildNavButton(context, 'Pregnancy Planning', AppRoutes.pregnancyPlanning, Icons.favorite_border),
              _buildNavButton(context, 'Medical Data', AppRoutes.medicalData, Icons.medical_services),
              
              const SizedBox(height: 24),
              _buildSectionHeader('Child Care & Pregnancy'),
              _buildNavButton(context, 'Pregnancy Tracking', AppRoutes.pregnancyTracking, Icons.pregnant_woman),
              _buildNavButton(context, 'Newborn & Child Care', AppRoutes.newbornChildCare, Icons.child_care),
              _buildNavButton(context, 'Mother\'s Health', AppRoutes.mothersHealth, Icons.spa),
              
              const SizedBox(height: 24),
              _buildAISection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String title, String route, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => context.push(route),
      ),
    );
  }

  Widget _buildAISection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade100),
      ),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome, size: 40, color: Colors.purple),
          const SizedBox(height: 8),
          const Text(
            'Ask Fertility AI',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
          ),
          const Text(
            'Get instant answers to your fertility and child care questions.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              // TODO: Open AI Chat
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text('Start Chat', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
