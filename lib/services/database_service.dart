import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/patient_profile_model.dart';
import '../models/doctor_profile_model.dart';
import '../utils/logger.dart';

class DatabaseService {
  SupabaseClient get _client => Supabase.instance.client;

  // Table names
  static const String _usersTable = 'users';
  static const String _patientsTable = 'patients';
  static const String _doctorsTable = 'doctors';
  
  // Storage buckets
  static const String _profileBucket = 'profiles';
  static const String _documentsBucket = 'documents';

  // Constructor - keeping signature compatible but ignoring Firestore
  DatabaseService({dynamic firestore});

  // --- User Methods ---

  /// Save or update user data
  Future<void> saveUser(UserModel user) async {
    try {
      if (user.id == null) {
        throw Exception('User ID cannot be null when saving to database');
      }

      await _client.from(_usersTable).upsert(user.toJson());
      logger.d('User saved to Supabase: ${user.id}');
    } catch (e) {
      logger.e('Error saving user to Supabase: $e');
      throw Exception('Failed to save user data to Supabase');
    }
  }

  /// Get user data by ID
  Future<UserModel?> getUser(String uid) async {
    try {
      final response = await _client
          .from(_usersTable)
          .select()
          .eq('id', uid)
          .maybeSingle();

      if (response != null) {
        return UserModel.fromJson(response);
      }
      return null;
    } catch (e) {
      logger.e('Error getting user from Supabase: $e');
      throw Exception('Failed to get user data from Supabase');
    }
  }

  /// Update specific fields for a user
  Future<void> updateUserField(String uid, Map<String, dynamic> data) async {
    try {
      await _client.from(_usersTable).update(data).eq('id', uid);
      logger.d('User field updated in Supabase: $uid - $data');
    } catch (e) {
      logger.e('Error updating user field in Supabase: $e');
      throw Exception('Failed to update user data in Supabase');
    }
  }
  
  /// Check if user exists
  Future<bool> userExists(String uid) async {
    try {
      final response = await _client
          .from(_usersTable)
          .select('id')
          .eq('id', uid)
          .maybeSingle();
      return response != null;
    } catch (e) {
      logger.e('Error checking if user exists in Supabase: $e');
      return false;
    }
  }

  // --- Patient Profile Methods ---

  Future<void> savePatientProfile(String uid, PatientProfileModel profile) async {
    try {
      final data = profile.toJson();
      if (!data.containsKey('id')) {
        data['id'] = uid;
      }
      
      await _client.from(_patientsTable).upsert(data);
      logger.d('Patient profile saved to Supabase for user: $uid');
    } catch (e) {
      logger.e('Error saving patient profile to Supabase: $e');
      throw Exception('Failed to save patient profile to Supabase');
    }
  }

  Future<PatientProfileModel?> getPatientProfile(String uid) async {
    try {
      final response = await _client
          .from(_patientsTable)
          .select()
          .eq('id', uid)
          .maybeSingle();

      if (response != null) {
        return PatientProfileModel.fromJson(response);
      }
      return null;
    } catch (e) {
      logger.e('Error getting patient profile from Supabase: $e');
      throw Exception('Failed to get patient profile from Supabase');
    }
  }

  // --- Doctor Profile Methods ---

  Future<void> saveDoctorProfile(String uid, DoctorProfileModel profile) async {
    try {
      final data = profile.toJson();
      if (!data.containsKey('id')) {
        data['id'] = uid;
      }

      await _client.from(_doctorsTable).upsert(data);
      logger.d('Doctor profile saved to Supabase for user: $uid');
    } catch (e) {
      logger.e('Error saving doctor profile to Supabase: $e');
      throw Exception('Failed to save doctor profile to Supabase');
    }
  }

  Future<DoctorProfileModel?> getDoctorProfile(String uid) async {
    try {
      final response = await _client
          .from(_doctorsTable)
          .select()
          .eq('id', uid)
          .maybeSingle();

      if (response != null) {
        return DoctorProfileModel.fromJson(response);
      }
      return null;
    } catch (e) {
      logger.e('Error getting doctor profile from Supabase: $e');
      throw Exception('Failed to get doctor profile from Supabase');
    }
  }

  // --- Storage Methods ---

  Future<String> uploadProfilePicture(String userId, File file) async {
    try {
      final fileExt = file.path.split('.').last;
      final fileName = '$userId/profile_pic_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      
      await _client.storage.from(_profileBucket).upload(
        fileName,
        file,
        fileOptions: const FileOptions(upsert: true),
      );
      
      final imageUrl = _client.storage.from(_profileBucket).getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      logger.e('Error uploading profile picture: $e');
      throw Exception('Failed to upload profile picture');
    }
  }

  Future<String> uploadDocument(String userId, File file, String type) async {
    try {
      final fileExt = file.path.split('.').last;
      final fileName = '$userId/$type/${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      
      await _client.storage.from(_documentsBucket).upload(
        fileName,
        file,
        fileOptions: const FileOptions(upsert: true),
      );
      
      final docUrl = _client.storage.from(_documentsBucket).getPublicUrl(fileName);
      return docUrl;
    } catch (e) {
      logger.e('Error uploading document: $e');
      throw Exception('Failed to upload document');
    }
  }

  // --- Appointment Methods ---

  Future<void> createAppointment({
    required String userId,
    required String facilityId,
    required String facilityName,
    required String facilityType,
    required DateTime appointmentDateTime,
  }) async {
    try {
      await _client.from('appointments').insert({
        'user_id': userId,
        'facility_id': facilityId,
        'facility_name': facilityName,
        'facility_type': facilityType,
        'appointment_date': appointmentDateTime.toIso8601String(),
        'status': 'pending', // Default status
        'created_at': DateTime.now().toIso8601String(),
      });
      logger.d('Appointment created for user: $userId at $facilityName');
    } catch (e) {
      logger.e('Error creating appointment in Supabase: $e');
      throw Exception('Failed to create appointment');
    }
  }
}
