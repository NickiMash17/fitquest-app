import 'package:flutter/material.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_spacing.dart';
import 'package:fitquest/core/constants/app_border_radius.dart';
import 'package:fitquest/core/navigation/app_router.dart' as router;
import 'package:fitquest/core/di/injection.dart';
import 'package:fitquest/shared/services/local_storage_service.dart';
import 'package:fitquest/shared/widgets/premium_button.dart';
import 'package:fitquest/shared/widgets/theme_toggle_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      icon: Icons.fitness_center_rounded,
      title: 'Track Your Wellness',
      description:
          'Log daily activities like exercise, meditation, hydration, and sleep to build healthy habits that last.',
      gradient: AppColors.primaryGradient,
      iconGradient: LinearGradient(
        colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
      ),
    ),
    _OnboardingSlide(
      icon: Icons.eco_rounded,
      title: 'Grow Your Companion',
      description:
          'Watch your virtual plant evolve from a tiny seed to a majestic tree as you complete activities and reach new milestones.',
      gradient: AppColors.blueGradient,
      iconGradient: LinearGradient(
        colors: [Color(0xFF64B5F6), Color(0xFF2196F3)],
      ),
    ),
    _OnboardingSlide(
      icon: Icons.emoji_events_rounded,
      title: 'Compete & Connect',
      description:
          'Join leaderboards, unlock achievements, and challenge friends on your wellness journey to stay motivated.',
      gradient: AppColors.accentGradient,
      iconGradient: LinearGradient(
        colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _skipOnboarding() {
    _finishOnboarding();
  }

  void _finishOnboarding() async {
    // Mark onboarding as completed
    try {
      final storage = getIt<LocalStorageService>();
      await storage.setBool('has_seen_onboarding', true);
    } catch (e) {
      debugPrint('Error saving onboarding status: $e');
    }
    // Navigate to login
    if (!mounted) return;
    router.AppRouter.navigateAndRemoveUntil(context, router.AppRouter.login);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1B1B1B),
                    const Color(0xFF2E7D32).withValues(alpha: 0.3),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryLightest,
                    AppColors.primaryLight.withValues(alpha: 0.3),
                  ],
                ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button and Theme toggle
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox.shrink(), // Spacer
                    Row(
                      children: [
                        const ThemeToggleButton(),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: _skipOnboarding,
                          style: TextButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    return _buildSlide(_slides[index], isDark);
                  },
                ),
              ),

              // Dots indicator
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _slides.length,
                    (index) => _buildDot(index, isDark),
                  ),
                ),
              ),

              // Next/Get Started button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: PremiumButton(
                  label: _currentPage == _slides.length - 1
                      ? 'Get Started'
                      : 'Next',
                  onPressed: _nextPage,
                  icon: _currentPage == _slides.length - 1
                      ? Icons.arrow_forward_rounded
                      : Icons.arrow_forward_rounded,
                  gradient: _slides[_currentPage].gradient,
                  width: double.infinity,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlide(_OnboardingSlide slide, bool isDark) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with gradient background
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: slide.iconGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: slide.iconGradient.colors.first
                          .withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  slide.icon,
                  size: 70,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),
              // Title
              Text(
                slide.title,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Description
              Text(
                slide.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.6,
                      letterSpacing: 0.2,
                    ),
                textAlign: TextAlign.center,
                maxLines: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(int index, bool isDark) {
    final isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isActive ? 32.0 : 8.0,
      height: 8.0,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        borderRadius: AppBorderRadius.allRound,
        gradient: isActive ? _slides[_currentPage].gradient : null,
        color: isActive
            ? null
            : Theme.of(context)
                .colorScheme
                .onSurfaceVariant
                .withValues(alpha: 0.4),
      ),
    );
  }
}

class _OnboardingSlide {
  final IconData icon;
  final String title;
  final String description;
  final Gradient gradient;
  final Gradient iconGradient;

  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
    required this.iconGradient,
  });
}
