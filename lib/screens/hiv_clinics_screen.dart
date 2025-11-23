import 'package:flutter/material.dart';
import '../widgets/translated_widget.dart';
import '../constants/colors.dart';

class HIVClinicsScreen extends StatefulWidget {
  const HIVClinicsScreen({Key? key}) : super(key: key);

  @override
  State<HIVClinicsScreen> createState() => _HIVClinicsScreenState();
}

class _HIVClinicsScreenState extends State<HIVClinicsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Mock data for clinics
  final List<Map<String, dynamic>> _clinics = [
    {
      'name': 'City Health Clinic (Free)',
      'address': '123 Main St, Downtown',
      'distance': '0.8 km',
      'type': 'Public',
      'cost': 'Free',
    },
    {
      'name': 'Community Care Center',
      'address': '456 Oak Ave, Westside',
      'distance': '2.5 km',
      'type': 'Non-profit',
      'cost': 'Low-cost',
    },
    {
      'name': 'Global Health STI Center',
      'address': '789 Pine Rd, North Hills',
      'distance': '5.2 km',
      'type': 'Private',
      'cost': 'Insurance/Paid',
    },
    {
      'name': 'Youth Outreach Clinic',
      'address': '321 Elm St, University District',
      'distance': '12.0 km',
      'type': 'Non-profit',
      'cost': 'Free for <25',
    },
  ];

  List<Map<String, dynamic>> get _filteredClinics {
    if (_searchQuery.isEmpty) return _clinics;
    return _clinics.where((clinic) {
      final query = _searchQuery.toLowerCase();
      return clinic['name'].toString().toLowerCase().contains(query) ||
             clinic['address'].toString().toLowerCase().contains(query);
    }).toList();
  }

  void _bookAppointment(String clinicName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AutoTranslateText('Booking appointment at $clinicName...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _callClinic(String clinicName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AutoTranslateText('Calling reception at $clinicName...'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const AutoTranslateText('HIV/STI Clinics'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by Name, Address, Pincode...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(Icons.location_on, size: 16, color: AppColors.primary),
                    SizedBox(width: 4),
                    AutoTranslateText(
                      'Showing results near you',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredClinics.length,
              itemBuilder: (context, index) {
                final clinic = _filteredClinics[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                clinic['name'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: clinic['cost'] == 'Free' ? AppColors.success : AppColors.accent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                clinic['cost'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${clinic['address']} (${clinic['distance']})',
                                style: const TextStyle(color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _callClinic(clinic['name']),
                                icon: const Icon(Icons.phone),
                                label: const AutoTranslateText('Call'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.success,
                                  side: const BorderSide(color: AppColors.success),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _bookAppointment(clinic['name']),
                                icon: const Icon(Icons.calendar_today),
                                label: const AutoTranslateText('Book'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
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
    );
  }
}
