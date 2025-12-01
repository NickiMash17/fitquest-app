import 'package:flutter/material.dart';
import 'package:fitquest/core/navigation/app_router.dart';
import 'package:fitquest/core/di/injection.dart';
import 'package:fitquest/shared/services/local_storage_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      // Wait for animation
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Check if dependencies are ready
      try {
        final storage = getIt<LocalStorageService>();
        final hasSeenOnboarding = storage.getBool('has_seen_onboarding');

        // Only navigate to login if explicitly set to true
        // If null (first time) or false, show onboarding
        if (hasSeenOnboarding == true) {
          // User has seen onboarding, go to login
          if (mounted) {
            Navigator.of(context).pushReplacementNamed(AppRouter.login);
          }
        } else {
          // First time or reset - show onboarding
          if (mounted) {
            Navigator.of(context).pushReplacementNamed(AppRouter.onboarding);
          }
        }
      } catch (e) {
        debugPrint('Dependencies not ready, navigating to onboarding: $e');
        // If dependencies aren't ready, show onboarding anyway
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(AppRouter.onboarding);
        }
      }
    } catch (e) {
      debugPrint('Error in splash: $e');
      // Navigate to login on error
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRouter.login);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.eco,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  'FitQuest',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 32),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
