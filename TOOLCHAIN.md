# ARCLE CLI Toolchain

Versions enforced or required by this release. Update the values here **and** in the linked source file whenever you bump a version.

---

## Flutter & Dart

| Component | Version | Constraint |
|-----------|---------|-----------|
| Flutter   | 3.29.3+ (stable) | `>=3.29.3` |
| Dart SDK  | 3.7.0+ | `>=3.7.0 <4.0.0` |

Source of truth: `pubspec.yaml` → `environment.sdk`

---

## Android SDK

| Setting | Value | Source |
|---------|-------|--------|
| `compileSdk` | 35 | `lib/src/generators/project_generator.dart` → `_ensureAndroidSdkVersions*` |
| `targetSdk`  | 35 | same file |
| `minSdk`     | 21 | same file |
| Core desugaring library | `com.android.tools:desugar_jdk_libs:2.0.4` | same file → `_ensureCoreLibraryDesugaring*` |
| `coreLibraryDesugaringEnabled` | `true` | same file |

**How to bump Android SDK values:**
1. Update the `replacement:` strings in `_ensureAndroidSdkVersionsGroovy` and `_ensureAndroidSdkVersionsKotlin` in `project_generator.dart`.
2. Update the desugaring library version in `_ensureCoreLibraryDesugaringDependency` and `_ensureCoreLibraryDesugaringDependencyKotlin`.
3. Update the table above.

---

## iOS

| Setting | Value | Source |
|---------|-------|--------|
| Deployment target | 13.0 | `lib/src/generators/project_generator.dart` → `_configurePodfile` |

---

## Kotlin / AGP / Gradle

ARCLE does not pin these — it reads them from the Flutter-created project and patches them in place. Detected at runtime from:
- `android/build.gradle` / `android/build.gradle.kts` → AGP version (`com.android.application`)
- `android/build.gradle` / `android/build.gradle.kts` → Kotlin version
- `android/gradle/wrapper/gradle-wrapper.properties` → Gradle wrapper version

Source: `project_generator.dart` → `_AndroidVersions`, `_readExistingVersions`, `_patchBuildGradle*`.

---

## Update checklist (per release)

- [ ] Bump `pubspec.yaml` version
- [ ] Update `CHANGELOG.md` with what changed
- [ ] If Flutter/Dart minimum raised: update `pubspec.yaml` `environment.sdk` **and** the table above
- [ ] If Android `compileSdk`/`targetSdk`/`minSdk` changed: update `project_generator.dart` constants **and** the Android table above
- [ ] If desugaring library version bumped: update both Groovy and Kotlin branches in `project_generator.dart` **and** the table above
- [ ] Run `dart analyze lib/` — must be clean
- [ ] Run `dart pub publish --dry-run` — must pass
