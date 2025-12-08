# Production Readiness Checklist

This document outlines all the requirements and steps needed to launch FitQuest on Google Play Store.

## ✅ Completed

- [x] App version updated to 1.0.0
- [x] Application ID configured (com.fitquest.app)
- [x] App name set in AndroidManifest
- [x] Firebase Crashlytics integrated
- [x] Firebase Analytics service created
- [x] Privacy Policy page created
- [x] Terms of Service page created
- [x] About page created
- [x] Legal links added to Settings
- [x] Connectivity service for offline handling
- [x] Offline banner widget

## 📋 Pre-Launch Requirements

### 1. App Signing

**Required for Release Builds:**

1. Generate a keystore:
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. Create `android/key.properties`:
   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=upload
   storeFile=<path-to-keystore>
   ```

3. Update `android/app/build.gradle.kts` to use signing config (see below)

4. **IMPORTANT:** Never commit `key.properties` or the keystore file to version control!

### 2. App Icons and Assets

**Required Assets:**
- [ ] App icon (1024x1024px PNG)
  - Place at: `assets/icons/app_icon.png`
  - Run: `flutter pub run flutter_launcher_icons`

- [ ] Adaptive icon foreground (1024x1024px PNG)
  - Place at: `assets/icons/adaptive_icon.png`

- [ ] Splash screen logo (optional but recommended)
  - Place at: `assets/images/splash_logo.png`
  - Run: `flutter pub run flutter_native_splash:create`

### 3. Google Play Store Listing

**Required Information:**

1. **App Title:** FitQuest (50 characters max)
2. **Short Description:** (80 characters max)
   - Example: "Gamified wellness app with plant companion. Track fitness, build habits!"
3. **Full Description:** (4000 characters max)
   - Include features, benefits, screenshots descriptions
4. **App Category:** Health & Fitness
5. **Content Rating:** Complete questionnaire in Play Console
6. **Privacy Policy URL:** Required - host your privacy policy online
7. **Screenshots:**
   - Phone: At least 2, up to 8 (16:9 or 9:16)
   - Tablet: At least 1, up to 8 (optional)
   - Minimum resolution: 320px
   - Recommended: 1080x1920px or higher
8. **Feature Graphic:** 1024x500px PNG
9. **Promo Video:** Optional but recommended (YouTube link)

### 4. Firebase Configuration

**Required:**
- [ ] Firebase project configured for production
- [ ] `google-services.json` added to `android/app/`
- [ ] SHA-1 and SHA-256 certificates added to Firebase Console
  - Get SHA-1: `keytool -list -v -keystore <keystore-path> -alias upload`
- [ ] Firestore indexes created (if using complex queries)
- [ ] Firebase Analytics enabled
- [ ] Crashlytics enabled

### 5. Testing

**Before Launch:**
- [ ] Test on multiple Android versions (API 21+)
- [ ] Test on different screen sizes
- [ ] Test offline functionality
- [ ] Test all user flows (signup, login, activity logging, etc.)
- [ ] Test error handling and edge cases
- [ ] Performance testing (check for memory leaks, slow screens)
- [ ] Security testing (verify data encryption, secure storage)

### 6. Legal and Compliance

**Required:**
- [ ] Privacy Policy hosted online (required for Play Store)
- [ ] Terms of Service hosted online (recommended)
- [ ] GDPR compliance (if targeting EU users)
- [ ] COPPA compliance (app is 13+)
- [ ] Data deletion policy implemented
- [ ] User consent for data collection (if applicable)

### 7. Performance Optimization

**Checklist:**
- [ ] App size optimized (aim for < 50MB)
- [ ] Images optimized and compressed
- [ ] Unused dependencies removed
- [ ] ProGuard/R8 rules configured (if needed)
- [ ] Startup time < 3 seconds
- [ ] No memory leaks detected
- [ ] Battery usage optimized

### 8. Security

**Required:**
- [ ] No hardcoded API keys or secrets
- [ ] Secure authentication implemented
- [ ] Data encrypted in transit (HTTPS)
- [ ] Sensitive data encrypted at rest
- [ ] Input validation on all user inputs
- [ ] SQL injection prevention (if using SQL)
- [ ] XSS prevention (if using web views)

### 9. Accessibility

**Recommended:**
- [ ] Semantic labels on interactive elements
- [ ] Proper contrast ratios (WCAG AA minimum)
- [ ] Screen reader support tested
- [ ] Text scaling support
- [ ] Touch target sizes (minimum 48x48dp)

### 10. Analytics and Monitoring

**Setup:**
- [ ] Firebase Analytics events configured
- [ ] Crashlytics monitoring active
- [ ] Performance monitoring enabled
- [ ] User feedback mechanism (in-app or Play Store reviews)

## 🚀 Launch Steps

1. **Internal Testing:**
   - Upload APK/AAB to Play Console
   - Create internal testing track
   - Test with internal testers

2. **Closed Beta:**
   - Create closed testing track
   - Invite beta testers
   - Collect feedback and fix issues

3. **Open Beta (Optional):**
   - Create open testing track
   - Allow anyone to join
   - Monitor reviews and ratings

4. **Production Release:**
   - Complete all store listing information
   - Upload release AAB
   - Set pricing (Free/Paid)
   - Select countries for distribution
   - Submit for review
   - Wait for approval (usually 1-3 days)

## 📝 Post-Launch

- [ ] Monitor crash reports
- [ ] Respond to user reviews
- [ ] Track analytics and user behavior
- [ ] Plan updates and improvements
- [ ] Monitor app performance metrics

## 🔧 Build Commands

**Debug Build:**
```bash
flutter build apk --debug
```

**Release Build (for testing):**
```bash
flutter build apk --release
```

**Release App Bundle (for Play Store):**
```bash
flutter build appbundle --release
```

**Generate Icons:**
```bash
flutter pub run flutter_launcher_icons
```

**Generate Splash Screen:**
```bash
flutter pub run flutter_native_splash:create
```

## 📚 Resources

- [Google Play Console](https://play.google.com/console)
- [Flutter App Signing](https://docs.flutter.dev/deployment/android#signing-the-app)
- [Firebase Setup](https://firebase.google.com/docs/flutter/setup)
- [Play Store Policies](https://play.google.com/about/developer-content-policy/)

## ⚠️ Important Notes

1. **Never commit sensitive files:**
   - `key.properties`
   - `upload-keystore.jks` or any keystore files
   - `google-services.json` (if contains sensitive info)

2. **Version Management:**
   - Increment `version` in `pubspec.yaml` for each release
   - Format: `major.minor.patch+buildNumber`
   - Example: `1.0.1+2` (version 1.0.1, build 2)

3. **Testing:**
   - Always test release builds before submitting
   - Test on real devices, not just emulators
   - Test all critical user flows

4. **Privacy:**
   - Ensure Privacy Policy is accessible and up-to-date
   - Be transparent about data collection
   - Provide data deletion options

