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
