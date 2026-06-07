import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewbornChildCareScreen extends StatefulWidget {
  const NewbornChildCareScreen({super.key});

  @override
  State<NewbornChildCareScreen> createState() => _NewbornChildCareScreenState();
}

class _NewbornChildCareScreenState extends State<NewbornChildCareScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Baby Care', style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4CAF50),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4CAF50),
          tabs: const [
            Tab(text: 'Feeding'),
            Tab(text: 'Sleep'),
            Tab(text: 'Growth'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeedingTab(),
          _buildSleepTab(),
          _buildGrowthTab(),
        ],
      ),
    );
  }

  Widget _buildFeedingTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildTimerCard('Last fed: 2h ago', Colors.green),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildActionButton('Left Breast', Icons.arrow_back_ios)),
              const SizedBox(width: 16),
              Expanded(child: _buildActionButton('Bottle', Icons.local_drink)),
              const SizedBox(width: 16),
              Expanded(child: _buildActionButton('Right Breast', Icons.arrow_forward_ios)),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(child: _buildLogList(['10:00 AM - Right Breast (15m)', '07:30 AM - Left Breast (20m)'])),
        ],
      ),
    );
  }

  Widget _buildSleepTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildTimerCard('Sleeping for: 45m', Colors.indigo),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.bedtime),
              label: const Text('Start Sleep Timer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildGrowthInput('Weight', 'kg', Colors.teal),
          _buildGrowthInput('Height', 'cm', Colors.teal),
          _buildGrowthInput('Head Circ.', 'cm', Colors.teal),
          const SizedBox(height: 24),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            alignment: Alignment.center,
            child: const Text('Growth Chart Placeholder'),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCard(String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer, size: 40, color: color),
          const SizedBox(height: 12),
          Text(text, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.green.shade50,
          child: Icon(icon, color: Colors.green),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.poppins(fontSize: 12), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildGrowthInput(String label, String unit, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          Text(unit, style: GoogleFonts.poppins(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildLogList(List<String> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.history, size: 18),
          title: Text(items[index], style: GoogleFonts.poppins(fontSize: 14)),
        );
      },
    );
  }
}