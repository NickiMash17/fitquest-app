/// Application-wide constants
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // App Information
  static const String appName = 'FitQuest';
  static const String appVersion = '0.1.0';
  static const String appTagline = 'Grow Your Wellness Journey';

  // Evolution Stages
  static const int seedStageThreshold = 0;
  static const int sproutStageThreshold = 20;
  static const int saplingStageThreshold = 50;
  static const int treeStageThreshold = 100;
  static const int ancientTreeStageThreshold = 200;

  // Points Configuration
  static const int exercisePointsPerMinute = 2;
  static const int meditationPointsPerMinute = 3;
  static const int hydrationPointsPerGlass = 10;
  static const int sleepPointsPerHour = 5;

  // XP Configuration
  static const int exerciseXpPerMinute = 5;
  static const int meditationXpPerMinute = 7;
  static const int hydrationXpPerGlass = 15;
  static const int sleepXpPerHour = 10;

  // Streak Configuration
  static const int streakBonusMultiplier = 2;
  static const int weeklyStreakMilestone = 7;
  static const int monthlyStreakMilestone = 30;

  // Activity Limits
  static const int maxDailyActivities = 10;
  static const int maxActivityDurationMinutes = 180;
  static const int minActivityDurationMinutes = 1;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;

  // Animation Durations (milliseconds)
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 400;
  static const int longAnimationDuration = 600;

  // Pagination
  static const int leaderboardPageSize = 20;
  static const int activitiesPageSize = 15;

  // Local Storage Keys
  static const String userIdKey = 'user_id';
  static const String userDataKey = 'user_data';
  static const String plantDataKey = 'plant_data';
  static const String themeKey = 'theme_mode';
  static const String notificationTimeKey = 'notification_time';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String activitiesCollection = 'activities';
  static const String badgesCollection = 'badges';
  static const String leaderboardCollection = 'leaderboard';
  static const String challengesCollection = 'challenges';

  // Error Messages
  static const String networkErrorMessage =
      'No internet connection. Please check your network.';
  static const String genericErrorMessage =
      'Something went wrong. Please try again.';
  static const String authErrorMessage =
      'Authentication failed. Please try again.';
}
