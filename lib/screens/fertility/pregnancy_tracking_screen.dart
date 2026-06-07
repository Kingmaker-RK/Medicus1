import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PregnancyTrackingScreen extends StatefulWidget {
  const PregnancyTrackingScreen({super.key});

  @override
  State<PregnancyTrackingScreen> createState() => _PregnancyTrackingScreenState();
}

class _PregnancyTrackingScreenState extends State<PregnancyTrackingScreen> {
  int _currentWeek = 24;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Pregnancy Tracker', style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildWeekProgress(),
            const SizedBox(height: 30),
            _buildBabySizeCard(),
            const SizedBox(height: 30),
            _buildToolsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekProgress() {
    return Column(
      children: [
        Text(
          'Week $_currentWeek',
          style: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.bold, color: const Color(0xFFFF9800)),
        ),
        Text(
          'Trimester 2 • 112 Days to go',
          style: GoogleFonts.poppins(color: Colors.grey[600]),
        ),
        const SizedBox(height: 20),
        Stack(
          children: [
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Container(
              height: 12,
              width: MediaQuery.of(context).size.width * 0.6, // Mock progress
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFFFCC80)]),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBabySizeCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.child_care, size: 40, color: Colors.orange),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Baby is the size of an',
                  style: GoogleFonts.poppins(color: Colors.orange[800], fontSize: 12),
                ),
                Text(
                  'Ear of Corn',
                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange[900]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Length: 30 cm • Weight: 600 g',
                  style: GoogleFonts.poppins(color: Colors.orange[800], fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildToolCard('Kick Counter', Icons.touch_app_rounded, Colors.blue, () {}),
        _buildToolCard('Contraction Timer', Icons.timer_rounded, Colors.red, () {}),
        _buildToolCard('Weight Tracker', Icons.monitor_weight_rounded, Colors.green, () {}),
        _buildToolCard('Bump Gallery', Icons.photo_library_rounded, Colors.purple, () {}),
      ],
    );
  }

  Widget _buildToolCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}