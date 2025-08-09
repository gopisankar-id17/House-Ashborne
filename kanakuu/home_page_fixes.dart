// Fixed sections for your home_page.dart
// Replace the corresponding methods in your file with these complete versions

  Widget _buildBudgetManagement() {
    if (_currentUserId == null) {
      return _buildStaticBudgetManagement();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: _currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF2A2D3A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text('Error loading budget data', style: TextStyle(color: Colors.white)),
            ),
          );
        }

        double totalSpent = 0.0;
        final double totalBudget = 4500.0;

        if (snapshot.hasData) {
          final now = DateTime.now();
          final currentMonth = now.month;
          final currentYear = now.year;

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final type = data['type'] as String? ?? '';
            final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
            final timestamp = data['date'] as Timestamp?;

            if (timestamp != null) {
              final date = timestamp.toDate();
              if (type == 'Expense' && date.month == currentMonth && date.year == currentYear) {
                totalSpent += amount;
              }
            }
          }
        }

        final remaining = totalBudget - totalSpent;
        final spentPercentage = totalBudget > 0 ? (totalSpent / totalBudget * 100).round() : 0;

        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF2A2D3A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.donut_large, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Budget Management',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.settings, color: Colors.orange, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Manage',
                        style: TextStyle(color: Colors.orange, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF1A1D29),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.pie_chart, color: Colors.blue, size: 24),
                          SizedBox(height: 8),
                          Text(
                            'Total\nBudget',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '\$${totalBudget.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'This month',
                            style: TextStyle(color: Colors.blue, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF1A1D29),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.attach_money, color: Colors.orange, size: 24),
                          SizedBox(height: 8),
                          Text(
                            'Spent',
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '\$${totalSpent.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$spentPercentage% of budget',
                            style: TextStyle(color: Colors.orange, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF1A1D29),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 24),
                          SizedBox(height: 8),
                          Text(
                            'Remaining',
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '\$${remaining.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${100 - spentPercentage}% left',
                            style: TextStyle(color: Colors.green, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryBudgets() {
    if (_currentUserId == null) {
      return _buildStaticCategoryBudgets();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: _currentUserId)
          .where('type', isEqualTo: 'Expense')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF2A2D3A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text('Error loading category data', style: TextStyle(color: Colors.white)),
            ),
          );
        }

        Map<String, double> categorySpending = {};
        
        if (snapshot.hasData) {
          final now = DateTime.now();
          final currentMonth = now.month;
          final currentYear = now.year;

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final category = data['category'] as String? ?? 'Other';
            final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
            final timestamp = data['date'] as Timestamp?;
            
            if (timestamp != null) {
              final date = timestamp.toDate();
              if (date.month == currentMonth && date.year == currentYear) {
                categorySpending[category] = (categorySpending[category] ?? 0) + amount;
              }
            }
          }
        }

        final categoryBudgets = {
          'Food': 800.00,
          'Transport': 300.00,
          'Bills': 1200.00,
          'Shopping': 500.00,
          'Fun': 200.00,
          'Health': 300.00,
        };

        final categoryIcons = {
          'Food': Icons.restaurant,
          'Transport': Icons.directions_car,
          'Bills': Icons.home,
          'Shopping': Icons.shopping_bag,
          'Fun': Icons.movie,
          'Health': Icons.local_hospital,
        };

        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF2A2D3A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Category Budgets',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Current Month',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ...categoryBudgets.entries.map((entry) {
                final category = entry.key;
                final budget = entry.value;
                final spent = categorySpending[category] ?? 0.0;
                final icon = categoryIcons[category] ?? Icons.category;
                
                return _buildCategoryItem(category, icon, spent, budget, _getCategoryColor(category));
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpendingAnalysis() {
    if (_currentUserId == null) {
      return _buildStaticSpendingAnalysis();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: _currentUserId)
          .where('type', isEqualTo: 'Expense')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF2A2D3A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text('Error loading spending data', style: TextStyle(color: Colors.white)),
            ),
          );
        }

        Map<String, double> categoryExpenses = {};
        double totalExpenses = 0.0;

        if (snapshot.hasData) {
          final now = DateTime.now();
          final currentMonth = now.month;
          final currentYear = now.year;

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final category = data['category'] as String? ?? 'Other';
            final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
            final timestamp = data['date'] as Timestamp?;
            
            if (timestamp != null) {
              final date = timestamp.toDate();
              if (date.month == currentMonth && date.year == currentYear) {
                categoryExpenses[category] = (categoryExpenses[category] ?? 0) + amount;
                totalExpenses += amount;
              }
            }
          }
        }

        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF2A2D3A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.pie_chart, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Spending Analysis',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Center(
                child: Container(
                  width: 160,
                  height: 160,
                  child: CustomPaint(
                    painter: DynamicPieChartPainter(categoryExpenses),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                          Text(
                            '\$${totalExpenses.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildExpenseLegend(categoryExpenses),
            ],
          ),
        );
      },
    );
  }
