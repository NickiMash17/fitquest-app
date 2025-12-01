# 🚀 Quick Start Guide - FitQuest

## Step 1: Install Dependencies

```bash
flutter pub get
```

## Step 2: Generate Code

This app uses code generation for models, dependency injection, and JSON serialization. **You MUST run this before the app will work:**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate:
- Freezed model files (`.freezed.dart` and `.g.dart`)
- Injectable dependency injection code (`injection.config.dart`)
- JSON serialization code

**Note:** This may take a few minutes the first time.

## Step 3: Firebase Setup (Required)

### Option A: Using FlutterFire CLI (Recommended)

1. Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

2. Configure Firebase:
```bash
flutterfire configure
```

Follow the prompts to select your Firebase project and platforms.

### Option B: Manual Setup

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project (or use existing)
3. Add Android app:
   - Download `google-services.json`
   - Place it in `android/app/`
4. Add iOS app:
   - Download `GoogleService-Info.plist`
   - Place it in `ios/Runner/`

## Step 4: Run the App

### For Android:
```bash
flutter run
```

### For iOS:
```bash
flutter run -d ios
```

### For Web:
```bash
flutter run -d chrome
```

### For a specific device:
```bash
flutter devices  # List available devices
flutter run -d <device-id>
```

## Troubleshooting

### "Cannot find module" or "Missing generated files" errors

Run code generation again:
```bash
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Firebase errors

- Ensure Firebase is initialized in your project
- Check that configuration files are in the correct locations
- Verify Firebase services are enabled in Firebase Console:
  - Authentication (Email/Password)
  - Cloud Firestore
  - Crashlytics

### Build errors

1. Clean the project:
```bash
flutter clean
```

2. Get dependencies again:
```bash
flutter pub get
```

3. Generate code:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Try running again:
```bash
flutter run
```

## Development Workflow

### Watch Mode (Auto-regenerate code)

While developing, use watch mode to automatically regenerate code when you change models:

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

Keep this running in a separate terminal while you develop.

### Hot Reload

Once the app is running:
- Press `r` in the terminal for hot reload
- Press `R` for hot restart
- Press `q` to quit

## Testing

Run tests:
```bash
flutter test
```

Run with coverage:
```bash
flutter test --coverage
```

## Building for Release

### Android APK:
```bash
flutter build apk --release
```

### Android App Bundle:
```bash
flutter build appbundle --release
```

### iOS:
```bash
flutter build ipa --release
```

## Need Help?

- Check `SETUP.md` for detailed setup instructions
- Check `IMPLEMENTATION_SUMMARY.md` for architecture details
- Check `README.md` for project overview

