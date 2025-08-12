import 'package:cloud_firestore/cloud_firestore.dart';
import 'session_service.dart';

// Model for monthly budget
class MonthlyBudgetModel {
  final double totalAmount;
  final DateTime month;
  final DateTime createdAt;
  final DateTime updatedAt;

  MonthlyBudgetModel({
    required this.totalAmount,
    required this.month,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalAmount': totalAmount,
      'month': month,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static MonthlyBudgetModel fromMap(Map<String, dynamic> map) {
    return MonthlyBudgetModel(
      totalAmount: (map['totalAmount'] as num).toDouble(),
      month: (map['month'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
}

// Model for category budget
class CategoryBudgetModel {
  final String categoryId;
  final String categoryName;
  final double budgetAmount;
  final double spentAmount;
  final DateTime month;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryBudgetModel({
    required this.categoryId,
    required this.categoryName,
    required this.budgetAmount,
    this.spentAmount = 0.0,
    required this.month,
    required this.createdAt,
    required this.updatedAt,
  });

  double get remainingAmount => budgetAmount - spentAmount;
  double get spentPercentage => budgetAmount > 0 ? (spentAmount / budgetAmount) * 100 : 0;

  Map<String, dynamic> toMap() {
    return {
      'userId': '', // This will be filled by the service
      'categoryId': categoryId,
      'categoryName': categoryName,
      'budgetAmount': budgetAmount,
      'spentAmount': spentAmount,
      'month': month,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static CategoryBudgetModel fromMap(Map<String, dynamic> map) {
    return CategoryBudgetModel(
      categoryId: map['categoryId'],
      categoryName: map['categoryName'],
      budgetAmount: (map['budgetAmount'] as num).toDouble(),
      spentAmount: (map['spentAmount'] as num?)?.toDouble() ?? 0.0,
      month: (map['month'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
}

class BudgetManagementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SessionService _sessionService = SessionService();

  // MONTHLY BUDGET METHODS

  // Set monthly budget
  Future<void> setMonthlyBudget(double totalAmount, {DateTime? forMonth}) async {
    final userId = await _sessionService.getUserSession();
    if (userId == null) return;

    final now = DateTime.now();
    final targetMonth = forMonth ?? DateTime(now.year, now.month, 1);
    
    final monthlyBudget = MonthlyBudgetModel(
      totalAmount: totalAmount,
      month: targetMonth,
      createdAt: now,
      updatedAt: now,
    );

    final docId = '${userId}_${targetMonth.year}_${targetMonth.month}';
    await _firestore.collection('monthly_budgets').doc(docId).set(monthlyBudget.toMap());
  }

  // Get monthly budget
  Future<MonthlyBudgetModel?> getMonthlyBudget({DateTime? forMonth}) async {
    final userId = await _sessionService.getUserSession();
    if (userId == null) return null;

    final now = DateTime.now();
    final targetMonth = forMonth ?? DateTime(now.year, now.month, 1);
    final docId = '${userId}_${targetMonth.year}_${targetMonth.month}';

    final doc = await _firestore.collection('monthly_budgets').doc(docId).get();
    if (doc.exists) {
      return MonthlyBudgetModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Delete monthly budget
  Future<void> deleteMonthlyBudget({DateTime? forMonth}) async {
    final userId = await _sessionService.getUserSession();
    if (userId == null) return;

    final now = DateTime.now();
    final targetMonth = forMonth ?? DateTime(now.year, now.month, 1);
    final docId = '${userId}_${targetMonth.year}_${targetMonth.month}';

    await _firestore.collection('monthly_budgets').doc(docId).delete();
  }

  // CATEGORY BUDGET METHODS

  // Set category budget
  Future<void> setCategoryBudget({
    required String categoryId,
    required String categoryName,
    required double budgetAmount,
    DateTime? forMonth,
  }) async {
    final userId = await _sessionService.getUserSession();
    if (userId == null) {
      print('DEBUG Budget: No user session found');
      return;
    }

    print('DEBUG Budget: Setting budget for category $categoryName ($categoryId) - Amount: \$${budgetAmount}');

    final now = DateTime.now();
    final targetMonth = forMonth ?? DateTime(now.year, now.month, 1);

    // Calculate spent amount for this category and month
    final spentAmount = await _calculateCategorySpending(categoryId, targetMonth);
    print('DEBUG Budget: Calculated spent amount: \$${spentAmount}');

    final categoryBudget = CategoryBudgetModel(
      categoryId: categoryId,
      categoryName: categoryName,
      budgetAmount: budgetAmount,
      spentAmount: spentAmount,
      month: targetMonth,
      createdAt: now,
      updatedAt: now,
    );

    final docId = '${userId}_${categoryId}_${targetMonth.year}_${targetMonth.month}';
    print('DEBUG Budget: Saving with document ID: $docId');
    
    final budgetData = categoryBudget.toMap();
    budgetData['userId'] = userId; // Add userId to the data
    print('DEBUG Budget: Budget data: $budgetData');
    
    await _firestore.collection('category_budgets').doc(docId).set(budgetData);
    print('DEBUG Budget: Successfully saved budget to Firestore');
  }

  // Get category budgets for current month
  Future<List<CategoryBudgetModel>> getCategoryBudgets({DateTime? forMonth}) async {
    final userId = await _sessionService.getUserSession();
    if (userId == null) return [];

    final now = DateTime.now();
    final targetMonth = forMonth ?? DateTime(now.year, now.month, 1);

    final querySnapshot = await _firestore.collection('category_budgets')
        .where('month', isEqualTo: targetMonth)
        .get();

    final budgets = <CategoryBudgetModel>[];
    for (final doc in querySnapshot.docs) {
      final data = doc.data();
      // Filter by user (since we can't compound query efficiently)
      if (doc.id.startsWith(userId)) {
        // Update spent amount
        final categoryId = data['categoryId'];
        final spentAmount = await _calculateCategorySpending(categoryId, targetMonth);
        
        final budget = CategoryBudgetModel.fromMap(data);
        final updatedBudget = CategoryBudgetModel(
          categoryId: budget.categoryId,
          categoryName: budget.categoryName,
          budgetAmount: budget.budgetAmount,
          spentAmount: spentAmount,
          month: budget.month,
          createdAt: budget.createdAt,
          updatedAt: budget.updatedAt,
        );
        budgets.add(updatedBudget);
      }
    }

    return budgets;
  }

  // Get category budget for specific category
  Future<CategoryBudgetModel?> getCategoryBudget(String categoryId, {DateTime? forMonth}) async {
    final userId = await _sessionService.getUserSession();
    if (userId == null) return null;

    final now = DateTime.now();
    final targetMonth = forMonth ?? DateTime(now.year, now.month, 1);
    final docId = '${userId}_${categoryId}_${targetMonth.year}_${targetMonth.month}';

    final doc = await _firestore.collection('category_budgets').doc(docId).get();
    if (doc.exists) {
      final budget = CategoryBudgetModel.fromMap(doc.data() as Map<String, dynamic>);
      final spentAmount = await _calculateCategorySpending(categoryId, targetMonth);
      
      return CategoryBudgetModel(
        categoryId: budget.categoryId,
        categoryName: budget.categoryName,
        budgetAmount: budget.budgetAmount,
        spentAmount: spentAmount,
        month: budget.month,
        createdAt: budget.createdAt,
        updatedAt: budget.updatedAt,
      );
    }
    return null;
  }

  // Delete category budget
  Future<void> deleteCategoryBudget(String categoryId, {DateTime? forMonth}) async {
    final userId = await _sessionService.getUserSession();
    if (userId == null) return;

    final now = DateTime.now();
    final targetMonth = forMonth ?? DateTime(now.year, now.month, 1);
    final docId = '${userId}_${categoryId}_${targetMonth.year}_${targetMonth.month}';

    await _firestore.collection('category_budgets').doc(docId).delete();
  }

  // HELPER METHODS

  // Calculate spending for a specific category and month
  Future<double> _calculateCategorySpending(String categoryId, DateTime month) async {
    final userId = await _sessionService.getUserSession();
    if (userId == null) return 0.0;

    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 1).subtract(Duration(days: 1));

    // Use simpler query to avoid composite index requirement
    final querySnapshot = await _firestore.collection('transactions')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'Expense')
        .get();

    double totalSpent = 0.0;
    for (final doc in querySnapshot.docs) {
      final data = doc.data();
      
      // Filter locally to avoid composite index
      final docCategoryId = data['category'] as String?;
      final docDate = (data['date'] as Timestamp?)?.toDate();
      
      if (docCategoryId == categoryId && 
          docDate != null && 
          docDate.isAfter(startOfMonth.subtract(Duration(days: 1))) && 
          docDate.isBefore(endOfMonth.add(Duration(days: 1)))) {
        final amount = (data['originalAmount'] ?? data['amount'] ?? 0) as num;
        totalSpent += amount.toDouble();
      }
    }

    return totalSpent;
  }

  // Get total spending for the month
  Future<double> getTotalMonthlySpending({DateTime? forMonth}) async {
    final userId = await _sessionService.getUserSession();
    if (userId == null) return 0.0;

    final now = DateTime.now();
    final targetMonth = forMonth ?? DateTime(now.year, now.month, 1);
    final startOfMonth = DateTime(targetMonth.year, targetMonth.month, 1);
    final endOfMonth = DateTime(targetMonth.year, targetMonth.month + 1, 1).subtract(Duration(days: 1));

    final querySnapshot = await _firestore.collection('transactions')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'Expense')
        .where('date', isGreaterThanOrEqualTo: startOfMonth)
        .where('date', isLessThanOrEqualTo: endOfMonth)
        .get();

    double totalSpent = 0.0;
    for (final doc in querySnapshot.docs) {
      final data = doc.data();
      final amount = (data['originalAmount'] ?? data['amount'] ?? 0) as num;
      totalSpent += amount.toDouble();
    }

    return totalSpent;
  }
}
