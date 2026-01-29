import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/start_screen.dart';
import 'services/storage_service.dart';

void main() {
  runApp(const KundaliApp());
}

class KundaliApp extends StatefulWidget {
  const KundaliApp({super.key});

  @override
  State<KundaliApp> createState() => KundaliAppState();
}

class KundaliAppState extends State<KundaliApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  static KundaliAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<KundaliAppState>();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadTheme);
  }

  Future<void> _loadTheme() async {
    final isDark = await StorageService.isDarkModeEnabled();
    if (!mounted) return;
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  Future<void> setDarkMode(bool isDark) async {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
    await StorageService.setDarkModeEnabled(isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Misty AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: const StartScreen(),
    );
  }
}
