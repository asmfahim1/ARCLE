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

# Create with explicit state
arcle create my_app --state bloc
arcle create my_app --state getx
arcle create my_app --state riverpod

# Add a feature
arcle feature auth

# Build APK
arcle build apk --debug
arcle build apk --release
```

## 📝 Commands

- `arcle create <name>`: Create a new Flutter project with Clean Architecture
- `arcle init`: Scaffold Clean Architecture in an existing project
- `arcle feature <name>`: Generate feature data/domain/presentation layers
- `arcle auto-gen-di`: Regenerate DI and refresh dependencies (BLoC)
- `arcle gen-di`: Regenerate DI files only (BLoC)
- `arcle build apk`: Build APK in debug or release mode
- `arcle gen-doc`: Generate project documentation

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
│   ├── core/                           # Shared infrastructure
│   │   ├── api/
│   │   │   ├── api_service.dart       # HTTP client wrapper
│   │   │   ├── base_response.dart     # API response model
│   │   │   └── dio_client.dart        # Dio configuration
│   │   ├── di/
│   │   │   ├── injection.dart         # DI setup
│   │   │   └── register_module.dart   # Module registration
│   │   ├── env/
│   │   │   ├── env.dart               # Environment interface
│   │   │   ├── local_env.dart         # Local config
│   │   │   ├── production_env.dart    # Production config
│   │   │   ├── staging_env.dart       # Staging config
│   │   │   └── env_factory.dart       # Environment factory
│   │   ├── error/
│   │   │   ├── failures.dart          # Failure classes
│   │   │   └── result.dart            # Either pattern
│   │   ├── localization/
│   │   │   └── app_localizations.dart # Localization setup
│   │   ├── routes/
│   │   │   └── app_routes.dart        # Navigation
│   │   ├── session_manager/
│   │   │   ├── pref_manager.dart      # SharedPreferences wrapper
│   │   │   └── session_manager.dart   # Session handling
│   │   ├── theme/
│   │   │   └── app_theme.dart         # Theme configuration
│   │   ├── utils/
│   │   │   ├── constants.dart         # App constants
│   │   │   ├── dialog_manager.dart    # Dialogs & snackbars
│   │   │   ├── enums.dart             # Enumerations
│   │   │   └── extensions.dart        # Extension methods
│   │   └── common_widgets/
│   │       └── common_loader.dart     # Reusable widgets
│   ├── features/                       # Feature modules
│   │   └── user_demo/                 # Demo feature (included!)
│   │       ├── data/
│   │       │   ├── models/
│   │       │   ├── repositories/
│   │       │   └── sources/
│   │       ├── domain/
│   │       │   ├── entities/
│   │       │   ├── repositories/
│   │       │   └── usecases/
│   │       └── presentation/
│   │           ├── logic/
│   │           ├── screens/
│   │           └── widgets/
│   └── main.dart                       # App entry point
├── assets/
│   └── lang/
│       ├── en.json                     # English translations
│       └── bn.json                     # Bengali translations
├── docs/                               # Auto-generated documentation
├── test/                               # Tests
└── pubspec.yaml                        # Dependencies
```

## 🏛️ State Management Details

### BLoC/Cubit (auto-gen-di)
- Event-based state management
- Automatic DI registration with Injectable
- Build runner required for code generation
- Run `arcle auto-gen-di` after adding features

### GetX
- Service locator pattern
- Bind controllers in feature modules
- No additional build steps required

### Riverpod
- Provider-based DI and state
- Compile-time safe
- Excellent for complex state composition

## 🌟 Features

- 📦 Full project scaffolding with chosen architecture
- 🧩 Feature generation (data/domain/presentation layers)
- 🔄 Automatic DI wiring
- 📱 Build APK (debug and release modes)
- 📚 Documentation generation
- 🎨 Pre-configured theming system
- 🌐 API client setup with error handling
- ✅ Comprehensive code templates

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
