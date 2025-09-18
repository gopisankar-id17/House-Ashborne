import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/currency_dropdown_widget.dart';
import '../widgets/animated_chat_fab.dart';
import '../widgets/live_currency_widget.dart';

// Service class stubs
class ProfileService {
  Future<String?> getUserSession() async => 'demoUser';
}

class SessionService {
  Future<String?> getUserSession() async => 'demoUser';
}

class CurrencyService {
  Future<String> getCurrencySymbol() async => '₹';
  Future<String> getSelectedCurrency() async => 'USD';
  Future<double> convertFromUSD(double usdAmount) async => usdAmount;
  Future<String> formatAmount(double amount) async => '₹${amount.toStringAsFixed(2)}';
}

class BudgetManagementService {}

// Skeleton loading widget
class HomePageSkeletonLoading extends StatelessWidget {
  const HomePageSkeletonLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// Pie chart painter
class ExpenseBreakdownPieChart extends CustomPainter {
  final List<MapEntry<String, double>> categories;
  final double total;

  ExpenseBreakdownPieChart({required this.categories, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    // Implement paint logic here
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ActualHomePage extends StatefulWidget {
  const ActualHomePage({Key? key}) : super(key: key);

  @override
  State<ActualHomePage> createState() => _ActualHomePageState();
}

class _ActualHomePageState extends State<ActualHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2232),
      body: ActualHomePageContent(),
    );
  }
}

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
  String _currencySymbol = '₹';
  String _selectedCurrency = 'USD';
  String _selectedTimePeriod = '1 Month'; // Initialize with 1 Month

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
    if (mounted) {
      setState(() {
        _currentUserId = userId;
      });
    }
  }

  Future<void> _loadCurrencySettings() async {
    final symbol = await _currencyService.getCurrencySymbol();
    final currency = await _currencyService.getSelectedCurrency();
    if (mounted) {
      setState(() {
        _currencySymbol = symbol;
        _selectedCurrency = currency;
      });
    }
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
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  // Shimmer container widget
  Widget buildShimmerContainer({double width = 100, double height = 20, double borderRadius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  // Build monthly budget section
  Widget _buildMonthlyBudget() {
    if (_currentUserId == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2D3A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: CircularProgressIndicator(color: Colors.orange)),
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
        double totalBudget = 0.0;
        if (monthlyBudgetSnapshot.hasData && monthlyBudgetSnapshot.data!.exists) {
          final monthlyBudgetData = monthlyBudgetSnapshot.data!.data() as Map<String, dynamic>?;
          if (monthlyBudgetData != null) {
            totalBudget = (monthlyBudgetData['totalAmount'] as num?)?.toDouble() ?? 0.0;
          }
        }
        
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('transactions')
              .where('userId', isEqualTo: _currentUserId)
              .where('type', isEqualTo: 'Expense')
              .snapshots(),
          builder: (context, expenseSnapshot) {
            double totalSpent = 0.0;
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
            if (totalBudget == 0.0) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2D3A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Monthly Budget',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/budgetManagement');
                          },
                          child: const Text('Set Budget', style: TextStyle(color: Colors.orange)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'You haven\'t set a monthly budget yet.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/budgetManagement');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Set Budget Now'),
                    ),
                  ],
                ),
              );
            }

            // Calculate percentages
            final spentPercentage = totalBudget > 0 ? (totalSpent / totalBudget * 100) : 0.0;
            final remainingPercentage = totalBudget > 0 ? (remaining / totalBudget * 100) : 0.0;

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2D3A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Monthly Budget',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/budgetManagement');
                        },
                        child: const Text('Edit', style: TextStyle(color: Colors.orange)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBudgetCard(
                          title: 'Spent',
                          icon: Icons.arrow_downward,
                          iconColor: Colors.orange,
                          iconBgColor: Colors.orange.withOpacity(0.2),
                          amount: '$_currencySymbol${totalSpent.toStringAsFixed(2)}',
                          actionText: '${spentPercentage.toStringAsFixed(0)}% used',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildBudgetCard(
                          title: 'Remaining',
                          icon: Icons.account_balance_wallet,
                          iconColor: Colors.green,
                          iconBgColor: Colors.green.withOpacity(0.2),
                          amount: '$_currencySymbol${remaining.toStringAsFixed(2)}',
                          actionText: '${remainingPercentage.toStringAsFixed(0)}% left',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Build budget card widget
  Widget _buildBudgetCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String amount,
    required String actionText,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF262B3D),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            actionText,
            style: TextStyle(
              color: title == 'Remaining' ? Colors.green : Colors.orange,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header section
        _buildHeader(),
        const SizedBox(height: 16),
        
        // Live Currency Display
        LiveCurrencyWidget(),
        const SizedBox(height: 20),
        
        // Balance card
        _buildBalanceCard(),
        const SizedBox(height: 20),
        
        // Income and expense cards
        _buildIncomeExpenseSection(),
        const SizedBox(height: 20),
        
        // Monthly budget section
        _buildMonthlyBudget(),
        const SizedBox(height: 20),
        
        // Budget insights section
        _buildBudgetInsightsCard(),
        const SizedBox(height: 20),
        
        // Category budgets section
        _buildCategoryBudgets(),
        const SizedBox(height: 20),
        
        // Expense breakdown section
        _buildExpenseBreakdown(),
        const SizedBox(height: 20),
      ],
    );
  }

  // Placeholder methods for other sections
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(top: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'My Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              CurrencyDropdownWidget(
                onCurrencyChanged: (newCurrency) {
                  setState(() {
                    _selectedCurrency = newCurrency;
                  });
                  _loadCurrencySettings();
                },
              ),
              SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(context, '/profile');
                },
                tooltip: 'Profile',
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF8C00), Color(0xFFFF7700), Color(0xFFFF6600)], // Orange gradient
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          FutureBuilder<String>(
            future: _formatAmount(5000), // Example balance
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? '$_currencySymbol${5000.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.greenAccent, size: 20),
              const SizedBox(width: 8),
              FutureBuilder<String>(
                future: _formatAmount(500), // Example income
                builder: (context, snapshot) {
                  return Text(
                    'Income: ${snapshot.data ?? '$_currencySymbol${500.toStringAsFixed(2)}'}',
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 14,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.trending_down, color: Colors.redAccent, size: 20),
              const SizedBox(width: 8),
              FutureBuilder<String>(
                future: _formatAmount(300), // Example expense
                builder: (context, snapshot) {
                  return Text(
                    'Expenses: ${snapshot.data ?? '$_currencySymbol${300.toStringAsFixed(2)}'}',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 14,
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

  Widget _buildIncomeExpenseSection() {
    return Row(
      children: [
        Expanded(child: _buildPlaceholderCard('Income', '+${_currencySymbol}0.00', Colors.green)),
        const SizedBox(width: 16),
        Expanded(child: _buildPlaceholderCard('Expense', '-${_currencySymbol}0.00', Colors.red)),
      ],
    );
  }

  Widget _buildPlaceholderCard(String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D3A),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          FutureBuilder<String>(
            future: _formatAmount(title == 'Income' ? 500 : 300), // Example amounts
            builder: (context, snapshot) {
              final displayAmount = title == 'Income' 
                  ? '+${snapshot.data ?? '$_currencySymbol${500.toStringAsFixed(2)}'}' 
                  : '-${snapshot.data ?? '$_currencySymbol${300.toStringAsFixed(2)}'}';
              return Text(
                displayAmount,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetInsightsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D3A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Budget Insights',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF3D4354),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'This Month',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Example insights
          _buildInsightCard(
            title: 'You\'ve spent 25% more on Food this month compared to last month',
            icon: Icons.fastfood,
            color: Colors.orange,
          ),
          if (_currentUserId != null) const SizedBox(height: 12),
          _buildInsightCard(
            title: 'Your Shopping expenses are 15% under budget this month',
            icon: Icons.shopping_bag,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF262B3D),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBudgets() {
    if (_currentUserId == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2D3A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('category_budgets')
          .where('userId', isEqualTo: _currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2D3A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(child: CircularProgressIndicator(color: Colors.orange)),
          );
        }

        final categoryBudgets = snapshot.data!.docs;
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2D3A),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Category Budgets',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/categoryManagement');
                    },
                    child: const Text('Edit', style: TextStyle(color: Colors.orange)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              if (categoryBudgets.isEmpty) ...[
                const Text(
                  'You haven\'t set any category budgets yet.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/categoryManagement');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Set Category Budgets'),
                ),
              ] else ...[
                // Display category budgets here
                for (var doc in categoryBudgets)
                  _buildCategoryBudgetItem(doc),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryBudgetItem(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final category = data['category'] as String;
    final budget = (data['budget'] as num).toDouble();
    
    // Get spent amount for this category
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: _currentUserId)
          .where('category', isEqualTo: category)
          .snapshots(),
      builder: (context, snapshot) {
        double spent = 0;
        if (snapshot.hasData) {
          final now = DateTime.now();
          final currentMonth = now.month;
          final currentYear = now.year;
          
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final amount = (data['amount'] as num).toDouble();
            final date = (data['date'] as Timestamp).toDate();
            
            if (date.month == currentMonth && date.year == currentYear) {
              spent += amount;
            }
          }
        }
        
        final spentPercentage = budget > 0 ? (spent / budget * 100).clamp(0, 100) : 0.0;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 12,
                    width: 12,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(category),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      FutureBuilder<String>(
                        future: _formatAmount(spent),
                        builder: (context, spentSnapshot) {
                          FutureBuilder<String>(
                            future: _formatAmount(budget),
                            builder: (context, budgetSnapshot) {
                              final spentText = spentSnapshot.data ?? '$_currencySymbol${spent.toStringAsFixed(2)}';
                              final budgetText = budgetSnapshot.data ?? '$_currencySymbol${budget.toStringAsFixed(2)}';
                              return Text(
                                '$spentText / $budgetText',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              );
                            },
                          );
                          return Text('Loading...');
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  Container(
                    height: 6,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3D4354),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Container(
                    height: 6,
                    width: (MediaQuery.of(context).size.width - 80) * (spentPercentage / 100),
                    decoration: BoxDecoration(
                      color: spentPercentage > 90 ? Colors.red : Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FutureBuilder<String>(
                    future: _formatAmount(budget - spent),
                    builder: (context, snapshot) {
                      return Text(
                        '${snapshot.data ?? '$_currencySymbol${(budget - spent).toStringAsFixed(2)}'} left',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpenseBreakdown() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D3A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expense Breakdown',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),
          
          // Time Period Tabs
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1F2232),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _buildTimePeriodTab('1 Month'),
                _buildTimePeriodTab('3 Months'),
                _buildTimePeriodTab('6 Months'),
                _buildTimePeriodTab('1 Year'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Expense Breakdown Pie Chart
          SizedBox(
            height: 200,
            child: FutureBuilder<List<PieChartSectionData>>(
              future: _buildPieChartSectionsFromTransactions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF8C00)),
                  );
                }
                
                List<PieChartSectionData> sections = snapshot.data ?? [];
                
                // If no real data, show fallback
                if (sections.isEmpty) {
                  sections = _buildFallbackPieChartSections();
                }

                return PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                    borderData: FlBorderData(show: false),
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        // Handle touch events if needed
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Expense breakdown items from real transactions
          FutureBuilder<List<Widget>>(
            future: _getExpenseBreakdownItemsFromTransactions(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: Color(0xFFFF8C00)),
                  ),
                );
              }
              
              final items = snapshot.data ?? _getFallbackExpenseBreakdownItems();
              return Column(children: items);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimePeriodTab(String period) {
    final isSelected = _selectedTimePeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTimePeriod = period;
          });
        },
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFF8C00) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              period,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Get expense breakdown items from real transactions
  Future<List<Widget>> _getExpenseBreakdownItemsFromTransactions() async {
    if (_currentUserId == null) {
      return _getFallbackExpenseBreakdownItems();
    }

    final startDate = _getStartDate();
    final endDate = DateTime.now();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: _currentUserId)
          .where('type', isEqualTo: 'Expense')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      // Group expenses by category
      Map<String, double> categoryTotals = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final category = data['category'] as String? ?? 'Other';
        final amount = (data['originalAmount'] as num?)?.toDouble() ?? 
                      (data['amount'] as num).toDouble();
        
        categoryTotals[category] = (categoryTotals[category] ?? 0.0) + amount;
      }

      if (categoryTotals.isEmpty) {
        return _getFallbackExpenseBreakdownItems();
      }

      // Convert to list and sort by amount
      final sortedCategories = categoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Take top 6 categories
      final topCategories = sortedCategories.take(6).toList();
      final total = topCategories.fold<double>(0, (sum, item) => sum + item.value);

      return topCategories.map((entry) {
        final percentage = (entry.value / total * 100);
        return _buildExpenseBreakdownItem(
          entry.key, 
          percentage, 
          entry.value
        );
      }).toList();

    } catch (e) {
      print('Error fetching transaction data for breakdown items: $e');
      return _getFallbackExpenseBreakdownItems();
    }
  }

  // Fallback expense breakdown items
  List<Widget> _getFallbackExpenseBreakdownItems() {
    // Return different data based on selected time period
    switch (_selectedTimePeriod) {
      case '1 Month':
        return [
          _buildExpenseBreakdownItem('Food & Dining', 35.0, 1050),
          _buildExpenseBreakdownItem('Transportation', 20.0, 600),
          _buildExpenseBreakdownItem('Shopping', 15.0, 450),
          _buildExpenseBreakdownItem('Bills', 30.0, 900),
        ];
      case '3 Months':
        return [
          _buildExpenseBreakdownItem('Food & Dining', 32.0, 3200),
          _buildExpenseBreakdownItem('Transportation', 22.0, 2200),
          _buildExpenseBreakdownItem('Shopping', 18.0, 1800),
          _buildExpenseBreakdownItem('Bills', 28.0, 2800),
        ];
      case '6 Months':
        return [
          _buildExpenseBreakdownItem('Food & Dining', 30.0, 6300),
          _buildExpenseBreakdownItem('Transportation', 25.0, 5250),
          _buildExpenseBreakdownItem('Shopping', 20.0, 4200),
          _buildExpenseBreakdownItem('Bills', 25.0, 5250),
        ];
      case '1 Year':
        return [
          _buildExpenseBreakdownItem('Food & Dining', 28.0, 13440),
          _buildExpenseBreakdownItem('Transportation', 27.0, 12960),
          _buildExpenseBreakdownItem('Shopping', 22.0, 10560),
          _buildExpenseBreakdownItem('Bills', 23.0, 11040),
        ];
      default:
        return [
          _buildExpenseBreakdownItem('Food & Dining', 35.0, 1050),
          _buildExpenseBreakdownItem('Transportation', 20.0, 600),
          _buildExpenseBreakdownItem('Shopping', 15.0, 450),
          _buildExpenseBreakdownItem('Bills', 30.0, 900),
        ];
    }
  }

  // Calculate date range based on selected time period
  DateTime _getStartDate() {
    final now = DateTime.now();
    switch (_selectedTimePeriod) {
      case '1 Month':
        return DateTime(now.year, now.month, 1);
      case '3 Months':
        return DateTime(now.year, now.month - 2, 1);
      case '6 Months':
        return DateTime(now.year, now.month - 5, 1);
      case '1 Year':
        return DateTime(now.year - 1, now.month, now.day);
      default:
        return DateTime(now.year, now.month, 1);
    }
  }

  // Build pie chart sections for expense breakdown from real transactions
  Future<List<PieChartSectionData>> _buildPieChartSectionsFromTransactions() async {
    if (_currentUserId == null) {
      return [];
    }

    final startDate = _getStartDate();
    final endDate = DateTime.now();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: _currentUserId)
          .where('type', isEqualTo: 'Expense')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      // Group expenses by category
      Map<String, double> categoryTotals = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final category = data['category'] as String? ?? 'Other';
        final amount = (data['originalAmount'] as num?)?.toDouble() ?? 
                      (data['amount'] as num).toDouble();
        
        categoryTotals[category] = (categoryTotals[category] ?? 0.0) + amount;
      }

      if (categoryTotals.isEmpty) {
        // Return empty list if no transactions
        return [];
      }

      // Convert to list and sort by amount
      final sortedCategories = categoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Take top 6 categories to avoid overcrowding
      final topCategories = sortedCategories.take(6).toList();
      
      final total = topCategories.fold<double>(0, (sum, item) => sum + item.value);

      return topCategories.map((entry) {
        final percentage = (entry.value / total * 100);
        return PieChartSectionData(
          color: _getCategoryColor(entry.key),
          value: entry.value,
          title: '${percentage.toStringAsFixed(0)}%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      }).toList();

    } catch (e) {
      print('Error fetching transaction data for pie chart: $e');
      return [];
    }
  }

  // Fallback pie chart sections with sample data
  List<PieChartSectionData> _buildFallbackPieChartSections() {
    final expenses = [
      {'category': 'Food & Dining', 'amount': 1050.0, 'color': const Color(0xFFFF8C00)},
      {'category': 'Transportation', 'amount': 600.0, 'color': const Color(0xFF4FC3F7)},
      {'category': 'Shopping', 'amount': 450.0, 'color': const Color(0xFF66BB6A)},
      {'category': 'Bills', 'amount': 900.0, 'color': const Color(0xFFBA68C8)},
    ];

    final total = expenses.fold<double>(0, (sum, item) => sum + (item['amount'] as double));

    return expenses.map((expense) {
      final percentage = ((expense['amount'] as double) / total * 100);
      return PieChartSectionData(
        color: expense['color'] as Color,
        value: expense['amount'] as double,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildExpenseBreakdownItem(String category, double percentage, double amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            height: 12,
            width: 12,
            decoration: BoxDecoration(
              color: _getCategoryColor(category),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(width: 12),
          FutureBuilder<String>(
            future: _formatAmount(amount),
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? '$_currencySymbol${amount.toStringAsFixed(0)}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              );
            },
          ),
        ],
      ),
    );
  }
}