import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/doctor_profile_model.dart';

class DoctorProfileProvider with ChangeNotifier {
  DoctorProfileModel _profile = DoctorProfileModel();
  bool _isLoading = false;

  DoctorProfileModel get profile => _profile;
  bool get isLoading => _isLoading;

  // Initialize profile
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString('doctor_profile');

      if (profileJson != null) {
        _profile = DoctorProfileModel.fromJson(
          json.decode(profileJson) as Map<String, dynamic>,
        );
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
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('doctor_profile', json.encode(_profile.toJson()));
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('doctor_profile');
    notifyListeners();
  }
}