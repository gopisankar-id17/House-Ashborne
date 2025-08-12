import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/budget_management_service.dart';
import '../services/category_service.dart';
import '../widgets/currency_display_widget.dart';

class BudgetManagementPage extends StatefulWidget {
  const BudgetManagementPage({Key? key}) : super(key: key);

  @override
  _BudgetManagementPageState createState() => _BudgetManagementPageState();
}

class _BudgetManagementPageState extends State<BudgetManagementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BudgetManagementService _budgetService = BudgetManagementService();
  final CategoryService _categoryService = CategoryService();
  String _currencySymbol = '\$';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCurrencySymbol();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrencySymbol() async {
    try {
      final symbol = await CurrencyService().getCurrencySymbol();
      setState(() {
        _currencySymbol = symbol;
      });
    } catch (e) {
      // Keep default symbol
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF16213E),
      appBar: AppBar(
        backgroundColor: Color(0xFF16213E),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Budget Management',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Color(0xFFFF6B35),
          labelColor: Color(0xFFFF6B35),
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Monthly Budget'),
            Tab(text: 'Category Budgets'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMonthlyBudgetTab(),
          _buildCategoryBudgetsTab(),
        ],
      ),
    );
  }

  Widget _buildMonthlyBudgetTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current month budget card
          _buildCurrentMonthBudgetCard(),
          SizedBox(height: 20),
          
          // Set budget button
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showSetMonthlyBudgetDialog(),
              icon: Icon(Icons.add, color: Colors.white),
              label: Text(
                'Set Monthly Budget',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF6B35),
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentMonthBudgetCard() {
    return FutureBuilder<MonthlyBudgetModel?>(
      future: _budgetService.getMonthlyBudget(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }
        
        final monthlyBudget = snapshot.data;
        
        return FutureBuilder<double>(
          future: _budgetService.getTotalMonthlySpending(),
          builder: (context, spendingSnapshot) {
            if (spendingSnapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingCard();
            }
            
            final totalSpent = spendingSnapshot.data ?? 0.0;
            
            return Card(
              color: Color(0xFF1E2749),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          color: Color(0xFFFF6B35),
                          size: 24,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Monthly Budget',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    
                    if (monthlyBudget != null) ...[
                      // Budget amount
                      Text(
                        'Budget: $_currencySymbol${monthlyBudget.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      
                      // Spent amount
                      Text(
                        'Spent: $_currencySymbol${totalSpent.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: totalSpent > monthlyBudget.totalAmount ? Colors.red : Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      
                      // Remaining amount
                      Text(
                        'Remaining: $_currencySymbol${(monthlyBudget.totalAmount - totalSpent).toStringAsFixed(2)}',
                        style: TextStyle(
                          color: (monthlyBudget.totalAmount - totalSpent) >= 0 ? Colors.green : Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 15),
                      
                      // Progress bar
                      LinearProgressIndicator(
                        value: monthlyBudget.totalAmount > 0 
                            ? (totalSpent / monthlyBudget.totalAmount).clamp(0.0, 1.0)
                            : 0.0,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          totalSpent > monthlyBudget.totalAmount 
                              ? Colors.red 
                              : Color(0xFFFF6B35),
                        ),
                      ),
                      SizedBox(height: 10),
                      
                      Text(
                        '${monthlyBudget.totalAmount > 0 ? ((totalSpent / monthlyBudget.totalAmount) * 100).toStringAsFixed(1) : "0"}% used',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 15),
                      
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showSetMonthlyBudgetDialog(existingBudget: monthlyBudget),
                              icon: Icon(Icons.edit, size: 16),
                              label: Text('Edit'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFFF6B35).withOpacity(0.8),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showDeleteMonthlyBudgetDialog(),
                              icon: Icon(Icons.delete, size: 16),
                              label: Text('Delete'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.withOpacity(0.8),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        'No monthly budget set',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Set a monthly budget to track your spending',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryBudgetsTab() {
    return Column(
      children: [
        // Header with add button
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Category Budgets',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showSetCategoryBudgetDialog(),
                icon: Icon(Icons.add, color: Colors.white, size: 16),
                label: Text(
                  'Add Budget',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF6B35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Category budgets list
        Expanded(
          child: FutureBuilder<List<CategoryBudgetModel>>(
            future: _budgetService.getCategoryBudgets(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFF6B35),
                  ),
                );
              }
              
              final budgets = snapshot.data ?? [];
              
              if (budgets.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category,
                        color: Colors.white54,
                        size: 64,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No category budgets set',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add category budgets to track spending by category',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: budgets.length,
                itemBuilder: (context, index) {
                  return _buildCategoryBudgetCard(budgets[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBudgetCard(CategoryBudgetModel budget) {
    final isOverBudget = budget.spentAmount > budget.budgetAmount;
    final progressValue = budget.budgetAmount > 0 
        ? (budget.spentAmount / budget.budgetAmount).clamp(0.0, 1.0)
        : 0.0;
    
    return Card(
      color: Color(0xFF1E2749),
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    budget.categoryName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.white70),
                  color: Color(0xFF1E2749),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showSetCategoryBudgetDialog(existingBudget: budget);
                    } else if (value == 'delete') {
                      _showDeleteCategoryBudgetDialog(budget);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.white70, size: 16),
                          SizedBox(width: 8),
                          Text('Edit', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 16),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            
            // Budget vs Spent
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '$_currencySymbol${budget.budgetAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Spent',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '$_currencySymbol${budget.spentAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: isOverBudget ? Colors.red : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            
            // Progress bar
            LinearProgressIndicator(
              value: progressValue,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? Colors.red : Color(0xFFFF6B35),
              ),
            ),
            SizedBox(height: 8),
            
            // Remaining and percentage
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Remaining: $_currencySymbol${budget.remainingAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: budget.remainingAmount >= 0 ? Colors.green : Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${budget.spentPercentage.toStringAsFixed(1)}% used',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      color: Color(0xFF1E2749),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF6B35),
          ),
        ),
      ),
    );
  }

  void _showSetMonthlyBudgetDialog({MonthlyBudgetModel? existingBudget}) {
    final TextEditingController amountController = TextEditingController();
    
    if (existingBudget != null) {
      amountController.text = existingBudget.totalAmount.toString();
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E2749),
        title: Text(
          existingBudget != null ? 'Edit Monthly Budget' : 'Set Monthly Budget',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Budget Amount',
                labelStyle: TextStyle(color: Colors.white70),
                prefixText: _currencySymbol,
                prefixStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFF6B35)),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final amountText = amountController.text.trim();
              if (amountText.isNotEmpty) {
                final amount = double.tryParse(amountText);
                if (amount != null && amount > 0) {
                  await _budgetService.setMonthlyBudget(amount);
                  Navigator.pop(context);
                  setState(() {});
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        existingBudget != null 
                            ? 'Monthly budget updated successfully'
                            : 'Monthly budget set successfully',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF6B35),
            ),
            child: Text(
              existingBudget != null ? 'Update' : 'Set Budget',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteMonthlyBudgetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E2749),
        title: Text(
          'Delete Monthly Budget',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete the monthly budget?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await _budgetService.deleteMonthlyBudget();
              Navigator.pop(context);
              setState(() {});
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Monthly budget deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showSetCategoryBudgetDialog({CategoryBudgetModel? existingBudget}) {
    String? selectedCategoryId = existingBudget?.categoryId;
    String selectedCategoryName = existingBudget?.categoryName ?? '';
    final TextEditingController amountController = TextEditingController();
    
    if (existingBudget != null) {
      amountController.text = existingBudget.budgetAmount.toString();
    }
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Color(0xFF1E2749),
        title: Text(
          existingBudget != null ? 'Edit Category Budget' : 'Set Category Budget',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category selector (only for new budgets)
            if (existingBudget == null) ...[
              FutureBuilder<List<CategoryModel>>(
                future: _categoryService.getAllCategoriesDebug(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(color: Color(0xFFFF6B35));
                  }
                  
                  if (snapshot.hasError) {
                    print('Error loading categories: ${snapshot.error}');
                    return Text('Error loading categories: ${snapshot.error}', 
                        style: TextStyle(color: Colors.red));
                  }
                  
                  final allCategories = snapshot.data ?? [];
                  final categories = allCategories.where((cat) => 
                      cat.type.toLowerCase() == 'expense' && cat.isActive).toList();
                  
                  print('DEBUG: Found ${categories.length} expense categories');
                  
                  if (categories.isEmpty) {
                    return Text('No expense categories found. Please create some categories first.',
                        style: TextStyle(color: Colors.white70));
                  }
                  
                  return DropdownButtonFormField<String>(
                    value: selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: 'Select Category (${categories.length} available)',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFFF6B35)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    dropdownColor: Color(0xFF1E2749),
                    style: TextStyle(color: Colors.white),
                    items: categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category.id,
                        child: Text(
                          category.name,
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedCategoryId = value;
                        final category = categories.firstWhere((cat) => cat.id == value);
                        selectedCategoryName = category.name;
                      });
                    },
                  );
                },
              ),
              SizedBox(height: 16),
            ],
            
            // Amount input
            TextField(
              controller: amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Budget Amount',
                labelStyle: TextStyle(color: Colors.white70),
                prefixText: _currencySymbol,
                prefixStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFF6B35)),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final amountText = amountController.text.trim();
              if (amountText.isNotEmpty && 
                  (existingBudget != null || selectedCategoryId != null)) {
                final amount = double.tryParse(amountText);
                if (amount != null && amount > 0) {
                  await _budgetService.setCategoryBudget(
                    categoryId: existingBudget?.categoryId ?? selectedCategoryId!,
                    categoryName: existingBudget?.categoryName ?? selectedCategoryName,
                    budgetAmount: amount,
                  );
                  
                  if (mounted) {
                    Navigator.pop(context);
                    setState(() {});
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          existingBudget != null 
                              ? 'Category budget updated successfully'
                              : 'Category budget set successfully',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF6B35),
            ),
            child: Text(
              existingBudget != null ? 'Update' : 'Set Budget',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        ),
      ),
    );
  }

  void _showDeleteCategoryBudgetDialog(CategoryBudgetModel budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E2749),
        title: Text(
          'Delete Category Budget',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete the budget for ${budget.categoryName}?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await _budgetService.deleteCategoryBudget(budget.categoryId);
              Navigator.pop(context);
              setState(() {});
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Category budget deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
