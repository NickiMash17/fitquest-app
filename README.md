# 🌱 FitQuest

<div align="center">

![FitQuest Banner](https://via.placeholder.com/800x200/4CAF50/FFFFFF?text=FitQuest+-+Grow+Your+Wellness+Journey)

**Transform daily wellness activities into an engaging adventure**

[![Flutter](https://img.shields.io/badge/Flutter-3.16.0-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Status-In%20Development-yellow)](https://github.com/NickiMash17/fitquest-app)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web-blue)]()

[Features](#-key-features) • [Getting Started](#-getting-started) • [Documentation](#-documentation) • [Contributing](#-contributing)

</div>

---

## 🎯 Project Overview

FitQuest combines wellness tracking with gamification mechanics to create an engaging experience that motivates users to maintain healthy habits. Complete daily activities to earn XP and watch your virtual plant companion evolve from a tiny seed to a majestic ancient tree.

### 💪 How It Works

Earn XP by completing daily wellness activities:

- 🏃 **Exercise**: 50 XP per session (cardio, strength, yoga)
- 🧘 **Meditation**: 30 XP per session (5+ minutes)
- 💧 **Hydration**: 10 XP per glass (track your water intake)
- 😴 **Sleep**: 40 XP for 7-9 hours of quality rest

### 🌳 Plant Evolution Stages

Watch your companion grow through 5 unique stages:

1. **Seed** (0-100 XP) - Just beginning your journey
2. **Sprout** (100-500 XP) - First signs of growth
3. **Sapling** (500-1500 XP) - Building strong habits
4. **Tree** (1500-5000 XP) - Thriving wellness routine
5. **Ancient Tree** (5000+ XP) - Master of healthy living

---

## ✨ Key Features

### 🎮 Core Gameplay
- 🌟 **Evolving Plant Companion** - Watch your companion grow through 5 evolution stages as you progress
- 🎯 **XP System** - Earn experience points for completing wellness activities
- 🔥 **Streak Tracking** - Maintain daily streaks to maximize your growth
- ⚡ **Combo Multipliers** - Complete multiple activities for bonus XP

### 📊 Tracking & Analytics
- 📈 **Activity Dashboard** - Visualize your progress with beautiful charts
- 📅 **Calendar View** - Track your consistency over time
- 💎 **Weekly Goals** - Set and achieve personalized targets
- 🎯 **Activity History** - Review all your logged activities

### 🏆 Social & Competition
- 🥇 **Global Leaderboards** - Compete with users worldwide
- 👥 **Friends System** - Connect and challenge friends
- 🏅 **Achievement System** - Unlock 15+ unique badges
- 🎊 **Milestone Celebrations** - Celebrate your progress with animations

### 🔧 User Experience
- 🌓 **Dark Mode** - Beautiful UI in light and dark themes
- 🔔 **Smart Notifications** - Timely reminders to maintain your streak
- 📱 **Offline-First** - Works seamlessly without internet connection
- 🌍 **Multi-language Support** - Available in multiple languages (coming soon)
- ♿ **Accessibility** - Designed with accessibility in mind

---

## 🛠️ Tech Stack

### Frontend
- **Framework:** Flutter 3.16.0
- **Language:** Dart 3.0+
- **State Management:** BLoC Pattern + Provider (for theme)
- **Animations:** Rive (plant animations), Lottie (UI animations), Custom Painters
- **UI Components:** Custom design system with Material 3

### Backend & Services
- **Authentication:** Firebase Auth (Email/Password, Google Sign-In)
- **Database:** Cloud Firestore (NoSQL, real-time sync, 40 MB cache limit)
- **Storage:** Firebase Cloud Storage (user avatars, plant images)
- **Functions:** Cloud Functions for Firebase (leaderboard calculations)
- **Analytics:** Firebase Analytics & Crashlytics

### Architecture & Patterns
- **Architecture:** Clean Architecture with Repository Pattern
- **Dependency Injection:** GetIt + Injectable
- **Local Storage:** Hive (offline data), Shared Preferences (settings)
- **Code Generation:** Freezed, Json Serializable, Injectable
- **Testing:** Unit tests (mockito), Widget tests, Integration tests

📖 **Demo Guides**: See the [docs/](docs/) folder for demo strategy and practice guides.

---

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- ✅ **Flutter SDK** (3.16.0 or higher) - [Install Flutter](https://docs.flutter.dev/get-started/install)
- ✅ **Dart SDK** (3.0.0 or higher) - Included with Flutter
- ✅ **Android Studio** or **Xcode** (for mobile development)
- ✅ **VS Code** with Flutter extensions (recommended) - [Setup VS Code](https://docs.flutter.dev/tools/vs-code)
- ✅ **Git** - [Install Git](https://git-scm.com/downloads)
- ✅ **Firebase Account** - [Create Firebase Account](https://firebase.google.com)

### Verify Installation

```bash
flutter doctor -v
```

---

## 🚀 Getting Started

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/NickiMash17/fitquest-app.git
cd fitquest-app
```

### 2️⃣ Install Dependencies

```bash
flutter pub get
```

### 3️⃣ Set up Firebase

#### a. Create a Firebase Project

1. Visit [Firebase Console](https://console.firebase.google.com)
2. Click **"Add project"**
3. Enter project name: `fitquest-app`
4. Follow the setup wizard (disable Google Analytics for development)

#### b. Enable Required Services

1. **Authentication**
   - Go to Authentication → Sign-in method
   - Enable **Email/Password**
   - Enable **Google** (optional)

2. **Firestore Database**
   - Go to Firestore Database
   - Click **"Create database"**
   - Start in **Test mode** (for development)
   - Choose your region

3. **Storage**
   - Go to Storage
   - Click **"Get started"**
   - Start in **Test mode**

#### c. Add Your App to Firebase

**For Android:**
1. Click the Android icon in Project Overview
2. Register app with package name: `com.nicolettemashaba.fitquest`
3. Download `google-services.json`
4. Place it in `android/app/` directory

**For iOS:**
1. Click the iOS icon in Project Overview
2. Register app with bundle ID: `com.nicolettemashaba.fitquest`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/` directory

#### d. Configure FlutterFire CLI

```bash
# Install FlutterFire CLI globally
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure
```

Follow the prompts and select your Firebase project.

### 4️⃣ Run the App

```bash
# Run on Chrome (Web)
flutter run -d chrome

# Run on Android Emulator
flutter run -d android

# Run on iOS Simulator (Mac only)
flutter run -d ios

# Run on specific device
flutter devices  # List available devices
flutter run -d <device-id>
```

### 5️⃣ Build for Production

**Android (APK)**
```bash
flutter build apk --release
```

**Android (App Bundle - for Play Store)**
```bash
flutter build appbundle --release
```

**iOS (Mac only)**
```bash
flutter build ipa --release
```

**Web**
```bash
flutter build web --release
```

---

## 📁 Project Structure

```
lib/
├── core/                    # Core functionality (config, constants, services, theme)
│   ├── constants/          # App constants, colors, strings
│   ├── theme/             # Theme data, text styles
│   ├── utils/             # Helper functions, validators
│   ├── config/            # App configuration
│   ├── services/          # Core services
│   └── widgets/           # Core reusable widgets
├── features/                # Feature modules (feature-based structure)
│   ├── authentication/     # Auth feature (BLoC, pages, widgets)
│   ├── activities/         # Activity tracking feature
│   ├── home/               # Home screen feature
│   ├── goals/              # Goals feature
│   ├── profile/            # User profile, settings
│   ├── community/          # Leaderboards, friends, social features
│   └── onboarding/         # First-time user experience
├── shared/                  # Shared code across features
│   ├── models/             # Data models (Freezed)
│   ├── repositories/       # Data repositories
│   ├── services/           # Business logic services
│   └── widgets/            # Reusable widgets
└── main.dart               # App entry point
```

---

## 🧪 Testing

### Run All Tests

```bash
flutter test
```

### Run Tests with Coverage

```bash
flutter test --coverage
lcov --list coverage/lcov.info  # View coverage summary
```

### Run Integration Tests

```bash
flutter test integration_test/
```

### Run Specific Test File

```bash
flutter test test/features/authentication/bloc/auth_bloc_test.dart
```

### Test Categories

- **Unit Tests** - Business logic, utilities, models
- **Widget Tests** - UI components, interactions
- **Integration Tests** - End-to-end user flows
- **Golden Tests** - Visual regression testing (coming soon)

---

## 📚 Documentation

- **[Demo Strategy](docs/DEMO_STRATEGY.md)** - Complete demo script and strategy
- **[Pre-Demo Checklist](docs/PRE_DEMO_CHECKLIST.md)** - Pre-demo action plan
- **[Quick Demo Practice](docs/QUICK_DEMO_PRACTICE.md)** - Quick practice guide

---

## 🗺️ Roadmap

### ✅ Completed
- [x] Project setup and architecture
- [x] Authentication system
- [x] Basic activity tracking
- [x] Plant companion mechanics
- [x] XP and leveling system
- [x] Celebration animations
- [x] Theme system (light/dark mode)

### 🚧 In Progress (Q1 2025)
- [ ] Firebase integration completion
- [ ] Real-time leaderboards
- [ ] Achievement system
- [ ] Push notifications
- [ ] Profile customization

### 📅 Planned (Q2 2025)
- [ ] Social features (friends, challenges)
- [ ] Custom plant themes and shop
- [ ] Apple Health / Google Fit integration
- [ ] Advanced analytics dashboard
- [ ] Multi-language support

### 🔮 Future (Q3 2025+)
- [ ] AI-powered habit recommendations
- [ ] Community challenges
- [ ] Premium subscription tier
- [ ] Wearable device integration
- [ ] Desktop applications (Windows, macOS)

---

## 🐛 Troubleshooting

### Common Issues

#### 1. Blank Screen on Web

**Symptoms:** White/blank screen when running on web browser

**Solutions:**
1. Check Browser Console (F12 → Console tab) for errors
2. Hard Refresh: `Ctrl+Shift+R` (Windows) or `Cmd+Shift+R` (Mac)
3. Clear Browser Cache: `Ctrl+Shift+Delete` → Clear cached images and files
4. Try Incognito Mode: Open browser in incognito and navigate to localhost

#### 2. Firebase Configuration Errors

**Symptoms:** `No Firebase App '[DEFAULT]' has been created`

**Solutions:**
```bash
# Re-run FlutterFire configuration
flutterfire configure

# Ensure google-services.json and GoogleService-Info.plist are in correct locations
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

#### 3. Firestore Index Errors

**Symptoms:** Console warnings about missing indexes

**Solutions:**
- These are warnings, not critical errors
- Click the provided link in the error message
- Firebase Console will auto-generate the required index
- Wait 2-5 minutes for index creation

#### 4. Build Errors After Updating Dependencies

**Solutions:**
```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter run
```

#### 5. Port Already in Use (Web)

**Symptoms:** `Port 8080 is already in use`

**Solutions:**
```bash
# Use a different port
flutter run -d chrome --web-port=8081

# Or kill the process using the port (Windows)
netstat -ano | findstr :8080
taskkill /PID <PID> /F

# Or kill the process (Mac/Linux)
lsof -ti:8080 | xargs kill -9
```

### Reset Onboarding

To see the onboarding screen again:
1. Press **F12** → **Console** tab
2. Type: `localStorage.clear()` and press Enter
3. Refresh the page (F5)

### Need More Help?

- 🐛 [Open an Issue](https://github.com/NickiMash17/fitquest-app/issues/new)
- 📧 Email: [nene171408@gmail.com](mailto:nene171408@gmail.com)

---

## 🤝 Contributing

We love contributions! FitQuest is built by developers like you.

### How to Contribute

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/AmazingFeature`)
3. **Commit your changes** (`git commit -m 'Add some AmazingFeature'`)
4. **Push to the branch** (`git push origin feature/AmazingFeature`)
5. **Open a Pull Request**

### Contribution Guidelines

- Follow the existing code style and architecture patterns
- Write tests for new features
- Update documentation as needed
- Keep commits atomic and well-described
- Be respectful and constructive in discussions

### Areas for Contribution

- 🐛 Bug fixes
- ✨ New features
- 📝 Documentation improvements
- 🌍 Translations
- 🎨 UI/UX enhancements
- 🧪 Test coverage

---

## 📊 Development Progress

### Phase 1: Foundation (✅ Complete)
- [x] Project setup and architecture
- [x] UI design system
- [x] Navigation structure

### Phase 2: Core Features (🚧 In Progress - 70%)
- [x] Authentication flow
- [x] Activity tracking UI
- [x] Plant companion visuals
- [x] Celebration animations
- [ ] Data persistence
- [ ] Offline support

### Phase 3: Firebase Integration (📅 Planned)
- [ ] Firestore integration
- [ ] Cloud storage setup
- [ ] Real-time sync
- [ ] Cloud functions

### Phase 4: Advanced Features (📅 Planned)
- [ ] Leaderboards
- [ ] Social features
- [ ] Notifications
- [ ] Analytics

### Phase 5: Testing & Quality (📅 Planned)
- [ ] Unit test coverage (80%+)
- [ ] Integration tests
- [ ] Performance optimization
- [ ] Accessibility audit

### Phase 6: Production (📅 Planned)
- [ ] Beta testing
- [ ] App Store submission
- [ ] Play Store submission
- [ ] Web deployment

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 Nicolette Mashaba

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
```

---

## 👤 Author

<div align="center">

### **Nicolette Mashaba**

[![GitHub](https://img.shields.io/badge/GitHub-NickiMash17-181717?logo=github)](https://github.com/NickiMash17)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Nicolette%20Mashaba-0A66C2?logo=linkedin)](https://linkedin.com/in/nicolette-mashaba)
[![Email](https://img.shields.io/badge/Email-nene171408%40gmail.com-EA4335?logo=gmail)](mailto:nene171408@gmail.com)

*Passionate Flutter developer building engaging mobile experiences*

</div>

---

## 🙏 Acknowledgments

Special thanks to:

- 💙 **Flutter Team** - For the amazing cross-platform framework
- 🔥 **Firebase Team** - For robust backend infrastructure
- 🎓 **Jediah Codes** - For the comprehensive learning path at [jediah.dev](https://jediah.dev)
- 🌟 **Open Source Community** - For invaluable packages and support
- 🎨 **Design Inspiration** - Duolingo, Habitica, and Forest App

### Key Dependencies

Special thanks to these amazing packages:

- `firebase_core` & `firebase_auth` - Backend services
- `flutter_bloc` - State management
- `rive` - Beautiful animations
- `fl_chart` - Data visualization
- `hive` - Local storage
- `confetti` - Celebration animations

---

## 📞 Support & Community

### Get Help
- 📖 [Documentation](docs/) - Comprehensive guides
- ❓ [Stack Overflow](https://stackoverflow.com/questions/tagged/fitquest) - Technical questions
- 🐛 [Issue Tracker](https://github.com/NickiMash17/fitquest-app/issues) - Report bugs

### Stay Updated
- ⭐ Star this repo to show support
- 👀 Watch for updates
- 📧 Subscribe to our newsletter (coming soon)

---

<div align="center">

### 🌱 Grow Your Wellness Journey with FitQuest

**Made with ❤️ and Flutter**

[⬆ Back to Top](#-fitquest)

</div>
