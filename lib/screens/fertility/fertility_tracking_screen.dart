import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class FertilityTrackingScreen extends StatefulWidget {
  const FertilityTrackingScreen({super.key});

  @override
  State<FertilityTrackingScreen> createState() => _FertilityTrackingScreenState();
}

class _FertilityTrackingScreenState extends State<FertilityTrackingScreen> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _bbtController = TextEditingController();
  
  // Tracking Data
  String _selectedFlow = 'Medium';
  String _selectedMood = 'Happy';
  String? _selectedLHResult;
  String? _selectedCervicalMucus;
  
  final List<String> _selectedSymptoms = [];
  final List<String> _symptomsList = [
    'Cramps', 'Headache', 'Bloating', 'Mood Swings', 'Fatigue', 'Acne', 'Backache', 'Nausea', 'Cravings'
  ];

  @override
  void dispose() {
    _bbtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Cycle & Ovulation', style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateSelector(),
              const SizedBox(height: 24),
              _buildCycleVisualizer(),
              const SizedBox(height: 24),
              Text('Daily Log', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              _buildFlowSelector(),
              const SizedBox(height: 16),
              _buildBBTCard(),
              const SizedBox(height: 16),
              _buildLHAndMucusSection(),
              const SizedBox(height: 16),
              _buildSymptomsChips(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _saveData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  child: Text('Save Log', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE4EC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18, color: Color(0xFF880E4F)),
            onPressed: () => setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1))),
          ),
          Column(
            children: [
              Text(
                DateFormat('EEEE').format(_selectedDate),
                style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF880E4F)),
              ),
              Text(
                DateFormat('MMM d, y').format(_selectedDate),
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF880E4F)),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFF880E4F)),
            onPressed: () => setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1))),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleVisualizer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFF8BBD0), Color(0xFFF48FB1)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.pink.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Cycle Day 12',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const SizedBox(
            height: 100,
            width: 100,
            child: CircularProgressIndicator(
              value: 0.4,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation(Colors.white),
              strokeWidth: 8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'High Fertility',
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            'Ovulation in 2 days',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowSelector() {
    final flows = ['Light', 'Medium', 'Heavy', 'Spotting'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Menstrual Flow', style: GoogleFonts.poppins(color: Colors.grey[700])),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: flows.map((flow) {
            final isSelected = _selectedFlow == flow;
            return GestureDetector(
              onTap: () => setState(() => _selectedFlow = flow),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE91E63) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected ? null : Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  flow,
                  style: GoogleFonts.poppins(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBBTCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle),
            child: const Icon(Icons.thermostat_rounded, color: Colors.orange),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Basal Body Temp', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                Text('Track first thing in AM', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            child: TextField(
              controller: _bbtController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '36.5',
                suffixText: '°C',
                border: InputBorder.none,
              ),
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLHAndMucusSection() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdownCard(
            title: 'LH Test',
            value: _selectedLHResult,
            items: ['Positive', 'Negative', 'Peak'],
            onChanged: (val) => setState(() => _selectedLHResult = val),
            icon: Icons.science_outlined,
            color: Colors.purple,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDropdownCard(
            title: 'Cervical Mucus',
            value: _selectedCervicalMucus,
            items: ['Dry', 'Sticky', 'Creamy', 'Egg White'],
            onChanged: (val) => setState(() => _selectedCervicalMucus = val),
            icon: Icons.water_drop_outlined,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownCard({
    required String title,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(title, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 4),
          DropdownButton<String>(
            isExpanded: true,
            value: value,
            hint: Text('Select', style: GoogleFonts.poppins(fontSize: 12)),
            underline: Container(),
            icon: const Icon(Icons.keyboard_arrow_down, size: 18),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Symptoms', style: GoogleFonts.poppins(color: Colors.grey[700])),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _symptomsList.map((symptom) {
            final isSelected = _selectedSymptoms.contains(symptom);
            return FilterChip(
              label: Text(symptom),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedSymptoms.add(symptom);
                  } else {
                    _selectedSymptoms.remove(symptom);
                  }
                });
              },
              backgroundColor: Colors.grey[100],
              selectedColor: const Color(0xFFF8BBD0),
              labelStyle: GoogleFonts.poppins(
                color: isSelected ? const Color(0xFF880E4F) : Colors.black87,
                fontSize: 12,
              ),
              checkmarkColor: const Color(0xFF880E4F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.transparent)),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _saveData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Daily log saved for ${DateFormat('MMM d').format(_selectedDate)}', style: GoogleFonts.poppins()),
        backgroundColor: Colors.green,
      ),
    );
  }
}
