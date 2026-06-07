import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/translated_widget.dart';
import '../constants/colors.dart';
import '../providers/user_provider.dart';
import 'dentist_history_screen.dart';
import '../services/medical_places_service.dart';
import '../models/medical_facility_model.dart';
import '../widgets/medical_search_bar.dart';
import '../widgets/medical_facility_card.dart';

class DentistScreen extends StatefulWidget {
  const DentistScreen({Key? key}) : super(key: key);

  @override
  State<DentistScreen> createState() => _DentistScreenState();
}

class _DentistScreenState extends State<DentistScreen> {
  late Future<List<MedicalFacility>> _dentistsFuture;

  @override
  void initState() {
    super.initState();
    _dentistsFuture = _fetchDentists();
  }

  Future<List<MedicalFacility>> _fetchDentists() async {
    try {
      final userProvider = context.read<UserProvider>();
      return await context.read<MedicalPlacesService>().fetchFacilities(
        queryType: 'dentist',
        lat: userProvider.latitude,
        lon: userProvider.longitude,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading dentists: $e')),
      );
      return [];
    }
  }

  void _performSearch(String query, String type) {
    setState(() {
      final userProvider = context.read<UserProvider>();
      _dentistsFuture = context.read<MedicalPlacesService>().fetchFacilities(
            queryType: 'dentist',
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
        title: const AutoTranslateText('Find a Dentist'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_edu_rounded),
            tooltip: 'History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DentistHistoryScreen()),
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
              future: _dentistsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: AutoTranslateText('No dentists found.'));
                } else {
                  final dentists = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: dentists.length,
                    itemBuilder: (context, index) {
                      return MedicalFacilityCard(
                        facility: dentists[index],
                        facilityType: 'Dentist',
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
