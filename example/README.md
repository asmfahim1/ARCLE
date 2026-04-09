# ARCLE CLI - Usage Examples

ARCLE is a Flutter CLI that scaffolds Clean Architecture projects with BLoC, GetX, or Riverpod.

## Installation

```bash
dart pub global activate arcle
```

Ensure the pub cache bin is in your PATH:

- **Linux/macOS**: `export PATH="$PATH:$HOME/.pub-cache/bin"`
- **Windows**: Add `%APPDATA%\Pub\Cache\bin` to System Environment Variables

---

## Quick Start

### 1. Create a New Project

```bash
# Interactive (prompts for state management)
arcle create my_app

# Explicit state
arcle create my_app --state bloc
arcle create my_app --state getx
arcle create my_app --state riverpod

# Short alias
arcle new my_app
```

### 2. Scaffold an Existing Project

```bash
arcle init
arcle init --state bloc
arcle setup            # alias
```

### 3. Generate a Feature

```bash
arcle feature payments
arcle feature payments --state bloc
arcle feat payments    # alias
```

Creates data/domain/presentation layers, wires routes, DI, endpoints, and localization keys automatically.

### 4. Localization

Locales are managed individually — you can add and remove any ISO 639-1 locale code.

#### Add a locale

```bash
arcle add locale en              # English — bootstraps dart infra on first run
arcle add locale bn              # Bengali — appends to existing infra
arcle add locale my              # Myanmar/Burmese
arcle add locale fr              # French
arcle add loc --de               # German (flag short form)
arcle add loc --ja --state getx  # Japanese with explicit state
```

First call creates:
- `lib/core/localization/app_strings.dart` — `AppLocalizations` delegate (BLoC/Riverpod) or `.tr` extension (GetX)
- `lib/core/localization/getx_localization.dart` — GetX `Language` class (GetX only)

Every call creates `assets/langs/<code>.json` and updates `pubspec.yaml`.  
Known locales (`en`, `bn`) get curated translations; all others get an English-value placeholder so the app stays runnable while you translate.

#### Remove a locale

```bash
arcle delete locale bn           # remove Bengali locale (prompts for confirmation)
arcle del locale en --force      # remove English, skip prompt
arcle del loc --my               # flag short form
```

Deletes `assets/langs/<code>.json`, removes the locale from `supportedLocales` / `isSupported` in `app_strings.dart`, and removes the GetX section when applicable.  
When the last JSON file is removed the `assets/langs/` entry is also cleaned from `pubspec.yaml`.

### 5. Build APK

```bash
arcle build apk --debug
arcle build apk --release

# Short aliases
arcle bd     # debug
arcle br     # release

# Persist version and environment before building
arcle build apk --release --env prod --version-name 2.0.0 --version-code 20
```

### 6. Verify Project

```bash
# Basic: analyze + test
arcle verify
arcle ver                          # alias

# Optional checks
arcle verify --skip-analyze
arcle verify --skip-test
arcle verify --check-16kb          # static 16 KB APK compatibility check

# Structural analysis (new in 1.0.4)
arcle verify --check-features      # each feature has all required layer files
arcle verify --check-assets        # every pubspec.yaml asset path exists on disk
arcle verify --check-l10n          # every feature has its translation key
arcle verify --full                 # run all of the above at once
```

### 7. Project Health

```bash
arcle doctor                       # validate project structure and dependencies
arcle doctor --fix                 # apply safe ARCLE-managed repairs
arcle health                       # alias
```

### 8. Dependency Injection (BLoC)

```bash
arcle auto-gen-di     # regenerate DI + run build_runner
arcle autodi          # alias

arcle gen-di          # regenerate DI files only
arcle di              # alias
```

### 9. Documentation

```bash
arcle gen-doc
arcle docs            # alias
```

---

## Supported State Management

| State       | Pattern                        | DI               | Code Gen     |
|-------------|--------------------------------|------------------|--------------|
| **BLoC**    | Event-driven, predictable      | GetIt + Injectable | build_runner |
| **GetX**    | Reactive, controller-based     | Built-in GetX    | None         |
| **Riverpod**| Type-safe, provider-based      | Built-in         | None         |

---

## Generated Project Structure

```
my_app/
├── lib/
│   ├── core/
│   │   ├── di/                    # DI setup
│   │   ├── localization/          # AppLocalizations / GetX Language
│   │   ├── route_handler/         # Routes and router
│   │   ├── api_client/            # Dio HTTP client
│   │   ├── env/                   # Environment configs
│   │   └── utils/                 # Constants, colors, validators, etc.
│   └── features/
│       └── feature_name/
│           ├── data/
│           ├── domain/
│           └── presentation/
├── assets/
│   ├── images/
│   ├── icons/
│   └── langs/
│       ├── en.json
│       └── bn.json
└── pubspec.yaml
```

---

## Learn More

- **GitHub**: https://github.com/asmfahim1/ARCLE
- **pub.dev**: https://pub.dev/packages/arcle
- **Issues**: https://github.com/asmfahim1/ARCLE/issues
