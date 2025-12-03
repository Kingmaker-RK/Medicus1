import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/patient_profile_model.dart';
import '../models/doctor_profile_model.dart';
import '../utils/logger.dart';

class SupabaseService {
  SupabaseClient get _client => Supabase.instance.client;

  // Table names
  static const String _usersTable = 'users';
  static const String _patientsTable = 'patients';
  static const String _doctorsTable = 'doctors';

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
      // Assuming the profile has a way to link back to the user, or we use uid as primary key
      // If the profile model doesn't have the ID, we might need to add it or ensure the table uses uid as PK
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
          .eq('id', uid) // Assuming 'id' is the column for user ID in patients table
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
}
