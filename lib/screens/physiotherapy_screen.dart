import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/translated_widget.dart';
import '../constants/colors.dart';
import '../providers/user_provider.dart';
import 'physiotherapy_history_screen.dart';
import '../services/medical_places_service.dart';
import '../models/medical_facility_model.dart';
import '../widgets/medical_search_bar.dart';
import '../widgets/medical_facility_card.dart';

class PhysiotherapyScreen extends StatefulWidget {
  const PhysiotherapyScreen({Key? key}) : super(key: key);

  @override
  State<PhysiotherapyScreen> createState() => _PhysiotherapyScreenState();
}

class _PhysiotherapyScreenState extends State<PhysiotherapyScreen> {
  late Future<List<MedicalFacility>> _centersFuture;

  @override
  void initState() {
    super.initState();
    _centersFuture = _fetchCenters();
  }

  Future<List<MedicalFacility>> _fetchCenters() async {
    try {
      final userProvider = context.read<UserProvider>();
      return await context.read<MedicalPlacesService>().fetchFacilities(
        queryType: 'physiotherapy',
        lat: userProvider.latitude,
        lon: userProvider.longitude,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading centers: $e')),
      );
      return [];
    }
  }

  void _performSearch(String query, String type) {
    setState(() {
      final userProvider = context.read<UserProvider>();
      _centersFuture = context.read<MedicalPlacesService>().fetchFacilities(
            queryType: 'physiotherapy',
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
        title: const AutoTranslateText('Find Physiotherapy'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_edu_rounded),
            tooltip: 'History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PhysiotherapyHistoryScreen()),
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
              future: _centersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: AutoTranslateText('No centers found.'));
                } else {
                  final centers = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: centers.length,
                    itemBuilder: (context, index) {
                      return MedicalFacilityCard(
                        facility: centers[index],
                        facilityType: 'Physiotherapy Center',
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
