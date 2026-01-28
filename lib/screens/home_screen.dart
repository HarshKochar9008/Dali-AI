import 'package:flutter/material.dart';
import 'input_screen.dart';
import 'chart_display_screen.dart';
import 'about_screen.dart';
import 'profile_screen.dart';
import '../models/kundali_data.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  KundaliData? _latestKundali;

  @override
  void initState() {
    super.initState();
    _loadLatestKundali();
  }

  Future<void> _loadLatestKundali() async {
    final history = await StorageService.getHistory();
    if (history.isNotEmpty) {
      setState(() {
        _latestKundali = history.first.kundaliData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboard(),
          const InputScreen(),
          _latestKundali != null
              ? ChartDisplayScreen(kundaliData: _latestKundali!)
              : _buildNoChartPlaceholder(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: const Color(0xFF262450),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) async {
            if (index == 2) {
              await _loadLatestKundali();
            }
            setState(() {
              _currentIndex = index;
            });
          },
          type: theme.bottomNavigationBarTheme.type,
          selectedItemColor:
              theme.bottomNavigationBarTheme.selectedItemColor ??
              colorScheme.primary,
          unselectedItemColor:
              theme.bottomNavigationBarTheme.unselectedItemColor ??
              colorScheme.onSurface.withOpacity(0.5),
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: theme.bottomNavigationBarTheme.elevation ?? 0,
          backgroundColor:
              theme.bottomNavigationBarTheme.backgroundColor ??
              colorScheme.surface,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              label: 'Generate',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome),
              label: 'Chart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Icon(
              Icons.auto_awesome_outlined,
              size: 48,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Misty AI',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w300,
                letterSpacing: 2,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Astrological chart generator',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: colorScheme.onBackground.withOpacity(0.7),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 48),
            _buildQuickActionCard(
              icon: Icons.add_circle_outline,
              title: 'Generate Chart',
              subtitle: 'Create new Kundali',
              onTap: () {
                setState(() {
                  _currentIndex = 1;
                });
              },
            ),
            const SizedBox(height: 12),
            if (_latestKundali != null) ...[
              _buildQuickActionCard(
                icon: Icons.auto_awesome_outlined,
                title: 'Latest Chart',
                subtitle: 'View recent Kundali',
                onTap: () {
                  setState(() {
                    _currentIndex = 2;
                  });
                },
              ),
              const SizedBox(height: 12),
            ],
            _buildQuickActionCard(
              icon: Icons.history_outlined,
              title: 'History',
              subtitle: 'Saved charts',
              onTap: () {
                setState(() {
                  _currentIndex = 3;
                });
              },
            ),
            const SizedBox(height: 12),
            _buildQuickActionCard(
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'Learn more',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF262450),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colorScheme.onSurface.withOpacity(0.4),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoChartPlaceholder() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kundali Chart'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 100,
              color: Colors.white24,
            ),
            const SizedBox(height: 24),
            Text(
              'No Chart Available',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate a new Kundali chart to view it here',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white60,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _currentIndex = 1;
                });
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Generate Chart'),
            ),
          ],
        ),
      ),
    );
  }
}
