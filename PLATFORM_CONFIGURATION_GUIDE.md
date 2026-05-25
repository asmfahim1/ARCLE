# iOS/Android Platform Configuration Guide

## Overview

As of the latest version, ARCLE CLI now provides **automatic and comprehensive platform configuration** for both Android and iOS during project creation, ensuring projects are production-ready out-of-the-box.

## ✅ What ARCLE Automatically Configures

### Android Configuration

#### Gradle Build System
- **Android Gradle Plugin (AGP)**: Automatically detects and pins the version from your Flutter SDK templates
- **Kotlin Plugin**: Resolves and updates `org.jetbrains.kotlin.android` version for consistency
- **Gradle Distribution**: Extracts and enforces the correct Gradle version from Flutter templates

#### Android SDK Versions
- **compileSdk**: Set to `35` (latest stable)
- **minSdk**: Set to `21` (ensures broad device compatibility)
- **targetSdk**: Set to `35` (recommended for Play Store)
- Applied to both Groovy (`build.gradle`) and Kotlin DSL (`build.gradle.kts`)

#### Modern Java Support
- **Core Library Desugaring**: Enabled for Java 8+ features on devices running Android 6.0+
- **Dependency**: `com.android.tools:desugar_jdk_libs:2.0.4`
- Ensures apps run smoothly across all supported Android versions

#### Gradle Files Updated
1. **settings.gradle / settings.gradle.kts** - Plugin version synchronization
2. **gradle-wrapper.properties** - Correct Gradle distribution URL
3. **app/build.gradle / app/build.gradle.kts** - Flutter source configuration

### iOS Configuration

#### Podfile Configuration
- **Platform Deployment Target**: Enforced to minimum iOS 13.0
- **Post-Install Hooks**: Automatically configured for consistent build settings across all targets
- Prevents CocoaPods conflicts and deprecated API warnings

#### Info.plist Permissions
Automatically generates essential permission descriptions:

| Permission | Description | Use Case |
|-----------|-------------|----------|
| NSCameraUsageDescription | Camera access | Photo/video capture |
| NSPhotoLibraryUsageDescription | Photo library access | Media selection |
| NSPhotoLibraryAddUsageDescription | Save to photo library | Export functionality |
| NSMicrophoneUsageDescription | Microphone access | Audio recording |
| NSLocationWhenInUseUsageDescription | Location while in use | Map/navigation features |
| NSLocationAlwaysAndWhenInUseUsageDescription | Always-on location | Background tracking |
| NSContactsUsageDescription | Contacts access | User directory |
| NSCalendarsUsageDescription | Calendar access | Event management |

**Note:** These permissions are required for the generated `permission_handler` and `flutter_local_notifications` packages to work on iOS.

## 📦 Platform-Aware Dependencies

All included dependencies support both platforms:

| Dependency | Purpose | Android | iOS |
|-----------|---------|---------|-----|
| **dio** | HTTP client | ✅ | ✅ |
| **shared_preferences** | Key-value storage | ✅ | ✅ |
| **permission_handler** | Runtime permissions | ✅ (Info.plist required) | ✅ (Info.plist required) |
| **flutter_local_notifications** | Local notifications | ✅ | ✅ (Config required) |
| **timezone** | Timezone handling | ✅ | ✅ |
| **google_fonts** | Dynamic fonts | ✅ | ✅ |
| **flutter_svg** | SVG rendering | ✅ | ✅ |
| **intl** | Internationalization | ✅ | ✅ |

## 🚀 Platform-Specific Build Commands

### Android
```bash
# Debug APK
arcle build apk --debug

# Release APK
arcle build apk --release

# With version management
arcle build apk --release --version-name 1.2.0 --version-code 12

# With environment switching
arcle build apk --release --env prod
```

### iOS
iOS builds should be done through Xcode or Flutter CLI:
```bash
# Debug
flutter run

# Release (requires Xcode setup)
flutter build ipa
```

**Note:** ARCLE currently supports APK generation via `arcle build apk`. IPA builds require Xcode configuration (Team ID, provisioning profiles).

## 📋 Pre-Release Checklist (iOS-Specific)

Before submitting to App Store, ensure:

- [ ] **Xcode Project Configuration**
  - [ ] Team ID set correctly
  - [ ] Bundle ID matches App Store configuration
  - [ ] Signing certificate configured

- [ ] **Info.plist Permissions**
  - [ ] All required permissions have localized descriptions
  - [ ] Permission descriptions match your actual feature set
  - [ ] No unused permissions declared

- [ ] **Deployment Target**
  - [ ] Matches or exceeds iOS 13.0
  - [ ] All dependencies support the target version

- [ ] **App Icons & Launch Screen**
  - [ ] iOS app icons added to `ios/Runner/Assets.xcassets`
  - [ ] Launch screen configured in Xcode

- [ ] **Capabilities**
  - [ ] Required capabilities enabled (e.g., Background Modes)
  - [ ] Associated Domains configured (if needed)

## 📋 Pre-Release Checklist (Android-Specific)

Before publishing to Google Play Store:

- [ ] **Gradle Configuration**
  - [ ] SDK versions match Play Store requirements
  - [ ] minSdk 21+ (✅ automatic)
  - [ ] targetSdk 35+ (✅ automatic)

- [ ] **Signing Configuration**
  - [ ] Keystore created and backed up
  - [ ] `signingConfigs` block in `app/build.gradle`

- [ ] **Permissions in AndroidManifest.xml**
  - [ ] Required permissions declared
  - [ ] Dangerous permissions for Runtime > Android 6.0

- [ ] **App Icons**
  - [ ] Launcher icons added to `android/app/src/main/res/`

## 🔧 Manual Configuration After Project Creation

### iOS Signing (Required for Release)

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** project in navigator
3. Select **Runner** target
4. Go to **Signing & Capabilities** tab
5. Select a Team for development signing
6. Configure provisioning profile

### Android Keystore (Required for Release)

1. Generate keystore (one-time):
   ```bash
   keytool -genkey -v -keystore ~/my-release-key.keystore \
     -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias
   ```

2. Configure in `android/app/build.gradle`:
   ```gradle
   signingConfigs {
     release {
       storeFile file(project.properties.storeFile)
       storePassword project.properties.storePassword
       keyAlias project.properties.keyAlias
       keyPassword project.properties.keyPassword
     }
   }
   ```

3. or use `arcle build apk --release` (handles most of this automatically)

## 🐛 Common Issues & Solutions

### iOS: "Permission denied" on launch
**Issue:** App crashes when requesting permissions that aren't in Info.plist
**Solution:** ARCLE automatically adds common permissions. If custom permissions needed, add manually to `ios/Runner/Info.plist`

### iOS: Podfile conflicts
**Issue:** CocoaPods fails during `flutter pub get`
**Solution:** ARCLE configures post-install hooks. If issues persist:
```bash
cd ios
rm -rf Pods Podfile.lock
cd ..
flutter clean
flutter pub get
```

### Android: Gradle build errors
**Issue:** AGP or Gradle version conflicts
**Solution:** ARCLE syncs versions from Flutter SDK. Ensure Flutter is up to date:
```bash
flutter upgrade
```

### Android: `minSdk` too low
**Issue:** Play Store rejects APK with minSdk < 21
**Solution:** ARCLE sets minSdk to 21 automatically ✅

## 📚 References

- [Flutter Platform Channels](https://flutter.dev/docs/development/platform-integration/platform-channels)
- [Android Build Configuration](https://developer.android.com/build)
- [iOS Build Configuration](https://developer.apple.com/xcode/)
- [Permission Handler Documentation](https://pub.dev/packages/permission_handler)
- [Flutter Local Notifications Documentation](https://pub.dev/packages/flutter_local_notifications)

## 📝 Changelog

### Version 1.0.4+ (Latest)

**iOS Configuration Improvements:**
- ✅ Automatic Podfile iOS 13.0+ deployment target
- ✅ Automatic Info.plist permission descriptions
- ✅ Post-install hooks for consistent build settings

**Android Configuration (Existing):**
- ✅ Gradle version synchronization
- ✅ SDK versions (minSdk 21, compileSdk/targetSdk 35)
- ✅ Core library desugaring enabled
- ✅ Flutter source configuration

## Migration for Existing Projects

If you created a project with an older version of ARCLE, manually apply these configurations:

### For iOS:

1. **Update `ios/Podfile`** - Set platform to 13.0:
   ```ruby
   platform :ios, '13.0'
   ```

2. **Add permissions to `ios/Runner/Info.plist`** - Add needed permission keys and descriptions (see table above)

### For Android:

1. **Ensure SDK versions in `android/app/build.gradle`**:
   ```gradle
   android {
     compileSdk 35
     defaultConfig {
       minSdk 21
       targetSdk 35
     }
   }
   ```

---

For help, visit: [GitHub Issues](https://github.com/arcle-cli/arcle/issues)
