import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_spacing.dart';
import 'package:fitquest/shared/widgets/premium_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('dark_mode') ?? false;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
    setState(() {
      _darkMode = value;
    });
    // Trigger app rebuild to apply theme change
    // This will be handled by the main app state
    if (mounted) {
      Navigator.of(context).pop();
      // Small delay to ensure state is saved
      await Future.delayed(const Duration(milliseconds: 100));
      // Restart app to apply theme - in production, use a state management solution
      // For now, user needs to restart manually or we can use a callback
    }
  }

  Future<void> _saveNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  Future<String> _getVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return '${packageInfo.version} (${packageInfo.buildNumber})';
    } catch (e) {
      return '1.0.0';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          // Appearance section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.palette_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Appearance',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: -0.3,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          PremiumCard(
            padding: EdgeInsets.zero,
            child: SwitchListTile(
              title: Text(
                'Dark Mode',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                'Use dark theme for better viewing in low light',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              value: _darkMode,
              onChanged: _saveDarkMode,
              activeThumbColor: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Notifications section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.notifications_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Notifications',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: -0.3,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          PremiumCard(
            padding: EdgeInsets.zero,
            child: SwitchListTile(
              title: Text(
                'Enable Notifications',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                'Receive activity reminders and updates',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              value: _notificationsEnabled,
              onChanged: _saveNotifications,
              activeThumbColor: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // About section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.blueGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'About',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: -0.3,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          PremiumCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.phone_android_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  title: Text(
                    'App Version',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  subtitle: FutureBuilder<String>(
                    future: _getVersion(),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? '1.0.0',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      );
                    },
                  ),
                ),
                Divider(
                  height: 1,
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.12),
                ),
                ListTile(
                  leading: Icon(
                    Icons.privacy_tip_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  title: Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed('/privacy-policy');
                  },
                ),
                Divider(
                  height: 1,
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.12),
                ),
                ListTile(
                  leading: Icon(
                    Icons.description_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  title: Text(
                    'Terms of Service',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed('/terms-of-service');
                  },
                ),
                Divider(
                  height: 1,
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.12),
                ),
                ListTile(
                  leading: Icon(
                    Icons.info_outline_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  title: Text(
                    'About',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed('/about');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
