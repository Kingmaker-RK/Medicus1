import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/logger.dart';

class DatabaseService {
  final FirebaseFirestore _firestore;

  DatabaseService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _patientsCollection => _firestore.collection('patients');
  CollectionReference get _doctorsCollection => _firestore.collection('doctors');

  // --- User Methods ---

  // Save user data (create or update)
  Future<void> saveUser(UserModel user) async {
    try {
      if (user.id == null) {
        throw Exception('User ID cannot be null when saving to database');
      }

      await _usersCollection.doc(user.id).set(
            user.toJson(),
            SetOptions(merge: true),
          );
      logger.d('User saved to database: ${user.id}');
    } catch (e) {
      logger.e('Error saving user to database: $e');
      throw Exception('Failed to save user data');
    }
  }

  // Get user data
  Future<UserModel?> getUser(String uid) async {
    try {
      final docSnapshot = await _usersCollection.doc(uid).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        // Ensure ID is included in the model if it's missing from the data
        if (!data.containsKey('id')) {
          data['id'] = uid;
        }
        return UserModel.fromJson(data);
      }
      return null;
    } catch (e) {
      logger.e('Error getting user from database: $e');
      throw Exception('Failed to get user data');
    }
  }

  // Update specific fields
  Future<void> updateUserField(String uid, Map<String, dynamic> data) async {
    try {
      await _usersCollection.doc(uid).update(data);
      logger.d('User field updated: $uid - $data');
    } catch (e) {
      logger.e('Error updating user field: $e');
      throw Exception('Failed to update user data');
    }
  }
  
  // Check if user exists
  Future<bool> userExists(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      return doc.exists;
    } catch (e) {
      logger.e('Error checking if user exists: $e');
      return false;
    }
  }

  // --- Patient Profile Methods ---

  Future<void> savePatientProfile(String uid, PatientProfileModel profile) async {
    try {
      await _patientsCollection.doc(uid).set(
            profile.toJson(),
            SetOptions(merge: true),
          );
      logger.d('Patient profile saved for user: $uid');
    } catch (e) {
      logger.e('Error saving patient profile: $e');
      throw Exception('Failed to save patient profile');
    }
  }

  Future<PatientProfileModel?> getPatientProfile(String uid) async {
    try {
      final docSnapshot = await _patientsCollection.doc(uid).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        return PatientProfileModel.fromJson(
            docSnapshot.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      logger.e('Error getting patient profile: $e');
      throw Exception('Failed to get patient profile');
    }
  }

  // --- Doctor Profile Methods ---

  Future<void> saveDoctorProfile(String uid, DoctorProfileModel profile) async {
    try {
      await _doctorsCollection.doc(uid).set(
            profile.toJson(),
            SetOptions(merge: true),
          );
      logger.d('Doctor profile saved for user: $uid');
    } catch (e) {
      logger.e('Error saving doctor profile: $e');
      throw Exception('Failed to save doctor profile');
    }
  }

  Future<DoctorProfileModel?> getDoctorProfile(String uid) async {
    try {
      final docSnapshot = await _doctorsCollection.doc(uid).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        return DoctorProfileModel.fromJson(
            docSnapshot.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      logger.e('Error getting doctor profile: $e');
      throw Exception('Failed to get doctor profile');
    }
  }
}
