import 'package:flutter/foundation.dart';
import '../models/doctor_profile_model.dart';

class DoctorProfileProvider with ChangeNotifier {
  DoctorProfileModel _profile = DoctorProfileModel();
  bool _isLoading = false;

  DoctorProfileModel get profile => _profile;
  bool get isLoading => _isLoading;

  // Initialize with demo data
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Load from backend/Firebase
      await Future.delayed(const Duration(milliseconds: 500));

      // Demo data for testing
      _profile = DoctorProfileModel(
        name: 'Dr. Hans Müller',
        speciality: 'Cardiology',
        highestQualification: 'MD, PhD in Cardiovascular Medicine',
        yearsOfExperience: 15,
        clinicAddress:
            'Universitätsklinikum Hamburg-Eppendorf\nMartinistraße 52\n20251 Hamburg, Germany',
        approbationCertificate: 'DE-HH-2008-12345',
        idNumber: 'ID-987654321',
        personnelNumber: 'PN-2008-0042',
        profilePictureUrl: null, // Will use default avatar
      );
    } catch (e) {
      print('Error loading doctor profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update profile
  Future<void> updateProfile(DoctorProfileModel newProfile) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Save to backend/Firebase
      await Future.delayed(const Duration(milliseconds: 500));
      _profile = newProfile;
    } catch (e) {
      print('Error updating doctor profile: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update specific fields
  Future<void> updateName(String name) async {
    await updateProfile(_profile.copyWith(name: name));
  }

  Future<void> updateSpeciality(String speciality) async {
    await updateProfile(_profile.copyWith(speciality: speciality));
  }

  Future<void> updateQualification(String qualification) async {
    await updateProfile(_profile.copyWith(highestQualification: qualification));
  }

  Future<void> updateExperience(int years) async {
    await updateProfile(_profile.copyWith(yearsOfExperience: years));
  }

  Future<void> updateClinicAddress(String address) async {
    await updateProfile(_profile.copyWith(clinicAddress: address));
  }

  Future<void> updateProfilePicture(String url) async {
    await updateProfile(_profile.copyWith(profilePictureUrl: url));
  }

  // Clear profile data
  void clearProfile() {
    _profile = DoctorProfileModel();
    notifyListeners();
  }
}
