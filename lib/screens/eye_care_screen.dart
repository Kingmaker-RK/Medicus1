import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/translated_widget.dart';
import '../constants/colors.dart';
import '../providers/user_provider.dart';
import 'eye_care_history_screen.dart';
import '../services/medical_places_service.dart';
import '../models/medical_facility_model.dart';
import '../widgets/medical_search_bar.dart';
import '../widgets/medical_facility_card.dart';

class EyeCareScreen extends StatefulWidget {
  const EyeCareScreen({Key? key}) : super(key: key);

  @override
  State<EyeCareScreen> createState() => _EyeCareScreenState();
}

class _EyeCareScreenState extends State<EyeCareScreen> {
  late Future<List<MedicalFacility>> _clinicsFuture;

  @override
  void initState() {
    super.initState();
    _clinicsFuture = _fetchClinics();
  }

  Future<List<MedicalFacility>> _fetchClinics() async {
    try {
      final userProvider = context.read<UserProvider>();
      return await context.read<MedicalPlacesService>().fetchFacilities(
        queryType: 'eye_care',
        lat: userProvider.latitude,
        lon: userProvider.longitude,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading clinics: $e')),
      );
      return [];
    }
  }

  void _performSearch(String query, String type) {
    setState(() {
      final userProvider = context.read<UserProvider>();
      _clinicsFuture = context.read<MedicalPlacesService>().fetchFacilities(
            queryType: 'eye_care',
            searchQuery: query,
            searchType: type,
            lat: userProvider.latitude,
            lon: userProvider.longitude,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const AutoTranslateText('Eye Care'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_edu_rounded),
            tooltip: 'History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EyeCareHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: MedicalSearchBar(onSearch: _performSearch),
          ),
          Expanded(
            child: FutureBuilder<List<MedicalFacility>>(
              future: _clinicsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: AutoTranslateText('No clinics found.'));
                } else {
                  final clinics = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: clinics.length,
                    itemBuilder: (context, index) {
                      return MedicalFacilityCard(
                        facility: clinics[index],
                        facilityType: 'Eye Care Specialist',
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
