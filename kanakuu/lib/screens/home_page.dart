import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:math' as math;
import '../services/profile_service.dart';
import '../services/session_service.dart';
import '../services/currency_service.dart';
import '../services/budget_management_service.dart';
import 'home_page_painters.dart';
import 'budget_management_page.dart';
import 'category_management_page.dart';

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildShimmerContainer(width: 140, height: 18),
              buildShimmerContainer(width: 100, height: 24, borderRadius: 12),
            ],
          ),
          SizedBox(height: 20),
          // Category skeleton items
          for (int i = 0; i < 3; i++) ...[
            _buildCategorySkeletonItem(),
            if (i < 2) SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildCategorySkeletonItem() {
    return Row(
      children: [
        buildShimmerContainer(width: 40, height: 40, borderRadius: 8),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildShimmerContainer(width: 80, height: 16),
                  buildShimmerContainer(width: 40, height: 14),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  buildShimmerContainer(width: 60, height: 12),
                  SizedBox(width: 8),
                  buildShimmerContainer(width: 60, height: 12),
                ],
              ),
              SizedBox(height: 8),
              buildShimmerContainer(width: double.infinity, height: 6, borderRadius: 3),
            ],
          ),
        ),
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
  final BudgetManagementService _budgetService = BudgetManagementService();
  String? _currentUserId;
  String _currencySymbol = '\$';
  String _selectedCurrency = 'USD';
  String _selectedTimePeriod = 'Current Month'; // Add time period state

  // Helper method to check if URL is a network URL or local file path
  bool _isNetworkUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

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
        return Colors.orange.shade800;
      case 'shopping':
        return Colors.orange.shade300;
      case 'bills & utilities':
      case 'bills':
        return Colors.purple;
      case 'entertainment':
      case 'fun':
        return Colors.green;
      case 'healthcare':
      case 'health':
        return Colors.purple.shade300;
      case 'education':
        return Colors.blue;
      case 'travel':
        return Colors.teal;
      case 'fitness':
        return Colors.lightGreen;
      case 'salary':
        return Colors.green;
      case 'freelance':
        return Colors.orange;
      case 'investment':
        return Colors.brown;
      case 'bonus':
        return Colors.purple;
      case 'others':
      case 'other':
        return Colors.grey;
      default:
        // Generate consistent colors for unknown categories
        final colors = [
          Colors.orange,
          Colors.orange.shade800,
          Colors.orange.shade300,
          Colors.purple,
          Colors.green,
          Colors.purple.shade300,
          Colors.blue,
          Colors.teal,
          Colors.lightGreen,
          Colors.grey,
        ];
        return colors[category.hashCode % colors.length];
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
              _buildCategoryBreakdown(),
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
        String? profileImageUrl;
        
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          userName = data['name'] ?? 'User';
          profileImageUrl = data['profileImageUrl'] ?? data['profileImagePath']; // Try both fields for profile image
          print('🏠 Home page profile image URL: $profileImageUrl');
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
                      child: profileImageUrl != null && profileImageUrl.isNotEmpty
                          ? _isNetworkUrl(profileImageUrl)
                              ? Image.network(
                                  profileImageUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[600],
                                        shape: BoxShape.circle,
                                      ),
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                            : null,
                                        color: Colors.orange,
                                        strokeWidth: 2,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    print('❌ Home page: Error loading profile image: $error');
                                    print('🔗 Home page: Failed URL: $profileImageUrl');
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[600],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.orange,
                                        size: 20,
                                      ),
                                    );
                                  },
                                )
                              : File(profileImageUrl).existsSync()
                                  ? Image.file(
                                      File(profileImageUrl),
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[600],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.orange,
                                        size: 20,
                                      ),
                                    )
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[600],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person,
                                color: Colors.orange,
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
            final amount = (data['originalAmount'] as num?)?.toDouble() ?? (data['amount'] as num).toDouble(); // Use originalAmount if available

            if (type == 'Income') {
              totalIncome += amount;
            } else {
              totalExpenses += amount;
            }
          }
        }

        final balance = totalIncome - totalExpenses;
        final hasTransactions = snapshot.hasData && snapshot.data!.docs.isNotEmpty;

        // Show empty state if no transactions
        if (!hasTransactions) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey.shade700, Colors.grey.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
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
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white.withOpacity(0.8),
                      size: 20,
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  '$_currencySymbol${0.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        color: Colors.white.withOpacity(0.6),
                        size: 32,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No transactions yet',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Add your first income or expense to see your balance',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.deepOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
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
                      fontWeight: FontWeight.w300,
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
                      fontSize: 25,
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
            final amount = (data['originalAmount'] as num?)?.toDouble() ?? (data['amount'] as num).toDouble(); // Use originalAmount if available
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
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Income - This Month',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
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
                              fontSize: 16,
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
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Expenses - This Month',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
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
                              fontSize: 16,
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
    if (_currentUserId == null) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFF2A2D3A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    final now = DateTime.now();
    final targetMonth = DateTime(now.year, now.month, 1);
    final docId = '${_currentUserId}_${targetMonth.year}_${targetMonth.month}';

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('monthly_budgets')
          .doc(docId)
          .snapshots(),
      builder: (context, monthlyBudgetSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('transactions')
              .where('userId', isEqualTo: _currentUserId)
              .where('type', isEqualTo: 'Expense')
              .snapshots(),
          builder: (context, expenseSnapshot) {
            // Get monthly budget data
            final monthlyBudgetData = monthlyBudgetSnapshot.hasData && monthlyBudgetSnapshot.data!.exists
                ? monthlyBudgetSnapshot.data!.data() as Map<String, dynamic>?
                : null;

            double totalBudget = 0.0;
            double totalSpent = 0.0;

            // Get monthly budget amount
            if (monthlyBudgetData != null) {
              totalBudget = (monthlyBudgetData['totalAmount'] as num?)?.toDouble() ?? 0.0;
            }

            // Calculate total spent this month
            if (expenseSnapshot.hasData) {
              final currentMonth = now.month;
              final currentYear = now.year;

              for (var doc in expenseSnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                final amount = (data['originalAmount'] as num?)?.toDouble() ?? (data['amount'] as num).toDouble();
                final date = (data['date'] as Timestamp).toDate();

                if (date.month == currentMonth && date.year == currentYear) {
                  totalSpent += amount;
                }
              }
            }

            final remaining = totalBudget - totalSpent;

            // Show empty state if no monthly budget is set
            if (totalBudget == 0.0) {
              return Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFF2A2D3A),
                  borderRadius: BorderRadius.circular(20),
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
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color(0xFF3A3D4A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            color: Colors.grey[400],
                            size: 48,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No Monthly Budget Set',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Set up your monthly budget to track your spending and get insights',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BudgetManagementPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Set Monthly Budget',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
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

            // Calculate percentages
            final spentPercentage = totalBudget > 0 ? (totalSpent / totalBudget * 100) : 0.0;
            final remainingPercentage = totalBudget > 0 ? (remaining / totalBudget * 100) : 0.0;

            return Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF2A2D3A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Budget Management',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BudgetManagementPage(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        ),
                        child: Text(
                          'Manage',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  
                  // Budget breakdown cards
                  Row(
                    children: [
                      // Total Budget Card
                      Expanded(
                        child: FutureBuilder<String>(
                          future: _formatAmount(totalBudget),
                          builder: (context, snapshot) {
                            return Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color(0xFF3A3D4A),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.blue.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.account_balance_wallet,
                                          color: Colors.blue,
                                          size: 16,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Total Budget',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    snapshot.data ?? '$_currencySymbol${totalBudget.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Set for this month',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      
                      SizedBox(width: 12),
                      
                      // Amount Spent Card
                      Expanded(
                        child: FutureBuilder<String>(
                          future: _formatAmount(totalSpent),
                          builder: (context, snapshot) {
                            final percentage = totalBudget > 0 ? (totalSpent / totalBudget * 100).toInt() : 0;
                            return Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color(0xFF3A3D4A),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.orange.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.trending_up,
                                          color: Colors.orange,
                                          size: 16,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Amount Spent',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    snapshot.data ?? '$_currencySymbol${totalSpent.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '$percentage% of budget',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 12),
                  
                  // Remaining Card (full width)
                  FutureBuilder<String>(
                    future: _formatAmount(remaining),
                    builder: (context, snapshot) {
                      final percentage = totalBudget > 0 ? (remaining / totalBudget * 100).toInt() : 0;
                      return Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFF3A3D4A),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: (remaining >= 0 ? Colors.green : Colors.red).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: (remaining >= 0 ? Colors.green : Colors.red).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.savings,
                                color: remaining >= 0 ? Colors.green : Colors.red,
                                size: 16,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Remaining',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    snapshot.data ?? '$_currencySymbol${remaining.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    remaining >= 0 ? '$percentage% left to spend' : 'Over budget',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (remaining >= 0 ? Colors.green : Colors.red).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: remaining >= 0 ? Colors.green : Colors.red,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                remaining >= 0 ? 'Available' : 'Exceeded',
                                style: TextStyle(
                                  color: remaining >= 0 ? Colors.green : Colors.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
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
        borderRadius: BorderRadius.circular(20),
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
              borderRadius: BorderRadius.circular(20),
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
                    fontSize: 16,
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
    if (_currentUserId == null) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFF2A2D3A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: _currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          // Show empty state when no transactions
          return Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF2A2D3A),
              borderRadius: BorderRadius.circular(20),
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
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFF3A3D4A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.insights_outlined,
                        color: Colors.grey[400],
                        size: 48,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No Insights Available',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Start adding transactions to get personalized budget insights and spending analysis',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[400],
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

        // Calculate insights from real data
        final now = DateTime.now();
        final currentMonth = now.month;
        final currentYear = now.year;
        final lastMonth = currentMonth == 1 ? 12 : currentMonth - 1;
        final lastMonthYear = currentMonth == 1 ? currentYear - 1 : currentYear;

        Map<String, double> currentMonthExpenses = {};
        Map<String, double> lastMonthExpenses = {};
        double totalSavings = 0.0;

        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final amount = (data['originalAmount'] as num?)?.toDouble() ?? (data['amount'] as num).toDouble(); // Use originalAmount if available
          final category = data['category'] as String? ?? 'Other';
          final date = (data['date'] as Timestamp).toDate();
          final type = data['type'] as String;

          if (type == 'Expense') {
            if (date.month == currentMonth && date.year == currentYear) {
              currentMonthExpenses[category] = (currentMonthExpenses[category] ?? 0.0) + amount;
            } else if (date.month == lastMonth && date.year == lastMonthYear) {
              lastMonthExpenses[category] = (lastMonthExpenses[category] ?? 0.0) + amount;
            }
          } else if (type == 'Income') {
            if (date.month == currentMonth && date.year == currentYear) {
              totalSavings += amount;
            }
          }
        }

        // Calculate total expenses for comparison
        final currentTotal = currentMonthExpenses.values.fold(0.0, (sum, amount) => sum + amount);
        final lastTotal = lastMonthExpenses.values.fold(0.0, (sum, amount) => sum + amount);
        totalSavings -= currentTotal; // Net savings

        List<Widget> insights = [];

        // Compare spending with last month
        if (lastTotal > 0) {
          final difference = ((currentTotal - lastTotal) / lastTotal * 100);
          if (difference > 10) {
            insights.add(_buildInsightCard(
              icon: Icons.warning_amber,
              iconColor: Colors.orange,
              iconBgColor: Colors.orange.withOpacity(0.2),
              cardColor: Color(0xFF3A3D4A),
              borderColor: Colors.orange.withOpacity(0.3),
              header: 'Warning',
              headerColor: Colors.orange,
              content: 'You\'re spending ${difference.toInt()}% more this month compared to last month',
            ));
          } else if (difference < -10) {
            insights.add(_buildInsightCard(
              icon: Icons.tips_and_updates,
              iconColor: Colors.green,
              iconBgColor: Colors.green.withOpacity(0.2),
              cardColor: Color(0xFF3A3D4A),
              borderColor: Colors.green.withOpacity(0.3),
              header: 'Good News',
              headerColor: Colors.green,
              content: 'Great job! You\'re spending ${difference.abs().toInt()}% less this month',
            ));
          }
        }

        // Category-specific insights
        currentMonthExpenses.forEach((category, amount) {
          final lastAmount = lastMonthExpenses[category] ?? 0.0;
          if (lastAmount > 0) {
            final categoryDiff = ((amount - lastAmount) / lastAmount * 100);
            if (categoryDiff > 20) {
              insights.add(_buildInsightCard(
                icon: Icons.info_outline,
                iconColor: Colors.blue,
                iconBgColor: Colors.blue.withOpacity(0.2),
                cardColor: Color(0xFF3A3D4A),
                borderColor: Colors.blue.withOpacity(0.3),
                header: 'Tip',
                headerColor: Colors.blue,
                content: 'Consider reviewing your $category expenses - they\'ve increased by ${categoryDiff.toInt()}%',
              ));
            }
          }
        });

        // Savings insight
        if (totalSavings > 0) {
          insights.add(_buildInsightCard(
            icon: Icons.savings,
            iconColor: Colors.green,
            iconBgColor: Colors.green.withOpacity(0.2),
            cardColor: Color(0xFF3A3D4A),
            borderColor: Colors.green.withOpacity(0.3),
            header: 'Good News',
            headerColor: Colors.green,
            content: 'You have positive savings this month! Keep up the good work.',
          ));
        }

        // If no meaningful insights, show general tip
        if (insights.isEmpty) {
          insights.add(_buildInsightCard(
            icon: Icons.info_outline,
            iconColor: Colors.blue,
            iconBgColor: Colors.blue.withOpacity(0.2),
            cardColor: Color(0xFF3A3D4A),
            borderColor: Colors.blue.withOpacity(0.3),
            header: 'Tip',
            headerColor: Colors.blue,
            content: 'Track your expenses regularly to get better insights and improve your spending habits',
          ));
        }

        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF2A2D3A),
            borderRadius: BorderRadius.circular(20),
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
              SizedBox(height: 20),
              ...insights.take(3).map((insight) => [
                insight,
                if (insights.indexOf(insight) < insights.length - 1) SizedBox(height: 12),
              ]).expand((element) => element),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required Color cardColor,
    required Color borderColor,
    required String header,
    required Color headerColor,
    required String content,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Section
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          
          SizedBox(width: 12),
          
          // Content Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  header,
                  style: TextStyle(
                    color: headerColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  content,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBudgets() {
    if (_currentUserId == null) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFF2A2D3A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('category_budgets')
          .where('userId', isEqualTo: _currentUserId)
          .snapshots(),
      builder: (context, budgetSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('transactions')
              .where('userId', isEqualTo: _currentUserId)
              .where('type', isEqualTo: 'Expense')
              .snapshots(),
          builder: (context, expenseSnapshot) {
            Map<String, double> categoryBudgets = {};
            Map<String, double> categorySpending = {};

            // Get category budgets
            if (budgetSnapshot.hasData) {
              print('DEBUG Home: Found ${budgetSnapshot.data!.docs.length} budget documents');
              for (var doc in budgetSnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                print('DEBUG Home: Budget doc data: $data');
                final categoryName = data['categoryName'] as String; // Use categoryName instead of category
                final amount = (data['budgetAmount'] as num?)?.toDouble() ?? 0.0; // Use budgetAmount instead of amount
                categoryBudgets[categoryName] = amount;
                print('DEBUG Home: Added budget for $categoryName: \$${amount}');
              }
            } else {
              print('DEBUG Home: No budget snapshot data available');
            }

            // Calculate category spending for current month
            if (expenseSnapshot.hasData) {
              final now = DateTime.now();
              final currentMonth = now.month;
              final currentYear = now.year;

              for (var doc in expenseSnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                final amount = (data['originalAmount'] as num?)?.toDouble() ?? (data['amount'] as num).toDouble(); // Use originalAmount if available
                final category = data['category'] as String? ?? 'Other';
                final date = (data['date'] as Timestamp).toDate();

                if (date.month == currentMonth && date.year == currentYear) {
                  categorySpending[category] = (categorySpending[category] ?? 0.0) + amount;
                }
              }
            }

            print('DEBUG Home: Total category budgets found: ${categoryBudgets.length}');
            print('DEBUG Home: Category budgets: $categoryBudgets');

            // Show empty state if no category budgets are set
            if (categoryBudgets.isEmpty) {
              print('DEBUG Home: Showing empty state for category budgets');
              return Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFF2A2D3A),
                  borderRadius: BorderRadius.circular(20),
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
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CategoryManagementPage(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.blue,
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              ),
                              child: Text(
                                'Categories',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BudgetManagementPage(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.orange,
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              ),
                              child: Text(
                                'Budgets',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
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
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color(0xFF3A3D4A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.category_outlined,
                            color: Colors.grey[400],
                            size: 48,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No Category Budgets',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Set budgets for different categories like food, transport, and entertainment to better track your spending',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to budget management page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BudgetManagementPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Set Category Budgets',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
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

            return Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF2A2D3A),
                borderRadius: BorderRadius.circular(20),
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
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BudgetManagementPage(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.orange,
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            ),
                            child: Text(
                              'Manage',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
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
                    ],
                  ),
                  SizedBox(height: 20),
                  // Display actual category budgets with real spending data
                  ...categoryBudgets.entries.map((entry) {
                    final category = entry.key;
                    final budget = entry.value;
                    final spent = categorySpending[category] ?? 0.0;
                    final icon = _getCategoryIcon(category);
                    final color = _getCategoryColor(category);
                    
                    return _buildCategoryItem(category, icon, spent, budget, color);
                  }).toList(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food & dining':
      case 'food':
        return Icons.restaurant;
      case 'transportation':
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'bills & utilities':
      case 'bills':
        return Icons.receipt_long;
      case 'entertainment':
      case 'fun':
        return Icons.sports_esports;
      case 'healthcare':
      case 'health':
        return Icons.favorite;
      case 'education':
        return Icons.school;
      case 'travel':
        return Icons.flight;
      case 'fitness':
        return Icons.fitness_center;
      default:
        return Icons.category;
    }
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

  // NOTE: Analytics-related methods below are no longer used and can be removed
  // They were previously used for financial analytics that was removed from home page
  
  Widget _buildOverviewContent(double currentMonthExpenses, double currentMonthIncome, double savingsRate, double financialHealthScore) {
    return Column(
      children: [
        // Financial Health Score
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF3A3D4A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
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
                  Text(
                    financialHealthScore >= 70 ? 'Good' :
                    financialHealthScore >= 40 ? 'Fair' : 'Needs Work',
                    style: TextStyle(
                      color: financialHealthScore >= 70 ? Colors.green :
                             financialHealthScore >= 40 ? Colors.orange : Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                financialHealthScore.toInt().toString(),
                style: TextStyle(
                  color: Colors.orange,
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
              LinearProgressIndicator(
                value: financialHealthScore / 100,
                backgroundColor: Colors.grey[700],
                valueColor: AlwaysStoppedAnimation<Color>(
                  financialHealthScore >= 70 ? Colors.green :
                  financialHealthScore >= 40 ? Colors.orange : Colors.red,
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 16),
        
        // Total Spending and Savings Rate Cards
        Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF3A3D4A),
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
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Total Spending',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
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
            
            SizedBox(width: 12),
            
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF3A3D4A),
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
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Savings Rate',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${savingsRate.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      savingsRate > 0 ? 'This month' : 'No savings',
                      style: TextStyle(
                        color: Colors.grey[500],
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
    );
  }

  Widget _buildSpendingContent(Map<String, double> categoryTotals, double currentMonthExpenses) {
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF3A3D4A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Expense Breakdown',
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
                width: 160,
                height: 160,
                child: CustomPaint(
                  painter: ExpenseBreakdownPieChart(
                    Map.fromEntries(sortedCategories.take(6)),
                    currentMonthExpenses,
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Legend Below Chart
            Column(
              children: sortedCategories.take(6).map((entry) {
                final percentage = currentMonthExpenses > 0 
                    ? (entry.value / currentMonthExpenses * 100)
                    : 0.0;
                return _buildLiveExpenseLegendItem(
                  entry.key,
                  _getCategoryColor(entry.key),
                  entry.value,
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
    );
  }

  Widget _buildCategoriesContent(Map<String, double> categoryTotals, double currentMonthExpenses) {
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF3A3D4A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories This Month',
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
                final percentage = currentMonthExpenses > 0 
                    ? (entry.value / currentMonthExpenses * 100)
                    : 0.0;
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF2A2D3A),
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
                  'No category data available',
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
    );
  }

  Widget _buildGoalsContent() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF3A3D4A),
        borderRadius: BorderRadius.circular(12),
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
        color: Color(0xFF2A2D3A),
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

  Widget _buildCategoryBreakdown() {
    if (_currentUserId == null) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFF2A2D3A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: _currentUserId)
          .where('type', isEqualTo: 'Expense')
          .snapshots(),
      builder: (context, snapshot) {
        Map<String, double> categoryTotals = {};
        double totalExpenses = 0.0;

        if (snapshot.hasData) {
          final now = DateTime.now();
          final currentMonth = now.month;
          final currentYear = now.year;

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final amount = (data['originalAmount'] as num?)?.toDouble() ?? (data['amount'] as num).toDouble();
            final category = data['category'] as String? ?? 'Other';
            final date = (data['date'] as Timestamp).toDate();

            // Current month data
            if (date.month == currentMonth && date.year == currentYear) {
              categoryTotals[category] = (categoryTotals[category] ?? 0.0) + amount;
              totalExpenses += amount;
            }
          }
        }

        final sortedCategories = categoryTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        if (sortedCategories.isEmpty) {
          return Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF2A2D3A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.donut_small,
                      color: Colors.orange,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Category Breakdown',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFF3A3D4A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.donut_small_outlined,
                        color: Colors.grey[400],
                        size: 48,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No Expenses This Month',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Start adding expense transactions to see your category breakdown',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[400],
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
                    Icons.donut_small,
                    color: Colors.orange,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Category Breakdown',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              
              // Pie Chart Centered with Legend Below
              if (sortedCategories.isNotEmpty) ...[
                // Centered Pie Chart
                Center(
                  child: Container(
                    width: 180,
                    height: 180,
                    child: CustomPaint(
                      painter: ExpenseBreakdownPieChart(
                        Map.fromEntries(sortedCategories.take(6)), // Top 6 categories
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
                    return _buildLiveExpenseLegendItem(
                      entry.key,
                      _getCategoryColor(entry.key),
                      entry.value,
                    );
                  }).toList(),
                ),
                
                SizedBox(height: 16),
                // Total amount for current month
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF3A3D4A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total This Month',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      FutureBuilder<String>(
                        future: _formatAmount(totalExpenses),
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ?? '$_currencySymbol${totalExpenses.toStringAsFixed(0)}',
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
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildLiveExpenseLegendItem(String name, Color color, double amount) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
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
          SizedBox(width: 8),
          Expanded(
            child: Text(
              name.replaceAll('&', '\n&'), // Handle "Food & Dining" case
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
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
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ],
          ),
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
