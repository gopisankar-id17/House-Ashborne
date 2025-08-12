import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'skeleton_loading_page.dart';
import '../services/session_service.dart';
import '../services/currency_service.dart';

class AnalyticsPage extends StatefulWidget {
  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate data loading
    Future.delayed(Duration(seconds: 3), () {
      setState(() => isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading 
      ? AnalyticsSkeletonPage()
      : ActualAnalyticsPage(); // Your existing analytics page content
  }
}

class ActualAnalyticsPage extends StatefulWidget {
  @override
  _ActualAnalyticsPageState createState() => _ActualAnalyticsPageState(); // Fixed: Changed to _ActualAnalyticsPageState
}

class _ActualAnalyticsPageState extends State<ActualAnalyticsPage> {
  String selectedPeriod = '1M';
  String selectedTab = 'Overview';
  
  final SessionService _sessionService = SessionService();
  final CurrencyService _currencyService = CurrencyService();
  String? _currentUserId;
  String _currencySymbol = '\$';
  String _selectedCurrency = 'USD';

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _loadCurrencySettings();
  }

  Future<void> _loadUserId() async {
    final userId = await _sessionService.getUserSession();
    setState(() {
      _currentUserId = userId;
    });
  }

  Future<void> _loadCurrencySettings() async {
    final symbol = await _currencyService.getCurrencySymbol();
    final currency = await _currencyService.getSelectedCurrency();
    setState(() {
      _currencySymbol = symbol;
      _selectedCurrency = currency;
    });
  }

  // Convert USD amounts to selected currency
  Future<double> _convertFromUSD(double usdAmount) async {
    return await _currencyService.convertFromUSD(usdAmount);
  }

  // Format amount with selected currency
  Future<String> _formatAmount(double amount) async {
    final convertedAmount = await _convertFromUSD(amount);
    return await _currencyService.formatAmount(convertedAmount);
  }

  // Helper method to get category color
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food & dining':
      case 'food':
        return Colors.orange;
      case 'transportation':
      case 'transport':
        return Colors.blue;
      case 'shopping':
        return Colors.pink;
      case 'entertainment':
      case 'fun':
        return Colors.purple;
      case 'bills & utilities':
      case 'bills':
        return Colors.red;
      case 'healthcare':
      case 'medical':
        return Colors.teal;
      case 'education':
        return Colors.indigo;
      case 'travel':
        return Colors.cyan;
      case 'personal care':
        return Colors.amber;
      case 'gifts & donations':
        return Colors.green;
      case 'business':
        return Colors.brown;
      case 'income':
        return Colors.lightGreen;
      default:
        return Colors.grey;
    }
  }

  // Calculate financial health score based on savings rate and spending patterns
  double _calculateFinancialHealthScore(double savingsRate, double income, double expenses) {
    // Base score from savings rate (0-50 points)
    double savingsScore = (savingsRate / 20.0 * 50).clamp(0.0, 50.0);
    
    // Income utilization score (0-30 points)
    double utilizationScore = 0.0;
    if (income > 0) {
      double utilizationRate = expenses / income;
      if (utilizationRate <= 0.8) {
        utilizationScore = 30.0;
      } else if (utilizationRate <= 1.0) {
        utilizationScore = 20.0;
      } else {
        utilizationScore = 0.0;
      }
    }
    
    // Bonus for having any income (0-20 points)
    double incomeBonus = income > 0 ? 20.0 : 0.0;
    
    return (savingsScore + utilizationScore + incomeBonus).clamp(0.0, 100.0);
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return Scaffold(
        backgroundColor: Color(0xFF1A1D29),
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFF1A1D29),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('transactions')
              .where('userId', isEqualTo: _currentUserId)
              .snapshots(),
          builder: (context, snapshot) {
            Map<String, double> categoryTotals = {};
            double totalExpenses = 0.0;
            double totalIncome = 0.0;
            double currentMonthExpenses = 0.0;
            double currentMonthIncome = 0.0;
            List<Map<String, dynamic>> monthlyData = [];

            if (snapshot.hasData) {
              final now = DateTime.now();
              final currentMonth = now.month;
              final currentYear = now.year;

              // Calculate date range based on selected period
              DateTime startDate;
              switch (selectedPeriod) {
                case '1W':
                  startDate = now.subtract(Duration(days: 7));
                  break;
                case '1M':
                  startDate = DateTime(now.year, now.month, 1);
                  break;
                case '6M':
                  startDate = DateTime(now.year, now.month - 6, 1);
                  break;
                case '1Y':
                  startDate = DateTime(now.year - 1, now.month, now.day);
                  break;
                case 'ALL':
                default:
                  startDate = DateTime(2000, 1, 1); // Very old date for all time
                  break;
              }

              // Initialize monthly data for the last 6 months
              for (int i = 5; i >= 0; i--) {
                final date = DateTime(now.year, now.month - i, 1);
                monthlyData.add({
                  'month': date,
                  'income': 0.0,
                  'expenses': 0.0,
                });
              }

              for (var doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                final amount = (data['originalAmount'] as num?)?.toDouble() ?? (data['amount'] as num).toDouble();
                final category = data['category'] as String? ?? 'Other';
                final date = (data['date'] as Timestamp).toDate();
                final type = data['type'] as String;

                // Current month data for financial health
                if (date.month == currentMonth && date.year == currentYear) {
                  if (type == 'Expense') {
                    currentMonthExpenses += amount;
                  } else if (type == 'Income') {
                    currentMonthIncome += amount;
                  }
                }

                // Category data based on selected period
                if (date.isAfter(startDate.subtract(Duration(days: 1)))) {
                  if (type == 'Expense') {
                    categoryTotals[category] = (categoryTotals[category] ?? 0.0) + amount;
                    totalExpenses += amount;
                  } else if (type == 'Income') {
                    totalIncome += amount;
                  }
                }

                // Monthly data for chart
                for (var monthData in monthlyData) {
                  final monthDate = monthData['month'] as DateTime;
                  if (date.year == monthDate.year && date.month == monthDate.month) {
                    if (type == 'Expense') {
                      monthData['expenses'] += amount;
                    } else if (type == 'Income') {
                      monthData['income'] += amount;
                    }
                    break;
                  }
                }
              }
            }

            // Calculate financial health metrics
            final savingsRate = currentMonthIncome > 0 
                ? ((currentMonthIncome - currentMonthExpenses) / currentMonthIncome * 100).clamp(0.0, 100.0)
                : 0.0;
            
            final financialHealthScore = _calculateFinancialHealthScore(
              savingsRate, 
              currentMonthIncome, 
              currentMonthExpenses
            );

            return SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: 20),
                  _buildPeriodSelector(),
                  SizedBox(height: 20),
                  _buildTabSelector(),
                  SizedBox(height: 20),
                  _buildContent(
                    categoryTotals,
                    totalExpenses,
                    currentMonthExpenses,
                    currentMonthIncome,
                    savingsRate,
                    financialHealthScore,
                    monthlyData,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    Map<String, double> categoryTotals,
    double totalExpenses,
    double currentMonthExpenses,
    double currentMonthIncome,
    double savingsRate,
    double financialHealthScore,
    List<Map<String, dynamic>> monthlyData,
  ) {
    switch (selectedTab) {
      case 'Overview':
        return Column(
          children: [
            _buildFinancialHealth(financialHealthScore),
            SizedBox(height: 20),
            _buildStatsCards(currentMonthExpenses, savingsRate),
            SizedBox(height: 20),
            _buildIncomeVsExpenses(monthlyData),
          ],
        );
      case 'Spending':
        return _buildSpendingContent(categoryTotals, totalExpenses);
      case 'Categories':
        return _buildCategoriesContent(categoryTotals, totalExpenses);
      case 'Goals':
        return _buildGoalsContent();
      default:
        return Column(
          children: [
            _buildFinancialHealth(financialHealthScore),
            SizedBox(height: 20),
            _buildStatsCards(currentMonthExpenses, savingsRate),
            SizedBox(height: 20),
            _buildIncomeVsExpenses(monthlyData),
          ],
        );
    }
  }

  Widget _buildSpendingContent(Map<String, double> categoryTotals, double totalExpenses) {
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Get period description
    String periodDescription;
    switch (selectedPeriod) {
      case '1W':
        periodDescription = 'This Week';
        break;
      case '1M':
        periodDescription = 'This Month';
        break;
      case '6M':
        periodDescription = 'Last 6 Months';
        break;
      case '1Y':
        periodDescription = 'This Year';
        break;
      case 'ALL':
      default:
        periodDescription = 'All Time';
        break;
    }

    return Column(
      children: [
        // Weekly Spending Line Graph
        Container(
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
                    'Weekly Spending Trend',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    Icons.trending_up,
                    color: Colors.orange,
                    size: 20,
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                height: 200,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('transactions')
                      .where('userId', isEqualTo: _currentUserId)
                      .where('type', isEqualTo: 'Expense')
                      .snapshots(),
                  builder: (context, snapshot) {
                    List<Map<String, dynamic>> weeklyData = [];
                    
                    if (snapshot.hasData) {
                      // Get last 8 weeks of data
                      final now = DateTime.now();
                      for (int i = 7; i >= 0; i--) {
                        final weekStart = now.subtract(Duration(days: now.weekday - 1 + (i * 7)));
                        final weekEnd = weekStart.add(Duration(days: 6));
                        weeklyData.add({
                          'weekStart': weekStart,
                          'weekEnd': weekEnd,
                          'amount': 0.0,
                        });
                      }

                      for (var doc in snapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        final amount = (data['originalAmount'] as num?)?.toDouble() ?? (data['amount'] as num).toDouble();
                        final date = (data['date'] as Timestamp).toDate();

                        for (var weekData in weeklyData) {
                          final weekStart = weekData['weekStart'] as DateTime;
                          final weekEnd = weekData['weekEnd'] as DateTime;
                          if (date.isAfter(weekStart.subtract(Duration(days: 1))) && 
                              date.isBefore(weekEnd.add(Duration(days: 1)))) {
                            weekData['amount'] += amount;
                            break;
                          }
                        }
                      }
                    }

                    return CustomPaint(
                      size: Size(double.infinity, 200),
                      painter: WeeklySpendingLineChart(weeklyData),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 20),

        // Monthly Spending Bar Chart
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF2A2D3A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Monthly Spending',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    Icons.bar_chart,
                    color: Colors.orange,
                    size: 20,
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                height: 220,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('transactions')
                      .where('userId', isEqualTo: _currentUserId)
                      .where('type', isEqualTo: 'Expense')
                      .snapshots(),
                  builder: (context, snapshot) {
                    List<Map<String, dynamic>> monthlyData = [];
                    
                    if (snapshot.hasData) {
                      // Get last 6 months of data
                      final now = DateTime.now();
                      for (int i = 5; i >= 0; i--) {
                        final month = DateTime(now.year, now.month - i, 1);
                        monthlyData.add({
                          'month': month,
                          'amount': 0.0,
                        });
                      }

                      for (var doc in snapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        final amount = (data['originalAmount'] as num?)?.toDouble() ?? (data['amount'] as num).toDouble();
                        final date = (data['date'] as Timestamp).toDate();

                        for (var monthData in monthlyData) {
                          final month = monthData['month'] as DateTime;
                          if (date.year == month.year && date.month == month.month) {
                            monthData['amount'] += amount;
                            break;
                          }
                        }
                      }
                    }

                    return CustomPaint(
                      size: Size(double.infinity, 220),
                      painter: MonthlySpendingBarChart(monthlyData),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 20),

        // Total spending for selected period
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF2A2D3A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Spending - $periodDescription',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12),
              FutureBuilder<String>(
                future: _formatAmount(totalExpenses),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? '$_currencySymbol${totalExpenses.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              SizedBox(height: 8),
              Text(
                'Across ${sortedCategories.length} categories',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesContent(Map<String, double> categoryTotals, double totalExpenses) {
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Get period description
    String periodDescription;
    switch (selectedPeriod) {
      case '1W':
        periodDescription = 'This Week';
        break;
      case '1M':
        periodDescription = 'This Month';
        break;
      case '6M':
        periodDescription = 'Last 6 Months';
        break;
      case '1Y':
        periodDescription = 'This Year';
        break;
      case 'ALL':
      default:
        periodDescription = 'All Time';
        break;
    }

    return Column(
      children: [
        // Pie Chart for Category Breakdown
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF2A2D3A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Category Breakdown',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    Icons.donut_small,
                    color: Colors.orange,
                    size: 20,
                  ),
                ],
              ),
              SizedBox(height: 20),
              
              if (sortedCategories.isNotEmpty) ...[
                // Centered Chart
                Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    child: CustomPaint(
                      painter: ExpenseBreakdownPieChart(
                        Map.fromEntries(sortedCategories.take(6)),
                        totalExpenses,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Legend Below Chart
                Column(
                  children: sortedCategories.take(6).map((entry) {
                    final percentage = totalExpenses > 0 
                        ? (entry.value / totalExpenses * 100)
                        : 0.0;
                    return _buildLegendItem(
                      entry.key,
                      _getCategoryColor(entry.key),
                      entry.value,
                      percentage,
                    );
                  }).toList(),
                ),
              ] else ...[
                Container(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.donut_small_outlined,
                          color: Colors.grey[600],
                          size: 40,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No spending data available',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        SizedBox(height: 20),

        // Detailed Category List
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF2A2D3A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Categories - $periodDescription',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16),
              
              if (sortedCategories.isNotEmpty) ...[
                Column(
                  children: sortedCategories.map((entry) {
                    final percentage = totalExpenses > 0 
                        ? (entry.value / totalExpenses * 100)
                        : 0.0;
                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF1A1D29),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getCategoryColor(entry.key),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${percentage.toStringAsFixed(1)}% of total spending',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FutureBuilder<String>(
                            future: _formatAmount(entry.value),
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.data ?? '$_currencySymbol${entry.value.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ] else ...[
                Container(
                  height: 100,
                  child: Center(
                    child: Text(
                      'No category data available for $periodDescription',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsContent() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF2A2D3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Goals',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          
          // Example goals
          _buildGoalItem('Emergency Fund', 75.0, 'Build 6 months of expenses'),
          SizedBox(height: 12),
          _buildGoalItem('Save for Vacation', 40.0, 'Save \$3,000 for trip'),
          SizedBox(height: 12),
          _buildGoalItem('Pay Off Debt', 60.0, 'Reduce credit card debt'),
          
          SizedBox(height: 20),
          
          // Add goal button
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.orange, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.orange, size: 16),
                SizedBox(width: 8),
                Text(
                  'Add New Goal',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItem(String title, double progress, String description) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1A1D29),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${progress.toInt()}%',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
          SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.grey[700],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String category, Color color, double amount, double percentage) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              category,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FutureBuilder<String>(
                future: _formatAmount(amount),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? '$_currencySymbol${amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analytics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Insights into your financial patterns',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ),
       
      ],
    );
  }

  Widget _buildPeriodSelector() {
    List<String> periods = ['1W', '1M', '6M', '1Y', 'ALL'];
    
    return Row(
      children: periods.map((period) {
        bool isSelected = selectedPeriod == period;
        return GestureDetector(
          onTap: () => setState(() => selectedPeriod = period),
          child: Container(
            margin: EdgeInsets.only(right: 8),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.orange : Color(0xFF2A2D3A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              period,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTabSelector() {
    List<Map<String, dynamic>> tabs = [
      {'name': 'Overview', 'icon': Icons.dashboard_outlined},
      {'name': 'Spending', 'icon': Icons.trending_down},
      {'name': 'Categories', 'icon': Icons.pie_chart_outline},
      {'name': 'Goals', 'icon': Icons.flag_outlined},
    ];

    return Row(
      children: tabs.map((tab) {
        bool isSelected = selectedTab == tab['name'];
        return GestureDetector(
          onTap: () => setState(() => selectedTab = tab['name']),
          child: Container(
            margin: EdgeInsets.only(right: 20),
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 12 : 0, 
              vertical: isSelected ? 8 : 0
            ),
            decoration: BoxDecoration(
              color: isSelected ? Colors.orange : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  tab['icon'],
                  color: isSelected ? Colors.black : Colors.grey[400],
                  size: 16,
                ),
                if (isSelected) ...[
                  SizedBox(width: 6),
                  Text(
                    tab['name'],
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFinancialHealth(double financialHealthScore) {
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
                'Financial Health',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: financialHealthScore >= 70 ? Colors.green.withOpacity(0.2) :
                         financialHealthScore >= 40 ? Colors.orange.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  financialHealthScore >= 70 ? 'Good' :
                  financialHealthScore >= 40 ? 'Fair' : 'Needs Work',
                  style: TextStyle(
                    color: financialHealthScore >= 70 ? Colors.green :
                           financialHealthScore >= 40 ? Colors.orange : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Text(
                  financialHealthScore.toInt().toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Health Score',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: financialHealthScore / 100,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: financialHealthScore >= 70 ? [Colors.green, Colors.lightGreen] :
                                 financialHealthScore >= 40 ? [Colors.orange, Colors.amber] : [Colors.red, Colors.redAccent],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(double currentMonthExpenses, double savingsRate) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF2A2D3A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      color: Colors.orange,
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Total Spending',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                FutureBuilder<String>(
                  future: _formatAmount(currentMonthExpenses),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? '$_currencySymbol${currentMonthExpenses.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                SizedBox(height: 4),
                Text(
                  'This month',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF2A2D3A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: Colors.green,
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Savings Rate',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '${savingsRate.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  savingsRate > 0 ? 'This month' : 'No savings',
                  style: TextStyle(
                    color: savingsRate > 0 ? Colors.green : Colors.grey[500],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeVsExpenses(List<Map<String, dynamic>> monthlyData) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF2A2D3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Income vs Expenses',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 200,
            child: CustomPaint(
              size: Size(double.infinity, 200),
              painter: IncomeExpenseChartPainter(monthlyData),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 2,
                    color: Colors.green,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Income',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 20),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 2,
                    color: Colors.orange,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Spending',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class IncomeExpenseChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> monthlyData;

  IncomeExpenseChartPainter(this.monthlyData);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = 2..style = PaintingStyle.stroke;

    // Chart background
    final backgroundPaint = Paint()..color = Color(0xFF1A1D29);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Y-axis labels and grid lines
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );

    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..strokeWidth = 1;

    // Calculate max value for scaling
    double maxValue = 0;
    for (var data in monthlyData) {
      maxValue = [maxValue, data['income'] as double, data['expenses'] as double].reduce((a, b) => a > b ? a : b);
    }
    maxValue = maxValue > 0 ? maxValue * 1.2 : 6000; // Add 20% padding or default to 6000

    List<double> yValues = [0, maxValue * 0.25, maxValue * 0.5, maxValue * 0.75, maxValue];
    for (int i = 0; i < yValues.length; i++) {
      double y = size.height - (i * size.height / (yValues.length - 1));
      
      // Draw grid line
      canvas.drawLine(
        Offset(40, y),
        Offset(size.width, y),
        gridPaint,
      );

      // Draw Y-axis label
      textPainter.text = TextSpan(
        text: yValues[i].toStringAsFixed(0),
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - 6));
    }

    // X-axis labels - show last 6 months
    List<String> months = [];
    for (var data in monthlyData) {
      final date = data['month'] as DateTime;
      months.add(['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month - 1]);
    }
    
    double xStep = (size.width - 40) / (months.length - 1);
    
    for (int i = 0; i < months.length; i++) {
      double x = 40 + (i * xStep);
      textPainter.text = TextSpan(
        text: months[i],
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - 10, size.height + 5));
    }

    if (monthlyData.isEmpty) return;

    // Extract income and expense data
    List<double> incomeData = monthlyData.map((data) => data['income'] as double).toList();
    List<double> expenseData = monthlyData.map((data) => data['expenses'] as double).toList();

    // Draw income area (green)
    paint.color = Colors.green;
    Path incomePath = Path();
    List<Offset> incomePoints = [];
    
    for (int i = 0; i < incomeData.length; i++) {
      double x = 40 + (i * xStep);
      double y = size.height - (incomeData[i] / maxValue * size.height);
      incomePoints.add(Offset(x, y));
      
      if (i == 0) {
        incomePath.moveTo(x, y);
      } else {
        incomePath.lineTo(x, y);
      }
    }

    // Fill area under income curve
    Path incomeAreaPath = Path.from(incomePath);
    incomeAreaPath.lineTo(40 + ((incomeData.length - 1) * xStep), size.height);
    incomeAreaPath.lineTo(40, size.height);
    incomeAreaPath.close();
    
    Paint incomeAreaPaint = Paint()
      ..color = Colors.green.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawPath(incomeAreaPath, incomeAreaPaint);
    canvas.drawPath(incomePath, paint);

    // Draw expense area (orange)
    paint.color = Colors.orange;
    Path expensePath = Path();
    
    for (int i = 0; i < expenseData.length; i++) {
      double x = 40 + (i * xStep);
      double y = size.height - (expenseData[i] / maxValue * size.height);
      
      if (i == 0) {
        expensePath.moveTo(x, y);
      } else {
        expensePath.lineTo(x, y);
      }
    }

    // Fill area under expense curve
    Path expenseAreaPath = Path.from(expensePath);
    expenseAreaPath.lineTo(40 + ((expenseData.length - 1) * xStep), size.height);
    expenseAreaPath.lineTo(40, size.height);
    expenseAreaPath.close();
    
    Paint expenseAreaPaint = Paint()
      ..color = Colors.orange.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawPath(expenseAreaPath, expenseAreaPaint);
    canvas.drawPath(expensePath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Simple pie chart painter for expense breakdown
class ExpenseBreakdownPieChart extends CustomPainter {
  final Map<String, double> categoryData;
  final double total;

  ExpenseBreakdownPieChart(this.categoryData, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;
    
    if (total <= 0 || categoryData.isEmpty) {
      // Draw empty circle
      final paint = Paint()
        ..color = Colors.grey[600]!
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, paint);
      return;
    }

    double startAngle = -90 * (3.14159 / 180); // Start from top
    
    categoryData.entries.forEach((entry) {
      final sweepAngle = (entry.value / total) * 2 * 3.14159;
      final paint = Paint()
        ..color = _getCategoryColorStatic(entry.key)
        ..style = PaintingStyle.fill;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      
      startAngle += sweepAngle;
    });
  }

  static Color _getCategoryColorStatic(String category) {
    switch (category.toLowerCase()) {
      case 'food & dining':
      case 'food':
        return Colors.orange;
      case 'transportation':
      case 'transport':
        return Colors.blue;
      case 'shopping':
        return Colors.pink;
      case 'entertainment':
      case 'fun':
        return Colors.purple;
      case 'bills & utilities':
      case 'bills':
        return Colors.red;
      case 'healthcare':
      case 'medical':
        return Colors.teal;
      case 'education':
        return Colors.indigo;
      case 'travel':
        return Colors.cyan;
      case 'personal care':
        return Colors.amber;
      case 'gifts & donations':
        return Colors.green;
      case 'business':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Weekly Spending Line Chart Painter
class WeeklySpendingLineChart extends CustomPainter {
  final List<Map<String, dynamic>> weeklyData;

  WeeklySpendingLineChart(this.weeklyData);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = 3..style = PaintingStyle.stroke;

    // Chart background
    final backgroundPaint = Paint()..color = Color(0xFF1A1D29);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    if (weeklyData.isEmpty) return;

    // Calculate max value for scaling
    double maxValue = weeklyData.fold(0, (max, data) => 
        (data['amount'] as double) > max ? data['amount'] as double : max);
    maxValue = maxValue > 0 ? maxValue * 1.2 : 1000; // Add 20% padding

    // Draw grid lines and Y-axis labels
    List<double> yValues = [0, maxValue * 0.25, maxValue * 0.5, maxValue * 0.75, maxValue];
    for (int i = 0; i < yValues.length; i++) {
      double y = size.height - 30 - (i * (size.height - 60) / (yValues.length - 1));
      
      // Draw grid line
      canvas.drawLine(Offset(40, y), Offset(size.width, y), gridPaint);

      // Draw Y-axis label
      textPainter.text = TextSpan(
        text: yValues[i].toStringAsFixed(0),
        style: TextStyle(color: Colors.grey[400], fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - 6));
    }

    // Draw X-axis labels (weeks)
    double xStep = weeklyData.length > 1 ? (size.width - 40) / (weeklyData.length - 1) : 0;
    for (int i = 0; i < weeklyData.length; i++) {
      double x = 40 + (i * xStep);
      
      textPainter.text = TextSpan(
        text: 'W${i + 1}',
        style: TextStyle(color: Colors.grey[400], fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - 8, size.height - 20));
    }

    // Draw the line
    paint.color = Colors.orange;
    Path linePath = Path();
    List<Offset> points = [];

    for (int i = 0; i < weeklyData.length; i++) {
      double x = 40 + (i * xStep);
      double amount = weeklyData[i]['amount'] as double;
      double y = size.height - 30 - (amount / maxValue * (size.height - 60));
      points.add(Offset(x, y));

      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
      }
    }

    // Draw line
    canvas.drawPath(linePath, paint);

    // Draw points
    paint.style = PaintingStyle.fill;
    for (var point in points) {
      canvas.drawCircle(point, 4, paint);
    }

    // Draw area under curve
    Path areaPath = Path.from(linePath);
    if (points.isNotEmpty) {
      areaPath.lineTo(points.last.dx, size.height - 30);
      areaPath.lineTo(40, size.height - 30);
      areaPath.close();
    }

    Paint areaPaint = Paint()
      ..color = Colors.orange.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawPath(areaPath, areaPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Monthly Spending Bar Chart Painter
class MonthlySpendingBarChart extends CustomPainter {
  final List<Map<String, dynamic>> monthlyData;

  MonthlySpendingBarChart(this.monthlyData);

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    if (monthlyData.isEmpty) return;

    // Calculate max value for scaling
    double maxValue = monthlyData.fold(0, (max, data) => 
        (data['amount'] as double) > max ? data['amount'] as double : max);
    maxValue = maxValue > 0 ? maxValue * 1.2 : 1000; // Add 20% padding

    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..strokeWidth = 1;

    // Draw grid lines and Y-axis labels
    List<double> yValues = [0, maxValue * 0.25, maxValue * 0.5, maxValue * 0.75, maxValue];
    for (int i = 0; i < yValues.length; i++) {
      double y = size.height - 40 - (i * (size.height - 80) / (yValues.length - 1));
      
      // Draw grid line
      canvas.drawLine(Offset(40, y), Offset(size.width, y), gridPaint);

      // Draw Y-axis label
      textPainter.text = TextSpan(
        text: yValues[i].toStringAsFixed(0),
        style: TextStyle(color: Colors.grey[400], fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - 6));
    }

    // Draw bars
    double barWidth = (size.width - 80) / monthlyData.length;
    double barSpacing = barWidth * 0.1;
    barWidth *= 0.8; // Make bars thinner for spacing

    for (int i = 0; i < monthlyData.length; i++) {
      double amount = monthlyData[i]['amount'] as double;
      double barHeight = amount / maxValue * (size.height - 80);
      
      double x = 40 + (i * (barWidth + barSpacing)) + barSpacing / 2;
      double y = size.height - 40 - barHeight;

      // Create gradient for bars
      Paint barPaint = Paint()
        ..shader = LinearGradient(
          colors: [Colors.orange.withOpacity(0.8), Colors.orange],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(x, y, barWidth, barHeight));

      // Draw bar
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          Radius.circular(4),
        ),
        barPaint,
      );

      // Draw month label
      final month = monthlyData[i]['month'] as DateTime;
      final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                         'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      
      textPainter.text = TextSpan(
        text: monthNames[month.month - 1],
        style: TextStyle(color: Colors.grey[400], fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + barWidth / 2 - 12, size.height - 25));

      // Draw value on top of bar if there's space
      if (barHeight > 30) {
        textPainter.text = TextSpan(
          text: amount.toStringAsFixed(0),
          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x + barWidth / 2 - 15, y - 15));
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}