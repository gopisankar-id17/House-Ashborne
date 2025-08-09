import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:intl/intl.dart'; // For date formatting
import 'skeleton_loading_page.dart';
import '../services/session_service.dart'; // Import SessionService
import '../services/currency_service.dart'; // Import CurrencyService

class TransactionsPage extends StatefulWidget {
  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      setState(() => isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
      ? TransactionsSkeletonPage()
      : ActualTransactionsPage(); // Your existing transactions page content
  }
}

class ActualTransactionsPage extends StatefulWidget {
  const ActualTransactionsPage({Key? key}) : super(key: key);

  @override
  State<ActualTransactionsPage> createState() => _ActualTransactionsPageState();
}

class _ActualTransactionsPageState extends State<ActualTransactionsPage> {
  final SessionService _sessionService = SessionService();
  final CurrencyService _currencyService = CurrencyService();
  String? _currentUserId;
  String _currencySymbol = '\$';

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _loadCurrencySymbol();
  }

  Future<void> _loadUserId() async {
    final userId = await _sessionService.getUserSession();
    setState(() {
      _currentUserId = userId;
    });
  }

  Future<void> _loadCurrencySymbol() async {
    final symbol = await _currencyService.getCurrencySymbol();
    if (mounted) {
      setState(() {
        _currencySymbol = symbol;
      });
    }
  }

  // Helper method to format amount with currency conversion
  Future<String> _formatAmount(double amount, bool isIncome, {String? originalCurrency}) async {
    double displayAmount;
    
    // If transaction has original currency info, use it, otherwise convert from USD
    if (originalCurrency != null) {
      final currentCurrency = await _currencyService.getSelectedCurrency();
      if (originalCurrency == currentCurrency) {
        // Same currency, no conversion needed
        displayAmount = amount;
      } else {
        // Convert from stored USD to current currency
        displayAmount = await _currencyService.convertFromUSD(amount);
      }
    } else {
      // Legacy transaction without currency info, assume it's in USD and convert
      displayAmount = await _currencyService.convertFromUSD(amount);
    }
    
    final prefix = isIncome ? '+' : '-';
    return '$prefix$_currencySymbol${displayAmount.toStringAsFixed(2)}';
  }

  // Helper to get icon for a category
  IconData _getCategoryIcon(String category, String type) {
    if (type == 'Income') {
      switch (category.toLowerCase()) {
        case 'salary': return Icons.work_outline;
        case 'freelance': return Icons.laptop_mac;
        case 'investment': return Icons.trending_up;
        case 'bonus': return Icons.card_giftcard_outlined;
        default: return Icons.attach_money;
      }
    } else { // Expense
      switch (category.toLowerCase()) {
        case 'food': return Icons.restaurant_outlined;
        case 'transport': return Icons.directions_car_outlined;
        case 'bills': return Icons.receipt_outlined;
        case 'shopping': return Icons.shopping_bag_outlined;
        case 'fun': return Icons.celebration_outlined;
        case 'health': return Icons.favorite_outline;
        default: return Icons.money_off;
      }
    }
  }

  // Helper to get color for a category
  Color _getCategoryColor(String category, String type) {
    if (type == 'Income') {
      switch (category.toLowerCase()) {
        case 'salary': return Colors.green;
        case 'freelance': return Colors.orange;
        case 'investment': return Colors.brown;
        case 'bonus': return Colors.purple;
        default: return Colors.green;
      }
    } else { // Expense
      switch (category.toLowerCase()) {
        case 'food': return Colors.orange;
        case 'transport': return Colors.brown;
        case 'bills': return Colors.red;
        case 'shopping': return Colors.orange; // Changed from brown to orange for variety
        case 'fun': return Colors.purple;
        case 'health': return Colors.green;
        default: return Colors.red;
      }
    }
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Today, ${DateFormat('h:mm a').format(date)}';
    } else if (transactionDate == yesterday) {
      return 'Yesterday, ${DateFormat('h:mm a').format(date)}';
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE, h:mm a').format(date); // E.g., Monday, 9:30 AM
    } else {
      return DateFormat('MMM d, yyyy').format(date); // E.g., Jul 29, 2024
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1D29),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _currentUserId == null
                  ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.orange)))
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('transactions')
                          .where('userId', isEqualTo: _currentUserId)
                          .orderBy('createdAt', descending: true) // Order by creation time
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.orange)));
                        }

                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.info_outline, color: Colors.grey[600], size: 40),
                                SizedBox(height: 10),
                                Text(
                                  'No transactions found.',
                                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                                ),
                                Text(
                                  'Add your first transaction!',
                                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                                ),
                              ],
                            ),
                          );
                        }

                        final transactions = snapshot.data!.docs;

                        return ListView.builder(
                          padding: EdgeInsets.all(20),
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = transactions[index].data() as Map<String, dynamic>;
                            final type = transaction['type'] as String;
                            final amount = (transaction['originalAmount'] as num?)?.toDouble() ?? (transaction['amount'] as num).toDouble(); // Use originalAmount if available, fallback to amount
                            final category = transaction['category'] as String;
                            final description = transaction['description'] as String;
                            final date = transaction['date'] as Timestamp;
                            final originalCurrency = transaction['currency'] as String?; // Get stored currency

                            final isIncome = type == 'Income';
                            final icon = _getCategoryIcon(category, type);
                            final iconColor = _getCategoryColor(category, type);
                            final formattedDate = _formatDate(date);

                            return FutureBuilder<String>(
                              future: _formatAmount(amount, isIncome, originalCurrency: originalCurrency),
                              builder: (context, amountSnapshot) {
                                final displayAmount = amountSnapshot.data ?? '${isIncome ? '+' : '-'}$_currencySymbol${amount.toStringAsFixed(2)}';
                                
                                return _buildTransactionItem(
                                  description.isNotEmpty ? description : category, // Use description if available, else category
                                  category,
                                  displayAmount,
                                  formattedDate,
                                  icon,
                                  iconColor,
                                  isIncome,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Transactions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Track your latest financial activity',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement navigation to a "View All Transactions" page
            },
            child: Text(
              'View All',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    String title,
    String category,
    String amount,
    String time,
    IconData icon,
    Color iconColor,
    bool isIncome,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2A2D3A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
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
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(category, isIncome ? 'Income' : 'Expense'), // Use helper for consistency
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  color: isIncome ? Colors.green : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                time,
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
}