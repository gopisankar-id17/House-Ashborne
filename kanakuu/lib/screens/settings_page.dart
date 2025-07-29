import 'package:flutter/material.dart';
import 'skeleton_loading_page.dart';
import '../services/session_service.dart'; // Import the SessionService

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
      ? SettingsSkeletonPage()
      : ActualSettingsPage(); // Your existing settings page content
  }
}

class ActualSettingsPage extends StatelessWidget {
  const ActualSettingsPage({Key? key}) : super(key: key);

  // Removed the final _sessionService field from here.

  Future<void> _signOut(BuildContext context) async {
    // Initialize SessionService locally within the method
    final SessionService sessionService = SessionService();
    await sessionService.clearSession();
    if (Navigator.canPop(context)) {
      Navigator.popUntil(context, (route) => route.isFirst); // Pop all routes until the first one
    }
    Navigator.pushReplacementNamed(context, '/signin'); // Navigate to sign-in page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Manage your preferences',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16213E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Settings List
              Expanded(
                child: ListView(
                  children: [
                    _buildSettingsSection(
                      'Account',
                      [
                        _buildSettingsItem(Icons.person, 'Profile', 'Manage your profile information'),
                        _buildSettingsItem(Icons.security, 'Security', 'Password and security settings'),
                        _buildSettingsItem(Icons.notifications, 'Notifications', 'Manage notification preferences'),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    _buildSettingsSection(
                      'Preferences',
                      [
                        _buildSettingsItem(Icons.palette, 'Theme', 'Dark mode, colors, and appearance'),
                        _buildSettingsItem(Icons.language, 'Language', 'Change app language'),
                        _buildSettingsItem(Icons.attach_money, 'Currency', 'Set default currency'),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    _buildSettingsSection(
                      'Data',
                      [
                        _buildSettingsItem(Icons.backup, 'Backup', 'Backup and restore your data'),
                        _buildSettingsItem(Icons.download, 'Export', 'Export your financial data'),
                        _buildSettingsItem(Icons.delete, 'Clear Data', 'Reset all app data'),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    _buildSettingsSection(
                      'Support',
                      [
                        _buildSettingsItem(Icons.help, 'Help Center', 'Get help and support'),
                        _buildSettingsItem(Icons.feedback, 'Feedback', 'Send us your feedback'),
                        _buildSettingsItem(Icons.info, 'About', 'App version and information'),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Sign Out Section
                    _buildSettingsSection(
                      'Session',
                      [
                        _buildSignOutItem(context), // New Sign Out item
                      ],
                    ),
                    
                    const SizedBox(height: 100), // Space for bottom navigation
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFFF6B35),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF16213E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white10,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFF6B35),
              size: 20,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white54,
            size: 16,
          ),
        ],
      ),
    );
  }

  // New widget for the Sign Out item
  Widget _buildSignOutItem(BuildContext context) {
    return GestureDetector(
      onTap: () => _signOut(context), // Call the sign out method
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.white10,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2), // Red for sign out
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.logout,
                color: Colors.red, // Red icon
                size: 20,
              ),
            ),
            
            const SizedBox(width: 16),
            
            const Expanded(
              child: Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.red, // Red text
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white54,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
