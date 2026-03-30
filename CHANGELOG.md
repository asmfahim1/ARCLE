## 1.0.3

**Platform Configuration Improvements:**
- **[CRITICAL FIX]** Added automatic iOS Podfile configuration with minimum deployment target of iOS 13.0.
- **[CRITICAL FIX]** Added automatic iOS Info.plist generation with essential permission descriptions (camera, photos, microphone, location, contacts, calendar).
- **[CRITICAL FIX]** Added post-install hooks to Podfile to ensure consistent iOS build settings across all targets.
- **[CRITICAL FIX]** Fixed iOS builds that would previously fail due to missing Info.plist permission descriptions.
- Added automatic iOS deployment target enforcement to prevent compatibility issues.
- Updated iOS configuration to match Android's rigorous platform setup standard.
- Both Android and iOS are now configured equally during project creation for production-ready apps.
- Created comprehensive `PLATFORM_CONFIGURATION_GUIDE.md` with setup details, checklists, and troubleshooting.

**Build & DI Improvements:**
- Added persistent build version updates in `arcle build apk` with `--version-name` and `--version-code`, which rewrite the target project's `pubspec.yaml`.
- Added persistent environment updates in `arcle build apk --env prod|stag|local`, which rewrite the target project's `lib/core/env/env_factory.dart`.
- Added static 16 KB Android APK compatibility checks with `arcle verify --check-16kb`.
- Added separated `gen-di` and `auto-gen-di` commands with clear documentation on when/why to use each.
- Added comprehensive DI_COMMANDS_GUIDE.md explaining command differences and use cases.

**Developer Experience:**
- Added optional short command aliases such as `new`, `feat`, `health`, `autodi`, `di`, `docs`, `ver`, `b`, `br`, and `bd` while keeping all existing commands unchanged.
- Platform configuration status now shown during project creation (Android & iOS setup feedback).

## 1.0.2

- Added `doctor` command for ARCLE project health checks.
- Added `doctor --fix` for safe ARCLE-owned repairs.
- Added `verify` command to run analyze, test, and BLoC codegen verification.
- Added generated `core/utils/date_formatter.dart` with UTC/local conversion and UX-friendly date helpers.
- Added automatic `intl` dependency injection to generated projects.
- Updated generated notification service to be platform-safe across Android, iOS, macOS, and unsupported platforms.
- Updated generated permission service to use platform-aware permission handling and safe fallbacks.
- Updated README with platform notes for Android, iOS, macOS, and web behavior.
- Removed generated `lib/features/README.md` from new projects across all state management options.

## 1.0.1

- Fixed pubspec description length.
- Added usage example.
