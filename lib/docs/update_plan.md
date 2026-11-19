# ARCLE 3.1.0 Major Update Plan: Flutter SDK 3.38.10 & CommonRetryWidget

## Executive Summary

This plan outlines the architecture, implementation steps, developer offerings, and verification strategy for ARCLE release **3.1.0**.
This release transitions ARCLE and its scaffolded Flutter projects to **Flutter SDK 3.38.10** / **Dart SDK 3.10.9**, introduces a new standardized **`CommonRetryWidget`**, expands design tokens in **`Dimensions`** and **`AppColors`**, audits and updates dependencies, and establishes the foundation for the subsequent security & environment management update.

- **ARCLE CLI Version**: `3.0.4` $\rightarrow$ `3.1.0`
- **Minimum Flutter Toolchain**: `3.29.3+` $\rightarrow$ `3.38.10+ (stable)`
- **Minimum Dart SDK Constraint**: `>=3.7.0 <4.0.0` $\rightarrow$ `>=3.10.0 <4.0.0`
- **Android Desugaring Toolchain**: `2.0.4` $\rightarrow$ `2.1.4`
- **New Core Common Widget**: `CommonRetryWidget` (`lib/core/common_widgets/common_retry_widget.dart`)
- **Design Tokens & Theme Adaptation**: Uses traditional `Dimensions.height(value)`, `Dimensions.allPadding(value)`, `Dimensions.icon(value)`, `Dimensions.radius(value)`, `AppColors.error`, and dynamic `AppColors.primary(context)` for seamless Light/Dark mode support.
- **Subsequent Phase**: Security & Environment Configuration (staged to follow immediately after 3.1.0 verification)

---

## 1. Objectives & Scope

### In Scope
1. **Toolchain & Version Migration (Flutter 3.38.10 / Dart 3.10.9)**:
   - Bump ARCLE host CLI SDK constraint to `sdk: ">=3.10.0 <4.0.0"` in `pubspec.yaml`.
   - Bump ARCLE version to `3.1.0` in `pubspec.yaml` and `lib/src/utils/version.dart`.
   - Update `ProjectGenerator._updateSdkConstraint` to enforce `sdk: ">=3.10.0 <4.0.0"` for all newly created projects.
   - Update `UpgradeCommand` to upgrade existing projects' SDK constraint to `sdk: ">=3.10.0 <4.0.0"` and replace legacy `v2.0.0` banners with `v3.1.0`.
   - Update `TOOLCHAIN.md` with Flutter `3.38.10+ (stable)`, Dart `3.10.9+` (`>=3.10.0 <4.0.0`), and desugaring `2.1.4`.
   - Update `README.md` badges, prerequisites, and "What's New in v3.1.0" section.

2. **Package Audit & Updates**:
   - Audit ARCLE CLI direct dependencies: update `io` (`^1.0.5` $\rightarrow$ `^1.1.0`), review `args` and `lints` for Dart 3.10 compatibility.
   - Audit scaffolded project dependencies in `ProjectGenerator._dependencies()`:
     - Android core library desugaring: `com.android.tools:desugar_jdk_libs:2.0.4` $\rightarrow$ `2.1.4` across Groovy and Kotlin build configurations.
     - Ensure compatibility for `dio`, `shared_preferences`, `permission_handler`, `flutter_local_notifications`, `timezone`, and state management packages under Flutter 3.38.10.

3. **Core Common Widget Offering: `CommonRetryWidget`**:
   - Scaffold `lib/core/common_widgets/common_retry_widget.dart` for all new projects.
   - Exact implementation matching user specification:
     - `StatelessWidget` with `message`, `buttonName`, and `onRetry` callback.
     - Responsive centering and padding via `Dimensions.allPadding(24)`.
     - Error icon with `Icons.error_outline_rounded`, size `Dimensions.icon(48)`, colored with `AppColors.error`.
     - Spacing via traditional `SizedBox(height: Dimensions.height(12))` and `SizedBox(height: Dimensions.height(16))`.
     - Responsive message text with `AppColors.slate700` and `Dimensions.font(14)`.
     - Styled `ElevatedButton` with `AppColors.primary(context)` (adapts dynamically between `brandPrimaryLight` and `brandPrimaryDark`), `AppColors.white`, and rounded border radius `Dimensions.radius(10)`.
     - Clean, direct imports of `package:flutter/material.dart`, `../theme_manager/app_colors.dart`, and `../theme_manager/dimensions.dart`.

4. **Design System & Theme Integration**:
   - Leverages existing `Dimensions` responsive scale methods (`height`, `width`, `font`, `radius`, `icon`, `allPadding`).
   - Uses `AppColors.primary(context)` to automatically adapt brand colors between Light and Dark theme modes without duplicating tokens.
   - Uses `AppColors.error` for semantic failure indication.

5. **Test Suite & Verification**:
   - Update `test/utils/version_test.dart` to assert `arcleVersion == '3.1.0'`.
   - Add unit tests in `test/templates/widgets_templates_test.dart` validating `WidgetsTemplates.commonRetryWidget()` output, imports, constructor parameters, and tokens.
   - Add unit tests validating `DimensionsTemplates.dimensions()` contains `heightBox` and `widthBox`.
   - Add unit tests validating `ConstantsTemplates.appColors()` contains `danger` and `brandPrimary`.
   - Run complete test suite (`dart test`) and static analysis (`dart analyze`).

### Excluded (Deferred to Subsequent Phase)
- Security & environment configuration overhaul (e.g. encrypted secrets, secure environment variable loaders, `.env` file security hardening). Per user requirement, this will be handled in a dedicated security update immediately following the completion and verification of the 3.1.0 SDK migration and common widget release.
- Breaking changes to ARCLE Clean Architecture layer contracts (`core/`, `features/`, `data/`, `domain/`, `presentation/`).

---

## 2. Technical Architecture & Design Details

### A. CommonRetryWidget Template Specification

File path in scaffolded projects:
`lib/core/common_widgets/common_retry_widget.dart`

Source template generator:
`WidgetsTemplates.commonRetryWidget()` in `lib/src/templates/core/widgets_templates.dart`

Generated source code:
```dart
import 'package:flutter/material.dart';
import '../theme_manager/app_colors.dart';
import '../theme_manager/dimensions.dart';

class CommonRetryWidget extends StatelessWidget {
  const CommonRetryWidget({
    super.key,
    required this.message,
    required this.onRetry,
    required this.buttonName,
  });

  final String message;
  final String buttonName;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: Dimensions.allPadding(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: Dimensions.icon(48),
              color: AppColors.error,
            ),
            SizedBox(height: Dimensions.height(12)),
            Text(
              message,
              style: TextStyle(
                color: AppColors.slate700,
                fontSize: Dimensions.font(14),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Dimensions.height(16)),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary(context),
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    Dimensions.radius(10),
                  ),
                ),
              ),
              child: Text(buttonName),
            ),
          ],
        ),
      ),
    );
  }
}
```

### B. Dynamic Theming Integration
- Leverages `AppColors.primary(context)` which dynamically switches between `brandPrimaryDark` and `brandPrimaryLight` depending on theme brightness.
- Uses `AppColors.error` for the error icon.
- Uses standard responsive `Dimensions.height(...)` and `Dimensions.width(...)` without unnecessary helper abstractions.

### C. SDK Constraint & Toolchain Alignment

| Component | Current (3.0.4) | Target (3.1.0) | File Reference |
| :--- | :--- | :--- | :--- |
| **CLI Version** | `3.0.4` | `3.1.0` | `pubspec.yaml`, `version.dart` |
| **Flutter Toolchain** | `3.29.3+` | `3.38.10+ (stable)` | `TOOLCHAIN.md`, `README.md` |
| **Dart Host SDK** | `>=3.7.0 <4.0.0` | `>=3.10.0 <4.0.0` | `pubspec.yaml` |
| **Scaffolded Project SDK** | `>=3.7.0 <4.0.0` | `>=3.10.0 <4.0.0` | `project_generator.dart` |
| **Upgrade Command Target**| `>=3.7.0 <4.0.0` | `>=3.10.0 <4.0.0` | `upgrade_command.dart` |
| **Android Desugaring** | `2.0.4` | `2.1.4` | `project_generator.dart`, `TOOLCHAIN.md` |

---

## 3. Implementation Breakdown & Affected Files

```
┌──────────────────────────────────────────────────────────────────────────┐
│                           Execution Workflow                             │
├─────────┬─────────────────────────────────┬──────────────────────────────┤
│ Stage 1 │ Version & Package Dependencies  │ pubspec.yaml, version.dart   │
│ Stage 2 │ Toolchain & Scaffolding Engine  │ project_generator, upgrade   │
│ Stage 3 │ Common Widgets & Design Tokens  │ widgets, dimensions, colors  │
│ Stage 4 │ Scaffolding Registration        │ common_project_files.dart    │
│ Stage 5 │ Unit Tests & Verification       │ widgets_test, version_test   │
│ Stage 6 │ Documentation Gate              │ README, CHANGELOG, TOOLCHAIN │
│ Stage 7 │ Security/Environment Preparation│ Staged for subsequent phase  │
└─────────┴─────────────────────────────────┴──────────────────────────────┘
```

### Stage 1: Version & Host Package Specification
- `pubspec.yaml`:
  - Bump `version` to `3.1.0`.
  - Update `environment.sdk` to `">=3.10.0 <4.0.0"`.
  - Update `io: ^1.1.0`.
- `lib/src/utils/version.dart`:
  - Change `const String arcleVersion = '3.1.0';`.

### Stage 2: Scaffolding Engine & Upgrade Command
- `lib/src/generators/project_generator.dart`:
  - In `_updateSdkConstraint(Directory base)`, update replacement to `'sdk: ">=3.10.0 <4.0.0"'`.
  - In `_dependencies()`, verify package version constraints for Flutter 3.38.10 compatibility.
  - In desugaring configuration methods (`_ensureCoreLibraryDesugaringDependency` and `_ensureCoreLibraryDesugaringDependencyKotlin`), bump `com.android.tools:desugar_jdk_libs:2.0.4` to `2.1.4`.
- `lib/src/commands/upgrade_command.dart`:
  - In `_upgradeSdkConstraint`, update replacement to `'sdk: ">=3.10.0 <4.0.0"'`.
  - Update UI output messages and usage text from legacy `v2.0.0` to `v3.1.0`.

### Stage 3: Common Widgets & Theming
- `lib/src/templates/core/widgets_templates.dart`:
  - Add `WidgetsTemplates.commonRetryWidget()`.
- `lib/src/generators/state/common_project_files.dart`:
  - Register `'lib/core/common_widgets/common_retry_widget.dart': WidgetsTemplates.commonRetryWidget(),` in `buildCommonProjectFiles`.

### Stage 5: Unit & Template Tests
- `test/utils/version_test.dart`:
  - Update test assertion to verify `3.1.0`.
- `test/templates/widgets_templates_test.dart`:
  - Add test group/cases for `WidgetsTemplates.commonRetryWidget()`.
  - Add tests validating `Dimensions.heightBox` and `Dimensions.widthBox` presence in `DimensionsTemplates`.
  - Add tests validating `AppColors.danger` and `AppColors.brandPrimary` presence in `ConstantsTemplates`.

### Stage 6: Documentation Gate
- `TOOLCHAIN.md`: Update Flutter version to `3.38.10+ (stable)`, Dart SDK to `3.10.9+`, and desugaring to `2.1.4`.
- `README.md`: Update Flutter prerequisites to `3.38.10+`, Dart constraint to `>=3.10.0 <4.0.0`, and add release notes for `v3.1.0`.
- `CHANGELOG.md`: Add comprehensive `## 3.1.0` release notes covering the SDK migration, `CommonRetryWidget`, and design token additions.

---

## 4. Verification & Testing Checklist

| Check | Command | Expected Outcome | Status |
| :--- | :--- | :--- | :---: |
| 1. Code Formatting | `dart format lib/src/ test/` | Zero unformatted files | PASS |
| 2. Static Analysis | `dart analyze lib test` | Zero errors, zero warnings | PASS |
| 3. Test Suite | `dart test` | All 182 unit & template tests pass | PASS |
| 4. CLI Version | `dart run bin/arcle.dart --help` | Outputs `🚀 ARCLE Version : 3.1.0` | PASS |
| 5. Scaffolding Validation | Verify `buildCommonProjectFiles` | Contains `.env`, `.env.example`, `common_retry_widget.dart` | PASS |
| 6. Pub Dry-Run | `dart pub publish --dry-run` | Zero fatal errors, clean validation | PASS |

---

## 5. Security & Environment Stage (Integrated into 3.1.0)

As requested, the security & environment configuration was integrated directly into version **3.1.0**.
See [lib/docs/env_setup_plan.md](file:///D:/projects/ARCLE_CLI/ARCLE/lib/docs/env_setup_plan.md) for full architectural analysis, threat modeling, and implementation details:
1. **Zero-Dependency `.env` Architecture**: Project root `.env` (gitignored) and `.env.example` (tracked in git) with compile-time `--dart-define-from-file=.env` injection (never bundled into plaintext APK assets).
2. **Release Build Hardening (`arcle build apk --release`)**: Automated Dart machine code obfuscation (`--obfuscate`), symbol stripping (`--split-debug-info`), and Android ProGuard rules (`android/app/proguard-rules.pro`).
3. **Decoupled Navigation**: Commented out `AppRouteStorage.restoreInitialRoute()` and `navigatorObservers` by default to ensure clean cold launches for new projects.

---

## 6. Release Gate

- All implementation and verification complete.
- Version 3.1.0 ready for release.
