import 'package:flutter/material.dart';
import '../widgets/translated_widget.dart';
import '../constants/colors.dart';

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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showSearchOptions = false;

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

  final List<Map<String, dynamic>> donationCenters = [
    {
      'name': 'City Blood Bank',
      'address': 'Hauptstraße 123, 10115 Berlin',
      'distance': '2.3 km',
      'bloodTypes': ['All'],
      'hours': 'Mon-Fri: 8:00 - 18:00',
      'urgentNeed': ['O-', 'AB-'],
      'phoneNumber': '+49 30 12345678',
    },
    {
      'name': 'University Hospital Blood Center',
      'address': 'Universitätsplatz 1, 10117 Berlin',
      'distance': '3.8 km',
      'bloodTypes': ['All'],
      'hours': 'Mon-Sun: 7:00 - 20:00',
      'urgentNeed': ['A-', 'B+'],
      'phoneNumber': '+49 30 87654321',
    },
    {
      'name': 'Red Cross Donation Center',
      'address': 'Wilhelmstraße 45, 10963 Berlin',
      'distance': '5.1 km',
      'bloodTypes': ['All'],
      'hours': 'Mon-Sat: 9:00 - 17:00',
      'urgentNeed': ['O+'],
      'phoneNumber': '+49 30 11223344',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        actions: [
          if (_isEligible)
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () {
                setState(() {
                  _showSearchOptions = !_showSearchOptions;
                });
              },
            ),
        ],
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
    // Filter logic can be added here based on _searchQuery
    final filteredCenters = donationCenters.where((center) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return center['name'].toString().toLowerCase().contains(q) ||
             center['address'].toString().toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        if (_showSearchOptions)
          _buildSearchSection(),
        
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nearby Donation Centers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.textSecondary.withOpacity(0.3),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedBloodType,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down_rounded),
                    items: bloodTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: AutoTranslateText('Blood Type: $type'),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedBloodType = newValue!;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: filteredCenters.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredCenters.length,
                  itemBuilder: (context, index) {
                    final center = filteredCenters[index];
                    return _buildDonationCenterCard(center);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search Hospital, Address, Pincode...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // Mock LLM Search
                setState(() {
                  _showSearchOptions = false; 
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const AutoTranslateText('AI is searching for the best locations...'),
                    backgroundColor: AppColors.primary,
                  ),
                );
                // Simulate delay then maybe show a result or just reset
                Future.delayed(const Duration(seconds: 2), () {
                   if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const AutoTranslateText('Found optimal locations based on your criteria.'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                   }
                });
              },
              icon: const Icon(Icons.auto_awesome_rounded, color: Colors.purple),
              label: const AutoTranslateText('Ask AI to Find Location'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Colors.purple),
              ),
            ),
          ),
        ],
      ),
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showSearchOptions = true;
                });
              },
              child: const AutoTranslateText('Open Search'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationCenterCard(Map<String, dynamic> center) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  color: Colors.red,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      center['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          center['distance'],
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            center['address'],
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time_rounded,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                center['hours'],
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (center['urgentNeed'].isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Urgent need: ${center['urgentNeed'].join(', ')}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                     showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const AutoTranslateText('Call Donation Center'),
                          content: Text('Phone: ${center['phoneNumber']}'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const AutoTranslateText('Close'),
                            ),
                            FilledButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Calling ${center['phoneNumber']}...')),
                                );
                              },
                              child: const AutoTranslateText('Call'),
                            ),
                          ],
                        ),
                      );
                  },
                  icon: const Icon(Icons.phone_rounded, size: 18),
                  label: const AutoTranslateText('Call'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: AutoTranslateText('Booking appointment at ${center['name']}'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_today_rounded, size: 18),
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
    );
  }
}
