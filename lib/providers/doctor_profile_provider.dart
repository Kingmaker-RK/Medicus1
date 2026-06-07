import 'package:flutter/foundation.dart';
import '../models/doctor_profile_model.dart';
import '../services/database_service.dart';

class DoctorProfileProvider with ChangeNotifier {
  final DatabaseService _databaseService;

  DoctorProfileModel _profile = DoctorProfileModel();
  bool _isLoading = false;
  String? _userId;

  DoctorProfileProvider({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService();

  DoctorProfileModel get profile => _profile;
  bool get isLoading => _isLoading;

  // Update provider with current user ID
  Future<void> updateUser(String? userId) async {
    if (_userId == userId) return;

    _userId = userId;

    if (_userId != null) {
      await _loadProfile();
    } else {
      _profile = DoctorProfileModel();
      notifyListeners();
    }
  }

  // Initialize profile - Deprecated, use updateUser
  Future<void> initialize() async {
    // No-op: Initialization is handled by updateUser via ProxyProvider
  }

  Future<void> _loadProfile() async {
    if (_userId == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final profile = await _databaseService.getDoctorProfile(_userId!);
      
      if (profile != null) {
        _profile = profile;
      } else {
        _profile = DoctorProfileModel();
      }
    } catch (e) {
      print('Error loading doctor profile: $e');
      _profile = DoctorProfileModel();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save profile helper
  Future<void> _saveProfile() async {
    if (_userId == null) return;

    try {
      await _databaseService.saveDoctorProfile(_userId!, _profile);
    } catch (e) {
      print('Error saving doctor profile: $e');
    }
  }

  // Update profile
  Future<void> updateProfile(DoctorProfileModel newProfile) async {
    _isLoading = true;
    notifyListeners();

    try {
      _profile = newProfile;
      await _saveProfile();
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
  Future<void> clearProfile() async {
    _profile = DoctorProfileModel();
    // No need to remove from prefs, just memory reset.
    // To delete from DB would be a different method if needed.
    notifyListeners();
  }
}