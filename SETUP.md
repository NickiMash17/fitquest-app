# FitQuest Setup Guide

## Prerequisites

1. Flutter SDK (3.16.0 or higher)
2. Dart SDK (3.0.0 or higher)
3. Firebase project configured

## Setup Steps

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Generate Code

This project uses code generation for:
- Freezed models (User, Activity, Badge, etc.)
- Injectable dependency injection
- JSON serialization

Run the following command to generate the code:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Or for continuous generation during development:

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

### 3. Firebase Configuration

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add Android and iOS apps to your Firebase project
3. Download configuration files:
   - `google-services.json` → place in `android/app/`
   - `GoogleService-Info.plist` → place in `ios/Runner/`
4. Run FlutterFire CLI:

```bash
flutterfire configure
```

### 4. Run the App

```bash
flutter run
```

## Project Structure

```
lib/
├── core/              # Core functionality
│   ├── config/        # App configuration
│   ├── constants/     # App constants
│   ├── di/            # Dependency injection
│   ├── navigation/    # Navigation/routing
│   ├── theme/         # App theming
│   └── utils/         # Utility functions
├── features/          # Feature modules
│   ├── activities/    # Activity tracking
│   ├── authentication/# Auth (login/signup)
│   ├── community/     # Leaderboard, social
│   ├── home/          # Home screen
│   └── profile/       # User profile
└── shared/            # Shared code
    ├── models/        # Data models
    ├── repositories/ # Data repositories
    ├── services/      # Business logic services
    └── widgets/       # Reusable widgets
```

## Architecture

- **State Management**: BLoC pattern
- **Dependency Injection**: GetIt + Injectable
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Local Storage**: SharedPreferences + Hive
- **Code Generation**: Freezed, JSON Serializable, Injectable

## Troubleshooting

### Build Runner Issues

If you encounter issues with code generation:

```bash
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Firebase Issues

- Ensure Firebase configuration files are in the correct locations
- Verify Firebase project settings match your app bundle ID/package name
- Check Firebase console for any service enablement requirements

