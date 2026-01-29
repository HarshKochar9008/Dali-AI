import 'package:flutter/material.dart';
import '../main.dart' show KundaliAppState;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _autoSave = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Appearance'),
          _buildSettingCard(
            icon: Icons.dark_mode_rounded,
            title: 'Dark Mode',
            subtitle: 'Switch between light and dark theme',
            trailing: Switch(
              value: isDark,
              onChanged: (value) {
                final appState =
                    context.findAncestorStateOfType<KundaliAppState>();
                appState?.setDarkMode(value);
              },
              activeColor: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('Chart Settings'),
          _buildSettingCard(
            icon: Icons.save_rounded,
            title: 'Auto Save',
            subtitle: 'Automatically save generated charts',
            trailing: Switch(
              value: _autoSave,
              onChanged: (value) {
                setState(() {
                  _autoSave = value;
                });
              },
              activeColor: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('Notifications'),
          _buildSettingCard(
            icon: Icons.notifications_rounded,
            title: 'Push Notifications',
            subtitle: 'Receive updates and reminders',
            trailing: Switch(
              value: _notifications,
              onChanged: (value) {
                setState(() {
                  _notifications = value;
                });
              },
              activeColor: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('About'),
          _buildSettingCard(
            icon: Icons.info_rounded,
            title: 'App Version',
            subtitle: '1.0.0',
            trailing: Icon(Icons.chevron_right,
                color: colorScheme.onSurface.withOpacity(0.5)),
            onTap: () {},
          ),
          _buildSettingCard(
            icon: Icons.privacy_tip_rounded,
            title: 'Privacy Policy',
            subtitle: 'How we handle your data',
            trailing: Icon(Icons.chevron_right,
                color: colorScheme.onSurface.withOpacity(0.5)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Privacy policy coming soon!'),
                ),
              );
            },
          ),
          _buildSettingCard(
            icon: Icons.description_rounded,
            title: 'Terms of Service',
            subtitle: 'Terms and conditions',
            trailing: Icon(Icons.chevron_right,
                color: colorScheme.onSurface.withOpacity(0.5)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Terms of service coming soon!'),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_outline,
                    size: 14, color: colorScheme.onSurface.withOpacity(0.6)),
                const SizedBox(width: 4),
                Text(
                  'Made for astrology enthusiasts',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      elevation: 0,
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
