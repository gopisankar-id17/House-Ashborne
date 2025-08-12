import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'session_service.dart';

class CategoryModel {
  final String id;
  final String name;
  final String type; // 'expense' or 'income'
  final IconData icon;
  final Color color;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'iconCode': icon.codePoint,
      'colorValue': color.value,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static CategoryModel fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      icon: IconData(map['iconCode'], fontFamily: 'MaterialIcons'),
      color: Color(map['colorValue']),
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
}

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SessionService _sessionService = SessionService();

  // Default categories
  static List<CategoryModel> getDefaultExpenseCategories() {
    final now = DateTime.now();
    return [
      CategoryModel(
        id: 'food',
        name: 'Food & Dining',
        type: 'expense',
        icon: Icons.restaurant,
        color: Colors.orange,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryModel(
        id: 'transport',
        name: 'Transportation',
        type: 'expense',
        icon: Icons.directions_car,
        color: Colors.blue,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryModel(
        id: 'entertainment',
        name: 'Entertainment',
        type: 'expense',
        icon: Icons.movie,
        color: Colors.purple,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryModel(
        id: 'shopping',
        name: 'Shopping',
        type: 'expense',
        icon: Icons.shopping_bag,
        color: Colors.pink,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryModel(
        id: 'bills',
        name: 'Bills & Utilities',
        type: 'expense',
        icon: Icons.receipt_long,
        color: Colors.red,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryModel(
        id: 'health',
        name: 'Health & Medical',
        type: 'expense',
        icon: Icons.local_hospital,
        color: Colors.green,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryModel(
        id: 'education',
        name: 'Education',
        type: 'expense',
        icon: Icons.school,
        color: Colors.indigo,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryModel(
        id: 'travel',
        name: 'Travel',
        type: 'expense',
        icon: Icons.flight,
        color: Colors.teal,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryModel(
        id: 'others',
        name: 'Others',
        type: 'expense',
        icon: Icons.more_horiz,
        color: Colors.grey,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  static List<CategoryModel> getDefaultIncomeCategories() {
    final now = DateTime.now();
    return [
      CategoryModel(
        id: 'salary',
        name: 'Salary',
        type: 'income',
        icon: Icons.work,
        color: Colors.green,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryModel(
        id: 'freelance',
        name: 'Freelance',
        type: 'income',
        icon: Icons.laptop,
        color: Colors.blue,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryModel(
        id: 'business',
        name: 'Business',
        type: 'income',
        icon: Icons.business,
        color: Colors.purple,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryModel(
        id: 'investment',
        name: 'Investment',
        type: 'income',
        icon: Icons.trending_up,
        color: Colors.orange,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryModel(
        id: 'gift',
        name: 'Gift',
        type: 'income',
        icon: Icons.card_giftcard,
        color: Colors.pink,
        createdAt: now,
        updatedAt: now,
      ),
      CategoryModel(
        id: 'other_income',
        name: 'Other Income',
        type: 'income',
        icon: Icons.attach_money,
        color: Colors.teal,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  // Initialize default categories for a user
  Future<void> initializeDefaultCategories() async {
    final userId = await _sessionService.getUserSession();
    if (userId == null) return;

    final expenseCategories = getDefaultExpenseCategories();
    final incomeCategories = getDefaultIncomeCategories();

    final batch = _firestore.batch();

    // Add expense categories
    for (final category in expenseCategories) {
      final docRef = _firestore.collection('users').doc(userId).collection('categories').doc(category.id);
      batch.set(docRef, category.toMap());
    }

    // Add income categories
    for (final category in incomeCategories) {
      final docRef = _firestore.collection('users').doc(userId).collection('categories').doc(category.id);
      batch.set(docRef, category.toMap());
    }

    await batch.commit();
  }

  // Get all categories for a user
  Future<List<CategoryModel>> getCategories({String? type}) async {
    final userId = await _sessionService.getUserSession();
    if (userId == null) return [];

    Query query = _firestore.collection('users').doc(userId).collection('categories')
        .where('isActive', isEqualTo: true);

    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }

    final querySnapshot = await query.get();
    List<CategoryModel> categories = querySnapshot.docs
        .map((doc) => CategoryModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
    
    // Sort by name locally to avoid needing a composite index
    categories.sort((a, b) => a.name.compareTo(b.name));
    return categories;
  }

  // Get categories as stream
  Stream<List<CategoryModel>> getCategoriesStream({String? type}) async* {
    final userId = await _sessionService.getUserSession();
    if (userId == null) {
      yield [];
      return;
    }

    Query query = _firestore.collection('users').doc(userId).collection('categories')
        .where('isActive', isEqualTo: true);

    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }

    await for (final querySnapshot in query.snapshots()) {
      List<CategoryModel> categories = querySnapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      
      // Sort by name locally to avoid needing a composite index
      categories.sort((a, b) => a.name.compareTo(b.name));
      yield categories;
    }
  }

  // Get all categories for debugging (no filters)
  Future<List<CategoryModel>> getAllCategoriesDebug() async {
    final userId = await _sessionService.getUserSession();
    if (userId == null) return [];

    final querySnapshot = await _firestore.collection('users').doc(userId).collection('categories').get();
    print('DEBUG: Found ${querySnapshot.docs.length} total categories');
    
    List<CategoryModel> categories = querySnapshot.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          print('DEBUG: Category - ${data['name']} (${data['type']}) - Active: ${data['isActive']}');
          return CategoryModel.fromMap(data);
        })
        .toList();
    
    return categories;
  }

  // Add new category
  Future<void> addCategory(CategoryModel category) async {
    final userId = await _sessionService.getUserSession();
    if (userId == null) return;

    await _firestore.collection('users').doc(userId).collection('categories').doc(category.id).set(category.toMap());
  }

  // Update category
  Future<void> updateCategory(CategoryModel category) async {
    final userId = await _sessionService.getUserSession();
    if (userId == null) return;

    final updatedCategory = CategoryModel(
      id: category.id,
      name: category.name,
      type: category.type,
      icon: category.icon,
      color: category.color,
      isActive: category.isActive,
      createdAt: category.createdAt,
      updatedAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(userId).collection('categories').doc(category.id).update(updatedCategory.toMap());
  }

  // Soft delete category
  Future<void> deleteCategory(String categoryId) async {
    final userId = await _sessionService.getUserSession();
    if (userId == null) return;

    await _firestore.collection('users').doc(userId).collection('categories').doc(categoryId).update({
      'isActive': false,
      'updatedAt': DateTime.now(),
    });
  }

  // Get category by ID
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    final userId = await _sessionService.getUserSession();
    if (userId == null) return null;

    final doc = await _firestore.collection('users').doc(userId).collection('categories').doc(categoryId).get();
    if (doc.exists) {
      return CategoryModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Check if categories are initialized
  Future<bool> areCategoriesInitialized() async {
    final userId = await _sessionService.getUserSession();
    if (userId == null) return false;

    final querySnapshot = await _firestore.collection('users').doc(userId).collection('categories').limit(1).get();
    return querySnapshot.docs.isNotEmpty;
  }
}
