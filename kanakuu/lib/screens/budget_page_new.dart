import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/budget_service.dart';
import '../services/currency_service.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({Key? key}) : super(key: key);

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final BudgetService _budgetService = BudgetService();
  final CurrencyService _currencyService = CurrencyService();
  String _currencySymbol = '\$';
  
  // Predefined categories with icons
  final Map<String, IconData> _categories = {
    'Food & Dining': Icons.restaurant,
    'Transportation': Icons.directions_car,
    'Shopping': Icons.shopping_bag,
    'Entertainment': Icons.movie,
    'Bills & Utilities': Icons.receipt_long,
    'Health & Fitness': Icons.fitness_center,
    'Education': Icons.school,
    'Travel': Icons.flight,
    'Personal Care': Icons.spa,
    'Gifts & Donations': Icons.card_giftcard,
    'Business Services': Icons.business,
    'Investments': Icons.trending_up,
  };

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, double> _currentBudgets = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadData();
  }

  void _initializeControllers() {
    for (String category in _categories.keys) {
      _controllers[category] = TextEditingController();
    }
  }

  Future<void> _loadData() async {
    try {
      final symbol = await _currencyService.getCurrencySymbol();
      
      setState(() {
        _currencySymbol = symbol;
        _isLoading = false;
      });

      // Load existing budgets
      final budgetsList = await _budgetService.getCategoryBudgetsStream().first;
      
      setState(() {
        _currentBudgets.clear();
        
        for (String category in _categories.keys) {
          _currentBudgets[category] = 0.0;
        }
        
        for (var budget in budgetsList) {
          final category = budget['category'] as String? ?? '';
          final amount = (budget['originalAmount'] as num?)?.toDouble() ?? 
                        (budget['amount'] as num?)?.toDouble() ?? 0.0;
          
          if (_categories.containsKey(category)) {
            _currentBudgets[category] = amount;
            _controllers[category]!.text = amount > 0 ? amount.toStringAsFixed(0) : '';
          }
        }
      });
    } catch (e) {
      print('Error loading budget data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveBudgets() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // First, get existing budgets to delete them
      final existingBudgets = await _budgetService.getCategoryBudgetsStream().first;
      
      // Delete existing budgets
      for (var budget in existingBudgets) {
        final budgetId = budget['id'] as String? ?? '';
        if (budgetId.isNotEmpty) {
          await _budgetService.deleteCategoryBudget(budgetId);
        }
      }

      // Set new budgets
      for (String category in _categories.keys) {
        final text = _controllers[category]!.text.trim();
        if (text.isNotEmpty) {
          final amount = double.tryParse(text);
          if (amount != null && amount > 0) {
            await _budgetService.setCategoryBudget(
              category: category,
              amount: amount,
              currency: 'USD',
            );
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Budgets saved successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving budgets: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF16213E), // Dark blue background like other pages
      appBar: AppBar(
        backgroundColor: Color(0xFF16213E),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manage Budgets',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _isSaving ? null : _saveBudgets,
              child: _isSaving 
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)), // Orange color
                    ),
                  )
                : Text(
                    'Save',
                    style: TextStyle(
                      color: Color(0xFFFF6B35), // Orange color
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ),
          SizedBox(width: 16),
        ],
      ),
      body: _isLoading 
        ? Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
            ),
          )
        : _buildBudgetForm(),
    );
  }

  Widget _buildBudgetForm() {
    return Column(
      children: [
        // Header with info
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set Category Budgets',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Set monthly spending limits for each category to better track your expenses.',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        
        // Budget categories list
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories.keys.elementAt(index);
              final icon = _categories[category]!;
              
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Color(0xFF1E2A47), // Slightly lighter than background
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Color(0xFF2A3F5F),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Category icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Color(0xFFFF6B35).withOpacity(0.2), // Orange background
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          color: Color(0xFFFF6B35), // Orange icon
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      
                      // Category name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_currentBudgets[category]! > 0) ...[
                              SizedBox(height: 4),
                              Text(
                                'Current: $_currencySymbol${_currentBudgets[category]!.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      // Budget input
                      Container(
                        width: 120,
                        child: TextField(
                          controller: _controllers[category],
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                          ],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: '0',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            prefixText: _currencySymbol,
                            prefixStyle: TextStyle(
                              color: Color(0xFFFF6B35), // Orange prefix
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            filled: true,
                            fillColor: Color(0xFF16213E),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFF2A3F5F)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFF2A3F5F)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFFFF6B35)), // Orange focus
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        // Bottom padding for safe area and navigation bar
        SizedBox(height: 100), // Space for bottom navigation
      ],
    );
  }
}
