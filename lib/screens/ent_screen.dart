import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/translated_widget.dart';
import '../constants/colors.dart';
import 'ent_history_screen.dart';
import '../services/medical_places_service.dart';
import '../models/medical_facility_model.dart';
import '../widgets/medical_search_bar.dart';

class ENTScreen extends StatefulWidget {
  const ENTScreen({Key? key}) : super(key: key);

  @override
  State<ENTScreen> createState() => _ENTScreenState();
}

class _ENTScreenState extends State<ENTScreen> {
  List<MedicalFacility> displayedENTs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchENTs();
  }

  Future<void> _fetchENTs() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final ents = await context.read<MedicalPlacesService>().fetchFacilities(queryType: 'ent');
      if (mounted) {
        setState(() {
          displayedENTs = ents;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading ENT specialists: $e')),
        );
      }
    }
  }

  Future<void> _performSearch(String query, String type) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final ents = await context.read<MedicalPlacesService>().fetchFacilities(
            queryType: 'ent',
            searchQuery: query,
            searchType: type,
          );
      if (mounted) {
        setState(() {
          displayedENTs = ents;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching ENT specialists: $e')),
        );
      }
    }
  }

  void _showCallDialog(MedicalFacility ent) {
    if (ent.phone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AutoTranslateText('Phone number not available')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const AutoTranslateText('Contact Reception'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ent.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                SelectableText(
                  ent.phone!,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AutoTranslateText('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: AutoTranslateText('Calling ${ent.phone}...')),
              );
            },
            icon: const Icon(Icons.call),
            label: const AutoTranslateText('Call Now'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayedENTs.isEmpty
                    ? const Center(child: AutoTranslateText('No ENT specialists found.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: displayedENTs.length,
                        itemBuilder: (context, index) {
                          return _buildENTCard(displayedENTs[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildENTCard(MedicalFacility ent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.hearing_rounded,
                        color: Colors.blue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ent.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ENT Specialist',
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        ent.address,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.directions_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${ent.distance.toStringAsFixed(1)} km',
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
          Divider(height: 1, color: AppColors.textSecondary.withOpacity(0.2)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showCallDialog(ent),
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
                          content: AutoTranslateText('Booking appointment with ${ent.name}'),
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
          ),
        ],
      ),
    );
  }
}
