import 'package:flutter/material.dart';
import '../widgets/translated_widget.dart';
import '../constants/colors.dart';
import 'addiction_history_screen.dart';
import '../services/addiction_recovery_service.dart';

class AddictionRecoveryCentersScreen extends StatefulWidget {
  final String addictionType;
  final AddictionRecoveryService? service;

  const AddictionRecoveryCentersScreen({
    Key? key,
    required this.addictionType,
    this.service,
  }) : super(key: key);

  @override
  State<AddictionRecoveryCentersScreen> createState() => _AddictionRecoveryCentersScreenState();
}

class _AddictionRecoveryCentersScreenState extends State<AddictionRecoveryCentersScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final AddictionRecoveryService _service;
  String searchType = 'Name';
  final List<String> searchTypes = ['Name', 'Location', 'Pincode'];

  List<Map<String, dynamic>> allCenters = [];
  List<Map<String, dynamic>> displayedCenters = [];
  bool isSearchingAI = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? AddictionRecoveryService();
    _loadCenters();
  }

  Future<void> _loadCenters() async {
    setState(() => _isLoading = true);
    final centers = await _service.findCenters(widget.addictionType);
    if (mounted) {
      setState(() {
        allCenters = centers;
        displayedCenters = List.from(allCenters);
        _isLoading = false;
      });
    }
  }

  void _filterCenters(String query) {
    setState(() {
      if (query.isEmpty) {
        displayedCenters = List.from(allCenters);
        return;
      }

      displayedCenters = allCenters.where((center) {
        String searchTerm = query.toLowerCase();
        switch (searchType) {
          case 'Name':
            return center['name'].toString().toLowerCase().contains(searchTerm);
          case 'Location':
            return center['location'].toString().toLowerCase().contains(searchTerm);
          case 'Pincode':
            return center['pincode'].toString().contains(searchTerm);
          default:
            return false;
        }
      }).toList();
    });
  }

  Future<void> _performAISearch() async {
    setState(() {
      isSearchingAI = true;
    });

    // Simulate AI processing of the REAL data
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        isSearchingAI = false;
        // AI "Sort" - prioritization based on simulated ratings/reviews
        displayedCenters.sort((a, b) {
           final ratingA = (a['rating'] as num?) ?? 0;
           final ratingB = (b['rating'] as num?) ?? 0;
           return ratingB.compareTo(ratingA);
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AutoTranslateText('AI found top-rated centers for ${widget.addictionType} recovery!'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  void _showCallDialog(Map<String, dynamic> center) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const AutoTranslateText('Contact Reception'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              center['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                SelectableText(
                  center['phone'],
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
                const SnackBar(content: AutoTranslateText('Calling...')),
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
        title: AutoTranslateText('Centers for ${widget.addictionType}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_edu_rounded),
            tooltip: 'History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddictionHistoryScreen()),
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
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by $searchType',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded),
                                  onPressed: () {
                                    _searchController.clear();
                                    _filterCenters('');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.textSecondary.withValues(alpha: 0.3),
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.background,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: _filterCenters,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: searchTypes.map((type) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Center(child: Text(type)),
                          selected: searchType == type,
                          onSelected: (selected) {
                            setState(() {
                              searchType = type;
                              if (_searchController.text.isNotEmpty) {
                                _filterCenters(_searchController.text);
                              }
                            });
                          },
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: searchType == type
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isSearchingAI || _isLoading ? null : _performAISearch,
                    icon: isSearchingAI
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.auto_awesome_rounded),
                    label: Text(isSearchingAI ? 'Asking AI...' : 'Ask AI to Find Location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : displayedCenters.isEmpty
                    ? const Center(child: AutoTranslateText('No centers found.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: displayedCenters.length,
                        itemBuilder: (context, index) {
                          return _buildCenterCard(displayedCenters[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterCard(Map<String, dynamic> center) {
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
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.spa_rounded,
                        color: Colors.green,
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
                          Text(
                            center['type'],
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (center['available'])
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Available',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    center['specialty'],
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                        center['location'],
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
                      Icons.pin_drop_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Pincode: ${center['pincode']}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.directions_rounded,
                      size: 16,
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${center['rating']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${center['reviews']} reviews)',
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
          Divider(height: 1, color: AppColors.textSecondary.withValues(alpha: 0.2)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showCallDialog(center),
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
                          content: AutoTranslateText('Booking appointment with ${center['name']}'),
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
