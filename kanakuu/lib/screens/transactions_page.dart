import 'package:flutter/material.dart';

class TransactionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1D29),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(20),
                children: [
                  _buildTransactionItem(
                    'Starbucks Coffee',
                    'Food & Dining',
                    '\$8.95',
                    'Today, 9:30 AM',
                    Icons.local_cafe,
                    Colors.brown,
                    false,
                  ),
                  _buildTransactionItem(
                    'Salary Deposit',
                    'Income',
                    '+\$3500.00',
                    'Today, 8:00 AM',
                    Icons.account_balance_wallet,
                    Colors.green,
                    true,
                  ),
                  _buildTransactionItem(
                    'Uber Ride',
                    'Transportation',
                    '\$14.50',
                    'Yesterday, 7:45 PM',
                    Icons.directions_car,
                    Colors.orange,
                    false,
                  ),
                  _buildTransactionItem(
                    'Amazon Purchase',
                    'Shopping',
                    '\$89.99',
                    'Yesterday, 2:30 PM',
                    Icons.shopping_bag,
                    Colors.orange,
                    false,
                  ),
                  _buildTransactionItem(
                    'Electricity Bill',
                    'Bills & Utilities',
                    '\$125.00',
                    '2 days ago',
                    Icons.home,
                    Colors.red,
                    false,
                  ),
                ],
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
            onPressed: () {},
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
                    color: _getCategoryColor(category),
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

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food & dining':
        return Colors.brown;
      case 'income':
        return Colors.green;
      case 'transportation':
        return Colors.blue;
      case 'shopping':
        return Colors.purple;
      case 'bills & utilities':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}