import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/transactions_page.dart';
import 'screens/analytics_page.dart';
import 'screens/settings_page.dart';
import 'screens/add_transaction_page.dart';
import 'widgets/animated_chat_fab.dart';

class MainNavigationRouter extends StatefulWidget {
  @override
  _MainNavigationRouterState createState() => _MainNavigationRouterState();
}

class _MainNavigationRouterState extends State<MainNavigationRouter> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    ActualHomePage(), // Changed from ActualHomePage to ActualHomePageContent
    TransactionsPage(),
    Container(), // Placeholder for Add button (not used)
    AnalyticsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      floatingActionButton: AnimatedChatFAB(
        onPressed: () {
          Navigator.pushNamed(context, '/chatbot');
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Color(0xFF2A2D3A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_outlined, 'Home', 0),
            _buildNavItem(Icons.swap_horiz, 'Transactions', 1),
            _buildAddButton(),
            _buildNavItem(Icons.analytics_outlined, 'Analytics', 3),
            _buildNavItem(Icons.settings_outlined, 'Settings', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.orange : Colors.grey,
            size: 24,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.orange : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => AddTransactionPage(),
        );
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}