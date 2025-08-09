import 'package:cloud_firestore/cloud_firestore.dart';
import 'session_service.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SessionService _sessionService = SessionService();

  // Get all category budgets for the current user
  Stream<List<Map<String, dynamic>>> getCategoryBudgetsStream() {
    return Stream.fromFuture(_sessionService.getUserSession()).asyncExpand((userId) {
      if (userId == null) {
        return Stream.value([]);
      }
      
      return _firestore
          .collection('category_budgets')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();
      });
    });
  }

  // Get category budgets as a future (for one-time read)
  Future<List<Map<String, dynamic>>> getCategoryBudgets() async {
    try {
      final userId = await _sessionService.getUserSession();
      if (userId == null) {
        print('Error: No active user session found');
        return [];
      }

      final snapshot = await _firestore
          .collection('category_budgets')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error getting category budgets: $e');
      return [];
    }
  }

  // Set or update a category budget
  Future<bool> setCategoryBudget({
    required String category,
    required double amount,
    String? currency,
  }) async {
    try {
      final userId = await _sessionService.getUserSession();
      if (userId == null) {
        print('Error: No active user session found');
        return false;
      }

      // Check if budget for this category already exists
      final existingQuery = await _firestore
          .collection('category_budgets')
          .where('userId', isEqualTo: userId)
          .where('category', isEqualTo: category)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        // Update existing budget
        final docId = existingQuery.docs.first.id;
        await _firestore.collection('category_budgets').doc(docId).update({
          'amount': amount,
          'originalAmount': amount, // Store the original amount
          'currency': currency ?? 'USD',
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('Updated budget for $category: $amount');
      } else {
        // Create new budget
        await _firestore.collection('category_budgets').add({
          'userId': userId,
          'category': category,
          'amount': amount,
          'originalAmount': amount, // Store the original amount
          'currency': currency ?? 'USD',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('Created budget for $category: $amount');
      }

      return true;
    } catch (e) {
      print('Error setting category budget: $e');
      return false;
    }
  }

  // Delete a category budget
  Future<bool> deleteCategoryBudget(String budgetId) async {
    try {
      await _firestore.collection('category_budgets').doc(budgetId).delete();
      print('Deleted budget: $budgetId');
      return true;
    } catch (e) {
      print('Error deleting category budget: $e');
      return false;
    }
  }

  // Get total budget amount
  Future<double> getTotalBudget() async {
    try {
      final budgets = await getCategoryBudgets();
      double total = 0.0;
      
      for (var budget in budgets) {
        final amount = (budget['originalAmount'] as num?)?.toDouble() ?? 
                      (budget['amount'] as num?)?.toDouble() ?? 0.0;
        total += amount;
      }
      
      return total;
    } catch (e) {
      print('Error calculating total budget: $e');
      return 0.0;
    }
  }

  // Get predefined categories
  List<String> getPredefinedCategories() {
    return [
      'Food & Dining',
      'Transportation',
      'Shopping',
      'Entertainment',
      'Bills & Utilities',
      'Health & Fitness',
      'Travel',
      'Education',
      'Personal Care',
      'Gifts & Donations',
      'Business Services',
      'Fees & Charges',
      'Investments',
      'Other'
    ];
  }

  // Get spending for a specific category in current month
  Future<double> getCategorySpending(String category) async {
    try {
      final userId = await _sessionService.getUserSession();
      if (userId == null) return 0.0;

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('category', isEqualTo: category)
          .where('type', isEqualTo: 'Expense')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      double total = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final amount = (data['originalAmount'] as num?)?.toDouble() ?? 
                      (data['amount'] as num?)?.toDouble() ?? 0.0;
        total += amount;
      }

      return total;
    } catch (e) {
      print('Error getting category spending: $e');
      return 0.0;
    }
  }
}
