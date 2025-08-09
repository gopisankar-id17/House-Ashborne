import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Assuming this is used for some icons
import 'package:url_launcher/url_launcher.dart'; // Assuming this is used for launching URLs
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:path_provider/path_provider.dart'; // For file paths
import 'package:share_plus/share_plus.dart'; // For sharing files
import 'dart:io'; // For File operations
import 'dart:convert'; // For JSON operations
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore operations

import 'profile_page.dart'; // Ensure this path is correct relative to settings_page.dart
import '../services/session_service.dart'; // Import the SessionService
import '../services/biometric_service.dart'; // Import BiometricService for clearing biometric data

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

class SettingsPageSkeletonLoading extends StatefulWidget {
  @override
  _SettingsPageSkeletonLoadingState createState() => _SettingsPageSkeletonLoadingState();
}

class _SettingsPageSkeletonLoadingState extends BaseSkeletonLoadingState<SettingsPageSkeletonLoading> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1D29),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: shimmerAnimation,
          builder: (context, child) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeaderSkeleton(),
                  SizedBox(height: 20),
                  _buildProfileSectionSkeleton(),
                  _buildSettingsSectionSkeleton(),
                  _buildSocialMediaSectionSkeleton(),
                  _buildAppInfoSectionSkeleton(),
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
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          buildShimmerContainer(width: 40, height: 40, borderRadius: 20),
          SizedBox(width: 16),
          Expanded(child: buildShimmerContainer(width: double.infinity, height: 24)),
        ],
      ),
    );
  }

  Widget _buildProfileSectionSkeleton() {
    return Column(
      children: [
        _buildListTileSkeleton(),
        _buildListTileSkeleton(),
      ],
    );
  }

  Widget _buildSettingsSectionSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: buildShimmerContainer(width: 120, height: 18),
        ),
        _buildListTileSkeleton(),
        _buildListTileSkeleton(),
        _buildListTileSkeleton(),
        _buildListTileSkeleton(),
      ],
    );
  }

  Widget _buildSocialMediaSectionSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: buildShimmerContainer(width: 140, height: 18),
        ),
        _buildListTileSkeleton(),
        _buildListTileSkeleton(),
      ],
    );
  }

  Widget _buildAppInfoSectionSkeleton() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: buildShimmerContainer(width: 100, height: 18),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: buildShimmerContainer(width: 80, height: 14),
        ),
      ],
    );
  }

  Widget _buildListTileSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          buildShimmerContainer(width: 24, height: 24),
          SizedBox(width: 20),
          Expanded(child: buildShimmerContainer(width: double.infinity, height: 16)),
        ],
      ),
    );
  }
}

class ActualSettingsPage extends StatefulWidget {
  @override
  _ActualSettingsPageState createState() => _ActualSettingsPageState();
}

class _ActualSettingsPageState extends State<ActualSettingsPage> {
  bool isLoading = true;
  bool _isSigningOut = false;
  bool _isResetting = false;
  final _sessionService = SessionService();
  final _biometricService = BiometricService();
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

  Future<void> _resetFinancialData() async {
    // Step 1: Ask if user wants to download and reset data
    final bool? shouldDownloadAndReset = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF2A2D3A),
          title: Text(
            'Reset Financial Data',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Do you want to download and reset your financial data?\n\nThis will let you select a date range, download that data, and delete it from the app.',
            style: TextStyle(color: Color(0xFF9CA3AF)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF9CA3AF)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
              ),
              child: Text('Download and Reset'),
            ),
          ],
        );
      },
    );

    if (shouldDownloadAndReset != true) return; // User cancelled

    // Step 2: Ask for date range
    DateTimeRange? dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
      helpText: 'Select date range to download and delete',
      fieldStartHintText: 'From date',
      fieldEndHintText: 'To date',
    );

    if (dateRange == null) return; // User cancelled date selection

    // Step 3: Download and delete data in the selected range
    await _downloadAndDeleteDataForRange(dateRange);
  }

  Future<void> _downloadAndDeleteDataForRange(DateTimeRange dateRange) async {
    setState(() => _isResetting = true);

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Color(0xFF2A2D3A),
          content: Row(
            children: [
              CircularProgressIndicator(color: Color(0xFFFF6B35)),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  'Downloading and deleting data from ${_formatDate(dateRange.start)} to ${_formatDate(dateRange.end)}...',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );

      // Get current user ID
      final userId = await SessionService().getUserSession();
      if (userId == null) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User not logged in. Please sign in again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get all transactions, income, and expenses from Firestore
      List<Map<String, dynamic>> allTransactions = [];
      List<Map<String, dynamic>> allIncome = [];
      List<Map<String, dynamic>> allExpenses = [];

      // Fetch transactions from Firestore
      final transactionsSnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .get();
      
      for (var doc in transactionsSnapshot.docs) {
        var data = doc.data();
        data['id'] = doc.id; // Store document ID for deletion
        // Convert Firestore Timestamp to DateTime string
        if (data['date'] is Timestamp) {
          data['date'] = (data['date'] as Timestamp).toDate().toIso8601String();
        }
        allTransactions.add(data);
      }

      // Fetch income from Firestore
      final incomeSnapshot = await FirebaseFirestore.instance
          .collection('income')
          .where('userId', isEqualTo: userId)
          .get();
      
      for (var doc in incomeSnapshot.docs) {
        var data = doc.data();
        data['id'] = doc.id; // Store document ID for deletion
        // Convert Firestore Timestamp to DateTime string
        if (data['date'] is Timestamp) {
          data['date'] = (data['date'] as Timestamp).toDate().toIso8601String();
        }
        allIncome.add(data);
      }

      // Fetch expenses from Firestore
      final expensesSnapshot = await FirebaseFirestore.instance
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          .get();
      
      for (var doc in expensesSnapshot.docs) {
        var data = doc.data();
        data['id'] = doc.id; // Store document ID for deletion
        // Convert Firestore Timestamp to DateTime string
        if (data['date'] is Timestamp) {
          data['date'] = (data['date'] as Timestamp).toDate().toIso8601String();
        }
        allExpenses.add(data);
      }

      // Filter data within the selected date range
      List<Map<String, dynamic>> downloadTransactions = [];
      List<Map<String, dynamic>> downloadIncome = [];
      List<Map<String, dynamic>> downloadExpenses = [];

      print("Debug: Total data found - Transactions: ${allTransactions.length}, Income: ${allIncome.length}, Expenses: ${allExpenses.length}");
      print("Debug: Date range - Start: ${dateRange.start}, End: ${dateRange.end}");

      // Filter transactions
      for (var transaction in allTransactions) {
        try {
          String dateStr = transaction['date']?.toString() ?? '';
          print("Debug: Processing transaction date: $dateStr");
          
          if (dateStr.isNotEmpty) {
            DateTime transactionDate = DateTime.parse(dateStr);
            bool isInRange = transactionDate.isAfter(dateRange.start.subtract(Duration(days: 1))) &&
                           transactionDate.isBefore(dateRange.end.add(Duration(days: 1)));
            
            print("Debug: Transaction date $transactionDate, in range: $isInRange");
            
            if (isInRange) {
              downloadTransactions.add(transaction);
            }
          }
        } catch (e) {
          print("Debug: Error parsing transaction date: $e");
        }
      }

      // Filter income
      for (var income in allIncome) {
        try {
          String dateStr = income['date']?.toString() ?? '';
          if (dateStr.isNotEmpty) {
            DateTime incomeDate = DateTime.parse(dateStr);
            bool isInRange = incomeDate.isAfter(dateRange.start.subtract(Duration(days: 1))) &&
                           incomeDate.isBefore(dateRange.end.add(Duration(days: 1)));
            
            if (isInRange) {
              downloadIncome.add(income);
            }
          }
        } catch (e) {
          print("Debug: Error parsing income date: $e");
        }
      }

      // Filter expenses
      for (var expense in allExpenses) {
        try {
          String dateStr = expense['date']?.toString() ?? '';
          if (dateStr.isNotEmpty) {
            DateTime expenseDate = DateTime.parse(dateStr);
            bool isInRange = expenseDate.isAfter(dateRange.start.subtract(Duration(days: 1))) &&
                           expenseDate.isBefore(dateRange.end.add(Duration(days: 1)));
            
            if (isInRange) {
              downloadExpenses.add(expense);
            }
          }
        } catch (e) {
          print("Debug: Error parsing expense date: $e");
        }
      }

      print("Debug: Filtered results - Download Transactions: ${downloadTransactions.length}, Download Income: ${downloadIncome.length}, Download Expenses: ${downloadExpenses.length}");

      // Create CSV content for download
      List<String> csvContent = [
        'Financial Data Export from ${_formatDate(dateRange.start)} to ${_formatDate(dateRange.end)}',
        'Downloaded on ${DateTime.now().toString()}',
        '',
      ];

      // Add transactions to CSV
      if (downloadTransactions.isNotEmpty) {
        csvContent.add('TRANSACTIONS');
        csvContent.add('Date,Description,Amount,Category,Type');
        for (var transaction in downloadTransactions) {
          csvContent.add(
            '${transaction['date']},${transaction['description'] ?? ''},${transaction['amount'] ?? 0},${transaction['category'] ?? ''},${transaction['type'] ?? ''}'
          );
        }
        csvContent.add('');
      }

      // Add income to CSV
      if (downloadIncome.isNotEmpty) {
        csvContent.add('INCOME');
        csvContent.add('Date,Source,Amount,Category');
        for (var income in downloadIncome) {
          csvContent.add(
            '${income['date']},${income['source'] ?? ''},${income['amount'] ?? 0},${income['category'] ?? ''}'
          );
        }
        csvContent.add('');
      }

      // Add expenses to CSV
      if (downloadExpenses.isNotEmpty) {
        csvContent.add('EXPENSES');
        csvContent.add('Date,Description,Amount,Category');
        for (var expense in downloadExpenses) {
          csvContent.add(
            '${expense['date']},${expense['description'] ?? ''},${expense['amount'] ?? 0},${expense['category'] ?? ''}'
          );
        }
      }

      // Save CSV file and share it
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/financial_data_${dateRange.start.year}_${dateRange.start.month}_${dateRange.start.day}_to_${dateRange.end.year}_${dateRange.end.month}_${dateRange.end.day}.csv');
      await file.writeAsString(csvContent.join('\n'));

      // Delete the downloaded data from Firestore using batch operations
      final batch = FirebaseFirestore.instance.batch();

      // Delete transactions that were downloaded
      for (var transaction in downloadTransactions) {
        if (transaction['id'] != null) {
          batch.delete(FirebaseFirestore.instance.collection('transactions').doc(transaction['id']));
        }
      }

      // Delete income that was downloaded
      for (var income in downloadIncome) {
        if (income['id'] != null) {
          batch.delete(FirebaseFirestore.instance.collection('income').doc(income['id']));
        }
      }

      // Delete expenses that were downloaded
      for (var expense in downloadExpenses) {
        if (expense['id'] != null) {
          batch.delete(FirebaseFirestore.instance.collection('expenses').doc(expense['id']));
        }
      }

      // Commit the batch deletion
      await batch.commit();

      Navigator.of(context).pop(); // Close loading dialog

      // Share the downloaded file
      await Share.shareFiles([file.path], text: 'Financial Data Export');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Downloaded ${downloadTransactions.length} transactions, ${downloadIncome.length} income, ${downloadExpenses.length} expenses.\nSelected data has been deleted from app.',
            ),
            backgroundColor: Color(0xFFFF6B35),
            duration: Duration(seconds: 4),
          ),
        );
      }

    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      print("Error downloading and deleting data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing data. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResetting = false);
    }
  }

  Future<void> _resetAllFinancialData() async {
    setState(() => _isResetting = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear all financial data
      await prefs.remove('savings_amount');
      await prefs.remove('total_balance');
      await prefs.remove('current_balance');
      await prefs.remove('monthly_goal');
      await prefs.remove('savings_goal');
      await prefs.remove('yearly_goal');
      await prefs.remove('transactions');
      await prefs.remove('transaction_history');
      await prefs.remove('expenses');
      await prefs.remove('expense_history');
      await prefs.remove('income');
      await prefs.remove('income_history');
      await prefs.remove('savings_goals');
      await prefs.remove('financial_goals');
      await prefs.remove('expense_categories');
      await prefs.remove('budget_data');
      await prefs.remove('monthly_budget');
      await prefs.remove('spending_limit');
      await prefs.remove('financial_data');
      await prefs.remove('wallet_balance');
      await prefs.remove('bank_balance');
      await prefs.remove('investment_data');
      await prefs.remove('recurring_transactions');
      await prefs.remove('category_budgets');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('All financial data reset successfully'),
            backgroundColor: Color(0xFFFF6B35),
          ),
        );

        // Navigate back to home page to show the reset state
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      print("Error resetting financial data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resetting financial data. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResetting = false);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _signOut() async {
    // Show confirmation dialog
    final bool? shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF2A2D3A),
          title: Text(
            'Sign Out',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to sign out?',
            style: TextStyle(color: Color(0xFF9CA3AF)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF9CA3AF)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text('Sign Out'),
            ),
          ],
        );
      },
    );

    if (shouldSignOut != true) return;

    setState(() => _isSigningOut = true);

    try {
      // Clear the user session
      await _sessionService.clearSession();

      // Optionally clear biometric data (uncomment if you want to clear saved biometric email)
      // await _biometricService.disableBiometric();

      if (mounted) {
        // Navigate to sign-in page and clear all previous routes
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/signin',
          (route) => false,
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signed out successfully'),
            backgroundColor: Color(0xFFFF6B35),
          ),
        );
      }
    } catch (e) {
      print("Error signing out: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSigningOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? SettingsPageSkeletonLoading()
        : Scaffold(
            backgroundColor: Color(0xFF1A1D29),
            appBar: AppBar(
              backgroundColor: Color(0xFF1A1D29),
              elevation: 0,
              centerTitle: true,
              title: Text(
                'Settings',
                style: TextStyle(color: Colors.white),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  _buildSectionTitle('Profile'),
                  _buildSettingsTile(
                    context: context,
                    title: 'Edit Profile',
                    icon: Icons.person_outline,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      );
                    },
                  ),
                  _buildSettingsTile(
                    context: context,
                    title: 'Change Password',
                    icon: Icons.lock_outline,
                    onTap: () {},
                  ),
                  _buildSectionTitle('Preferences'),
                  _buildSettingsTile(
                    context: context,
                    title: 'Notifications',
                    icon: Icons.notifications_none,
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    context: context,
                    title: 'Theme',
                    icon: Icons.color_lens_outlined,
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    context: context,
                    title: 'Currency',
                    icon: Icons.monetization_on_outlined,
                    onTap: () {},
                  ),
                  _buildSectionTitle('Data Management'),
                  _buildSettingsTile(
                    context: context,
                    title: 'Reset Financial Data',
                    icon: Icons.refresh_outlined,
                    onTap: _resetFinancialData,
                    titleColor: Colors.orange,
                    iconColor: Colors.orange,
                  ),
                  _buildSectionTitle('App Info'),
                  _buildSettingsTile(
                    context: context,
                    title: 'About Ahorra',
                    icon: Icons.info_outline,
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    context: context,
                    title: 'Privacy Policy',
                    icon: Icons.privacy_tip_outlined,
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    context: context,
                    title: 'Terms of Service',
                    icon: Icons.description_outlined,
                    onTap: () {},
                  ),
                  _buildSectionTitle('Support'),
                  _buildSettingsTile(
                    context: context,
                    title: 'Help & FAQ',
                    icon: Icons.help_outline,
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    context: context,
                    title: 'Contact Us',
                    icon: Icons.email_outlined,
                    onTap: () {},
                  ),
                  SizedBox(height: 40),
                  _buildSignOutButton(),
                  SizedBox(height: 40),
                ],
              ),
            ),
          );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    return Card(
      color: Color(0xFF2A2D3A),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: iconColor ?? Color(0xFFFF6B35), size: 24),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: titleColor ?? Colors.white, fontSize: 16),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return Center(
      child: OutlinedButton(
        onPressed: _isSigningOut ? null : _signOut,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        ),
        child: _isSigningOut
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              )
            : Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

// Export ActualSettingsPage as SettingsPage for compatibility
typedef SettingsPage = ActualSettingsPage;
