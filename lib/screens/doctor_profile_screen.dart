import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/doctor_profile_provider.dart';
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
        title: const Text('Doctor Profile'),
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
                  _buildProfileHeader(profile),
                  const SizedBox(height: 24),

                  // Professional Information
                  _buildSectionCard(
                    title: 'Professional Information',
                    icon: Icons.work,
                    children: [
                      _buildInfoRow('Speciality', profile.speciality),
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

  Widget _buildProfileHeader(profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: profile.profilePictureUrl != null
                  ? NetworkImage(profile.profilePictureUrl!)
                  : null,
              child: profile.profilePictureUrl == null
                  ? Icon(Icons.person, size: 60, color: AppColors.primary)
                  : null,
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
                  color: AppColors.primary.withOpacity(0.1),
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
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
            child: const Text('Cancel'),
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
                );

                await provider.updateProfile(updatedProfile);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error updating profile: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
