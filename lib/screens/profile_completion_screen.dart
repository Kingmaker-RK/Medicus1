import 'package:flutter/material.dart';
import '../widgets/translated_widget.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_provider.dart';
import '../providers/patient_profile_provider.dart';
import '../providers/doctor_profile_provider.dart';
import '../constants/colors.dart';
import '../constants/app_constants.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({Key? key}) : super(key: key);

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();

  // Patient fields
  final _firstNameController = TextEditingController();
  final _secondNameController = TextEditingController();
  final _insuranceNumberController = TextEditingController();
  final _insuranceProviderController = TextEditingController();

  // Doctor fields
  final _doctorNameController = TextEditingController();
  final _specialityController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _clinicAddressController = TextEditingController();
  final _approbationController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _personnelNumberController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _secondNameController.dispose();
    _insuranceNumberController.dispose();
    _insuranceProviderController.dispose();
    _doctorNameController.dispose();
    _specialityController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    _clinicAddressController.dispose();
    _approbationController.dispose();
    _idNumberController.dispose();
    _personnelNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isDoctor = userProvider.currentUser?.role == AppConstants.roleDoctor;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const AutoTranslateText('Complete Your Profile'),
        automaticallyImplyLeading: false, // Prevent back navigation
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Warning banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Please complete all required fields to continue using the app',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Role indicator
              Text(
                isDoctor ? 'Doctor Profile' : 'Patient Profile',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fill in all the information below',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // Fields based on role
              if (isDoctor)
                ..._buildDoctorFields()
              else
                ..._buildPatientFields(),

              const SizedBox(height: 32),

              // Submit button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Complete Profile & Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPatientFields() {
    return [
      TextFormField(
        controller: _firstNameController,
        decoration: InputDecoration(
          labelText: 'First Name *',
          prefixIcon: const Icon(Icons.person),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) =>
            value?.isEmpty ?? true ? 'First name is required' : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _secondNameController,
        decoration: InputDecoration(
          labelText: 'Last Name *',
          prefixIcon: const Icon(Icons.person_outline),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) =>
            value?.isEmpty ?? true ? 'Last name is required' : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _insuranceNumberController,
        decoration: InputDecoration(
          labelText: 'Insurance Number *',
          prefixIcon: const Icon(Icons.badge),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) =>
            value?.isEmpty ?? true ? 'Insurance number is required' : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _insuranceProviderController,
        decoration: InputDecoration(
          labelText: 'Insurance Provider *',
          prefixIcon: const Icon(Icons.business),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) =>
            value?.isEmpty ?? true ? 'Insurance provider is required' : null,
      ),
    ];
  }

  List<Widget> _buildDoctorFields() {
    return [
      TextFormField(
        controller: _doctorNameController,
        decoration: InputDecoration(
          labelText: 'Full Name *',
          prefixIcon: const Icon(Icons.person),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) =>
            value?.isEmpty ?? true ? 'Name is required' : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _specialityController,
        decoration: InputDecoration(
          labelText: 'Speciality *',
          prefixIcon: const Icon(Icons.medical_services),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) =>
            value?.isEmpty ?? true ? 'Speciality is required' : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _qualificationController,
        decoration: InputDecoration(
          labelText: 'Highest Qualification *',
          prefixIcon: const Icon(Icons.school),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) =>
            value?.isEmpty ?? true ? 'Qualification is required' : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _experienceController,
        decoration: InputDecoration(
          labelText: 'Years of Experience *',
          prefixIcon: const Icon(Icons.work),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Experience is required';
          final years = int.tryParse(value!);
          if (years == null || years <= 0) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _clinicAddressController,
        decoration: InputDecoration(
          labelText: 'Clinic Address *',
          prefixIcon: const Icon(Icons.location_on),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        maxLines: 3,
        validator: (value) =>
            value?.isEmpty ?? true ? 'Clinic address is required' : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _approbationController,
        decoration: InputDecoration(
          labelText: 'Approbation Certificate *',
          prefixIcon: const Icon(Icons.verified),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) => value?.isEmpty ?? true
            ? 'Approbation certificate is required'
            : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _idNumberController,
        decoration: InputDecoration(
          labelText: 'ID Number *',
          prefixIcon: const Icon(Icons.fingerprint),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) =>
            value?.isEmpty ?? true ? 'ID number is required' : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _personnelNumberController,
        decoration: InputDecoration(
          labelText: 'Personnel Number *',
          prefixIcon: const Icon(Icons.badge_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) =>
            value?.isEmpty ?? true ? 'Personnel number is required' : null,
      ),
    ];
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final isDoctor =
          userProvider.currentUser?.role == AppConstants.roleDoctor;

      if (isDoctor) {
        // Save doctor profile
        final doctorProvider = Provider.of<DoctorProfileProvider>(
          context,
          listen: false,
        );
        await doctorProvider.updateProfile(
          doctorProvider.profile.copyWith(
            name: _doctorNameController.text,
            speciality: _specialityController.text,
            highestQualification: _qualificationController.text,
            yearsOfExperience: int.parse(_experienceController.text),
            clinicAddress: _clinicAddressController.text,
            approbationCertificate: _approbationController.text,
            idNumber: _idNumberController.text,
            personnelNumber: _personnelNumberController.text,
          ),
        );
      } else {
        // Save patient profile
        final userProfileProvider = Provider.of<PatientProfileProvider>(
          context,
          listen: false,
        );
        await userProfileProvider.updatePersonalInfo(
          firstName: _firstNameController.text,
          secondName: _secondNameController.text,
          insuranceNumber: _insuranceNumberController.text,
          insuranceProvider: _insuranceProviderController.text,
        );
      }

      // Mark profile as completed
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyProfileCompleted, true);

      if (mounted) {
        // Navigate to translation screen
        context.go('/translation');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AutoTranslateText('Error saving profile: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
