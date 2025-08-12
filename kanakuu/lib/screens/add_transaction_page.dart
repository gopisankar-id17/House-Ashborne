import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'skeleton_loading_page.dart';
import '../services/session_service.dart'; // Import the SessionService
import '../services/currency_service.dart'; // Import CurrencyService
import '../services/category_service.dart'; // Import CategoryService

// Function to show the modal bottom sheet
void showAddTransactionModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AddTransactionWithSkeleton(),
  );
}

// Wrapper to show skeleton loading for AddTransactionPage
class AddTransactionWithSkeleton extends StatefulWidget {
  @override
  _AddTransactionWithSkeletonState createState() => _AddTransactionWithSkeletonState();
}

class _AddTransactionWithSkeletonState extends State<AddTransactionWithSkeleton> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      setState(() => isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
      ? AddTransactionSkeletonPage()
      : AddTransactionPage(); // Your existing add transaction page
  }
}

// The actual Add Transaction Page content
class AddTransactionPage extends StatefulWidget {
  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  String selectedType = 'Income';
  String selectedCategory = ''; // Will be set when categories load
  TextEditingController amountController = TextEditingController(); // Initialize empty
  TextEditingController descriptionController = TextEditingController(); // Initialize empty
  DateTime selectedDate = DateTime.now();

  final SessionService _sessionService = SessionService(); // Initialize SessionService
  final CurrencyService _currencyService = CurrencyService(); // Initialize CurrencyService
  final CategoryService _categoryService = CategoryService(); // Initialize CategoryService
  bool _isSaving = false; // New state for saving indicator
  String _currencySymbol = '\$'; // Default currency symbol
  
  // Dynamic category lists
  List<CategoryModel> incomeCategories = [];
  List<CategoryModel> expenseCategories = [];

  @override
  void initState() {
    super.initState();
    _loadCurrencySymbol();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final allCategories = await _categoryService.getAllCategoriesDebug();
      setState(() {
        incomeCategories = allCategories.where((cat) => cat.type.toLowerCase() == 'income' && cat.isActive).toList();
        expenseCategories = allCategories.where((cat) => cat.type.toLowerCase() == 'expense' && cat.isActive).toList();
        
        // Set default selectedCategory based on available categories
        if (selectedType == 'Income' && incomeCategories.isNotEmpty) {
          selectedCategory = incomeCategories.first.name;
        } else if (selectedType == 'Expense' && expenseCategories.isNotEmpty) {
          selectedCategory = expenseCategories.first.name;
        }
      });
      print('DEBUG: Loaded ${incomeCategories.length} income categories, ${expenseCategories.length} expense categories');
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> _loadCurrencySymbol() async {
    final symbol = await _currencyService.getCurrencySymbol();
    if (mounted) {
      setState(() {
        _currencySymbol = symbol;
      });
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Color(0xFF2A2D3A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTypeSelector(),
                  SizedBox(height: 24),
                  _buildAmountField(),
                  SizedBox(height: 24),
                  _buildCategorySelector(),
                  SizedBox(height: 24),
                  _buildDescriptionField(),
                  SizedBox(height: 24),
                  _buildDateField(),
                  SizedBox(height: 32),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Add Transaction',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.close,
              color: Colors.grey[400],
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  selectedType = 'Expense';
                  if (expenseCategories.isNotEmpty) {
                    selectedCategory = expenseCategories.first.name; // Reset category when type changes
                  }
                }),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: selectedType == 'Expense' ? Colors.red : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selectedType == 'Expense' ? Colors.red : Colors.grey[600]!,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Expense',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  selectedType = 'Income';
                  if (incomeCategories.isNotEmpty) {
                    selectedCategory = incomeCategories.first.name; // Reset category when type changes
                  }
                }),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: selectedType == 'Income' ? Colors.green : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selectedType == 'Income' ? Colors.green : Colors.grey[600]!,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Income',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Color(0xFF1A1D29),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange, width: 2),
          ),
          child: Row(
            children: [
              Text(
                _currencySymbol, // Use dynamic currency symbol
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: amountController,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 18,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    List<CategoryModel> currentCategories = selectedType == 'Income' ? incomeCategories : expenseCategories;
    
    if (currentCategories.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'No categories found. Please create some categories first.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: currentCategories.length,
          itemBuilder: (context, index) {
            CategoryModel category = currentCategories[index];
            bool isSelected = selectedCategory == category.name;
            return GestureDetector(
              onTap: () => setState(() => selectedCategory = category.name),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF1A1D29),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.orange : Colors.grey[700]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: category.color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        category.icon,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      category.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Color(0xFF1A1D29),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[700]!, width: 1),
          ),
          child: TextField(
            controller: descriptionController,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'What was this for?',
              hintStyle: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Color(0xFF1A1D29),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange, width: 2),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.grey[400],
                  size: 20,
                ),
                SizedBox(width: 12),
                Text(
                  // Format date to show day-month-year
                  '${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[600]!, width: 1),
              ),
              child: Center(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: _isSaving ? null : _addTransaction, // Disable button while saving
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Add Transaction',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000), // Set a reasonable first date
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.orange,
              onPrimary: Colors.white, // Color of text on primary background
              surface: Color(0xFF2A2D3A),
              onSurface: Colors.white, // Color of text on surface
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange, // Color of the buttons (OK, Cancel)
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _addTransaction() async {
    // Basic validation
    if (amountController.text.isEmpty || double.tryParse(amountController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true; // Show loading indicator
    });

    try {
      final userId = await _sessionService.getUserSession();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not logged in. Please sign in again.'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context); // Dismiss modal
        return;
      }

      final double amount = double.parse(amountController.text);
      
      // Convert amount to USD for storage if not already USD
      final double amountInUSD = await _currencyService.convertToUSD(amount);

      // Prepare transaction data
      final transactionData = {
        'userId': userId,
        'type': selectedType,
        'amount': amountInUSD, // Store amount in USD
        'originalAmount': amount, // Store original amount in selected currency
        'currency': await _currencyService.getSelectedCurrency(), // Store currency
        'category': selectedCategory,
        'description': descriptionController.text.trim(),
        'date': Timestamp.fromDate(selectedDate), // Save date as Firestore Timestamp
        'createdAt': FieldValue.serverTimestamp(), // Automatically set server timestamp
      };

      // Add the transaction to Firestore
      await FirebaseFirestore.instance.collection('transactions').add(transactionData);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context); // Dismiss the modal after successful addition
    } catch (e) {
      print("Error adding transaction: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add transaction: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false; // Hide loading indicator
      });
    }
  }
}