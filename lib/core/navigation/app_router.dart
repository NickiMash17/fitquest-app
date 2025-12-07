// lib/core/navigation/app_router.dart
import 'package:flutter/material.dart';
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
import 'package:fitquest/shared/widgets/page_transition.dart';
import 'package:fitquest/features/statistics/pages/statistics_page.dart';
import 'package:fitquest/features/achievements/pages/achievements_page.dart';
import 'package:fitquest/features/goals/pages/goals_page.dart';
import 'package:fitquest/features/calendar/pages/calendar_page.dart';
import 'package:fitquest/features/profile/pages/privacy_policy_page.dart';
import 'package:fitquest/features/profile/pages/terms_of_service_page.dart';
import 'package:fitquest/features/profile/pages/about_page.dart';

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
  static const String statistics = '/statistics';
  static const String achievements = '/achievements';
  static const String goals = '/goals';
  static const String calendar = '/calendar';
  static const String privacyPolicy = '/privacy-policy';
  static const String termsOfService = '/terms-of-service';
  static const String about = '/about';

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

  static void navigate(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.of(context).pushNamed(routeName, arguments: arguments);
  }

  // Route generator with smooth transitions
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return FadePageRoute(child: const SplashPage());
      case onboarding:
        return SlidePageRoute(
          direction: SlideDirection.right,
          child: const OnboardingPage(),
        );
      case login:
        return SlidePageRoute(
          direction: SlideDirection.right,
          child: const LoginPage(),
        );
      case signUp:
        return SlidePageRoute(
          direction: SlideDirection.right,
          child: const SignUpPage(),
        );
      case home:
        return FadePageRoute(child: const MainNavigationPage());
      case activities:
        return SlidePageRoute(
          direction: SlideDirection.left,
          child: const ActivitiesPage(),
        );
      case profile:
        return SlidePageRoute(
          direction: SlideDirection.left,
          child: const ProfilePage(),
        );
      case AppRouter.settings:
        return SlidePageRoute(
          direction: SlideDirection.left,
          child: const SettingsPage(),
        );
      case leaderboard:
        return SlidePageRoute(
          direction: SlideDirection.left,
          child: const LeaderboardPage(),
        );
      case addActivity:
        final activityType = routeSettings.arguments as ActivityType?;
        return ScalePageRoute(
          child: AddActivityPage(initialType: activityType),
        );
      case statistics:
        return SlidePageRoute(
          direction: SlideDirection.left,
          child: const StatisticsPage(),
        );
      case achievements:
        return SlidePageRoute(
          direction: SlideDirection.left,
          child: const AchievementsPage(),
        );
      case goals:
        return SlidePageRoute(
          direction: SlideDirection.left,
          child: const GoalsPage(),
        );
      case calendar:
        final activities =
            routeSettings.arguments as List<ActivityModel>? ?? [];
        return SlidePageRoute(
          direction: SlideDirection.left,
          child: CalendarPage(activities: activities),
        );
      case privacyPolicy:
        return SlidePageRoute(
          direction: SlideDirection.left,
          child: const PrivacyPolicyPage(),
        );
      case termsOfService:
        return SlidePageRoute(
          direction: SlideDirection.left,
          child: const TermsOfServicePage(),
        );
      case about:
        return SlidePageRoute(
          direction: SlideDirection.left,
          child: const AboutPage(),
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
