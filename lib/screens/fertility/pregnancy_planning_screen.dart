import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PregnancyPlanningScreen extends StatefulWidget {
  const PregnancyPlanningScreen({super.key});

  @override
  State<PregnancyPlanningScreen> createState() => _PregnancyPlanningScreenState();
}

class _PregnancyPlanningScreenState extends State<PregnancyPlanningScreen> {
  bool _partnerMode = false;
  bool _medicationReminder = true;
  bool _ovulationTestReminder = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Pregnancy Planning', style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFertileWindowCard(),
            const SizedBox(height: 24),
            _buildSmartReminders(),
            const SizedBox(height: 24),
            _buildLifestyleTips(),
            const SizedBox(height: 24),
            _buildPartnerModeCard(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildFertileWindowCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFBA68C8), Color(0xFF9C27B0)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Best Fertile Window',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const Icon(Icons.stars_rounded, color: Colors.white),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Nov 12 - Nov 16',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'High Chance of Conception',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartReminders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Smart Reminders', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _buildSwitchTile('Medication & Supplements', 'Daily at 8:00 AM', _medicationReminder, (v) => setState(() => _medicationReminder = v)),
        _buildSwitchTile('Ovulation Test', 'Cycle Day 10-15', _ovulationTestReminder, (v) => setState(() => _ovulationTestReminder = v)),
      ],
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF9C27B0),
          ),
        ],
      ),
    );
  }

  Widget _buildLifestyleTips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lifestyle & Wellness', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildTipCard('Nutrition', 'Eat foods rich in Folic Acid', Icons.restaurant_menu, Colors.green),
              _buildTipCard('Sleep', 'Aim for 7-9 hours daily', Icons.bedtime, Colors.indigo),
              _buildTipCard('Exercise', 'Moderate yoga improves flow', Icons.directions_run, Colors.orange),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipCard(String title, String desc, IconData icon, Color color) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(desc, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildPartnerModeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.people_outline, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Partner Mode', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                Text('Share cycle data & reminders', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
              ],
            ),
          ),
          Switch(
            value: _partnerMode,
            onChanged: (v) => setState(() => _partnerMode = v),
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}