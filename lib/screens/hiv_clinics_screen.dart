import 'package:flutter/material.dart';
import '../widgets/translated_widget.dart';
import '../constants/colors.dart';
import '../services/addiction_recovery_service.dart';

class HIVClinicsScreen extends StatefulWidget {
  const HIVClinicsScreen({Key? key}) : super(key: key);

  @override
  State<HIVClinicsScreen> createState() => _HIVClinicsScreenState();
}

class _HIVClinicsScreenState extends State<HIVClinicsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AddictionRecoveryService _service = AddictionRecoveryService();
  
  String _searchQuery = '';
  List<Map<String, dynamic>> _clinics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClinics();
  }

  Future<void> _loadClinics() async {
    setState(() => _isLoading = true);
    // Fetch real clinics using the service
    final clinics = await _service.findCenters('HIV/STI');
    
    if (mounted) {
      setState(() {
        _clinics = clinics.map((c) => {
          'name': c['name'],
          'address': c['location'], // Mapping location to address
          'distance': c['distance'],
          'type': c['type'],
          'cost': 'Check with clinic', // Default for real data
          'phone': c['phone']
        }).toList();
        _isLoading = false;
      });
    }
  }

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

  void _callClinic(String clinicName, String? phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AutoTranslateText('Calling reception at $clinicName (${phone ?? "No number"})...'),
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
                      'Showing results near you (Real-time)',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _filteredClinics.isEmpty 
                    ? const Center(child: Text("No clinics found."))
                    : ListView.builder(
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
                                color: AppColors.accent,
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
                                onPressed: () => _callClinic(clinic['name'], clinic['phone']),
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
