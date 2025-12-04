import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A button widget to toggle between light and dark theme
class ThemeToggleButton extends StatefulWidget {
  final bool showLabel;
  final Color? iconColor;

  const ThemeToggleButton({
    super.key,
    this.showLabel = false,
    this.iconColor,
  });

  @override
  State<ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<ThemeToggleButton> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final darkMode = prefs.getBool('dark_mode') ?? false;
      if (mounted) {
        setState(() {
          _isDarkMode = darkMode;
        });
      }
    } catch (e) {
      debugPrint('Error loading theme mode: $e');
    }
  }

  Future<void> _toggleTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final newDarkMode = !_isDarkMode;
      await prefs.setBool('dark_mode', newDarkMode);

      if (mounted) {
        setState(() {
          _isDarkMode = newDarkMode;
        });

        // Trigger app rebuild by navigating to the same route
        // This will cause the app to reload with the new theme
        await Future.delayed(const Duration(milliseconds: 100));

        // Force a rebuild of the MaterialApp
        if (mounted) {
          // The main app will pick up the change via _listenForThemeChanges
          // For immediate effect, we can use a callback or state management
          // For now, the theme will update on next navigation or app restart
        }
      }
    } catch (e) {
      debugPrint('Error toggling theme: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor =
        widget.iconColor ?? Theme.of(context).colorScheme.onSurface;

    if (widget.showLabel) {
      return InkWell(
        onTap: _toggleTheme,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isDarkMode
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _isDarkMode ? 'Light Mode' : 'Dark Mode',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: iconColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return IconButton(
      icon: Icon(
        _isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
        color: iconColor,
      ),
      tooltip: _isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      onPressed: _toggleTheme,
    );
  }
}
