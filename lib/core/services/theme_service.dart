// lib/core/services/theme_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reactive theme service that manages app theme mode
/// Uses ValueNotifier for efficient state management
class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'dark_mode';

  ThemeMode _themeMode = ThemeMode.light;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Initialize theme from preferences
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final darkMode = prefs.getBool(_themeKey) ?? false;
      _themeMode = darkMode ? ThemeMode.dark : ThemeMode.light;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme: $e');
      _themeMode = ThemeMode.light;
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }

  /// Set theme mode explicitly
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, mode == ThemeMode.dark);
      _themeMode = mode;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  /// Set dark mode boolean
  Future<void> setDarkMode(bool isDark) async {
    await setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
