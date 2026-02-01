import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/kundali_data.dart';
import '../models/user_profile.dart';

class HistoryItem {
  final KundaliData kundaliData;
  final DateTime dateTime;
  final String location;

  HistoryItem({
    required this.kundaliData,
    required this.dateTime,
    required this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'dateTime': dateTime.toIso8601String(),
      'location': location,
      'houses': kundaliData.houses.map((h) => {
        'houseNumber': h.houseNumber,
        'zodiacSign': h.zodiacSign,
      }).toList(),
      'planets': kundaliData.planets.map((p) => {
        'name': p.name,
        'house': p.house,
        'sign': p.sign,
      }).toList(),
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    final houses = (json['houses'] as List).map((h) => HouseData(
      houseNumber: h['houseNumber'],
      zodiacSign: h['zodiacSign'],
    )).toList();

    final planets = (json['planets'] as List).map((p) => PlanetData(
      name: p['name'],
      house: p['house'],
      sign: p['sign'],
    )).toList();

    return HistoryItem(
      kundaliData: KundaliData(houses: houses, planets: planets),
      dateTime: DateTime.parse(json['dateTime']),
      location: json['location'] ?? '',
    );
  }
}

/// Font size options for profile/settings.
enum FontSizeOption { small, medium, large }

extension FontSizeOptionExt on FontSizeOption {
  String get label {
    switch (this) {
      case FontSizeOption.small:
        return 'Small';
      case FontSizeOption.medium:
        return 'Medium';
      case FontSizeOption.large:
        return 'Large';
    }
  }

  double get scale {
    switch (this) {
      case FontSizeOption.small:
        return 0.9;
      case FontSizeOption.medium:
        return 1.0;
      case FontSizeOption.large:
        return 1.15;
    }
  }
}

class StorageService {
  static const String _historyKey = 'kundali_history';
  static const String _profileKey = 'user_profile';
  static const String _themeKey = 'app_theme_is_dark';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _fontSizeKey = 'font_size'; // 'small' | 'medium' | 'large'
  static const String _subscriptionKey = 'subscription_plan'; // 'free' | 'premium' etc
  static const String _languageKey = 'app_language'; // 'en_US' etc

  static Future<void> saveKundali(
    KundaliData kundaliData,
    DateTime dateTime,
    String location,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();

    final newItem = HistoryItem(
      kundaliData: kundaliData,
      dateTime: dateTime,
      location: location,
    );

    history.insert(0, newItem);
    
    // Keep only last 50 items
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }

    final historyJson = history.map((item) => item.toJson()).toList();
    await prefs.setString(_historyKey, jsonEncode(historyJson));
  }

  static Future<List<HistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_historyKey);

    if (historyJson == null) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(historyJson);
      return decoded.map((item) => HistoryItem.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> deleteHistoryItem(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();

    if (index >= 0 && index < history.length) {
      history.removeAt(index);
      final historyJson = history.map((item) => item.toJson()).toList();
      await prefs.setString(_historyKey, jsonEncode(historyJson));
    }
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // THEME

  static Future<void> setDarkModeEnabled(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  static Future<bool> isDarkModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? true;
  }

  static Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  static Future<UserProfile> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    if (raw == null || raw.isEmpty) return UserProfile.empty;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return UserProfile.fromJson(decoded);
      }
      return UserProfile.empty;
    } catch (_) {
      return UserProfile.empty;
    }
  }

  static Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
  }

  // NOTIFICATIONS
  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
  }

  static Future<bool> isNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? true;
  }

  // FONT SIZE
  static Future<void> setFontSize(FontSizeOption size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fontSizeKey, size.name);
  }

  static Future<FontSizeOption> getFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_fontSizeKey);
    if (name == null) return FontSizeOption.medium;
    return FontSizeOption.values.firstWhere(
      (e) => e.name == name,
      orElse: () => FontSizeOption.medium,
    );
  }

  // SUBSCRIPTION
  static Future<void> setSubscriptionPlan(String plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_subscriptionKey, plan);
  }

  static Future<String> getSubscriptionPlan() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_subscriptionKey) ?? 'Free Plan';
  }

  // LANGUAGE
  static Future<void> setLanguage(String localeCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, localeCode);
  }

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en_US';
  }
}
