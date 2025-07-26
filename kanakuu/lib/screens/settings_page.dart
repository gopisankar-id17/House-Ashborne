import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

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
}