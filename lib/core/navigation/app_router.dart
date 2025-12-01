// lib/core/navigation/app_router.dart
import 'package:flutter/material.dart';
import 'package:fitquest/features/home/pages/home_page.dart';
import 'package:fitquest/features/home/pages/activities_page.dart';
import 'package:fitquest/features/onboarding/pages/onboarding_page.dart';
import 'package:fitquest/features/onboarding/pages/splash_page.dart';
import 'package:fitquest/features/authentication/pages/login_page.dart';
import 'package:fitquest/features/authentication/pages/signup_page.dart';
import 'package:fitquest/features/profile/pages/profile_page.dart';
import 'package:fitquest/features/profile/pages/settings_page.dart';
import 'package:fitquest/features/community/pages/leaderboard_page.dart';
import 'package:fitquest/features/activities/pages/add_activity_page.dart';
import 'package:fitquest/features/home/pages/main_navigation_page.dart';
import 'package:fitquest/shared/models/activity_model.dart';

class AppRouter {
  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String home = '/home';
  static const String activities = '/activities';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String leaderboard = '/leaderboard';
  static const String addActivity = '/add-activity';

  // Navigation methods
  static void navigateAndReplace(BuildContext context, String routeName) {
    Navigator.of(context).pushReplacementNamed(routeName);
  }

  static void navigateAndRemoveUntil(BuildContext context, String routeName) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
    );
  }

  static void navigate(BuildContext context, String routeName) {
    Navigator.of(context).pushNamed(routeName);
  }

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpPage());
      case home:
        return MaterialPageRoute(builder: (_) => const MainNavigationPage());
      case activities:
        return MaterialPageRoute(builder: (_) => const ActivitiesPage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case AppRouter.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case leaderboard:
        return MaterialPageRoute(builder: (_) => const LeaderboardPage());
      case addActivity:
        final activityType = routeSettings.arguments as ActivityType?;
        return MaterialPageRoute(
          builder: (_) => AddActivityPage(initialType: activityType),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${routeSettings.name}'),
            ),
          ),
        );
    }
  }
}
