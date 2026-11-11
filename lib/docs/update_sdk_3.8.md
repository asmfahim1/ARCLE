# ARCLE SDK Migration Plan: Dart 3.8.1 & Flutter 3.32.8

## Executive Summary

This plan outlines the architecture, implementation steps, developer offerings, and verification strategy for migrating ARCLE from **Dart SDK 3.7.2** / **Flutter 3.29.3** to **Dart SDK 3.8.1** / **Flutter 3.32.8**.

- **Host CLI Dart SDK Baseline**: `>=3.7.0 <4.0.0` $\rightarrow$ `>=3.8.1 <4.0.0`
- **Generated Project SDK Constraint**: `>=3.7.0 <4.0.0` $\rightarrow$ `>=3.8.1 <4.0.0`
- **Minimum Flutter Toolchain**: `3.29.3+` $\rightarrow$ `3.32.8+ (stable)`

---

## 1. Objectives & Scope

### In Scope
1. **ARCLE Host Toolchain**:
   - Bump SDK constraints in `pubspec.yaml`, `TOOLCHAIN.md`, and `README.md`.
2. **Project Scaffolding Engine**:
   - Update `ProjectGenerator._updateSdkConstraint` to enforce `>=3.8.1 <4.0.0`.
   - Update `UpgradeCommand` to migrate existing projects to `>=3.8.1 <4.0.0` and clean up legacy v2.0 references.
   - Review and update dependency versions (e.g. `dio`, `shared_preferences`, desugaring library) to modern stable releases.
3. **Android & iOS Toolchain Standards**:
   - Validate Android 15 (API 35) target and 16KB page size compliance.
   - Upgrade Android core library desugaring dependency from `2.0.4` to `2.1.4` (or `2.1.5`) for enhanced Java 11/17 API backports.
   - Confirm iOS deployment target `13.0` alignment in `Podfile`.
4. **Developer Value & Features**:
   - Introduce Dart 3.8 null-aware collection elements (`?` syntax) in template code.
   - Add `use_null_aware_elements: true` to generated `analysis_options.yaml`.
   - Modernize CI workflow templates (GitHub Actions & GitLab CI) for Flutter 3.32.8.
5. **AI Workflow & Agent Guidance**:
   - Instruct Claude, Codex, and Gemini on Dart 3.8 idioms and Flutter 3.32 API changes (e.g., `ExpansionTileController` $\rightarrow$ `ExpansibleController`, `InputDecoration.maintainHintHeight` $\rightarrow$ `maintainHintSize`).
6. **Diagnostics & Health**:
   - Update `ProjectHealthValidator` and `DoctorCommand` to detect and validate the new SDK baseline.

### Excluded
- Breaking changes to ARCLE Clean Architecture folder boundaries (`core/`, `features/`, `data/`, `domain/`, `presentation/`).
- Deprecating state management options (BLoC, GetX, and Riverpod remain fully supported).
- Unrelated CLI refactoring.

---

## 2. Developer Value Proposition: What We Offer Developers

Updating to Dart 3.8.1 and Flutter 3.32.8 provides significant developer experience (DX) and technical advantages:

### A. Dart 3.8 Null-Aware Collection Elements (`?` syntax)
* **Problem**: Conditionally adding widgets to lists/menus/action bars previously required awkward collection-ifs (`if (widget != null) widget`) or verbose ternary spreads.
* **Solution**: In Dart 3.8, elements can be prefixed with `?` directly in lists, sets, and maps:
  ```dart
    children: [
    const CommonAppBar(title: 'Overview'),
    bannerWidget?,         // Included only if non-null
    filterBar?,            // Automatically omitted if null
    Expanded(child: UserList()),
    ]
```
* **ARCLE Offering**:
  - Adopt this syntax across common widget templates and feature pages.
  - Enable `use_null_aware_elements: true` in `analysis_options.yaml` to encourage modern idiomatic Flutter.

### B. Formatter Refinements ("Tall" Style Polish)
* **Problem**: In older versions, trailing commas could force unwanted splits on simple, short widget calls.
* **Solution**: Dart 3.8's formatter intelligently evaluates line width before splitting, avoiding unnatural indentation breaks.
* **ARCLE Offering**: Preconfigured analysis options ensuring consistent formatting without team style debates.

### C. Android 15 & 16KB Page Size Guarantee
* **Problem**: Android 15 devices require native C++ binaries to support 16KB page alignment; legacy builds risk crashing on newer devices.
* **Solution**: Flutter 3.32 compiles with native 16KB memory page alignment.
* **ARCLE Offering**: Scaffolds projects with verified `compileSdk = 35`, `targetSdk = 35`, and desugaring `2.1.4`, providing immediate Google Play and Android 15 store readiness.

### D. Upgraded `arcle upgrade` Command
* **Problem**: Existing projects created on Flutter 3.29 need a frictionless migration path.
* **Solution**: Running `arcle upgrade` will:
  1. Update `pubspec.yaml` SDK constraint to `>=3.8.1 <4.0.0`.
  2. Update `analysis_options.yaml` with the latest lint rules.
  3. Validate Gradle and Podfile configurations.
  4. Guide developers on running `dart fix --apply` to convert collection-ifs into `?` null-aware elements.

---

## 3. Implementation Breakdown & Affected Files

```
┌────────────────────────────────────────────────────────────────────────┐
│                        Implementation Phases                           │
├─────────┬──────────────────────────────────┬───────────────────────────┤
│ Phase 1 │ ARCLE Toolchain & Package Spec   │ pubspec.yaml, TOOLCHAIN   │
│ Phase 2 │ Scaffolding & Code Generation    │ project_generator.dart    │
│ Phase 3 │ Upgrade Command & Health Doctor  │ upgrade_command, health   │
│ Phase 4 │ Analysis Options & CI Workflows  │ analysis_templates, CI    │
│ Phase 5 │ AI Workflow Rules & Templates    │ agent_templates, claude   │
│ Phase 6 │ Verification, Tests & Docs Gate  │ tests, README, CHANGELOG  │
└─────────┴──────────────────────────────────┴───────────────────────────┘
```

### Phase 1: ARCLE Toolchain & Package Specification
- **`pubspec.yaml`**:
  - Change `environment.sdk` from `">=3.7.0 <4.0.0"` to `">=3.8.1 <4.0.0"`.
- **`TOOLCHAIN.md`**:
  - Update Flutter version to `3.32.8+ (stable)` with constraint `>=3.32.8`.
  - Update Dart SDK version to `3.8.1+` with constraint `>=3.8.1 <4.0.0`.
  - Update core desugaring library reference to `2.1.4`.
- **`README.md`**:
  - Update prerequisite badges and requirements to Flutter `3.32.8+` and Dart `>=3.8.1 <4.0.0`.

### Phase 2: Project Generator Engine
- **`lib/src/generators/project_generator.dart`**:
  - `_updateSdkConstraint(Directory base)`:
    - Update replacement string to `'sdk: ">=3.8.1 <4.0.0"'`.
  - `_ensureCoreLibraryDesugaringDependency`:
    - Bump `'com.android.tools:desugar_jdk_libs:2.0.4'` $\rightarrow$ `'com.android.tools:desugar_jdk_libs:2.1.4'`.
  - `_ensureCoreLibraryDesugaringDependencyKotlin`:
    - Bump `"com.android.tools:desugar_jdk_libs:2.0.4"` $\rightarrow$ `"com.android.tools:desugar_jdk_libs:2.1.4"`.
  - Verify template dependency versions (`dio`, `shared_preferences`, `permission_handler`) against Dart 3.8.

### Phase 3: Project Upgrade Command & Health Diagnostics
- **`lib/src/commands/upgrade_command.dart`**:
  - Update `_upgradeSdkConstraint` replacement string to `'sdk: ">=3.8.1 <4.0.0"'`.
  - Update command output and banner from legacy "Upgrading to v2.0.0" to active modern version.
  - Add guidance to run `dart fix --apply` after upgrading.
- **`lib/src/utils/project_health.dart`**:
  - In `_validateEnvironment`, ensure minimum tool versions report meaningful guidance when Dart < 3.8.1 or Flutter < 3.32.8.
- **`lib/src/commands/doctor_command.dart`**:
  - Ensure `--fix` updates stale SDK constraints to `>=3.8.1 <4.0.0`.

### Phase 4: Analysis Options & CI Workflows
- **`lib/src/templates/core/analysis_templates.dart`**:
  - Add `use_null_aware_elements: true` to recommended linter rules.
  - Ensure strict cast and type inference rules are maintained.
- **`lib/src/templates/ci/github_actions_templates.dart`**:
  - Ensure Flutter setup action references stable Flutter 3.32.8 / Dart 3.8.1.
- **`lib/src/templates/ci/gitlab_ci_templates.dart`**:
  - Ensure CI image `ghcr.io/cirruslabs/flutter:stable` compatibility.

### Phase 5: AI Workflow Rules & Agent Templates
- **`lib/src/templates/ai/agent_templates.dart`** (`.ai/coding-rules.md`):
  - Add guidance promoting Dart 3.8 null-aware collection elements (`?` syntax).
  - Note deprecations: `ExpansionTileController` $\rightarrow$ `ExpansibleController`, `InputDecoration.maintainHintHeight` $\rightarrow$ `maintainHintSize`.
- **`lib/src/templates/ai/claude_templates.dart`**, **`codex_templates.dart`**, **`gemini_templates.dart`**:
  - Align native entry rules to reflect Dart 3.8 coding standards.

### Phase 6: Verification, Tests & Documentation Gate
- **`test/commands/upgrade_command_test.dart`** (or unit tests):
  - Add tests validating that SDK constraint bumps to `>=3.8.1 <4.0.0`.
- **`test/templates/analysis_templates_test.dart`**:
  - Validate inclusion of `use_null_aware_elements`.
- **Documentation Audit**:
  - Run the Mandatory Pre-release Documentation Gate on `README.md`, `CHANGELOG.md`, `TOOLCHAIN.md`, and CLI help messages.

---

## 4. Verification & Testing Checklist

| Step | Action | Expected Result | Status |
| :--- | :--- | :--- | :---: |
| 1. Code Analysis | `dart analyze lib/ test/` | Zero errors, zero warnings | PENDING |
| 2. Test Suite | `dart test` | All unit & template tests pass | PENDING |
| 3. Project Creation | `arcle create test_app --state bloc -n dio` | Scaffolds with `>=3.8.1 <4.0.0` SDK constraint | PENDING |
| 4. Health Check | `arcle doctor -p test_app` | Reports healthy status with 0 issues | PENDING |
| 5. Project Upgrade | `arcle upgrade -p <legacy_project>` | Bumps SDK to `>=3.8.1 <4.0.0` successfully | PENDING |
| 6. Package Dry-Run | `dart pub publish --dry-run` | Passes pub validation cleanly | PENDING |

---

## 5. Risks & Mitigation

1. **Host Environment Discrepancy**:
   - *Risk*: A developer running ARCLE on an older Flutter version (< 3.32) may encounter dependency resolution failures.
   - *Mitigation*: ARCLE's `ProjectHealthValidator` and `doctor` command will proactively report toolchain version mismatches with actionable upgrade instructions (`flutter upgrade`).
2. **Third-Party Package Constraints**:
   - *Risk*: Existing dependencies in user projects may pin an upper Dart bound `<3.8.0`.
   - *Mitigation*: `arcle upgrade` advises running `dart pub outdated` and `flutter pub upgrade`.
3. **Template Regression**:
   - *Risk*: Modifying template strings might introduce syntax errors in generated projects.
   - *Mitigation*: All template outputs are guarded by automated regression tests in `test/templates/`.

---

## 6. Execution Protocol

This plan is staged for execution upon developer authorization:
1. Review and approve the plan.
2. Branch/execute Phase 1 through Phase 5 in order.
3. Perform complete verification checklist (Phase 6).
4. Update `CHANGELOG.md` and bump release version when ready.
