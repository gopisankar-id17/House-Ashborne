import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a user profile using a custom userId (from your app logic)
  Future<void> createUserProfile({
    required String userId,
    required String fullName,
    required String email,
    required String password, // Add this for manual login (not recommended for production without hashing)
    bool biometricEnabled = false,
  }) async {
    await _firestore.collection('users').doc(userId).set({
      'fullName': fullName,
      'email': email,
      'password': password, // ⚠️ Insecure: only for prototype use
      'biometricEnabled': biometricEnabled,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'totalBalance': 0.0,
      'monthlyBudget': 0.0,
      'currency': 'USD',
    });
  }

  /// Get user by email and password (for sign-in)
  Future<Map<String, dynamic>?> getUserByEmailAndPassword(String email, String password) async {
    final query = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .where('password', isEqualTo: password)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.data() as Map<String, dynamic>;
    }
    return null;
  }

  /// Fetch user profile using userId
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data();
  }

  /// Update user profile fields
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('users').doc(userId).update(data);
  }

  /// Increment or decrement balance
  Future<void> updateBalance(String userId, double amount) async {
    await _firestore.collection('users').doc(userId).update({
      'totalBalance': FieldValue.increment(amount),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get total balance of a user
  Future<double> getTotalBalance(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final data = doc.data();
    return data?['totalBalance']?.toDouble() ?? 0.0;
  }
}
