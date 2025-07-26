import 'package:flutter/material.dart';

class AddTransactionPage extends StatefulWidget {
  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  String selectedType = 'Income';
  String selectedCategory = 'Salary';
  TextEditingController amountController = TextEditingController(text: '4556');
  TextEditingController descriptionController = TextEditingController(text: 'axx');
  DateTime selectedDate = DateTime.now();

  List<Map<String, dynamic>> incomeCategories = [
    {'name': 'Salary', 'icon': Icons.work_outline, 'color': Colors.green},
    {'name': 'Freelance', 'icon': Icons.laptop_mac, 'color': Colors.orange},
    {'name': 'Investment', 'icon': Icons.trending_up, 'color': Colors.brown},
    {'name': 'Bonus', 'icon': Icons.card_giftcard_outlined, 'color': Colors.purple},
  ];

  List<Map<String, dynamic>> expenseCategories = [
    {'name': 'Food', 'icon': Icons.restaurant_outlined, 'color': Colors.orange},
    {'name': 'Transport', 'icon': Icons.directions_car_outlined, 'color': Colors.brown},
    {'name': 'Bills', 'icon': Icons.receipt_outlined, 'color': Colors.red},
    {'name': 'Shopping', 'icon': Icons.shopping_bag_outlined, 'color': Colors.brown},
    {'name': 'Fun', 'icon': Icons.celebration_outlined, 'color': Colors.purple},
    {'name': 'Health', 'icon': Icons.favorite_outline, 'color': Colors.green},
  ];

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
                  selectedCategory = 'Food';
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
                  selectedCategory = 'Salary';
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
                '\$',
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
    List<Map<String, dynamic>> currentCategories = selectedType == 'Income' ? incomeCategories : expenseCategories;
    
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
            Map<String, dynamic> category = currentCategories[index];
            bool isSelected = selectedCategory == category['name'];
            return GestureDetector(
              onTap: () => setState(() => selectedCategory = category['name']),
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
                        color: category['color'],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        category['icon'],
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      category['name'],
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
                  '${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-yyyy',
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
            onTap: _addTransaction,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
      firstDate: DateTime(0000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.orange,
              surface: Color(0xFF2A2D3A),
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

  void _addTransaction() {
    // Handle adding transaction logic here
    print('Type: $selectedType');
    print('Amount: ${amountController.text}');
    print('Category: $selectedCategory');
    print('Description: ${descriptionController.text}');
    print('Date: $selectedDate');
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transaction added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    
    Navigator.pop(context);
  }
}