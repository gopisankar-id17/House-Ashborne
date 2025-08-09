import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'session_service.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final SessionService _sessionService = SessionService();

  // Get current user's profile data using SessionService
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userId = await _sessionService.getUserSession();
      if (userId == null) {
        print('Error: No active user session found');
        return null;
      }

      print('Getting profile for user ID: $userId');
      final docSnapshot = await _firestore.collection('users').doc(userId).get();
      
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        print('Profile data retrieved: $data');
        return data;
      } else {
        print('User document does not exist for ID: $userId');
        return null;
      }
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Get current user's profile data as a stream
  Stream<DocumentSnapshot> getUserProfileStream() {
    return Stream.fromFuture(_sessionService.getUserSession()).asyncExpand((userId) {
      if (userId == null) {
        // Return a stream that emits a fake empty document snapshot
        return Stream.empty();
      }
      
      return _firestore.collection('users').doc(userId).snapshots();
    });
  }

  // Check if user is authenticated using SessionService
  Future<bool> isUserAuthenticatedAsync() async {
    try {
      final userId = await _sessionService.getUserSession();
      return userId != null;
    } catch (e) {
      print('Error checking authentication: $e');
      return false;
    }
  }

  // Update user profile with local image storage
  Future<Map<String, dynamic>> updateUserProfile({
    String? name,
    String? email,
    String? phone,
    File? profileImage,
  }) async {
    try {
      final userId = await _sessionService.getUserSession();
      if (userId == null) {
        print('Error: No active user session found');
        return {'success': false, 'imageUploaded': false, 'error': 'No active user session'};
      }

      print('Updating profile for user ID: $userId');
      Map<String, dynamic> updateData = {};

      // Update basic info fields if provided
      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;
      if (phone != null) updateData['phone'] = phone;

      // Handle profile image - store local path for immediate display
      bool imageUploadSuccess = true;
      String? imageUploadError;
      
      if (profileImage != null) {
        try {
          print('🔄 Processing profile image...');
          print('📂 File path: ${profileImage.path}');
          
          // Check if file exists
          if (await profileImage.exists()) {
            // Store the local file path so image shows immediately
            updateData['profileImagePath'] = profileImage.path;
            print('📱 Stored local image path: ${profileImage.path}');
          } else {
            throw Exception('Selected image file does not exist');
          }
          
        } catch (e) {
          print('❌ Error processing profile image: $e');
          imageUploadSuccess = false;
          imageUploadError = e.toString();
        }
      }

      updateData['updatedAt'] = FieldValue.serverTimestamp();

      // Update Firestore document
      final docRef = _firestore.collection('users').doc(userId);
      final docSnapshot = await docRef.get();
      
      if (docSnapshot.exists) {
        await docRef.update(updateData);
        print('Profile updated successfully');
      } else {
        await docRef.set(updateData, SetOptions(merge: true));
        print('Profile created successfully');
      }

      return {
        'success': true, 
        'imageUploaded': imageUploadSuccess,
        'imageUploadError': imageUploadError,
      };
    } catch (e) {
      print('Error updating user profile: $e');
      return {
        'success': false, 
        'imageUploaded': false,
        'error': e.toString(),
      };
    }
  }

  // Delete profile image
  Future<bool> deleteProfileImage() async {
    try {
      final userId = await _sessionService.getUserSession();
      if (userId == null) {
        print('Error: No active user session found');
        return false;
      }

      final docRef = _firestore.collection('users').doc(userId);
      
      await docRef.update({
        'profileImageUrl': FieldValue.delete(),
        'profileImagePath': FieldValue.delete(),
      });
      
      print('Profile image references removed');
      return true;
    } catch (e) {
      print('Error deleting profile image: $e');
      return false;
    }
  }

  // Create user profile when account is created
  Future<void> createUserProfile({
    required String userId,
    required String name,
    required String email,
    String? phone,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print('User profile created successfully');
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  // Sign out user
  Future<void> signOut() async {
    try {
      await _sessionService.clearSession();
      print('User signed out successfully');
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }
}
