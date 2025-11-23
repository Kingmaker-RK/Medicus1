import 'package:flutter/material.dart';

class FertilityTrackingScreen extends StatefulWidget {
  const FertilityTrackingScreen({super.key});

  @override
  State<FertilityTrackingScreen> createState() => _FertilityTrackingScreenState();
}

class _FertilityTrackingScreenState extends State<FertilityTrackingScreen> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _bbtController = TextEditingController();
  String? _selectedLHResult;
  String? _selectedCervicalMucus;
  final List<String> _selectedSymptoms = [];

  final List<String> _symptomsList = [
    'Cramps', 'Headache', 'Bloating', 'Mood Swings', 'Fatigue', 'Acne', 'Backache'
  ];

  @override
  void dispose() {
    _bbtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fertility Tracking'),
        backgroundColor: Colors.pink.shade50,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCalendarSection(),
            const SizedBox(height: 24),
            _buildCyclePredictionCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Daily Logs'),
            _buildBBTInput(),
            _buildLHTestInput(),
            _buildCervicalMucusInput(),
            const SizedBox(height: 16),
            _buildSymptomsSection(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveDailyLog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Daily Log', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Select Date', style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null && picked != _selectedDate) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                  child: Text(
                    "${_selectedDate.toLocal()}".split(' ')[0],
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCyclePredictionCard() {
    // Mock logic for prediction
    return Card(
      color: Colors.pink.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Cycle Prediction',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.pink),
            ),
            const SizedBox(height: 8),
            const Text('Next Period Expected: Nov 28'),
            const SizedBox(height: 4),
            const Text('Fertile Window: Nov 12 - Nov 16'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 0.7,
              backgroundColor: Colors.white,
              color: Colors.pink.shade300,
            ),
            const SizedBox(height: 4),
            const Text('Day 21 of Cycle', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildBBTInput() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: const Text('Basal Body Temperature (BBT)'),
        trailing: SizedBox(
          width: 100,
          child: TextField(
            controller: _bbtController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              suffixText: '°C',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLHTestInput() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('LH Test Result'),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Positive'),
                    value: 'Positive',
                    groupValue: _selectedLHResult,
                    onChanged: (value) => setState(() => _selectedLHResult = value),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Negative'),
                    value: 'Negative',
                    groupValue: _selectedLHResult,
                    onChanged: (value) => setState(() => _selectedLHResult = value),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCervicalMucusInput() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cervical Mucus'),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedCervicalMucus,
              hint: const Text('Select Observation'),
              items: ['Dry', 'Sticky', 'Creamy', 'Watery', 'Egg White']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedCervicalMucus = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Symptoms'),
        Wrap(
          spacing: 8.0,
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
              selectedColor: Colors.pink.shade100,
            );
          }).toList(),
        ),
      ],
    );
  }

  void _saveDailyLog() {
    // Mock save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Daily log saved successfully!')),
    );
  }
}