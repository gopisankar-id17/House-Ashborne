import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:math' as math;
import '../services/profile_service.dart';
import '../services/session_service.dart';
import '../services/currency_service.dart';
import 'home_page_painters.dart';

// Add this function at the top level (outside any class) to handle background notifications
@pragma('vm:entry-point')
void backGroundNotificationHandler() {
  // Handle background notifications here
  print('Background notification received');
}

// Base Skeleton Loading Widget for shared animation logic
abstract class BaseSkeletonLoadingState<T extends StatefulWidget> extends State<T> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> shimmerAnimation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );
    animationController.repeat();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Widget buildShimmerContainer({
    required double width,
    required double height,
    double borderRadius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment(-1.0 + shimmerAnimation.value, 0.0),
          end: Alignment(-0.5 + shimmerAnimation.value, 0.0),
          colors: [
            Color(0xFF2A2D3A),
            Color(0xFF3A3D4A),
            Color(0xFF2A2D3A),
          ],
          stops: [0.0, 0.2, 0.5],
        ),
      ),
    );
  }
}

// Home Page Skeleton Loading that matches your actual home page
class HomePageSkeletonLoading extends StatefulWidget {
  @override
  _HomePageSkeletonLoadingState createState() => _HomePageSkeletonLoadingState();
}

class _HomePageSkeletonLoadingState extends BaseSkeletonLoadingState<HomePageSkeletonLoading> {
  // Add missing properties for the skeleton loading state
  String? get _currentUserId => null;
  String get _currencySymbol => '\$';
  
  // Add missing categories list
  List<Map<String, dynamic>> get categories => [
    {
      'name': 'Food',
      'icon': Icons.restaurant,
      'spent': 450.0,
      'budget': 800.0,
      'color': Colors.orange,
    },
    {
      'name': 'Transport',
      'icon': Icons.directions_car,
      'spent': 230.0,
      'budget': 400.0,
      'color': Colors.brown,
    },
    {
      'name': 'Shopping',
      'icon': Icons.shopping_bag,
      'spent': 320.0,
      'budget': 500.0,
      'color': Colors.pink,
    },
  ];

  // Add missing methods
  Future<String> _formatAmount(double amount) async {
    return '$_currencySymbol${amount.toStringAsFixed(2)}';
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food': return Colors.orange;
      case 'transport': return Colors.brown;
      case 'bills': return Colors.red;
      case 'shopping': return Colors.pink;
      case 'fun': return Colors.purple;
      case 'health': return Colors.green;
      default: return Colors.grey;
    }
  }

  Color _getBudgetColor(double percentage) {
    if (percentage >= 90) {
      return Colors.red;
    } else if (percentage >= 70) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1D29),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: shimmerAnimation,
          builder: (context, child) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSkeleton(),
                  SizedBox(height: 20),
                  _buildBalanceCardSkeleton(),
                  SizedBox(height: 20),
                  _buildIncomeExpenseCardsSkeleton(),
                  SizedBox(height: 30),
                  _buildWeeklySpendingSkeleton(),
                  SizedBox(height: 30),
                  _buildExpenseCategoriesSkeleton(),
                  SizedBox(height: 30),
                  _buildBudgetProgressSkeleton(),
                  SizedBox(height: 100),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderSkeleton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildShimmerContainer(width: 180, height: 18),
            SizedBox(height: 8),
            buildShimmerContainer(width: 200, height: 14),
          ],
        ),
        Row(
          children: [
            buildShimmerContainer(width: 40, height: 40, borderRadius: 20),
            SizedBox(width: 12),
            buildShimmerContainer(width: 40, height: 40, borderRadius: 20),
          ],
        ),
      ],
    );
  }

  Widget _buildBalanceCardSkeleton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF2A2D3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildShimmerContainer(width: 100, height: 14),
          SizedBox(height: 8),
          buildShimmerContainer(width: 160, height: 32),
          SizedBox(height: 4),
          buildShimmerContainer(width: 140, height: 12),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseCardsSkeleton() {
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
                    buildShimmerContainer(width: 8, height: 8, borderRadius: 4),
                    SizedBox(width: 8),
                    buildShimmerContainer(width: 50, height: 14),
                  ],
                ),
                SizedBox(height: 8),
                buildShimmerContainer(width: 80, height: 20),
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
                    buildShimmerContainer(width: 8, height: 8, borderRadius: 4),
                    SizedBox(width: 8),
                    buildShimmerContainer(width: 60, height: 14),
                  ],
                ),
                SizedBox(height: 8),
                buildShimmerContainer(width: 80, height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklySpendingSkeleton() {
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
          ...categories.map((category) => _buildCategoryItem(
            category['name'] as String,
            category['icon'] as IconData,
            category['spent'] as double,
            category['budget'] as double,
            category['color'] as Color,
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String name, IconData icon, double spent, double budget, Color color) {
    double percentage = budget > 0 ? (spent / budget) * 100 : 0;
    double progressValue = budget > 0 ? spent / budget : 0.0;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${percentage.toInt()}%',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progressValue.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getBudgetColor(percentage),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    FutureBuilder<String>(
                      future: _formatAmount(spent),
                      builder: (context, spentSnapshot) {
                        return FutureBuilder<String>(
                          future: _formatAmount(budget),
                          builder: (context, budgetSnapshot) {
                            final spentText = spentSnapshot.data ?? '$_currencySymbol${spent.toStringAsFixed(2)}';
                            final budgetText = budgetSnapshot.data ?? '$_currencySymbol${budget.toStringAsFixed(2)}';
                            return Text(
                              '$spentText / \$budgetText',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            );
                          },
                        );
                      },
                    ),
                    Spacer(),
                    FutureBuilder<String>(
                      future: _formatAmount(budget - spent),
                      builder: (context, snapshot) {
                        return Text(
                          '${snapshot.data ?? '$_currencySymbol${(budget - spent).toStringAsFixed(2)}'} left',
                          style: TextStyle(
                            color: _getBudgetColor(percentage),
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCategoriesSkeleton() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF2A2D3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildShimmerContainer(width: 140, height: 18),
          SizedBox(height: 20),
          Row(
            children: [
              buildShimmerContainer(width: 120, height: 120, borderRadius: 60),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: List.generate(4, (index) => _buildLegendItemSkeleton()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItemSkeleton() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          buildShimmerContainer(width: 12, height: 12, borderRadius: 6),
          SizedBox(width: 8),
          buildShimmerContainer(width: 80, height: 14),
          Spacer(),
          buildShimmerContainer(width: 30, height: 14),
        ],
      ),
    );
  }

  Widget _buildBudgetProgressSkeleton() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF2A2D3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildShimmerContainer(width: 120, height: 18),
          SizedBox(height: 20),
          ...List.generate(4, (index) => _buildBudgetItemSkeleton()),
        ],
      ),
    );
  }

  Widget _buildBudgetItemSkeleton() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildShimmerContainer(width: 100, height: 14),
              buildShimmerContainer(width: 30, height: 14),
            ],
          ),
          SizedBox(height: 6),
          buildShimmerContainer(width: double.infinity, height: 4, borderRadius: 2),
        ],
      ),
    );
  }
}

// Updated ActualHomePage class
class ActualHomePage extends StatefulWidget {
  @override
  _ActualHomePageState createState() => _ActualHomePageState();
}

class _ActualHomePageState extends State<ActualHomePage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? HomePageSkeletonLoading()
        : Scaffold(
            backgroundColor: Color(0xFF1A1D29),
            body: ActualHomePageContent(),
          );
  }
}

// Updated ActualHomePageContent with complete currency support
class ActualHomePageContent extends StatefulWidget {
  const ActualHomePageContent({Key? key}) : super(key: key);

  @override
  State<ActualHomePageContent> createState() => _ActualHomePageContentState();
}

class _ActualHomePageContentState extends State<ActualHomePageContent> {
  final ProfileService _profileService = ProfileService();
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
      case 'food': return Colors.orange;
      case 'transport': return Colors.brown;
      case 'bills': return Colors.red;
      case 'shopping': return Colors.pink;
      case 'fun': return Colors.purple;
      case 'health': return Colors.green;
      case 'salary': return Colors.green;
      case 'freelance': return Colors.orange;
      case 'investment': return Colors.brown;
      case 'bonus': return Colors.purple;
      default: return Colors.grey;
    }
  }

  // Currency selection handler
  Future<void> _onCurrencyChanged() async {
    await _loadCurrencySettings();
    setState(() {}); // Refresh the UI
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF1A1D29),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: 20),
              _buildBalanceCard(),
              SizedBox(height: 20),
              _buildIncomeExpenseCards(),
              SizedBox(height: 30),
              _buildBudgetManagement(),
              SizedBox(height: 20),
              _buildBudgetInsightsCard(),
              SizedBox(height: 20),
              _buildCategoryBudgets(),
              SizedBox(height: 20),
              _buildSpendingAnalysis(),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _profileService.getUserProfileStream(),
      builder: (context, snapshot) {
        String userName = 'User';
        String? profileImagePath;
        
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          userName = data['name'] ?? 'User';
          profileImagePath = data['profileImagePath'];
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good ${_getTimeOfDay()}, $userName',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Here\'s your financial overview',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                // Currency selector button
                GestureDetector(
                  onTap: () async {
                    final currencyInfo = await _currencyService.getCurrencyInfo();
                    showDialog(
                      context: context,
                      builder: (context) => CurrencySelectionDialog(
                        currentCurrency: _selectedCurrency,
                        onCurrencySelected: (currency) async {
                          await _currencyService.saveCurrency(currency);
                          await _onCurrencyChanged();
                        },
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF2A2D3A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _selectedCurrency,
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.orange,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFF2A2D3A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.orange, width: 2),
                    ),
                    child: ClipOval(
                      child: profileImagePath != null && File(profileImagePath).existsSync()
                          ? Image.file(
                              File(profileImagePath),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[600],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                );
                              },
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[600],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'morning';
    } else if (hour < 17) {
      return 'afternoon';
    } else {
      return 'evening';
    }
  }

  Widget _buildBalanceCard() {
    if (_currentUserId == null) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.deepOrange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: _currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        double totalIncome = 0.0;
        double totalExpenses = 0.0;

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final type = data['type'] as String;
            final amount = (data['amount'] as num).toDouble();

            if (type == 'Income') {
              totalIncome += amount;
            } else {
              totalExpenses += amount;
            }
          }
        }

        final balance = totalIncome - totalExpenses;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.deepOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Current Balance',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    Icons.visibility_off_outlined,
                    color: Colors.white.withOpacity(0.8),
                    size: 20,
                  ),
                ],
              ),
              SizedBox(height: 12),
              FutureBuilder<String>(
                future: _formatAmount(balance),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? '$_currencySymbol${balance.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              SizedBox(height: 12),
              Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      FutureBuilder<String>(
                        future: _formatAmount(totalIncome),
                        builder: (context, snapshot) {
                          return Text(
                            'Income: ${snapshot.data ?? '$_currencySymbol${totalIncome.toStringAsFixed(2)}'}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      FutureBuilder<String>(
                        future: _formatAmount(totalExpenses),
                        builder: (context, snapshot) {
                          return Text(
                            'Expenses: ${snapshot.data ?? '$_currencySymbol${totalExpenses.toStringAsFixed(2)}'}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildIncomeExpenseCards() {
    if (_currentUserId == null) {
      return Row(
        children: [
          Expanded(child: _buildPlaceholderCard('Income', '+${_currencySymbol}0.00', Colors.green)),
          SizedBox(width: 16),
          Expanded(child: _buildPlaceholderCard('Expense', '-${_currencySymbol}0.00', Colors.red)),
        ],
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: _currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        double monthlyIncome = 0.0;
        double monthlyExpenses = 0.0;

        if (snapshot.hasData) {
          final now = DateTime.now();
          final currentMonth = now.month;
          final currentYear = now.year;

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final type = data['type'] as String;
            final amount = (data['amount'] as num).toDouble();
            final date = (data['date'] as Timestamp).toDate();

            if (date.month == currentMonth && date.year == currentYear) {
              if (type == 'Income') {
                monthlyIncome += amount;
              } else {
                monthlyExpenses += amount;
              }
            }
          }
        }

        return Row(
          children: [
            Expanded(
              child: Container(
                height: 60,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF2A2D3A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Income - This Month',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 10,
                      ),
                    ),
                    SizedBox(height: 4),
                    FutureBuilder<String>(
                      future: _formatAmount(monthlyIncome),
                      builder: (context, snapshot) {
                        return FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '+${snapshot.data ?? '$_currencySymbol${monthlyIncome.toStringAsFixed(2)}'}',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 60,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF2A2D3A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Expenses - This Month',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 10,
                      ),
                    ),
                    SizedBox(height: 4),
                    FutureBuilder<String>(
                      future: _formatAmount(monthlyExpenses),
                      builder: (context, snapshot) {
                        return FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '-${snapshot.data ?? '$_currencySymbol${monthlyExpenses.toStringAsFixed(2)}'}',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlaceholderCard(String title, String amount, Color color) {
    return Container(
      height: 60,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Color(0xFF2A2D3A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                title == 'Income' ? Icons.trending_up : Icons.trending_down,
                color: color,
                size: 14,
              ),
              SizedBox(width: 4),
              Text(
                '$title - This Month',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 10,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetManagement() {
    // Mock data - replace with real data from your state management
    double totalBudget = 4500.0;
    double amountSpent = 3200.0;
    double remaining = totalBudget - amountSpent;

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
            'Budget Management',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 20),
          
          // Total Budget Card
          FutureBuilder<String>(
            future: _formatAmount(totalBudget),
            builder: (context, snapshot) {
              return _buildBudgetCard(
                icon: Icons.account_balance_wallet,
                iconColor: Colors.blue,
                iconBgColor: Colors.blue.withOpacity(0.2),
                title: 'Total Budget',
                amount: snapshot.data ?? '$_currencySymbol${totalBudget.toStringAsFixed(0)}',
                subtitle: 'Set for this month',
                actionText: 'Manage',
                actionColor: Colors.blue,
              );
            },
          ),
          
          SizedBox(height: 16),
          
          // Amount Spent Card
          FutureBuilder<String>(
            future: _formatAmount(amountSpent),
            builder: (context, snapshot) {
              return _buildBudgetCard(
                icon: Icons.trending_up,
                iconColor: Colors.orange,
                iconBgColor: Colors.orange.withOpacity(0.2),
                title: 'Amount Spent',
                amount: snapshot.data ?? '$_currencySymbol${amountSpent.toStringAsFixed(0)}',
                subtitle: '71% of budget',
                actionText: 'Used',
                actionColor: Colors.orange,
              );
            },
          ),
          
          SizedBox(height: 16),
          
          // Remaining Card
          FutureBuilder<String>(
            future: _formatAmount(remaining),
            builder: (context, snapshot) {
              return _buildBudgetCard(
                icon: Icons.savings,
                iconColor: Colors.green,
                iconBgColor: Colors.green.withOpacity(0.2),
                title: 'Remaining',
                amount: snapshot.data ?? '$_currencySymbol${remaining.toStringAsFixed(0)}',
                subtitle: '29% left to spend',
                actionText: 'Available',
                actionColor: Colors.green,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String amount,
    required String subtitle,
    required String actionText,
    required Color actionColor,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF3A3D4A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: iconColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon Section
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          
          SizedBox(width: 16),
          
          // Content Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  amount,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Action Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: actionColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: actionColor,
                width: 1,
              ),
            ),
            child: Text(
              actionText,
              style: TextStyle(
                color: actionColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetInsightsCard() {
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
              Icon(
                Icons.insights,
                color: Colors.orange,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Budget Insights',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            '• You\'re spending 15% more on food this month compared to last month',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          FutureBuilder<String>(
            future: _formatAmount(50.0),
            builder: (context, snapshot) {
              final formattedAmount = snapshot.data ?? '\$50';
              return Text(
                '• Transport costs are under control - you\'re saving $formattedAmount this month',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              );
            },
          ),
          SizedBox(height: 8),
          Text(
            '• Consider reducing shopping expenses to meet your budget goals',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBudgets() {
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
          _buildCategoryItem('Food', Icons.restaurant, 450.0, 800.0, Colors.orange),
          _buildCategoryItem('Transport', Icons.directions_car, 230.0, 400.0, Colors.brown),
          _buildCategoryItem('Bills', Icons.receipt_long, 380.0, 500.0, Colors.red),
          _buildCategoryItem('Shopping', Icons.shopping_bag, 320.0, 500.0, Colors.pink),
          _buildCategoryItem('Fun', Icons.sports_esports, 150.0, 300.0, Colors.purple),
          _buildCategoryItem('Health', Icons.favorite, 200.0, 250.0, Colors.green),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String name, IconData icon, double spent, double budget, Color color) {
    double percentage = budget > 0 ? (spent / budget) * 100 : 0;
    double progressValue = budget > 0 ? spent / budget : 0.0;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${percentage.toInt()}%',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progressValue.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getBudgetColor(percentage),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    FutureBuilder<String>(
                      future: _formatAmount(spent),
                      builder: (context, spentSnapshot) {
                        return FutureBuilder<String>(
                          future: _formatAmount(budget),
                          builder: (context, budgetSnapshot) {
                            final spentText = spentSnapshot.data ?? '$_currencySymbol${spent.toStringAsFixed(2)}';
                            final budgetText = budgetSnapshot.data ?? '$_currencySymbol${budget.toStringAsFixed(2)}';
                            return Text(
                              '$spentText / \$budgetText',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            );
                          },
                        );
                      },
                    ),
                    Spacer(),
                    FutureBuilder<String>(
                      future: _formatAmount(budget - spent),
                      builder: (context, snapshot) {
                        return Text(
                          '${snapshot.data ?? '$_currencySymbol${(budget - spent).toStringAsFixed(2)}'} left',
                          style: TextStyle(
                            color: _getBudgetColor(percentage),
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getBudgetColor(double percentage) {
    if (percentage >= 90) {
      return Colors.red;
    } else if (percentage >= 70) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  Widget _buildSpendingAnalysis() {
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
              Icon(
                Icons.pie_chart,
                color: Colors.orange,
                size: 24,
              ),
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
              width: 150,
              height: 150,
              child: CustomPaint(
                painter: PieChartPainter({
                  'Food': 450.0,
                  'Transport': 230.0,
                  'Bills': 380.0,
                  'Shopping': 320.0,
                  'Fun': 150.0,
                }, 1530.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '\$1,530',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
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
          _buildExpenseLegend(),
        ],
      ),
    );
  }

  Widget _buildExpenseLegend() {
    return Column(
      children: [
        _buildLegendItem('Food', Colors.orange, 450.0),
        _buildLegendItem('Bills', Colors.red, 380.0),
        _buildLegendItem('Shopping', Colors.pink, 320.0),
        _buildLegendItem('Transport', Colors.brown, 230.0),
        _buildLegendItem('Fun', Colors.purple, 150.0),
      ],
    );
  }

  Widget _buildLegendItem(String name, Color color, double amount) {
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
              name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          FutureBuilder<String>(
            future: _formatAmount(amount),
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? '$_currencySymbol${amount.toStringAsFixed(0)}',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
