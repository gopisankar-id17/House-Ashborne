import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'session_service.dart'; // Import your SessionService

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SessionService _sessionService = SessionService();

  // Get current user's profile data using SessionService
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userId = await _sessionService.getUserSession();
      if (userId == null) {
        print('No active user session found');
        return null;
      }

      print('Getting profile for user ID: $userId');
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data();
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
  
  // Get a stream of the current user's profile data for real-time updates
  Stream<DocumentSnapshot> getUserProfileStream() {
    return Stream.fromFuture(_sessionService.getUserSession()).asyncExpand((userId) {
      if (userId == null) {
        return Stream.empty();
      }
      return _firestore.collection('users').doc(userId).snapshots();
    });
  }

  // Update user profile with new data (without image upload to Firebase Storage)
  Future<bool> updateUserProfile({
    String? name,
    String? email,
    String? phone,
    File? profileImage, // We'll store this as a local path or ignore it
  }) async {
    try {
      final userId = await _sessionService.getUserSession();
      if (userId == null) {
        print('Error: No active user session found');
        return false;
      }

      print('Updating profile for user ID: $userId');
      Map<String, dynamic> updateData = {};

      // Update basic info fields if provided
      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;
      if (phone != null) updateData['phone'] = phone;

      // For image, you can either:
      // 1. Store the local file path (not recommended for production)
      // 2. Convert to base64 and store in Firestore (has size limits)
      // 3. Ignore the image for now
      if (profileImage != null) {
        // Option 1: Store local file path (will only work on same device)
        updateData['profileImagePath'] = profileImage.path;
        print('Profile image path stored: ${profileImage.path}');
      }

      updateData['updatedAt'] = FieldValue.serverTimestamp();

      // Check if document exists first
      final docRef = _firestore.collection('users').doc(userId);
      final docSnapshot = await docRef.get();
      
      if (docSnapshot.exists) {
        // Document exists, use update
        await docRef.update(updateData);
        print('Profile updated successfully using update()');
      } else {
        // Document doesn't exist, use set with merge
        await docRef.set(updateData, SetOptions(merge: true));
        print('Profile created/updated successfully using set() with merge');
      }

      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      print('Error type: ${e.runtimeType}');
      if (e is FirebaseException) {
        print('Firebase error code: ${e.code}');
        print('Firebase error message: ${e.message}');
      }
      return false;
    }
  }

  // Delete profile image (remove from Firestore document)
  Future<bool> deleteProfileImage() async {
    try {
      final userId = await _sessionService.getUserSession();
      if (userId == null) return false;

      // Remove the profileImagePath field from Firestore document
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'profileImagePath': FieldValue.delete(),
        'profileImageUrl': FieldValue.delete(), // Remove this too if it exists
      });

      print('Profile image path removed from Firestore');
      return true;
    } catch (e) {
      print('Error deleting profile image: $e');
      return false;
    }
  }

  // Create initial user profile (to be called when a user first registers)
  Future<bool> createUserProfile({
    required String name,
    required String email,
  }) async {
    try {
      final userId = await _sessionService.getUserSession();
      if (userId == null) return false;
      
      await _firestore
          .collection('users')
          .doc(userId)
          .set({
        'name': name,
        'email': email,
        'profileImagePath': null,
        'profileImageUrl': null,
        'phone': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print('User profile created successfully');
      return true;
    } catch (e) {
      print('Error creating user profile: $e');
      return false;
    }
  }
  
  // Sign out the current user using SessionService
  Future<void> signOut() async {
    await _sessionService.clearSession();
  }

  // Check if user is currently authenticated using SessionService
  bool get isUserAuthenticated {
    // This needs to be async, so we'll make it a Future
    return true; // Placeholder, use the method below
  }

  // Async method to check if user is authenticated
  Future<bool> isUserAuthenticatedAsync() async {
    return await _sessionService.isLoggedIn();
  }
  
  // Get current user ID if authenticated
  Future<String?> get currentUserId async {
    return await _sessionService.getUserSession();
  }
}