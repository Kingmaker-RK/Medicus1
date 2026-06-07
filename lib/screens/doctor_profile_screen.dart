import 'package:flutter/material.dart';
import '../widgets/translated_widget.dart';
import '../widgets/user_profile_avatar.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../providers/doctor_profile_provider.dart';
import '../models/doctor_profile_model.dart';
import '../constants/colors.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<DoctorProfileProvider>(context);
    final profile = profileProvider.profile;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const AutoTranslateText('Doctor Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showEditDialog(context, profileProvider);
            },
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: profileProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture and Basic Info
                  _buildProfileHeader(context, profile, profileProvider),
                  const SizedBox(height: 24),

                  // Professional Information
                  _buildSectionCard(
                    title: 'Professional Information',
                    icon: Icons.work,
                    children: [
                      _buildInfoRow('Speciality', profile.speciality),
                      const Divider(),
                      _buildInfoRow(
                        'Languages Spoken',
                        profile.languages.isNotEmpty
                            ? profile.languages.join(', ')
                            : 'Not specified',
                      ),
                      const Divider(),
                      _buildInfoRow(
                        'Highest Qualification',
                        profile.highestQualification,
                      ),
                      const Divider(),
                      _buildInfoRow(
                        'Years of Experience',
                        profile.yearsOfExperience > 0
                            ? '${profile.yearsOfExperience} years'
                            : 'Not specified',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Clinic Information
                  _buildSectionCard(
                    title: 'Clinic Information',
                    icon: Icons.local_hospital,
                    children: [
                      _buildInfoRow('Clinic Address', profile.clinicAddress),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Credentials
                  _buildSectionCard(
                    title: 'Credentials',
                    icon: Icons.verified,
                    children: [
                      _buildInfoRow(
                        'Approbation Certificate',
                        profile.approbationCertificate,
                      ),
                      const Divider(),
                      _buildInfoRow('ID Number', profile.idNumber),
                      const Divider(),
                      _buildInfoRow(
                        'Personnel Number',
                        profile.personnelNumber,
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    DoctorProfileModel profile,
    DoctorProfileProvider provider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Picture
            Stack(
              children: [
                UserProfileAvatar(
                  radius: 60,
                  onTap: () => _showProfileOptions(context, provider, profile),
                ),
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              profile.name.isNotEmpty ? profile.name : 'No Name',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Speciality Badge
            if (profile.speciality.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  profile.speciality,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showProfileOptions(
    BuildContext context,
    DoctorProfileProvider provider,
    DoctorProfileModel profile,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Profile Photo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionItem(
                  context,
                  icon: Icons.image,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(context, provider, ImageSource.gallery);
                  },
                ),
                _buildOptionItem(
                  context,
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(context, provider, ImageSource.camera);
                  },
                ),
                if (profile.profilePictureUrl != null &&
                    profile.profilePictureUrl!.isNotEmpty) ...[
                  _buildOptionItem(
                    context,
                    icon: Icons.person,
                    label: 'View',
                    onTap: () {
                      Navigator.pop(context);
                      ImageProvider? image;
                      if (profile.profilePictureUrl!.startsWith('http')) {
                        image = NetworkImage(profile.profilePictureUrl!);
                      } else {
                        image = FileImage(File(profile.profilePictureUrl!));
                      }
                      _showProfilePictureZoomDialog(context, image, provider);
                    },
                  ),
                  _buildOptionItem(
                    context,
                    icon: Icons.delete_outline,
                    label: 'Remove',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      provider.updateProfilePicture('');
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: (color ?? AppColors.textSecondary).withValues(alpha: 0.2),
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color ?? AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color ?? AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfilePictureZoomDialog(
    BuildContext context,
    ImageProvider image,
    DoctorProfileProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: InteractiveViewer(
                clipBehavior: Clip.none,
                minScale: 0.5,
                maxScale: 4.0,
                child: Image(image: image),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              label: const AutoTranslateText('Close'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(
    BuildContext context,
    DoctorProfileProvider provider,
    ImageSource source,
  ) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        await provider.updateProfilePicture(pickedFile.path);
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AutoTranslateText('Error picking image: $e')),
      );
    }
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

  void _showEditDialog(BuildContext context, DoctorProfileProvider provider) {
    final profile = provider.profile;
    final nameController = TextEditingController(text: profile.name);
    final specialityController = TextEditingController(
      text: profile.speciality,
    );
    final qualificationController = TextEditingController(
      text: profile.highestQualification,
    );
    final experienceController = TextEditingController(
      text: profile.yearsOfExperience > 0
          ? profile.yearsOfExperience.toString()
          : '',
    );
    final clinicAddressController = TextEditingController(
      text: profile.clinicAddress,
    );
    final approbationController = TextEditingController(
      text: profile.approbationCertificate,
    );
    final idNumberController = TextEditingController(text: profile.idNumber);
    final personnelNumberController = TextEditingController(
      text: profile.personnelNumber,
    );
    final languagesController = TextEditingController(
      text: profile.languages.join(', '),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const AutoTranslateText('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: specialityController,
                decoration: const InputDecoration(
                  labelText: 'Speciality',
                  prefixIcon: Icon(Icons.medical_services),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qualificationController,
                decoration: const InputDecoration(
                  labelText: 'Highest Qualification',
                  prefixIcon: Icon(Icons.school),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: experienceController,
                decoration: const InputDecoration(
                  labelText: 'Years of Experience',
                  prefixIcon: Icon(Icons.work_history),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: languagesController,
                decoration: const InputDecoration(
                  labelText: 'Languages (comma separated)',
                  prefixIcon: Icon(Icons.language),
                  hintText: 'English, German, Spanish',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: clinicAddressController,
                decoration: const InputDecoration(
                  labelText: 'Clinic Address',
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: approbationController,
                decoration: const InputDecoration(
                  labelText: 'Approbation Certificate',
                  prefixIcon: Icon(Icons.verified),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: idNumberController,
                decoration: const InputDecoration(
                  labelText: 'ID Number',
                  prefixIcon: Icon(Icons.badge),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: personnelNumberController,
                decoration: const InputDecoration(
                  labelText: 'Personnel Number',
                  prefixIcon: Icon(Icons.numbers),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AutoTranslateText('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final updatedProfile = profile.copyWith(
                  name: nameController.text,
                  speciality: specialityController.text,
                  highestQualification: qualificationController.text,
                  yearsOfExperience:
                      int.tryParse(experienceController.text) ?? 0,
                  clinicAddress: clinicAddressController.text,
                  approbationCertificate: approbationController.text,
                  idNumber: idNumberController.text,
                  personnelNumber: personnelNumberController.text,
                  languages:
                      languagesController.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList(),
                );

                await provider.updateProfile(updatedProfile);
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: AutoTranslateText('Profile updated successfully'),
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: AutoTranslateText('Error updating profile: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const AutoTranslateText('Save'),
          ),
        ],
      ),
    );
  }
}
