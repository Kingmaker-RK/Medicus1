import 'package:flutter/material.dart';
import '../widgets/translated_widget.dart';
import '../constants/colors.dart';
import 'ent_history_screen.dart';

class ENTScreen extends StatefulWidget {
  const ENTScreen({Key? key}) : super(key: key);

  @override
  State<ENTScreen> createState() => _ENTScreenState();
}

class _ENTScreenState extends State<ENTScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchType = 'Name';
  final List<String> searchTypes = ['Name', 'Location', 'Pincode'];

  final List<Map<String, dynamic>> allENTs = [
    {
      'name': 'Berlin ENT Specialist',
      'doctor': 'Dr. Hans Fischer',
      'specialty': 'Otolaryngology',
      'location': 'Mitte, Berlin',
      'pincode': '10115',
      'rating': 4.9,
      'reviews': 210,
      'distance': '1.0 km',
      'available': true,
      'phone': '+49 30 11112222',
    },
    {
      'name': 'Hearing & Balance Center',
      'doctor': 'Dr. Clara Meyer',
      'specialty': 'Audiology',
      'location': 'Kreuzberg, Berlin',
      'pincode': '10969',
      'rating': 4.7,
      'reviews': 145,
      'distance': '3.2 km',
      'available': true,
      'phone': '+49 30 33334444',
    },
    {
      'name': 'Nose & Sinus Clinic',
      'doctor': 'Dr. Markus Wagner',
      'specialty': 'Rhinology',
      'location': 'Charlottenburg, Berlin',
      'pincode': '10623',
      'rating': 4.8,
      'reviews': 180,
      'distance': '4.5 km',
      'available': false,
      'phone': '+49 30 55556666',
    },
  ];

  List<Map<String, dynamic>> displayedENTs = [];
  bool isSearchingAI = false;

  @override
  void initState() {
    super.initState();
    displayedENTs = List.from(allENTs);
  }

  void _filterENTs(String query) {
    setState(() {
      if (query.isEmpty) {
        displayedENTs = List.from(allENTs);
        return;
      }

      displayedENTs = allENTs.where((ent) {
        String searchTerm = query.toLowerCase();
        switch (searchType) {
          case 'Name':
            return ent['name'].toLowerCase().contains(searchTerm) ||
                ent['doctor'].toLowerCase().contains(searchTerm);
          case 'Location':
            return ent['location'].toLowerCase().contains(searchTerm);
          case 'Pincode':
            return ent['pincode'].contains(searchTerm);
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

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        isSearchingAI = false;
        displayedENTs.sort((a, b) => b['rating'].compareTo(a['rating']));
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const AutoTranslateText('AI found top-rated ENT specialists near you!'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  void _showCallDialog(Map<String, dynamic> ent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const AutoTranslateText('Contact Reception'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ent['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                SelectableText(
                  ent['phone'],
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
                                    _filterENTs('');
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
                        onChanged: _filterENTs,
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
                                _filterENTs(_searchController.text);
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
                    onPressed: isSearchingAI ? null : _performAISearch,
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
            child: displayedENTs.isEmpty
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

  Widget _buildENTCard(Map<String, dynamic> ent) {
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
                        color: Colors.blue.withValues(alpha: 0.1),
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
                            ent['name'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ent['doctor'],
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (ent['available'])
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
                    ent['specialty'],
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
                        ent['location'],
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
                      'Pincode: ${ent['pincode']}',
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
                      ent['distance'],
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
                      '${ent['rating']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${ent['reviews']} reviews)',
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
                          content: AutoTranslateText('Booking appointment with ${ent['doctor']}'),
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
