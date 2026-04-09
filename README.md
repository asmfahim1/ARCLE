# ARCLE CLI

A production-ready Flutter CLI that scaffolds Clean Architecture projects with BLoC, GetX, or Riverpod.

[![Pub Version](https://img.shields.io/pub/v/arcle?color=blue&logo=dart)](https://pub.dev/packages/arcle)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-blue)](LICENSE)

## Why ARCLE

ARCLE removes repetitive setup work for scalable Flutter apps.

- Create a project with Clean Architecture structure
- Choose BLoC, GetX, or Riverpod
- Generate full feature modules
- Keep DI and route wiring consistent
- API client ready with Dio
- Session management & token handling
- Multi-language support
- Environment configuration (local, staging, production)
- **Working demo feature** with login & API integration
- **Auto-generated documentation**
- Production-ready code structure
- Build APKs from the CLI

## What's New In 1.0.4

- Redesigned localization commands — locale management is now per-locale and composable:
  - `arcle add locale <code>` — add any locale (e.g. `en`, `my`, `fr`); first call bootstraps the dart infrastructure, subsequent calls append the locale
  - `arcle delete locale <code>` — remove a specific locale; cleans up JSON, dart files, and pubspec automatically
  - Short forms: `arcle add loc --my` / `arcle del loc --my`
  - `del` is a new alias for `delete`
- Any ISO 639-1 code is accepted; country codes for 60+ languages are built in
- Feature localization injection now covers all locales automatically (not just `en`/`bn`)
- Added `arcle verify --check-features`, `--check-assets`, `--check-l10n`, and `--full` for whole-project structural analysis

## 📦 Installation

### Option 1: Activate globally (Recommended)

```bash
dart pub global activate arcle
```

Then use the `arcle` command directly from anywhere in your terminal.

**Make sure your pub cache bin folder is in your PATH:**

- **Linux/macOS**: `$HOME/.pub-cache/bin`
- **Windows**: `%APPDATA%\Pub\Cache\bin`

Add to your PATH if not already present:
- **Linux/macOS**: Add to `~/.bashrc` or `~/.zshrc`: `export PATH="$PATH:$HOME/.pub-cache/bin"`
- **Windows**: Use System Properties → Environment Variables → Add `%APPDATA%\Pub\Cache\bin`

### Option 2: Run from pub

```bash
dart pub global activate arcle
arcle --help
```

Or use without activating:

```bash
dart pub global run arcle:arcle --help
```

## 🚀 Quick Start

```bash
# Create with interactive state selection
arcle create my_app

# Optional alias
arcle new my_app

# Create with explicit state
arcle create my_app --state bloc
arcle create my_app --state getx
arcle create my_app --state riverpod

# Add a feature
arcle feature auth

# Optional alias
arcle feat auth

# Build APK
arcle build apk --debug
arcle build apk --release
arcle br

# Persist version + environment before build
arcle build apk --release --env prod --version-name 1.2.0 --version-code 12

# Validate and verify an ARCLE project
arcle doctor
arcle doctor --fix
arcle verify
arcle verify --check-16kb

# Localization — add / remove individual locales
arcle add locale en                      # Add English (sets up infra on first run)
arcle add locale bn                      # Add Bengali
arcle add locale my                      # Add Myanmar / Burmese
arcle add loc --fr                       # Short form — add French
arcle delete locale bn                   # Remove Bengali locale
arcle del loc --my                       # Short form remove
arcle del locale en --force              # Skip confirmation prompt

# Deep project analysis
arcle verify --check-features            # Check feature layer completeness
arcle verify --check-assets              # Check pubspec asset paths exist
arcle verify --check-l10n               # Check feature translation key coverage
arcle verify --full                      # Run all checks at once
```

## 📝 Commands

- `arcle create <name>`: Create a new Flutter project with Clean Architecture
- Alias: `arcle new <name>`
- `arcle init`: Scaffold Clean Architecture in an existing project
- Alias: `arcle setup`
- `arcle feature <name>`: Generate feature data/domain/presentation layers
- Alias: `arcle feat <name>`
- `arcle doctor`: Validate ARCLE project health and safe repairs
- Alias: `arcle health`
- `arcle auto-gen-di`: Regenerate DI and refresh dependencies (BLoC)
- Alias: `arcle autodi`
- `arcle gen-di`: Regenerate DI files only (BLoC)
- Alias: `arcle di`
- `arcle build apk`: Build APK in debug or release mode, with optional persistent `--env`, `--version-name`, and `--version-code`
- Aliases: `arcle b`, `arcle br`, `arcle bd`
- `arcle gen-doc`: Generate project documentation
- Alias: `arcle docs`
- `arcle verify`: Run analyze/test/codegen verification
- Alias: `arcle ver`
- `arcle verify --check-16kb`: Build a release APK and run static 16 KB page-size compatibility checks
- `arcle verify --check-features`: Check every feature module has all required ARCLE layer files
- `arcle verify --check-assets`: Check every pubspec.yaml asset path exists on disk
- `arcle verify --check-l10n`: Check every feature has its translation key in the localization file
- `arcle verify --full`: Run all structural checks in a single pass
- `arcle add locale <code>`: Add a locale to the project (e.g. `en`, `my`, `fr`)
- Short form: `arcle add loc --<code>`
- `arcle delete locale <code>`: Remove a locale from the project
- Alias: `arcle del locale <code>` | Short: `arcle del loc --<code>`

## State Management

ARCLE includes templates and generators for three state management solutions:

### BLoC (Business Logic Component)
- Event-driven architecture
- Predictable state management with clear separation of concerns
- Automatic DI generation using `GetIt` and `Injectable`
- Best for: Complex apps with multiple features and events

### GetX
- Lightweight and simple to use
- Reactive state management with bindings
- No build_runner needed
- Best for: Quick prototyping and small to medium apps

### Riverpod
- Type-safe provider-based state management
- No context needed, functional approach
- Excellent for state composition
- Best for: Apps requiring strong typing and immutability

## ✅ Requirements

- **Dart SDK**: 3.5.4 or higher
- **Flutter**: Latest stable channel (3.24.5+)
- **Operating System**: macOS, Linux, or Windows
- **Terminal**: bash, sh, zsh, or PowerShell

## Platform Notes

- ARCLE project scaffolding works for Android, iOS, macOS, and web because it builds on `flutter create`
- Generated notification and permission services now include platform guards so unsupported platforms fail safely instead of crashing
- Android and iOS are the primary supported mobile targets for the generated permission and local notification setup
- iOS still requires proper native permission descriptions in `Info.plist` and Apple signing setup before release builds
- Web is safe for shared app code, but local notifications and runtime permissions are intentionally treated as unsupported by default

## Build Behavior

- `arcle build apk --version-name ... --version-code ...` rewrites the target project's `pubspec.yaml` version field before building
- `arcle build apk --env prod|stag|local` rewrites the target project's `lib/core/env/env_factory.dart` default environment before building
- These build changes are persistent in the target Flutter project
- Existing command forms remain fully supported; aliases are optional shortcuts only

## 🧪 Troubleshooting

### Command Not Found: arcle

If you get "command not found: arcle" after global activation, ensure the pub cache bin is in your PATH:

```bash
# Check if dart is properly installed
dart --version

# Re-activate arcle
dart pub global activate arcle

# On Linux/macOS, add to your shell profile (~/.bashrc, ~/.zshrc, etc.)
export PATH="$PATH:$HOME/.pub-cache/bin"

# On Windows, use System Environment Variables
%APPDATA%\Pub\Cache\bin
```

### Flutter SDK Not Found

ARCLE requires Flutter to be installed and available in PATH:

```bash
flutter --version
which flutter  # or 'where flutter' on Windows
```

###  Build Failures

Ensure you're using a compatible Flutter version:

```bash
flutter channel stable
flutter upgrade
```

## 🏗️ Project Structure

```
my_awesome_app/
├── lib/
│   ├── main.dart                       # App entry point
│   ├── bootstrap.dart                  # Bootstrap configuration
│   ├── app/
│   │   └── app.dart                    # App widget setup
│   ├── core/                           # Shared infrastructure
│   │   ├── api_client/
│   │   │   ├── api_service.dart       # HTTP client wrapper
│   │   │   ├── base_response.dart     # API response model
│   │   │   └── dio_client.dart        # Dio configuration
│   │   ├── di/
│   │   │   ├── app_di.dart            # DI setup
│   │   │   ├── injection.dart         # DI setup (BLoC only)
│   │   │   ├── injectable_module.dart # Module registration (BLoC only)
│   │   │   ├── injection.config.dart  # Generated config (BLoC only)
│   │   │   └── providers.dart         # Riverpod providers (Riverpod only)
│   │   ├── env/
│   │   │   ├── env.dart               # Environment interface
│   │   │   ├── local_env.dart         # Local config
│   │   │   ├── prod_env.dart          # Production config
│   │   │   ├── stag_env.dart          # Staging config
│   │   │   └── env_factory.dart       # Environment factory
│   │   ├── error_handler/
│   │   │   └── error_handler.dart     # Error handling
│   │   ├── response_handler/
│   │   │   ├── response_handler.dart  # Response handling
│   │   │   └── api_failure.dart       # Failure classes
│   │   ├── localization/
│   │   │   ├── app_strings.dart       # Localization keys
│   │   │   └── getx_localization.dart # GetX localization (GetX only)
│   │   ├── route_handler/
│   │   │   ├── app_routes.dart        # Route definitions
│   │   │   ├── app_router.dart        # Router configuration
│   │   │   └── app_route_observer.dart # Route observer
│   │   ├── session_manager/
│   │   │   ├── pref_manager.dart      # SharedPreferences wrapper
│   │   │   └── session_manager.dart   # Session handling
│   │   ├── theme_handler/
│   │   │   └── app_theme.dart         # Theme configuration
│   │   ├── notifications/
│   │   │   └── notification_service.dart # Notification handling
│   │   ├── permissions/
│   │   │   └── permission_service.dart  # Permission handling
│   │   ├── utils/
│   │   │   ├── constants.dart         # App constants
│   │   │   ├── endpoints.dart         # API endpoints
│   │   │   ├── enums.dart             # Enumerations
│   │   │   ├── app_assets.dart        # Asset constants
│   │   │   ├── app_colors.dart        # Color constants
│   │   │   ├── dimensions.dart        # Dimension constants
│   │   │   ├── dialogs.dart           # Dialog utilities
│   │   │   ├── logger.dart            # Logging utility
│   │   │   ├── result.dart            # Either pattern
│   │   │   ├── app_validators.dart    # Custom validators
│   │   │   └── validators.dart        # Validation utilities
│   │   └── common_widgets/
│   │       ├── svg_icon.dart          # SVG icon widget
│   │       ├── common_loader.dart     # Loading widget
│   │       ├── common_button.dart     # Button widget
│   │       ├── common_text_field.dart # Text input widget
│   │       ├── common_dropdown.dart   # Dropdown widget
│   │       ├── common_checkbox.dart   # Checkbox widget
│   │       ├── common_snackbar.dart   # Snackbar widget
│   │       ├── common_app_bar.dart    # App bar widget
│   │       ├── common_bottom_sheet.dart # Bottom sheet widget
│   │       ├── common_dialog.dart     # Dialog widget
│   │       └── common_image_container.dart # Image container widget
│   └── features/                       # Feature modules
│       ├── demo/                       # Demo feature (included!)
│       │   ├── data/
│       │   │   ├── models/
│       │   │   ├── sources/
│       │   │   └── repositories/
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   ├── repositories/
│       │   │   └── usecases/
│       │   └── presentation/
│       │       ├── pages/              # Feature screens
│       │       ├── widgets/            # Feature widgets
│       │       ├── bloc/ (BLoC)        # BLoC files (if using BLoC)
│       │       │   ├── *_bloc.dart
│       │       │   ├── *_event.dart
│       │       │   └── *_state.dart
│       │       ├── controller/ (GetX)  # Controllers (if using GetX)
│       │       │   └── *_controller.dart
│       │       ├── bindings/ (GetX)    # Bindings (if using GetX)
│       │       │   └── *_binding.dart
│       │       └── providers/ (Riverpod) # Providers (if using Riverpod)
│       │           └── *_providers.dart
│       └── settings/                   # Settings feature (included!)
├── assets/
│   ├── images/
│   ├── icons/
│   └── langs/
│       ├── en.json                     # English translations
│       └── bn.json                     # Bengali translations (BLoC & Riverpod only)
├── docs/                               # Auto-generated documentation
├── test/                               # Tests
│   ├── features/
│   │   └── */
│   │       └── *_test.dart
│   └── widget_test.dart
└── pubspec.yaml                        # Dependencies
```

## 🏛️ State Management Details

ARCLE generates different structures and setup requirements based on your chosen state management:

### BLoC/Cubit Architecture
- **Event-based state management** with predictable patterns
- **DI Setup**: Uses GetIt + Injectable library
- **Files Created**:
  - `lib/core/di/injection.dart` - Service locator initialization
  - `lib/core/di/injectable_module.dart` - Dependency registration module
  - `lib/core/di/injection.config.dart` - Auto-generated dependencies (generated by build_runner)
  - `lib/core/di/bloc_providers.dart` - BLoC provider instances
- **Localization**: Creates `assets/langs/en.json` and `assets/langs/bn.json`
- **Best For**: Complex apps with multiple features and events
- **Code Generation**: Requires `build_runner` - run `arcle auto-gen-di` after adding features

### GetX
- **Lightweight and simple reactive state management**
- **Controller-based**: Uses controller + binding pattern
- **DI Setup**: Service locator is built into GetX
- **Files Created**:
  - `lib/core/localization/getx_localization.dart` - GetX localization wrapper
  - Feature controller: `lib/features/*/presentation/controller/*_controller.dart`
  - Feature binding: `lib/features/*/presentation/bindings/*_binding.dart`
- **Localization**: Creates `.gitkeep` placeholder (you manage translations)
- **Best For**: Quick prototyping and small to medium apps
- **Build Step**: No additional build step required

### Riverpod
- **Type-safe provider-based state management**
- **Functional approach**: Providers instead of classes
- **DI Setup**: Built into Riverpod providers
- **Files Created**:
  - `lib/core/di/providers.dart` - Core provider definitions
  - Feature providers: `lib/features/*/presentation/providers/*_providers.dart`
  - Feature state: `lib/features/*/presentation/state/*_state.dart`
- **Localization**: Creates `assets/langs/en.json` and `assets/langs/bn.json`
- **Best For**: Apps requiring strong typing and immutability
- **Code Generation**: Uses code generation for some features

## 📋 Feature Structure by State Management

Generated features have different presentation structure depending on state management:

```
BLoC:
lib/features/feature_name/presentation/
├── pages/
│   └── feature_name_screen.dart
├── widgets/
│   └── feature_name_card.dart
└── bloc/
    ├── feature_name_bloc.dart
    ├── feature_name_event.dart
    └── feature_name_state.dart

GetX:
lib/features/feature_name/presentation/
├── pages/
│   └── feature_name_screen.dart
├── widgets/
│   └── feature_name_card.dart
├── controller/
│   └── feature_name_controller.dart
└── bindings/
    └── feature_name_binding.dart

Riverpod:
lib/features/feature_name/presentation/
├── pages/
│   └── feature_name_screen.dart
├── widgets/
│   └── feature_name_card.dart
├── providers/
│   └── feature_name_providers.dart
└── state/
    └── feature_name_state.dart
```

## 🌟 Features

- 📦 Full project scaffolding with chosen architecture
- 🧩 Feature generation (data/domain/presentation layers)
- 🔄 Automatic DI wiring
- 📱 Build APK (debug and release modes)
- 📚 Documentation generation
- 🎨 Pre-configured theming system
- 🌐 API client setup with error handling
- ✅ Comprehensive code templates
- Localization: per-locale management with `arcle add locale` and `arcle delete locale`
- 🔍 Deep project analysis with `arcle verify --full`

## 🎓 Toolchain

- Dart SDK: `^3.5.4`
- Flutter: stable channel recommended

See `TOOLCHAIN.md` for release-specific versions and environment setup details.

## 🗺️ Roadmap

- [ ] Add support for more state management options (Provider, Redux)
- [ ] Generate unit tests automatically
- [ ] Add GraphQL support
- [ ] Generate widget tests
- [ ] Add Firebase integration option
- [ ] Generate CI/CD configuration
- [ ] Add more demo features
- [ ] Support for custom templates

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to your branch
5. Open a pull request

## 📄 License

MIT License. See [LICENSE](LICENSE).

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- BLoC, Getx, Riverpod library maintainers
- Clean Architecture community
- All contributors

## ⭐ Star History

If ARCLE helps you, consider giving it a star! ⭐

## 📊 Stats

- **Lines of Code Generated**: ~5,000+ per project
- **Time Saved**: Hours of setup work
- **Architecture**: Production-ready from day one
- **Best Practices**: Baked in by default

**Happy Coding! 🚀**
