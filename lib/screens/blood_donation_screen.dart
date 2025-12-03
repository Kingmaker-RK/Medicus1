import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/translated_widget.dart';
import '../constants/colors.dart';
import '../providers/user_provider.dart';
import '../services/medical_places_service.dart';
import '../models/medical_facility_model.dart';
import '../widgets/medical_search_bar.dart';
import '../widgets/medical_facility_card.dart';

class BloodDonationScreen extends StatefulWidget {
  const BloodDonationScreen({Key? key}) : super(key: key);

  @override
  State<BloodDonationScreen> createState() => _BloodDonationScreenState();
}

class _BloodDonationScreenState extends State<BloodDonationScreen> {
  // State for Eligibility
  bool _isEligible = false;
  final Set<int> _checkedItems = {};
  
  // State for Search
  bool _isLoading = true;

  String selectedBloodType = 'All';
  final List<String> bloodTypes = ['All', 'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  final List<String> eligibilityCriteria = [
    'Age between 18-65 years',
    'Weight at least 50kg',
    'In good health (no cold, flu, etc.)',
    'Not donated in the last 8 weeks',
    'No recent tattoos or piercings (last 4 months)',
    'No recent travel to high-risk malaria areas',
  ];

  List<MedicalFacility> donationCenters = [];

  @override
  void initState() {
    super.initState();
    _fetchDonationCenters();
  }

  Future<void> _fetchDonationCenters() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userProvider = context.read<UserProvider>();
      final centers = await context.read<MedicalPlacesService>().fetchFacilities(
        queryType: 'blood_donation',
        lat: userProvider.latitude,
        lon: userProvider.longitude,
      );
      if (mounted) {
        setState(() {
          donationCenters = centers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print('Error loading donation centers: $e');
      }
    }
  }

  Future<void> _performSearch(String query, String type) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userProvider = context.read<UserProvider>();
      final centers = await context.read<MedicalPlacesService>().fetchFacilities(
            queryType: 'blood_donation',
            searchQuery: query,
            searchType: type,
            lat: userProvider.latitude,
            lon: userProvider.longitude,
          );
      if (mounted) {
        setState(() {
          donationCenters = centers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching donation centers: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const AutoTranslateText('Blood Donation'),
        centerTitle: true,
      ),
      body: _isEligible ? _buildMainContent() : _buildEligibilityView(),
    );
  }

  Widget _buildEligibilityView() {
    final bool allChecked = _checkedItems.length == eligibilityCriteria.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.health_and_safety_rounded, color: Colors.red, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Eligibility Check',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Please confirm the following to proceed to find donation centers.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(eligibilityCriteria.length, (index) {
            final isChecked = _checkedItems.contains(index);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                elevation: 1,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (isChecked) {
                        _checkedItems.remove(index);
                      } else {
                        _checkedItems.add(index);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(
                          isChecked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                          color: isChecked ? AppColors.primary : AppColors.textSecondary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            eligibilityCriteria[index],
                            style: TextStyle(
                              fontSize: 15,
                              color: isChecked ? AppColors.textPrimary : AppColors.textSecondary,
                              fontWeight: isChecked ? FontWeight.w500 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: allChecked
                  ? () {
                      setState(() {
                        _isEligible = true;
                      });
                      if (donationCenters.isEmpty && !_isLoading) {
                         _fetchDonationCenters();
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const AutoTranslateText('Eligibility confirmed! Finding nearby centers...'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const AutoTranslateText('Find Donation Centers'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: MedicalSearchBar(onSearch: _performSearch),
        ),
        Expanded(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : donationCenters.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: donationCenters.length,
                  itemBuilder: (context, index) {
                    final center = donationCenters[index];
                    return MedicalFacilityCard(
                      facility: center,
                      facilityType: 'Donation Center',
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off_rounded, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'No centers found nearby',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching manually or use the AI search helper.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
