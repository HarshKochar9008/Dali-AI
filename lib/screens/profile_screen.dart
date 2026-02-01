import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart' show KundaliAppState;
import '../models/user_profile.dart';
import '../services/storage_service.dart';
import 'edit_profile_screen.dart';
import 'start_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  UserProfile _profile = UserProfile.empty;
  bool _notificationsEnabled = true;
  FontSizeOption _fontSize = FontSizeOption.medium;
  bool _darkAppearance = true;
  String _subscriptionPlan = 'Free Plan';
  String _languageLabel = 'English(US)';

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    final profile = await StorageService.getProfile();
    final notifications = await StorageService.isNotificationsEnabled();
    final fontSize = await StorageService.getFontSize();
    final isDark = await StorageService.isDarkModeEnabled();
    final subscription = await StorageService.getSubscriptionPlan();
    final langCode = await StorageService.getLanguage();
    final languageLabel = _languageLabelFromCode(langCode);
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _notificationsEnabled = notifications;
      _fontSize = fontSize;
      _darkAppearance = isDark;
      _subscriptionPlan = subscription;
      _languageLabel = languageLabel;
      _loading = false;
    });
  }

  String _languageLabelFromCode(String code) {
    switch (code) {
      case 'en_US':
        return 'English(US)';
      case 'hi':
        return 'हिन्दी';
      case 'gu':
        return 'ગુજરાતી';
      default:
        return 'English(US)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_loading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    final displayName =
        _profile.fullName.trim().isEmpty ? 'Profile' : _profile.fullName;
    final displayEmail = _profile.email.trim().isEmpty
        ? 'Add email in edit profile'
        : _profile.email;

    final trailingIcon = Icon(
      Icons.chevron_right_rounded,
      color: colorScheme.onSurface.withOpacity(0.6),
      size: 24,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Profile',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
            ),
            // User profile row: avatar, name, email, arrow
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                      _loadAll();
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 4,
                      ),
                      child: Row(
                        children: [
                          _buildAvatar(context),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  displayEmail,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.onSurface.withOpacity(0.85),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: colorScheme.onSurface.withOpacity(0.7),
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Settings list
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color ?? colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.onSurface.withOpacity(0.08),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildListTile(
                        context,
                        icon: Icons.notifications_outlined,
                        title: 'Notification',
                        trailing: trailingIcon,
                        onTap: () => _openNotificationSettings(),
                      ),
                      _divider(context),
                      _buildListTile(
                        context,
                        icon: Icons.text_fields_rounded,
                        title: 'Font Size',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _pill(context, _fontSize.label),
                            const SizedBox(width: 4),
                            trailingIcon,
                          ],
                        ),
                        onTap: () => _openFontSizePicker(),
                      ),
                      _divider(context),
                      _buildListTile(
                        context,
                        icon: Icons.dark_mode_outlined,
                        title: 'Dark Appearance',
                        trailing: Switch(
                          value: _darkAppearance,
                          onChanged: (value) async {
                            final appState = context
                                .findAncestorStateOfType<KundaliAppState>();
                            appState?.setDarkMode(value);
                            await StorageService.setDarkModeEnabled(value);
                            setState(() => _darkAppearance = value);
                          },
                          activeTrackColor: colorScheme.primary.withOpacity(0.5),
                          activeThumbColor: colorScheme.primary,
                        ),
                      ),
                      _divider(context),
                      _buildListTile(
                        context,
                        icon: Icons.workspace_premium_outlined,
                        title: 'Subscriptions',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _pill(context, _subscriptionPlan),
                            const SizedBox(width: 4),
                            trailingIcon,
                          ],
                        ),
                        onTap: () => _openSubscriptions(),
                      ),
                      _divider(context),
                      _buildListTile(
                        context,
                        icon: Icons.star_outline_rounded,
                        title: 'Rate us',
                        trailing: trailingIcon,
                        onTap: () => _rateUs(),
                      ),
                      _divider(context),
                      _buildListTile(
                        context,
                        icon: Icons.chat_bubble_outline_rounded,
                        title: 'Contact us',
                        trailing: trailingIcon,
                        onTap: () => _contactUs(),
                      ),
                      _divider(context),
                      _buildListTile(
                        context,
                        icon: Icons.language_rounded,
                        title: 'Change Language',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _pill(context, _languageLabel),
                            const SizedBox(width: 4),
                            trailingIcon,
                          ],
                        ),
                        onTap: () => _openLanguagePicker(),
                      ),
                      _divider(context),
                      _buildListTile(
                        context,
                        icon: Icons.apps_rounded,
                        title: 'Change App Icon',
                        trailing: trailingIcon,
                        onTap: () => _changeAppIcon(),
                      ),
                      _divider(context),
                      _buildListTile(
                        context,
                        icon: Icons.delete_outline_rounded,
                        title: 'Delete Account',
                        titleColor: Colors.red,
                        iconColor: Colors.red,
                        onTap: () => _deleteAccount(),
                      ),
                      _divider(context),
                      _buildListTile(
                        context,
                        icon: Icons.logout_rounded,
                        title: 'Logout',
                        trailing: trailingIcon,
                        onTap: () => _signOut(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.secondary,
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: _profile.fullName.trim().isEmpty
            ? Icon(Icons.person_rounded, size: 32, color: colorScheme.onSecondary)
            : Center(
                child: Text(
                  _profile.fullName.trim().substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSecondary,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _pill(BuildContext context, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _divider(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Divider(
      height: 1,
      indent: 52,
      endIndent: 12,
      color: colorScheme.onSurface.withOpacity(0.08),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(
        icon,
        color: iconColor ?? colorScheme.onSurface.withOpacity(0.9),
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: titleColor ?? colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Future<void> _openNotificationSettings() async {
    bool value = _notificationsEnabled;
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final colorScheme = theme.colorScheme;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: theme.cardTheme.color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Notification', style: TextStyle(color: colorScheme.onSurface)),
              content: SwitchListTile(
                value: value,
                onChanged: (v) => setDialogState(() => value = v),
                title: Text(
                  'Enable notifications',
                  style: TextStyle(color: colorScheme.onSurface.withOpacity(0.8)),
                ),
                activeTrackColor: colorScheme.primary.withOpacity(0.5),
                activeThumbColor: colorScheme.primary,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text('Cancel', style: TextStyle(color: colorScheme.primary)),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: FilledButton.styleFrom(backgroundColor: colorScheme.primary),
                  child: Text('Save', style: TextStyle(color: colorScheme.onPrimary)),
                ),
              ],
            );
          },
        );
      },
    );
    if (saved == true) {
      await StorageService.setNotificationsEnabled(value);
      setState(() => _notificationsEnabled = value);
    }
  }

  Future<void> _openFontSizePicker() async {
    final chosen = await showDialog<FontSizeOption>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final colorScheme = theme.colorScheme;
        return AlertDialog(
          backgroundColor: theme.cardTheme.color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Font Size', style: TextStyle(color: colorScheme.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: FontSizeOption.values
                .map(
                  (e) => ListTile(
                    title: Text(e.label, style: TextStyle(color: colorScheme.onSurface)),
                    trailing: _fontSize == e
                        ? Icon(Icons.check, color: colorScheme.primary)
                        : null,
                    onTap: () => Navigator.pop(ctx, e),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
    if (chosen != null) {
      await StorageService.setFontSize(chosen);
      setState(() => _fontSize = chosen);
    }
  }

  Future<void> _openSubscriptions() async {
    final plan = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final colorScheme = theme.colorScheme;
        return AlertDialog(
          backgroundColor: theme.cardTheme.color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Subscriptions', style: TextStyle(color: colorScheme.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Free Plan', style: TextStyle(color: colorScheme.onSurface)),
                trailing: _subscriptionPlan == 'Free Plan'
                    ? Icon(Icons.check, color: colorScheme.primary)
                    : null,
                onTap: () => Navigator.pop(ctx, 'Free Plan'),
              ),
              ListTile(
                title: Text('Premium', style: TextStyle(color: colorScheme.onSurface)),
                trailing: _subscriptionPlan == 'Premium'
                    ? Icon(Icons.check, color: colorScheme.primary)
                    : null,
                onTap: () => Navigator.pop(ctx, 'Premium'),
              ),
            ],
          ),
        );
      },
    );
    if (plan != null) {
      await StorageService.setSubscriptionPlan(plan);
      setState(() => _subscriptionPlan = plan);
    }
  }

  void _rateUs() {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Rate us: opening store...'),
        backgroundColor: theme.cardTheme.color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _contactUs() async {
    final theme = Theme.of(context);
    final email = 'support@mistyai.com';
    final uri = Uri.parse('mailto:$email?subject=Support Request&body=Hello,');
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Contact us at $email'),
            backgroundColor: theme.cardTheme.color,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Contact us at $email'),
          backgroundColor: theme.cardTheme.color,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openLanguagePicker() async {
    final options = [
      {'label': 'English(US)', 'code': 'en_US'},
      {'label': 'हिन्दी', 'code': 'hi'},
      {'label': 'ગુજરાતી', 'code': 'gu'},
    ];
    
    final chosen = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final colorScheme = theme.colorScheme;
        return AlertDialog(
          backgroundColor: theme.cardTheme.color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Change Language', style: TextStyle(color: colorScheme.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options
                .map(
                  (e) => ListTile(
                    title: Text(e['label']!, style: TextStyle(color: colorScheme.onSurface)),
                    trailing: _languageLabel == e['label']
                        ? Icon(Icons.check, color: colorScheme.primary)
                        : null,
                    onTap: () => Navigator.pop(ctx, e),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
    if (chosen != null) {
      await StorageService.setLanguage(chosen['code']!);
      setState(() => _languageLabel = chosen['label']!);
    }
  }

  Future<void> _changeAppIcon() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final chosen = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: theme.cardTheme.color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Change App Icon', style: TextStyle(color: colorScheme.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.apps_rounded, color: colorScheme.primary),
                title: Text('Default', style: TextStyle(color: colorScheme.onSurface)),
                onTap: () => Navigator.pop(ctx, 'default'),
              ),
              ListTile(
                leading: Icon(Icons.star_rounded, color: colorScheme.primary),
                title: Text('Premium', style: TextStyle(color: colorScheme.onSurface)),
                onTap: () => Navigator.pop(ctx, 'premium'),
              ),
              ListTile(
                leading: Icon(Icons.dark_mode_rounded, color: colorScheme.primary),
                title: Text('Dark', style: TextStyle(color: colorScheme.onSurface)),
                onTap: () => Navigator.pop(ctx, 'dark'),
              ),
            ],
          ),
        );
      },
    );
    
    if (chosen != null && mounted) {
      // Note: Actual app icon change requires native code or flutter_launcher_icons package
      // This is a placeholder for the feature
      final iconName = chosen[0].toUpperCase() + chosen.substring(1);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('App icon changed to $iconName'),
          backgroundColor: theme.cardTheme.color,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final colorScheme = theme.colorScheme;
        return AlertDialog(
          backgroundColor: theme.cardTheme.color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Logout', style: TextStyle(color: colorScheme.onSurface)),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.8), fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: TextStyle(color: colorScheme.primary)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: colorScheme.primary),
              child: Text('Logout', style: TextStyle(color: colorScheme.onPrimary)),
            ),
          ],
        );
      },
    );
    
    if (confirmed == true && mounted) {
      // Clear all user data
      await StorageService.clearProfile();
      await StorageService.clearHistory();
      
      // Navigate to start screen
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const StartScreen()),
        (route) => false,
      );
      
      final theme = Theme.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Logged out successfully'),
          backgroundColor: theme.cardTheme.color,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final colorScheme = theme.colorScheme;
        return AlertDialog(
          backgroundColor: theme.cardTheme.color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Delete Account', style: TextStyle(color: colorScheme.onSurface)),
          content: Text(
            'Are you sure you want to delete your account? This will remove all your data and cannot be undone.',
            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.8), fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: TextStyle(color: colorScheme.primary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
    if (confirmed == true && mounted) {
      await StorageService.clearProfile();
      await StorageService.clearHistory();
      if (!mounted) return;
      setState(() => _profile = UserProfile.empty);
      final theme = Theme.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account data deleted'),
          backgroundColor: theme.cardTheme.color,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
