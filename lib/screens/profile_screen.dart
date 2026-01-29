import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';
import 'about_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  UserProfile _profile = UserProfile.empty;
  int _selectedTab = 0; // 0 = Personal Info, 1 = Settings

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    final profile = await StorageService.getProfile();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final displayName =
        _profile.fullName.trim().isEmpty ? 'Profile' : _profile.fullName;
    final displayPhone =
        _profile.phone.trim().isEmpty ? '9876543210' : _profile.phone;

    return Scaffold(
      backgroundColor: AppColors.surfaceBlack,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.headerViolet,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'My Profile',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.notifications_none,
                          color: AppColors.headerViolet, size: 22),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.headerViolet,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _buildVioletHeader(),
                _buildProfileCard(displayName, displayPhone),
                _buildProfileAvatar(),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMenuList(),
                  const SizedBox(height: 24),
                  _buildLogoutButton(),
                  const SizedBox(height: 28),
                  const Center(
                    child: Text(
                      'Follow us on',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSocialIcons(),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'App version 1.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVioletHeader() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.headerViolet,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: -40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentViolet.withOpacity(0.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(String displayName, String displayPhone) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 80, 20, 0),
      padding: const EdgeInsets.fromLTRB(20, 64, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone_android,
                  size: 16, color: AppColors.accentViolet),
              const SizedBox(width: 6),
              Text(
                displayPhone,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedTab = 0);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    ).then((_) => _loadProfile());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedTab == 0
                          ? AppColors.accentViolet.withOpacity(0.25)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Personal Info',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            _selectedTab == 0 ? Colors.white : Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedTab = 1);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedTab == 1
                          ? AppColors.accentViolet.withOpacity(0.25)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Settings',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            _selectedTab == 1 ? Colors.white : Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Positioned(
      left: 0,
      right: 0,
      top: 35,
      child: Center(
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: AppColors.accentViolet.withOpacity(0.6), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: _profile.fullName.trim().isEmpty
                ? Container(
                    color: AppColors.headerViolet,
                    child: const Icon(
                      Icons.person,
                      size: 44,
                      color: Colors.white,
                    ),
                  )
                : Container(
                    color: AppColors.headerViolet,
                    alignment: Alignment.center,
                    child: Text(
                      _profile.fullName.trim().isNotEmpty
                          ? _profile.fullName
                              .trim()
                              .substring(0, 1)
                              .toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Column(
          children: [
            _buildExpandableItem(
              title: 'FAQ',
              icon: Icons.help_outline,
              content:
                  'Find answers to common questions about Kundali, chart generation, and birth details.',
              onTap: () {},
            ),
            Divider(height: 1, color: Colors.white.withOpacity(0.08)),
            _buildExpandableItem(
              title: 'Feedbacks & Support',
              icon: Icons.feedback_outlined,
              content:
                  'Share your feedback or get help from our support team. We\'re here to assist you.',
              onTap: () {},
            ),
            Divider(height: 1, color: Colors.white.withOpacity(0.08)),
            _buildExpandableItem(
              title: 'Terms & Conditions',
              icon: Icons.description_outlined,
              content:
                  'Read our terms of service and conditions for using the Kundali app.',
              onTap: () {},
            ),
            Divider(height: 1, color: Colors.white.withOpacity(0.08)),
            _buildExpandableItem(
              title: 'Privacy',
              icon: Icons.privacy_tip_outlined,
              content:
                  'Learn how we collect, use, and protect your personal data and chart information.',
              onTap: () {},
            ),
            Divider(height: 1, color: Colors.white.withOpacity(0.08)),
            _buildExpandableItem(
              title: 'About Us',
              icon: Icons.info_outline_rounded,
              content:
                  'Discover more about our app and the team behind Kundali.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              },
            ),
            Divider(height: 1, color: Colors.white.withOpacity(0.08)),
            _buildExpandableItem(
              title: 'Contact US',
              icon: Icons.contact_support_outlined,
              content:
                  'Reach out to us for inquiries, partnerships, or general contact.',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableItem({
    required String title,
    required IconData icon,
    required String content,
    required VoidCallback onTap,
  }) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      leading:
          Icon(icon, color: AppColors.accentViolet.withOpacity(0.9), size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.keyboard_arrow_down,
        color: AppColors.accentViolet.withOpacity(0.8),
        size: 24,
      ),
      iconColor: AppColors.accentViolet.withOpacity(0.8),
      collapsedIconColor: AppColors.accentViolet.withOpacity(0.8),
      onExpansionChanged: (_) {},
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.8),
              height: 1.4,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onTap,
            icon: Icon(Icons.open_in_new,
                size: 16, color: AppColors.accentViolet),
            label: Text('Open',
                style: TextStyle(color: AppColors.accentViolet, fontSize: 13)),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to logout? Your profile data will be cleared from this device.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                Text('Cancel', style: TextStyle(color: AppColors.accentViolet)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accentViolet,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    await StorageService.clearProfile();
    if (!mounted) return;
    setState(() {
      _profile = UserProfile.empty;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('You have been logged out'),
        backgroundColor: AppColors.cardDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildLogoutButton() {
    return OutlinedButton.icon(
      onPressed: _handleLogout,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.accentViolet,
        side: BorderSide(color: AppColors.accentViolet.withOpacity(0.8)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: Icon(Icons.power_settings_new,
          color: AppColors.accentViolet, size: 20),
      label: const Text('Logout',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildSocialIcons() {
    final letters = ['f', 'i', '𝕏', 'P'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              customBorder: const CircleBorder(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentViolet.withOpacity(0.2),
                ),
                alignment: Alignment.center,
                child: Text(
                  letters[i],
                  style: TextStyle(
                    fontSize: i == 2 ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentViolet,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
