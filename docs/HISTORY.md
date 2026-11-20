# Project History

## 2026-11-20 23:04 +06:00 — [Pre-Release] 3.1.0 Pub.dev Publish Readiness & Documentation Audit Gate
- Agent: gemini
- Start: 2026-11-20T22:59:11+06:00
- End: 2026-11-20T23:04:30+06:00
- Elapsed: 5 minutes (wall-clock)
- Result: Conducted comprehensive dry test and documentation audit for ARCLE 3.1.0 release. Added `docs/` to `.pubignore`, resolving pub package validation warning regarding singular directory layout (`doc` vs `docs`) and optimizing published archive size from 6 MB down to 182 KB. Updated `PLATFORM_CONFIGURATION_GUIDE.md` to reflect Android core library desugaring dependency `2.1.4` (upgraded from `2.0.4`) and documented Android ProGuard / R8 rules (`android/app/proguard-rules.pro`). Updated `README.md` "What's New In v3.1.0" to include compile-time `.env` architecture, automated release security (`--obfuscate`, `--split-debug-info`), and HTTP method logging. Modernized CLI usage comments in `example/example.dart`.
- Reusable finding: Pub packager considers top-level `docs/` non-standard (convention is singular `doc/`). Adding `docs/` to `.pubignore` removes the warning cleanly, prevents packaging of internal developer plans and untracked artifacts, and keeps the published tarball lean (182 KB) while preserving raw GitHub URLs for assets in `README.md`.
- Verification: PASS `dart format` (104 files); PASS `dart analyze lib test` (0 errors, 0 warnings); PASS `dart test` (182/182 tests passed); PASS `dart pub publish --dry-run` (package validation passed, 0 warnings when committed).
- Token usage: Not available

## 2026-11-19 15:57 +06:00 — [Major Update] Version 3.1.0: Flutter 3.38.10 Migration, CommonRetryWidget, Secure Compile-Time Environment (.env), Release Obfuscation & Route Observer Decoupling
- Agent: gemini
- Start: 2026-11-19T15:47:21+06:00
- End: 2026-11-19T15:57:00+06:00
- Elapsed: 10 minutes (wall-clock)
- Result: Delivered ARCLE major release 3.1.0 targeting Flutter 3.38.10 / Dart 3.10.9 (sdk: '>=3.10.0 <4.0.0'). Added `CommonRetryWidget` in `lib/core/common_widgets/common_retry_widget.dart` using theme-adaptive brand color, semantic `AppColors.error`, and responsive dimensions. Implemented pure compile-time `.env` and `.env.example` architecture via `--dart-define-from-file=.env` (zero asset bundling). Updated `BuildCommand` to pre-check `.env`, inject compile-time defines, enable native Dart obfuscation (`--obfuscate`), strip debug symbols (`--split-debug-info`), and link Android ProGuard rules (`android/app/proguard-rules.pro`). Decoupled `AppRouteStorage.restoreInitialRoute()` and `navigatorObservers` by default to ensure clean cold launches for new projects. Updated all documentation (`README.md`, `CHANGELOG.md`, `TOOLCHAIN.md`, `docs/HISTORY.md`, `lib/docs/env_setup_plan.md`, `lib/docs/update_plan.md`).
- Reusable finding: Native Flutter `--dart-define-from-file=.env` injects environment constants into compiled AOT binary (`libapp.so`) without bundling `.env` into plaintext APK assets (`flutter_assets/.env`), defeating trivial `unzip app.apk` extraction attacks without adding third-party runtime package overhead. Dart code in `libapp.so` requires Flutter's native `--obfuscate --split-debug-info` flags, while ProGuard protects the Android Java/Kotlin host layer. Commenting out both route restoration in `bootstrap.dart` and `navigatorObservers` in `app.dart` simultaneously prevents `unused_import` lint warnings while keeping the opt-in path fully documented.
- Verification: PASS `dart format`; PASS `dart analyze lib test` (0 errors, 0 warnings); PASS `dart test` (182/182 tests passed); PASS `dart pub publish --dry-run` (package archive validated).
- Token usage: Not available

## 2026-11-18 15:02 +06:00 — [Feature] Add HTTP method logging to AppLogger.apiCall
- Agent: gemini
- Start: 2026-11-18T14:52:08+06:00
- End: 2026-11-18T15:02:00+06:00
- Elapsed: 10 minutes (wall-clock)
- Result: Added `String? method` parameter to `AppLogger.apiCall` in `lib/src/templates/core/utils_templates.dart` and printed `${color}** Method **${reset} ${method.toUpperCase()}`. Updated Dio interceptors and ApiHttpClient call sites in `lib/src/templates/core/api_templates.dart` to pass the HTTP request method. Added unit test coverage in `test/templates/network_templates_test.dart`.
- Reusable finding: `AppLogger.apiCall` is invoked in Dio interceptors (`onResponse`, `onError`) and `ApiHttpClient` (`send`, `upload`). Adding an optional `method` parameter allows backward compatibility while enabling structured HTTP method inspection across all network clients.
- Verification: PASS `dart format`; PASS `dart analyze lib test`; PASS `dart test` (172/172 tests passed).
- Token usage: Not available
