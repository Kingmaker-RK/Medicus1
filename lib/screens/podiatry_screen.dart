import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../models/podiatry_record_model.dart';
import '../widgets/translated_widget.dart';

class PodiatryScreen extends StatefulWidget {
  const PodiatryScreen({Key? key}) : super(key: key);

  @override
  State<PodiatryScreen> createState() => _PodiatryScreenState();
}

class _PodiatryScreenState extends State<PodiatryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final List<PodiatryRecord> _records = [];

  // Mock data for Podiatry centers
  final List<Map<String, dynamic>> _centers = [
    {
      'name': 'City Foot Care Center',
      'address': '123 Walk Ave, Downtown',
      'type': 'Clinic',
      'distance': '1.2 km',
      'phone': '+1234567890',
    },
    {
      'name': 'General Hospital - Podiatry Dept',
      'address': '456 Health Blvd, Westside',
      'type': 'Hospital',
      'distance': '3.5 km',
      'phone': '+1987654321',
    },
    {
      'name': 'Orthopedic & Podiatry Rehab',
      'address': '789 Recovery Rd, North Hills',
      'type': 'Rehabilitation Centre',
      'distance': '5.0 km',
      'phone': '+1122334455',
    },
    {
      'name': 'Advanced Diagnostic Lab',
      'address': '321 Test Ln, Eastside',
      'type': 'Diagnostic Lab',
      'distance': '2.1 km',
      'phone': '+1555666777',
    },
    {
      'name': 'Diabetic Foot Care Unit',
      'address': '654 Care Ct, Southside',
      'type': 'Intensive Care Unit',
      'distance': '8.2 km',
      'phone': '+1999888777',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredCenters {
    if (_searchQuery.isEmpty) return _centers;
    return _centers.where((center) {
      final query = _searchQuery.toLowerCase();
      return center['name'].toString().toLowerCase().contains(query) ||
             center['address'].toString().toLowerCase().contains(query) ||
             center['type'].toString().toLowerCase().contains(query);
    }).toList();
  }

  void _callCenter(String name, String phone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const AutoTranslateText('Call Reception'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Calling $name...', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(phone, style: const TextStyle(fontSize: 18, color: AppColors.primary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AutoTranslateText('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.call),
            label: const AutoTranslateText('Call Now'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
          ),
        ],
      ),
    );
  }

  void _bookAppointment(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AutoTranslateText('Booking appointment at $name...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _simulateLLMSearch() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: AutoTranslateText('Searching via AI for specialized foot care...'),
        backgroundColor: AppColors.info,
      ),
    );
    // Simulate finding a new result after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _searchQuery = ''; // Clear search to show all + new
          // Add a mock "AI found" result if not already there
          if (!_centers.any((c) => c['name'] == 'AI Suggested Podiatrist')) {
            _centers.insert(0, {
              'name': 'AI Suggested Podiatrist',
              'address': '101 Future Way, Tech City',
              'type': 'Specialist Clinic',
              'distance': '15.0 km',
              'phone': '+1000111000',
            });
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: AutoTranslateText('AI found highly recommended specialists!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  // Report Methods
  void _uploadReport() {
    setState(() {
      final now = DateTime.now();
      _records.insert(
        0,
        PodiatryRecord(
          id: now.millisecondsSinceEpoch.toString(),
          fileName: 'Foot_Report_${DateFormat('MM_dd').format(now)}',
          timestamp: now,
          filePath: '/mock/path/foot_report_${now.millisecondsSinceEpoch}.pdf',
        ),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: AutoTranslateText('Report uploaded successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _renameRecord(PodiatryRecord record, String newName) {
    setState(() {
      record.fileName = newName;
    });
  }

  void _showRenameDialog(PodiatryRecord record) {
    final TextEditingController controller = TextEditingController(text: record.fileName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const AutoTranslateText('Rename File'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'File Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AutoTranslateText('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _renameRecord(record, controller.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const AutoTranslateText('Save'),
          ),
        ],
      ),
    );
  }

  void _downloadRecord(PodiatryRecord record) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AutoTranslateText('Downloading ${record.fileName}.pdf...'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const AutoTranslateText('Podiatry'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Find Specialist', icon: Icon(LucideIcons.search)),
            Tab(text: 'My Reports', icon: Icon(LucideIcons.fileText)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFindSpecialistTab(),
          _buildReportsTab(),
        ],
      ),
    );
  }

  Widget _buildFindSpecialistTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Hospital, Clinic, Address...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(LucideIcons.sparkles, color: AppColors.primary),
                    tooltip: 'AI Search',
                    onPressed: _simulateLLMSearch,
                  ),
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
                    'Showing specialists near you',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredCenters.length,
            itemBuilder: (context, index) {
              final center = _filteredCenters[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  center['name'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    center['type'],
                                    style: const TextStyle(
                                      color: AppColors.accent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.directions_walk, size: 16, color: AppColors.textSecondary),
                                Text(
                                  center['distance'],
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
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
                              center['address'],
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
                              onPressed: () => _callCenter(center['name'], center['phone']),
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
                              onPressed: () => _bookAppointment(center['name']),
                              icon: const Icon(Icons.calendar_today),
                              label: const AutoTranslateText('Book Appointment'),
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
    );
  }

  Widget _buildReportsTab() {
    if (_records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.fileX, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const AutoTranslateText(
              'No reports uploaded yet',
              style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            const AutoTranslateText(
              'Upload your doctor visit reports here',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _uploadReport,
              icon: const Icon(Icons.upload_file),
              label: const AutoTranslateText('Upload First Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploadReport,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.upload_file),
        label: const AutoTranslateText('Upload Report'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _records.length,
        itemBuilder: (context, index) {
          final record = _records[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(LucideIcons.fileText, color: AppColors.primary),
              ),
              title: Text(
                record.fileName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                DateFormat('MMM d, yyyy - h:mm a').format(record.timestamp),
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => _showRenameDialog(record),
                    tooltip: 'Rename',
                    color: AppColors.textSecondary,
                  ),
                  IconButton(
                    icon: const Icon(Icons.download_rounded, size: 20),
                    onPressed: () => _downloadRecord(record),
                    tooltip: 'Download PDF',
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
