# 🌱 FitQuest

A gamified wellness application that helps users build healthy habits through a virtual plant companion that evolves with their progress.

![Flutter](https://img.shields.io/badge/Flutter-3.16.0-02569B?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Latest-FFCA28?logo=firebase)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Status](https://img.shields.io/badge/Status-In%20Development-yellow)

## 🎯 Project Overview

FitQuest combines wellness tracking with gamification mechanics to create an engaging experience that motivates users to maintain healthy habits. Users complete daily activities (exercise, meditation, hydration, sleep) to earn XP and watch their virtual plant companion evolve from a tiny seed to a majestic ancient tree.

## ✨ Key Features

- 🌟 **Evolving Plant Companion** - Watch your companion grow through 5 evolution stages
- 🎮 **Gamification System** - Earn XP, unlock badges, and maintain streaks
- 🔥 **Activity Tracking** - Log exercise, meditation, hydration, and sleep
- 📊 **Real-time Leaderboards** - Compete with friends and the community
- 🏆 **Achievement System** - Unlock 15+ unique badges
- 🔔 **Smart Notifications** - Timely reminders to maintain your streak
- 🌓 **Dark Mode** - Beautiful UI in light and dark themes
- 📱 **Offline-First** - Works seamlessly without internet connection

## 🛠️ Tech Stack

- **Framework:** Flutter 3.16.0
- **Language:** Dart 3.0+
- **Backend:** Firebase
  - Authentication
  - Cloud Firestore
  - Cloud Storage
  - Cloud Functions (planned)
- **State Management:** BLoC + Provider
- **Animations:** Rive, Lottie
- **Architecture:** Clean Architecture with Repository Pattern

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- Flutter SDK (3.16.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / Xcode (for mobile development)
- VS Code with Flutter extensions (recommended)
- Git

## 🚀 Getting Started

### Installation

1. **Clone the repository**
```bash
   git clone https://github.com/NickiMash17/fitquest-app.git
   cd fitquest-app
```

2. **Install dependencies**
```bash
   flutter pub get
```

3. **Set up Firebase**
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Add Android and iOS apps
   - Download and place configuration files:
     - `google-services.json` in `android/app/`
     - `GoogleService-Info.plist` in `ios/Runner/`
   - Run FlutterFire configuration:
```bash
     flutterfire configure
```

4. **Run the app**
```bash
   flutter run
```

## 📁 Project Structure
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── config/
├── features/
│   ├── authentication/
│   │   ├── bloc/
│   │   ├── models/
│   │   ├── pages/
│   │   ├── repositories/
│   │   └── widgets/
│   ├── activities/
│   ├── companion/
│   ├── community/
│   └── profile/
├── shared/
│   ├── widgets/
│   └── services/
└── main.dart

## 🧪 Testing
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/
```

## 📱 Build for Production

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ipa --release
```

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## 📝 Development Progress

- [x] Project setup and architecture
- [ ] Phase 1: Flutter Fundamentals
- [ ] Phase 2: State Management & Architecture
- [ ] Phase 3: Firebase Integration
- [ ] Phase 4: Advanced Features
- [ ] Phase 5: Testing & Quality
- [ ] Phase 6: Production & Deployment

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Nicolette Mashaba**

- GitHub: [@NickiMash17](https://github.com/NickiMash17)
- LinkedIn: [Nicolette Mashaba](https://linkedin.com/in/nicolette-mashaba)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend infrastructure
- [Learning path created by Jediah](https://jediah.dev)

## 🐛 Troubleshooting

### Blank Screen Issues
1. **Check Browser Console** (F12 → Console tab) for errors
2. **Hard Refresh**: Press Ctrl+Shift+R (Windows) or Cmd+Shift+R (Mac)
3. **Clear Browser Cache**: Ctrl+Shift+Delete → Clear cached images and files
4. **Try Incognito Mode**: Open Chrome in incognito and navigate to localhost

### Reset Onboarding
To see the onboarding screen again:
1. Press **F12** → **Console** tab
2. Type: `localStorage.clear()` and press Enter
3. Refresh the page (F5)

### Common Issues
- **Firestore Index Errors**: These are warnings. Create indexes in Firebase Console using the provided links
- **Port Conflicts**: Try `flutter run -d chrome --web-port=8080`
- **Build Errors**: Check terminal output for compilation errors

## 📧 Contact

For questions or support, please open an issue or contact [nene171408@gmail.com](mailto:nene171408@gmail.com)

---

<p align="center">Made with ❤️ and Flutter</p>