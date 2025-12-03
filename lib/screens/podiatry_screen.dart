import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/user_provider.dart';
import '../models/podiatry_record_model.dart';
import '../widgets/translated_widget.dart';
import '../widgets/upload_selector.dart';
import '../services/medical_places_service.dart';
import '../models/medical_facility_model.dart';
import '../widgets/medical_search_bar.dart';
import '../widgets/medical_facility_card.dart';

class PodiatryScreen extends StatefulWidget {
  const PodiatryScreen({Key? key}) : super(key: key);

  @override
  State<PodiatryScreen> createState() => _PodiatryScreenState();
}

class _PodiatryScreenState extends State<PodiatryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<PodiatryRecord> _records = [];
  late Future<List<MedicalFacility>> _centersFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _centersFuture = _fetchCenters();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<MedicalFacility>> _fetchCenters() async {
    try {
      final userProvider = context.read<UserProvider>();
      return await context.read<MedicalPlacesService>().fetchFacilities(
        queryType: 'podiatry',
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
            queryType: 'podiatry',
            searchQuery: query,
            searchType: type,
            lat: userProvider.latitude,
            lon: userProvider.longitude,
          );
    });
  }

  // Report Methods
  Future<void> _uploadReport() async {
    final filePath = await UploadSelector.pick(context);
    if (filePath == null) return;

    setState(() {
      final now = DateTime.now();
      _records.insert(
        0,
        PodiatryRecord(
          id: now.millisecondsSinceEpoch.toString(),
          fileName: 'Foot_Report_${DateFormat('MM_dd').format(now)}',
          timestamp: now,
          filePath: filePath,
        ),
      );
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: AutoTranslateText('Report uploaded successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
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
                      facilityType: 'Podiatry',
                    );
                  },
                );
              }
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
            Icon(LucideIcons.fileX, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
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
                  color: AppColors.primary.withOpacity(0.1),
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
