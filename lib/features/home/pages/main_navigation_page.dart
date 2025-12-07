import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_colors.dart';
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
                  ? Colors.black.withValues(alpha:0.3)
                  : Colors.black.withValues(alpha:0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
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
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: AppColors.primaryGreen,
          unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
          selectedIconTheme: const IconThemeData(size: 26),
          unselectedIconTheme: const IconThemeData(size: 24),
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_run_outlined),
              activeIcon: Icon(Icons.directions_run_rounded),
              label: 'Activities',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard_outlined),
              activeIcon: Icon(Icons.leaderboard_rounded),
              label: 'Leaderboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
