import 'package:flutter/material.dart';
import 'package:fitquest/core/di/injection.dart';
import 'package:fitquest/core/services/theme_service.dart';

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
  late ThemeService _themeService;

  @override
  void initState() {
    super.initState();
    _themeService = getIt<ThemeService>();
    _themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _toggleTheme() async {
    await _themeService.toggleTheme();
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
                _themeService.themeMode == ThemeMode.dark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _themeService.themeMode == ThemeMode.dark
                    ? 'Light Mode'
                    : 'Dark Mode',
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
        _themeService.themeMode == ThemeMode.dark
            ? Icons.light_mode_rounded
            : Icons.dark_mode_rounded,
        color: iconColor,
      ),
      tooltip: _themeService.themeMode == ThemeMode.dark
          ? 'Switch to Light Mode'
          : 'Switch to Dark Mode',
      onPressed: _toggleTheme,
    );
  }
}
