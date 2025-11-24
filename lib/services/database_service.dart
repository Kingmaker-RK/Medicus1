import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/logger.dart';

class DatabaseService {
  final FirebaseFirestore _firestore;

  DatabaseService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collection reference
  CollectionReference get _usersCollection => _firestore.collection('users');

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
}
