import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/user_profile_provider.dart';
import '../models/user_profile_model.dart';
import '../constants/colors.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<UserProfileProvider>(context);
    final profile = profileProvider.profile;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('User Profile'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Personal Info'),
            Tab(text: 'Certificates'),
            Tab(text: 'Sick Notes'),
            Tab(text: 'Reimbursements'),
            Tab(text: 'Mailbox'),
            Tab(text: 'Submit Documents'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPersonalInfoTab(profile, profileProvider),
          _buildCertificatesTab(profile),
          _buildSickNotesTab(profile, profileProvider),
          _buildReimbursementsTab(profile, profileProvider),
          _buildMailboxTab(profile, profileProvider),
          _buildSubmitDocumentsTab(profileProvider),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoTab(profile, UserProfileProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: profile.profilePicturePath.isNotEmpty
                      ? FileImage(File(profile.profilePicturePath))
                      : null,
                  child: profile.profilePicturePath.isEmpty
                      ? Icon(LucideIcons.user,
                          size: 50, color: AppColors.primary)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _showImagePickerOptions(provider),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.camera,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionCard(
            title: 'Personal Information',
            icon: LucideIcons.user,
            children: [
              _buildInfoRow('First Name', profile.firstName),
              const Divider(),
              _buildInfoRow('Second Name', profile.secondName),
              const Divider(),
              _buildInfoRow('Insurance Number', profile.insuranceNumber),
              const Divider(),
              _buildInfoRow('Insurance Provider', profile.insuranceProvider),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCertificatesTab(profile) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: profile.certificates.length,
      itemBuilder: (context, index) {
        final cert = profile.certificates[index];
        return _buildCertificateCard(cert);
      },
    );
  }

  Widget _buildCertificateCard(cert) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(LucideIcons.fileText, color: AppColors.primary),
        ),
        title: Text(
          cert.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Issue Date: ${cert.issueDate}'),
            if (cert.expiryDate.isNotEmpty)
              Text('Expiry Date: ${cert.expiryDate}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(LucideIcons.download),
          onPressed: () {
            // TODO: Implement download functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Download functionality coming soon'),
              ),
            );
          },
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildSickNotesTab(profile, UserProfileProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: profile.sickNotes.length,
      itemBuilder: (context, index) {
        final note = profile.sickNotes[index];
        return _buildSickNoteCard(note);
      },
    );
  }

  Widget _buildSickNoteCard(note) {
    Color statusColor;
    switch (note.status.toLowerCase()) {
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(LucideIcons.stethoscope, color: statusColor),
        ),
        title: Text(
          note.diagnosis.isNotEmpty ? note.diagnosis : 'Sick Leave',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Period: ${note.startDate} to ${note.endDate}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    note.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildReimbursementsTab(profile, UserProfileProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: profile.reimbursements.length,
      itemBuilder: (context, index) {
        final reimbursement = profile.reimbursements[index];
        return _buildReimbursementCard(reimbursement);
      },
    );
  }

  Widget _buildReimbursementCard(reimbursement) {
    Color statusColor;
    switch (reimbursement.status.toLowerCase()) {
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(LucideIcons.banknote, color: AppColors.primary),
        ),
        title: Text(
          reimbursement.description.isNotEmpty
              ? reimbursement.description
              : 'Reimbursement',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Amount: ${reimbursement.amount}'),
            Text('Date: ${reimbursement.date}'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                reimbursement.status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildMailboxTab(profile, UserProfileProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: profile.mailbox.length,
      itemBuilder: (context, index) {
        final message = profile.mailbox[index];
        return _buildMailboxCard(message, provider);
      },
    );
  }

  Widget _buildMailboxCard(message, UserProfileProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: message.isRead
          ? Colors.white
          : AppColors.primary.withOpacity(0.05),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: message.isRead
              ? Colors.grey.withOpacity(0.2)
              : AppColors.primary.withOpacity(0.1),
          child: Icon(
            message.isRead ? LucideIcons.mailOpen : LucideIcons.mail,
            color: message.isRead ? Colors.grey : AppColors.primary,
          ),
        ),
        title: Text(
          message.subject,
          style: TextStyle(
            fontWeight: message.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('From: ${message.sender}'),
            Text('Date: ${message.date}'),
            const SizedBox(height: 4),
            Text(message.message, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
        isThreeLine: true,
        onTap: () {
          if (!message.isRead) {
            provider.markMessageAsRead(message.id);
          }
          _showMessageDialog(message);
        },
      ),
    );
  }

  Widget _buildSubmitDocumentsTab(UserProfileProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSubmitCard(
            title: 'Submit Sick Note',
            icon: LucideIcons.stethoscope,
            description: 'Upload your medical certificate for sick leave',
            onTap: () => _showSubmitSickNoteDialog(provider),
          ),
          const SizedBox(height: 12),
          _buildSubmitCard(
            title: 'Submit Reimbursement',
            icon: LucideIcons.receipt,
            description: 'Request reimbursement for medical expenses',
            onTap: () => _showSubmitReimbursementDialog(provider),
          ),
          const SizedBox(height: 12),
          _buildSubmitCard(
            title: 'Upload Certificate',
            icon: LucideIcons.upload,
            description: 'Add a new medical certificate or document',
            onTap: () => _showUploadCertificateDialog(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitCard({
    required String title,
    required IconData icon,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Icon(icon, color: AppColors.primary, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Not provided',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessageDialog(message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message.subject),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'From: ${message.sender}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Date: ${message.date}',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const Divider(height: 24),
              Text(message.message),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSubmitSickNoteDialog(UserProfileProvider provider) {
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();
    final diagnosisController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Sick Note'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: startDateController,
                decoration: const InputDecoration(
                  labelText: 'Start Date',
                  hintText: 'YYYY-MM-DD',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: endDateController,
                decoration: const InputDecoration(
                  labelText: 'End Date',
                  hintText: 'YYYY-MM-DD',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: diagnosisController,
                decoration: const InputDecoration(
                  labelText: 'Diagnosis (optional)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (startDateController.text.isNotEmpty &&
                  endDateController.text.isNotEmpty) {
                provider.submitSickNote(
                  SickNote(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    startDate: startDateController.text,
                    endDate: endDateController.text,
                    diagnosis: diagnosisController.text,
                    status: 'pending',
                  ),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sick note submitted successfully'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showSubmitReimbursementDialog(UserProfileProvider provider) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Reimbursement'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: '€0.00',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (amountController.text.isNotEmpty) {
                provider.addReimbursement(
                  Reimbursement(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    date: DateTime.now().toString().substring(0, 10),
                    amount: amountController.text,
                    description: descriptionController.text,
                    status: 'pending',
                  ),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reimbursement submitted successfully'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showUploadCertificateDialog(UserProfileProvider provider) {
    final nameController = TextEditingController();
    final issueDateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Certificate'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Certificate Name',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: issueDateController,
                decoration: const InputDecoration(
                  labelText: 'Issue Date',
                  hintText: 'YYYY-MM-DD',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  issueDateController.text.isNotEmpty) {
                provider.addCertificate(
                  Certificate(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    issueDate: issueDateController.text,
                  ),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Certificate uploaded successfully'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(
    UserProfileProvider provider,
    ImageSource source,
  ) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        await provider.updateProfilePicture(pickedFile.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _showImagePickerOptions(UserProfileProvider provider) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(LucideIcons.camera),
                  title: const Text('Take a photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(provider, ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(LucideIcons.image),
                  title: const Text('Choose from gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(provider, ImageSource.gallery);
                  },
                ),
                if (provider.profile.profilePicturePath.isNotEmpty)
                  ListTile(
                    leading: const Icon(LucideIcons.trash2, color: Colors.red),
                    title: const Text(
                      'Remove photo',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      provider.updateProfilePicture('');
                    },
                  ),
              ],
            ),
          ),
    );
  }
}
