# ARCLE Environment Security & Management Architecture Plan

## Executive Overview

This document records the architectural discussion, threat analysis, technical impact, value resolution mechanics, developer education, and implementation strategy for introducing a secure `.env` and environment management system to ARCLE in version **3.1.0**.

---

## 1. Problem Statement & Current Baseline

### Current State in ARCLE
Currently, ARCLE generates static Dart classes under `lib/core/env/`:
- `lib/core/env/env.dart`: Abstract interface (`name`, `apiBaseUrl`).
- `lib/core/env/prod_env.dart`: Hardcoded Dart class (`https://prod/jsonplaceholder.typicode.com`).
- `lib/core/env/stag_env.dart`: Hardcoded Dart class.
- `lib/core/env/local_env.dart`: Hardcoded Dart class.
- `lib/core/env/env_factory.dart`: Factory using `const String.fromEnvironment('FLAVOR', defaultValue: 'stag')`.

### Limitations
1. **Secrets Committed to Version Control**: Developers frequently hardcode real production API URLs, third-party API keys, and sensitive tokens into `prod_env.dart` and commit them to Git.
2. **Team Onboarding Friction**: No standardized template (like `.env.example`) to inform new developers which keys are required to run the project.
3. **Build Toolchain Disconnect**: Building for different environments requires editing Dart files or passing individual `--dart-define` parameters manually.

---

## 2. File Architecture: Single `.env` & `.env.example` Model

Per architectural decision, ARCLE avoids file clutter by maintaining exactly **two** environment configuration files at the project root:

```
my_app/
├── .env.example          # Committed to Git: defines template keys with dummy values
├── .env                  # In .gitignore: holds actual local, staging, and production values
├── .gitignore            # Ignores .env, preserves .env.example
```

### A. Structure of `.env` (Project Root)
```properties
# ─────────────────────────────────────────────────────────────────────────────
# ARCLE Application Environment Configuration
# DO NOT COMMIT THIS FILE TO VERSION CONTROL
# ─────────────────────────────────────────────────────────────────────────────

# Active Flavor: prod | stag | local
FLAVOR=stag

# ── Production Environment ──────────────────────────────────────────────────
PROD_API_BASE_URL=https://api.example.com
PROD_API_KEY=prod_secret_key_placeholder

# ── Staging Environment ─────────────────────────────────────────────────────
STAG_API_BASE_URL=https://staging.api.example.com
STAG_API_KEY=staging_secret_key_placeholder

# ── Local Development Environment ───────────────────────────────────────────
LOCAL_API_BASE_URL=http://10.0.2.2:3000
LOCAL_API_KEY=local_debug_key_placeholder
```

### B. Structure of `.env.example` (Project Root)
```properties
# ─────────────────────────────────────────────────────────────────────────────
# ARCLE Environment Template
# Copy this file to .env and fill in your actual credentials.
# ─────────────────────────────────────────────────────────────────────────────

FLAVOR=stag

PROD_API_BASE_URL=https://api.example.com
PROD_API_KEY=your_production_api_key

STAG_API_BASE_URL=https://staging.api.example.com
STAG_API_KEY=your_staging_api_key

LOCAL_API_BASE_URL=http://10.0.2.2:3000
LOCAL_API_KEY=your_local_api_key
```

### C. Git Configuration (`.gitignore`)
```gitignore
# ARCLE Environment files
.env
.env.*
!.env.example
```

---

## 3. How Dart Env Classes Read from `.env`

All three classes (`ProdEnv`, `StagEnv`, `LocalEnv`) reside in `lib/core/env/` and read their respective prefixed keys from the single `.env` file via compile-time constants:

```dart
// lib/core/env/prod_env.dart
class ProdEnv implements Env {
  @override
  String get name => 'prod';

  @override
  String get apiBaseUrl => const String.fromEnvironment(
        'PROD_API_BASE_URL',
        defaultValue: 'https://api.example.com',
      );
}

// lib/core/env/stag_env.dart
class StagEnv implements Env {
  @override
  String get name => 'stag';

  @override
  String get apiBaseUrl => const String.fromEnvironment(
        'STAG_API_BASE_URL',
        defaultValue: 'https://staging.api.example.com',
      );
}

// lib/core/env/local_env.dart
class LocalEnv implements Env {
  @override
  String get name => 'local';

  @override
  String get apiBaseUrl => const String.fromEnvironment(
        'LOCAL_API_BASE_URL',
        defaultValue: 'http://10.0.2.2:3000',
      );
}
```

### Dynamic Environment Resolution in `EnvFactory`
```dart
// lib/core/env/env_factory.dart
class EnvFactory {
  static Env current() {
    const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'stag');

    switch (flavor) {
      case 'prod':
        return ProdEnv();
      case 'stag':
        return StagEnv();
      case 'local':
        return LocalEnv();
      default:
        return StagEnv();
    }
  }

  static Env getEnv() => current();
}
```

---

## 4. Value Resolution & Missing `.env` Handling at Build Time

To prevent runtime crashes (`DioException: Invalid URI`) when `.env` is absent on a fresh clone:

```
┌────────────────────────────────────────────────────────────────────────┐
│                   3-Tier Missing .env Protection                       │
├─────────┬───────────────────────────┬──────────────────────────────────┤
│ Tier 1  │ ARCLE CLI Pre-Build Gate  │ CLI checks .env before building; │
│         │ (Build Time)              │ auto-creates or halts with error │
├─────────┼───────────────────────────┼──────────────────────────────────┤
│ Tier 2  │ Dart Const Default Fallback│ defaultValue prevents empty /    │
│         │ (Compile Time)            │ null string crashes              │
├─────────┼───────────────────────────┼──────────────────────────────────┤
│ Tier 3  │ Bootstrap Assertion       │ Logs clear diagnostic error      │
│         │ (Runtime Initialization)  │ instead of confusing HTTP errors │
└─────────┴───────────────────────────┴──────────────────────────────────┘
```

1. **Tier 1 (CLI Pre-Build Gate)**:
   - When running `arcle build apk`, ARCLE checks if `.env` exists.
   - If missing, in interactive mode it prompts to copy `.env.example` $\rightarrow$ `.env`. In CI mode, it halts with an actionable error.
2. **Tier 2 (Dart Compile-Time Default)**:
   - `const String.fromEnvironment(..., defaultValue: '...')` ensures that if a developer runs raw `flutter run` without `.env`, the app does not crash.
3. **Tier 3 (Runtime Bootstrap Assertion)**:
   - `lib/bootstrap.dart` validates that `EnvFactory.current().apiBaseUrl` is not empty, printing an explicit warning to the console immediately on startup.

### D. Impact Analysis on `bootstrap.dart` & Dependency Injection

A vital architectural question is: **Will our `.env` changes break or require modifying `bootstrap.dart`?**

```dart
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final env = EnvFactory.current();
  await AppDi().register(env);
  await AppRouteStorage.restoreInitialRoute();

  runApp(const App());
}
```

#### Why `bootstrap.dart` Remains 100% Intact (Zero Breaking Changes):
1. **Perfect Abstraction Barrier**: `bootstrap.dart` does not know or care whether environment variables came from hardcoded strings, `.env`, or build flags. It simply requests `final env = EnvFactory.current();`.
2. **Identical Contract**: `EnvFactory.current()` still returns a polymorphic instance of `Env` (`ProdEnv`, `StagEnv`, or `LocalEnv`).
3. **Seamless Dependency Injection**: `await AppDi().register(env)` receives the exact same `Env` object interface. Services like `DioClient`, `ApiClient`, and controllers read `env.apiBaseUrl` without knowing where the string originated.
4. **Conclusion**: `bootstrap.dart` **does NOT break**, requires zero refactoring, and continues to function exactly as designed.

---

## 5. Security Truth & Reverse Engineering Analysis

### What `.env` with Native `--dart-define-from-file` Solves:
1. **Never in APK Assets**: Unlike `flutter_dotenv`, native Flutter `--dart-define-from-file` **never bundles the `.env` file into the APK**. It is strictly a build-time input.
2. **No Unencrypted Files to Decompile**: An attacker unzipping the APK will find **zero `.env` files**.
3. **Compiled into Machine Code**: Key values are compiled directly into the Dart AOT snapshot binary (`libapp.so`).
4. **Git Repository Hygiene**: Completely prevents committing production credentials to GitHub/GitLab.

### What `.env` Alone Does NOT Solve:
1. **Binary Strings Inspection**: If obfuscation is not applied, raw plaintext strings can still be found inside `libapp.so` using `strings libapp.so`.
2. **Network Proxying (MITM)**: Any secret transmitted over HTTP/HTTPS can be intercepted with proxy tools (Charles, Proxyman, Burp Suite) unless Certificate Pinning is enabled.
3. **Client-Side Secret Storage**: True backend secrets (e.g. AWS secret keys, Stripe secret key `sk_live`) must NEVER be placed in a mobile client.

---

## 6. ARCLE Build Security vs. Default Flutter / Android Studio Build

This section empowers developers by explaining why `arcle build apk` is superior to default Flutter build commands, while providing manual fallback steps if they must build outside ARCLE.

### Comparison Matrix

| Capability | Default Flutter Build (`flutter build apk`) | Android Studio GUI (`Build > Flutter > Release APK`) | ARCLE CLI (`arcle build apk --release`) |
| :--- | :---: | :---: | :---: |
| **`.env` File Injection** | ❌ Ignored (must pass flag manually) | ❌ Ignored (no flag support in menu) | ✅ **Automatic (`--dart-define-from-file=.env`)** |
| **Dart Symbol Obfuscation** | ❌ Disabled by default | ❌ Disabled by default | ✅ **Automatic (`--obfuscate`)** |
| **Debug Symbol Stripping** | ❌ Disabled (symbols remain in APK) | ❌ Disabled | ✅ **Automatic (`--split-debug-info=...`)** |
| **Flavor Selection** | ❌ Requires manual `--dart-define` | ❌ Not supported | ✅ **Automatic via `--env prod\|stag\|local`** |
| **Missing `.env` Guard** | ❌ Silent failure / empty URLs | ❌ Silent failure / empty URLs | ✅ **Pre-build check with guided copy** |
| **Output File Renaming** | ❌ Generic `app-release.apk` | ❌ Generic `app-release.apk` | ✅ **`my_app_prod_V1.0.0.apk`** |
| **Android ProGuard Rules** | ⚠️ Only if configured manually | ⚠️ Only if configured manually | ✅ **Pre-scaffolded `proguard-rules.pro`** |

### What Developers Miss When Using Default / Android Studio Builds
1. **Un-injected `.env`**: Android Studio's release build menu does not pass `--dart-define-from-file=.env`. The compiled APK will have empty environment values or fall back to mock staging defaults.
2. **Un-obfuscated Machine Code**: Default Flutter builds do not obfuscate `libapp.so`. Class names, function names, and architecture strings remain readable under disassemblers (Ghidra, IDA Pro).
3. **Bloated APK Size**: Without `--split-debug-info`, debugging symbols are packed into the APK, increasing download size.

---

## 7. Developer Security Guide: How to Build Securely Outside ARCLE

If a developer or CI environment must build without using `arcle build apk`, they must follow these exact steps to match ARCLE's security standards:

### A. Command-Line Release Build (Terminal / CI)
```bash
flutter build apk --release \
  --dart-define-from-file=.env \
  --dart-define=FLAVOR=prod \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols
```

### B. Android Studio / VS Code Configuration
To run or build with environment variables in Android Studio / VS Code:
1. In Android Studio: Open **Run/Debug Configurations** $\rightarrow$ **Edit Configurations**.
2. In **Additional run args**, add:
   ```text
   --dart-define-from-file=.env
   ```
3. In VS Code: In `.vscode/launch.json`, add to your configuration:
   ```json
   "args": [
     "--dart-define-from-file=.env"
   ]
   ```

---

## 8. Implementation Blueprint for ARCLE 3.1.0

### A. Template Additions
1. **`.env.example` Template**: Generated at project root by `ProjectGenerator`.
2. **`.env` Template**: Generated with default local/staging values so the project runs immediately.
3. **`.gitignore` Template**: Updated to ensure `.env` is ignored and `.env.example` is tracked.
4. **`EnvTemplates` (`lib/src/templates/core/env_templates.dart`)**:
   - `ProdEnv`: Reads `PROD_API_BASE_URL`.
   - `StagEnv`: Reads `STAG_API_BASE_URL`.
   - `LocalEnv`: Reads `LOCAL_API_BASE_URL`.
   - `EnvFactory`: Reads `FLAVOR` and routes to the matching class.
5. **Android ProGuard Template**: Scaffolds `android/app/proguard-rules.pro` and links it in `app/build.gradle`.

### B. CLI Automation in `BuildCommand` (`lib/src/commands/build_command.dart`)
1. Pre-build check: Verify `.env` exists; if missing, offer to copy from `.env.example`.
2. Automatically inject `--dart-define-from-file=.env` into `flutter build apk`.
3. If `--release`, automatically inject `--obfuscate --split-debug-info=build/app/outputs/symbols`.
4. Inject `--dart-define=FLAVOR=$env`.

---

## 9. Route Observer Decoupling & Optional Enablement

### Rationale
Currently, scaffolded projects automatically register `AppRouteObserver` and call `AppRouteStorage.restoreInitialRoute()` upon application bootstrap.
While useful for certain apps, enabling this by default creates unexpected behavior for new projects:
1. **Bypassing Auth/Splash Logic**: Restoring the last visited screen from `SharedPreferences` on cold restart can cause the app to skip initial Splash, authentication checks, or onboarding flows.
2. **Coupling Initial Navigation**: Fresh projects should follow predictable, deterministic navigation (`AppRoutes.initialRoute`).
3. **Developer Optionality**: Route observation and state restoration should be an explicit opt-in feature, complete with clear inline documentation guiding developers on how and why to enable it.

### Planned Changes in Scaffolding Templates

#### 1. In `lib/bootstrap.dart` (across BLoC, GetX, Riverpod):
Comment out the initial route restoration line and provide an actionable developer comment:
```dart
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final env = EnvFactory.current();
  await AppDi().register(env);

  // NOTE: To persist and restore the user's last visited screen across app restarts,
  // uncomment the line below (ensure auth guards handle restored routes properly):
  // await AppRouteStorage.restoreInitialRoute();

  runApp(const App());
}
```

#### 2. In `lib/app/app.dart` (across BLoC, GetX, Riverpod):
Comment out `navigatorObservers: [appRouteObserver]` and provide an actionable developer comment:
```dart
  // In MaterialApp / GetMaterialApp:
  // navigatorObservers: [
  //   // Uncomment below to enable navigation persistence or analytics tracking (Firebase, Sentry, etc.):
  //   // appRouteObserver,
  // ],
```

#### 3. In `lib/core/route_handler/app_route_observer.dart`:
Keep the implementation file generated, but add a top-level documentation header:
```dart
/// Route observer and navigation persistence utility.
///
/// By default, route observation is commented out in `lib/bootstrap.dart` and `lib/app/app.dart`.
///
/// To enable:
/// 1. In `lib/bootstrap.dart`: Uncomment `await AppRouteStorage.restoreInitialRoute();`
/// 2. In `lib/app/app.dart`: Uncomment `appRouteObserver` under `navigatorObservers: [...]`.
```

---

## 10. Implementation Readiness Checklist

- [x] Add `.env` and `.env.example` file generators to `ProjectGenerator` / `buildCommonProjectFiles`.
- [x] Add `.env*` to scaffolded `.gitignore` (with `!.env.example` exception).
- [x] Update `EnvTemplates` (`prod_env.dart`, `stag_env.dart`, `local_env.dart`, `env_factory.dart`) to read prefixed keys from `.env`.
- [x] Comment out `AppRouteStorage.restoreInitialRoute()` in `bootstrap.dart` template with developer guidelines.
- [x] Comment out `navigatorObservers: [appRouteObserver]` in `app.dart` template with developer guidelines.
- [x] Update `BuildCommand` to pre-check `.env`, inject `--dart-define-from-file=.env`, and add `--obfuscate --split-debug-info=...` for release builds.
- [x] Add tests verifying `.env`, `.env.example`, `.gitignore`, `EnvTemplates`, and commented route observer templates.
- [x] Run full verification suite (`dart analyze`, `dart test`, `dart pub publish --dry-run`).

