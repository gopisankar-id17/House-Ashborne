import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:math' as math;
import '../services/profile_service.dart';
import '../services/session_service.dart';

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
          buildShimmerContainer(width: 140, height: 18),
          SizedBox(height: 20),
          Container(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) => _buildBarChartSkeleton()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartSkeleton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        buildShimmerContainer(width: 20, height: 60, borderRadius: 10),
        SizedBox(height: 8),
        buildShimmerContainer(width: 25, height: 12),
      ],
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

// Updated ActualHomePageContent with profile integration and real transaction data
class ActualHomePageContent extends StatefulWidget {
  const ActualHomePageContent({Key? key}) : super(key: key);

  @override
  State<ActualHomePageContent> createState() => _ActualHomePageContentState();
}

class _ActualHomePageContentState extends State<ActualHomePageContent> {
  final ProfileService _profileService = ProfileService();
  final SessionService _sessionService = SessionService();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final userId = await _sessionService.getUserSession();
    setState(() {
      _currentUserId = userId;
    });
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
          print('Profile image path from Firestore: $profileImagePath');
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
                                print('Error loading profile image: $error');
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
              Text(
                '\$${balance.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
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
                  Text(
                    'Income: \$${totalIncome.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 20),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Expenses: \$${totalExpenses.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
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
  
  Widget _buildIncomeExpenseCards() {
    if (_currentUserId == null) {
      return Row(
        children: [
          Expanded(child: _buildPlaceholderCard('Income', '+\$0.00', Colors.green)),
          SizedBox(width: 16),
          Expanded(child: _buildPlaceholderCard('Expense', '-\$0.00', Colors.red)),
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

            // Check if transaction is from current month
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
                        SizedBox(width: 8),
                        Text(
                          'This Month',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '+\$${monthlyIncome.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
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
                          Icons.trending_down,
                          color: Colors.red,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'This Month',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '-\$${monthlyExpenses.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
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
                title == 'Income' ? Icons.trending_up : Icons.trending_down,
                color: color,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'This Month',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

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
        double totalSpent = 0.0;
        final double totalBudget = 4500.0; // You can make this dynamic later

        if (snapshot.hasData) {
          final now = DateTime.now();
          final currentMonth = now.month;
          final currentYear = now.year;

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final type = data['type'] as String;
            final amount = (data['amount'] as num).toDouble();
            final date = (data['date'] as Timestamp).toDate();

            // Only count expenses for current month
            if (type == 'Expense' && date.month == currentMonth && date.year == currentYear) {
              totalSpent += amount;
            }
          }
        }

        final remaining = totalBudget - totalSpent;
        final spentPercentage = totalBudget > 0 ? (totalSpent / totalBudget * 100).round() : 0;
        final remainingPercentage = 100 - spentPercentage;

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
                      Icon(
                        Icons.donut_large,
                        color: Colors.orange,
                        size: 20,
                      ),
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
                  GestureDetector(
                    onTap: () {
                      // Add navigation to budget settings if needed
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.settings,
                          color: Colors.orange,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Manage',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
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
                          Icon(
                            Icons.pie_chart,
                            color: Colors.blue,
                            size: 24,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Total\nBudget',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
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
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 10,
                            ),
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
                          Icon(
                            Icons.attach_money,
                            color: Colors.orange,
                            size: 24,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Spent',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
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
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 10,
                            ),
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
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 24,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Remaining',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
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
                            '$remainingPercentage% left',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 10,
                            ),
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

  Widget _buildStaticBudgetManagement() {
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
                  Icon(
                    Icons.donut_large,
                    color: Colors.orange,
                    size: 20,
                  ),
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
              GestureDetector(
                onTap: () {
                  // Add navigation to budget settings if needed
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.settings,
                      color: Colors.orange,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Manage',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
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
                      Icon(
                        Icons.pie_chart,
                        color: Colors.blue,
                        size: 24,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Total\nBudget',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '\$4,500',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'This month',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 10,
                        ),
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
                      Icon(
                        Icons.attach_money,
                        color: Colors.orange,
                        size: 24,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Spent',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '\$0',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '0% of budget',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 10,
                        ),
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
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 24,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Remaining',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '\$4,500',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '100% left',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                        ),
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
        Map<String, double> categorySpending = {};
        
        if (snapshot.hasData) {
          final now = DateTime.now();
          final currentMonth = now.month;
          final currentYear = now.year;

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final category = data['category'] as String;
            final amount = (data['amount'] as num).toDouble();
            final date = (data['date'] as Timestamp).toDate();

            // Only count expenses for current month
            if (date.month == currentMonth && date.year == currentYear) {
              categorySpending[category] = (categorySpending[category] ?? 0) + amount;
            }
          }
        }

        // Define budget limits for categories (you can make these dynamic later)
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
                
                return _buildCategoryItem(
                  category,
                  icon,
                  spent,
                  budget,
                  _getCategoryColor(category),
                );
              }).toList(),
              SizedBox(height: 20),
              _buildBudgetInsights(categorySpending, categoryBudgets),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStaticCategoryBudgets() {
    final categories = [
      {'name': 'Food', 'icon': Icons.restaurant, 'spent': 0.00, 'budget': 800.00, 'color': Colors.orange},
      {'name': 'Transport', 'icon': Icons.directions_car, 'spent': 0.00, 'budget': 300.00, 'color': Colors.brown},
      {'name': 'Bills', 'icon': Icons.home, 'spent': 0.00, 'budget': 1200.00, 'color': Colors.red},
      {'name': 'Shopping', 'icon': Icons.shopping_bag, 'spent': 0.00, 'budget': 500.00, 'color': Colors.pink},
      {'name': 'Fun', 'icon': Icons.movie, 'spent': 0.00, 'budget': 200.00, 'color': Colors.purple},
      {'name': 'Health', 'icon': Icons.local_hospital, 'spent': 0.00, 'budget': 300.00, 'color': Colors.green},
    ];

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
          SizedBox(height: 20),
          _buildStaticBudgetInsights(),
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
                // Progress Bar
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
                    Text(
                      '\$${spent.toStringAsFixed(2)} / \$${budget.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                    Spacer(),
                    Text(
                      '\$${(budget - spent).toStringAsFixed(2)} left',
                      style: TextStyle(
                        color: _getBudgetColor(percentage),
                        fontSize: 12,
                      ),
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

  Widget _buildBudgetInsights(Map<String, double> categorySpending, Map<String, double> categoryBudgets) {
    // Calculate insights based on actual spending
    bool allWithinBudget = true;
    String topSpendingCategory = '';
    double highestSpending = 0;

    categorySpending.forEach((category, spent) {
      final budget = categoryBudgets[category] ?? 0;
      if (budget > 0 && (spent / budget) > 0.9) {
        allWithinBudget = false;
      }
      if (spent > highestSpending) {
        highestSpending = spent;
        topSpendingCategory = category;
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget Insights',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF1A1D29),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          allWithinBudget ? Icons.check_circle : Icons.warning,
                          color: allWithinBudget ? Colors.green : Colors.orange,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          allWithinBudget ? 'Good News' : 'Warning',
                          style: TextStyle(
                            color: allWithinBudget ? Colors.green : Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      allWithinBudget 
                          ? 'You\'re staying within budget across all categories this month. Keep up the great work!'
                          : 'Some categories are approaching their budget limits. Consider reviewing your spending.',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF1A1D29),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.blue,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Tip',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      topSpendingCategory.isNotEmpty 
                          ? 'Your highest spending category is $topSpendingCategory. Consider tracking it more closely.'
                          : 'Consider setting aside 10% of your income for savings and emergency funds.',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStaticBudgetInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget Insights',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF1A1D29),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Good News',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Ready to start tracking your expenses! Add your first transaction to see budget insights.',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF1A1D29),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.blue,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Tip',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Consider setting aside 10% of your income for savings and emergency funds.',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
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
        Map<String, double> categoryExpenses = {};
        double totalExpenses = 0.0;

        if (snapshot.hasData) {
          final now = DateTime.now();
          final currentMonth = now.month;
          final currentYear = now.year;

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final category = data['category'] as String;
            final amount = (data['amount'] as num).toDouble();
            final date = (data['date'] as Timestamp).toDate();

            // Only count expenses for current month
            if (date.month == currentMonth && date.year == currentYear) {
              categoryExpenses[category] = (categoryExpenses[category] ?? 0) + amount;
              totalExpenses += amount;
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
                  Icon(
                    Icons.pie_chart,
                    color: Colors.orange,
                    size: 20,
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
              Row(
                children: [
                  Text(
                    'Expense Breakdown',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  Spacer(),
                  Icon(
                    Icons.access_time,
                    color: Colors.grey[400],
                    size: 16,
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
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
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

  Widget _buildStaticSpendingAnalysis() {
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
                size: 20,
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
          Row(
            children: [
              Text(
                'Expense Breakdown',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
              Spacer(),
              Icon(
                Icons.access_time,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
          SizedBox(height: 20),
          Center(
            child: Container(
              width: 160,
              height: 160,
              child: CustomPaint(
                painter: PieChartPainter(),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '\$0',
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
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.grey[600],
                  size: 40,
                ),
                SizedBox(height: 10),
                Text(
                  'No expenses yet',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Add transactions to see your spending analysis',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseLegend(Map<String, double> categoryExpenses) {
    if (categoryExpenses.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.grey[600],
              size: 40,
            ),
            SizedBox(height: 10),
            Text(
              'No expenses yet',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
            Text(
              'Add transactions to see your spending breakdown',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Sort categories by amount (highest first)
    final sortedEntries = categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedEntries.map((entry) => 
        Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
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
              Text(
                entry.key,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              Spacer(),
              Text(
                '\$${entry.value.toStringAsFixed(0)}',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ).toList(),
    );
  }
}

// Custom Painter Classes for Pie Charts
class DynamicPieChartPainter extends CustomPainter {
  final Map<String, double> categoryExpenses;

  DynamicPieChartPainter(this.categoryExpenses);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    if (categoryExpenses.isEmpty) {
      // Draw empty circle
      final paint = Paint()
        ..color = Colors.grey[700]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8;
      
      canvas.drawCircle(center, radius - 4, paint);
      return;
    }

    final totalAmount = categoryExpenses.values.fold(0.0, (sum, amount) => sum + amount);
    
    if (totalAmount == 0) {
      // Draw empty circle
      final paint = Paint()
        ..color = Colors.grey[700]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8;
      
      canvas.drawCircle(center, radius - 4, paint);
      return;
    }

    double startAngle = -math.pi / 2; // Start from top
    
    categoryExpenses.forEach((category, amount) {
      final sweepAngle = (amount / totalAmount) * 2 * math.pi;
      
      final paint = Paint()
        ..color = _getCategoryColorForPaint(category)
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

  Color _getCategoryColorForPaint(String category) {
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    // Draw empty circle for no data state
    final paint = Paint()
      ..color = Colors.grey[700]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    
    canvas.drawCircle(center, radius - 4, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}