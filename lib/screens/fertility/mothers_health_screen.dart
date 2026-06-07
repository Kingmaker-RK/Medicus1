import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MothersHealthScreen extends StatefulWidget {
  const MothersHealthScreen({super.key});

  @override
  State<MothersHealthScreen> createState() => _MothersHealthScreenState();
}

class _MothersHealthScreenState extends State<MothersHealthScreen> {
  double _moodValue = 3.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Mother\'s Wellness', style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w600)),
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
            _buildMoodCheckIn(),
            const SizedBox(height: 24),
            _buildRecoverySection(),
            const SizedBox(height: 24),
            _buildKegelTrainer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodCheckIn() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mental Health Check-in', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF00695C))),
          const SizedBox(height: 16),
          Text('How are you feeling today?', style: GoogleFonts.poppins(color: const Color(0xFF004D40))),
          Slider(
            value: _moodValue,
            min: 1,
            max: 5,
            divisions: 4,
            activeColor: const Color(0xFF009688),
            label: _getMoodLabel(_moodValue),
            onChanged: (val) => setState(() => _moodValue = val),
          ),
          Center(
            child: Text(
              _getMoodLabel(_moodValue),
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF009688)),
            ),
          ),
        ],
      ),
    );
  }

  String _getMoodLabel(double value) {
    if (value == 1) return 'Struggling';
    if (value == 2) return 'Anxious';
    if (value == 3) return 'Okay';
    if (value == 4) return 'Good';
    return 'Great';
  }

  Widget _buildRecoverySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Postpartum Recovery', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _buildRecoveryCard('Hydration', 'Drink 3L of water', Icons.local_drink),
        _buildRecoveryCard('Rest', 'Sleep when baby sleeps', Icons.bedtime),
        _buildRecoveryCard('Support', 'Call a friend today', Icons.phone),
      ],
    );
  }

  Widget _buildRecoveryCard(String title, String subtitle, IconData icon) {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF009688)),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 12)),
      ),
    );
  }

  Widget _buildKegelTrainer() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF80CBC4), Color(0xFF4DB6AC)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF009688).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Text('Pelvic Floor Trainer', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.play_arrow_rounded, size: 40, color: Color(0xFF009688)),
          ),
          const SizedBox(height: 12),
          Text('Start Session', style: GoogleFonts.poppins(color: Colors.white)),
        ],
      ),
    );
  }
}