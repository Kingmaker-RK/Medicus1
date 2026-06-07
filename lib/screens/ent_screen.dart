import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/translated_widget.dart';
import '../constants/colors.dart';
import '../providers/user_provider.dart';
import 'ent_history_screen.dart';
import '../services/medical_places_service.dart';
import '../models/medical_facility_model.dart';
import '../widgets/medical_search_bar.dart';
import '../widgets/medical_facility_card.dart';

class ENTScreen extends StatefulWidget {
  const ENTScreen({Key? key}) : super(key: key);

  @override
  State<ENTScreen> createState() => _ENTScreenState();
}

class _ENTScreenState extends State<ENTScreen> {
  late Future<List<MedicalFacility>> _entsFuture;

  @override
  void initState() {
    super.initState();
    _entsFuture = _fetchENTs();
  }

  Future<List<MedicalFacility>> _fetchENTs() async {
    try {
      final userProvider = context.read<UserProvider>();
      return await context.read<MedicalPlacesService>().fetchFacilities(
        queryType: 'ent',
        lat: userProvider.latitude,
        lon: userProvider.longitude,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading ENT specialists: $e')),
      );
      return [];
    }
  }

  void _performSearch(String query, String type) {
    setState(() {
      final userProvider = context.read<UserProvider>();
      _entsFuture = context.read<MedicalPlacesService>().fetchFacilities(
            queryType: 'ent',
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
        title: const AutoTranslateText('Find an ENT Specialist'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_edu_rounded),
            tooltip: 'History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ENTHistoryScreen()),
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
              future: _entsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: AutoTranslateText('No ENT specialists found.'));
                } else {
                  final ents = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: ents.length,
                    itemBuilder: (context, index) {
                      return MedicalFacilityCard(
                        facility: ents[index],
                        facilityType: 'ENT Specialist',
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
