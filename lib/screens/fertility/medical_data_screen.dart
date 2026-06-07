import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MedicalDataScreen extends StatefulWidget {
  const MedicalDataScreen({super.key});

  @override
  State<MedicalDataScreen> createState() => _MedicalDataScreenState();
}

class _MedicalDataScreenState extends State<MedicalDataScreen> {
  final Map<String, bool> _conditions = {
    'PCOS': false,
    'Endometriosis': false,
    'Thyroid Issues': false,
    'Irregular Cycles': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Medical Data', style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w600)),
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
            Text('Health Profile', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _buildConditionsGrid(),
            const SizedBox(height: 24),
            _buildHormoneSection(),
            const SizedBox(height: 24),
            _buildTreatmentHistory(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _conditions.length,
      itemBuilder: (context, index) {
        String key = _conditions.keys.elementAt(index);
        bool value = _conditions[key]!;
        return InkWell(
          onTap: () {
            setState(() {
              _conditions[key] = !value;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: value ? const Color(0xFF2196F3) : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: value ? const Color(0xFF2196F3) : Colors.grey[300]!),
            ),
            alignment: Alignment.center,
            child: Text(
              key,
              style: GoogleFonts.poppins(
                color: value ? Colors.white : Colors.black87,
                fontWeight: value ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  Widget _buildHormoneSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hormone Tracking', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        _buildHormoneInput('AMH Level', 'ng/mL'),
        _buildHormoneInput('FSH Level', 'mIU/mL'),
        _buildHormoneInput('Progesterone', 'ng/mL'),
      ],
    );
  }

  Widget _buildHormoneInput(String label, String unit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
          ),
          SizedBox(
            width: 100,
            child: TextField(
              keyboardType: TextInputType.number,
              textAlign: TextAlign.end,
              decoration: InputDecoration(
                hintText: '0.0',
                suffixText: ' $unit',
                border: InputBorder.none,
                hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
              ),
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Previous Treatments', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.add_circle_outline, color: Color(0xFF2196F3))),
          ],
        ),
        const SizedBox(height: 12),
        _buildHistoryItem('IVF Cycle 1', 'Jan 2024', 'Failed'),
        _buildHistoryItem('IUI Treatment', 'Oct 2023', 'Failed'),
      ],
    );
  }

  Widget _buildHistoryItem(String title, String date, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF1565C0))),
              Text(date, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF1E88E5))),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(status, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}