// lib/core/services/theme_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reactive theme service that manages app theme mode
/// Uses ValueNotifier for efficient state management
class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'dark_mode';

  ThemeMode _themeMode = ThemeMode.system; // Default to system
  bool _isInitialized = false;

  ThemeMode get themeMode {
    // If not initialized yet, return system mode
    if (!_isInitialized) {
      return ThemeMode.system;
    }
    return _themeMode;
  }
  
  /// Check if dark mode is currently active
  /// Takes into account system theme when in system mode
  bool get isDarkMode {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    // System mode - check platform brightness
    return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
  }

  /// Initialize theme from preferences
  /// Respects user preference or system default
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final darkMode = prefs.getBool(_themeKey);
      // Use saved preference, or default to system theme
      if (darkMode != null) {
        _themeMode = darkMode ? ThemeMode.dark : ThemeMode.light;
      } else {
        // Default to system theme if no preference saved
        _themeMode = ThemeMode.system;
      }
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme: $e');
      _themeMode = ThemeMode.system; // Default to system theme
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Toggle between light and dark mode
  /// If system mode, switches to dark. If dark, switches to light. If light, switches to dark.
  Future<void> toggleTheme() async {
    ThemeMode newMode;
    if (_themeMode == ThemeMode.system) {
      // If system mode, check actual brightness and toggle
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      newMode = brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    } else if (_themeMode == ThemeMode.light) {
      newMode = ThemeMode.dark;
    } else {
      newMode = ThemeMode.light;
    }
    await setThemeMode(newMode);
  }

  /// Set theme mode explicitly
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      if (mode == ThemeMode.system) {
        // Remove preference to use system default
        await prefs.remove(_themeKey);
      } else {
        await prefs.setBool(_themeKey, mode == ThemeMode.dark);
      }
      _themeMode = mode;
      debugPrint('Theme mode changed to: $mode');
      notifyListeners();
      debugPrint('Theme listeners notified');
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  /// Set dark mode boolean
  Future<void> setDarkMode(bool isDark) async {
    await setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
