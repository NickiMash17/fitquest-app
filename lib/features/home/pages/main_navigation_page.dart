import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';
import 'package:fitquest/core/constants/app_typography.dart';
import 'package:fitquest/features/home/pages/home_page.dart';
import 'package:fitquest/features/home/pages/activities_page.dart';
import 'package:fitquest/features/community/pages/leaderboard_page.dart';
import 'package:fitquest/features/profile/pages/profile_page.dart';
import 'package:fitquest/core/utils/haptic_feedback_service.dart';
import 'package:fitquest/core/di/injection.dart';
import 'package:fitquest/core/services/connectivity_service.dart';
import 'package:fitquest/shared/widgets/offline_banner.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  ConnectivityResult _connectivityStatus = ConnectivityResult.none;
  late ConnectivityService _connectivityService;

  final List<Widget> _pages = const [
    HomePage(),
    ActivitiesPage(),
    LeaderboardPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _connectivityService = getIt<ConnectivityService>();
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    final status = await _connectivityService.getCurrentStatus();
    if (mounted) {
      setState(() {
        _connectivityStatus = status;
      });
    }
    _connectivityService.onConnectivityChanged.listen((result) {
      if (mounted) {
        setState(() {
          _connectivityStatus = result;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isOffline = _connectivityStatus == ConnectivityResult.none;

    return Scaffold(
      body: Column(
        children: [
          OfflineBanner(isOffline: isOffline),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, -4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, -2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              if (index != _currentIndex) {
                HapticFeedbackService.selectionClick();
                _animationController.forward().then((_) {
                  _animationController.reverse();
                });
                setState(() {
                  _currentIndex = index;
                });
              }
            },
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            backgroundColor: Colors.transparent,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
            selectedIconTheme: IconThemeData(
              size: 28,
              color: AppColors.primary,
            ),
            unselectedIconTheme: IconThemeData(
              size: 24,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            selectedLabelStyle: AppTypography.labelMedium.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
            unselectedLabelStyle: AppTypography.labelMedium.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: AppBorderRadius.allMD,
                    color: _currentIndex == 0
                        ? AppColors.primary.withValues(alpha: 0.09)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    _currentIndex == 0
                        ? Icons.home_rounded
                        : Icons.home_outlined,
                  ),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: AppBorderRadius.allMD,
                    color: _currentIndex == 1
                        ? AppColors.primary.withValues(alpha: 0.09)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    _currentIndex == 1
                        ? Icons.directions_run_rounded
                        : Icons.directions_run_outlined,
                  ),
                ),
                label: 'Activities',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: AppBorderRadius.allMD,
                    color: _currentIndex == 2
                        ? AppColors.primary.withValues(alpha: 0.09)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    _currentIndex == 2
                        ? Icons.leaderboard_rounded
                        : Icons.leaderboard_outlined,
                  ),
                ),
                label: 'Leaderboard',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: AppBorderRadius.allMD,
                    color: _currentIndex == 3
                        ? AppColors.primary.withValues(alpha: 0.09)
                        : Colors.transparent,
                  ),
                  child: Icon(
                    _currentIndex == 3
                        ? Icons.person_rounded
                        : Icons.person_outline_rounded,
                  ),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
