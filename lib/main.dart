import 'package:flutter/material.dart';
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
    final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFB39DFF),
        secondary: Color(0xFF7C4DFF),
        surface: Color(0xFF050518),
        background: Color(0xFF02010C),
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF02010C),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF050518),
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF0B0A24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0xFF262450),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0B0A24),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF37346E),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF37346E),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFB39DFF),
            width: 1.5,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB39DFF),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF050518),
        selectedItemColor: Color(0xFFB39DFF),
        unselectedItemColor: Color(0xFF6967A6),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
    );

    final lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF7C4DFF),
        secondary: Color(0xFFB39DFF),
        surface: Colors.white,
        background: Color(0xFFF5F5F9),
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.black87,
        onBackground: Colors.black87,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F9),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0xFFE0E0EC),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFCCCCDD),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFCCCCDD),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF7C4DFF),
            width: 1.5,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7C4DFF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF7C4DFF),
        unselectedItemColor: Color(0xFF757595),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
    );

    return MaterialApp(
      title: 'Misty AI',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      home: const StartScreen(),
    );
  }
}
