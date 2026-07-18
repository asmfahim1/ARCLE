# ARCLE CLI

Agentic Flutter Development Platform — scaffold Clean Architecture projects with BLoC, GetX, or Riverpod, and configure AI agent support for Claude Code, Codex, and Gemini.

[![Pub Version](https://img.shields.io/pub/v/arcle?color=blue&logo=dart)](https://pub.dev/packages/arcle)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-blue)](LICENSE)

## Why ARCLE

ARCLE removes repetitive setup work for scalable Flutter apps.

- Create a project with Clean Architecture structure
- Choose BLoC, GetX, or Riverpod with a numbered prompt
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
- **AI agent context** — add Claude Code, Codex, or Gemini config via `arcle configure-ai` (opt-in)
- **Pre-commit code review** — `arcle review` catches analyze errors, format issues, and missing tests before you commit

## What's New In v2.1.x

- **Decoupled AI scaffolding** — `arcle create` now generates only the Flutter Clean Architecture structure. AI agent config (`.ai/`, `.claude/`, `.codex/`, `.gemini/`) is opt-in via the new `arcle configure-ai` command.
- **Numbered prompt for state management** — interactive selection shows `1. BLoC / 2. GetX / 3. Riverpod`. The `--state` flag bypasses the prompt for CI/CD use.
- **New `arcle configure-ai` command** (alias: `arcle agent-init`) — one-question interactive wizard that detects your state management from `arcle.yaml` and scaffolds the chosen AI agent context files.
- **New `arcle review` command** (aliases: `arcle audit`, `arcle -r`) — pre-commit quality gate:
  - `dart analyze` + `dart format` check (always on, fast)
  - Missing-tests scan scoped to files in the current git diff (warns without blocking)
  - `flutter test` (opt-in via `--test`)
  - `flutter test --coverage` with percentage report (opt-in via `--coverage`)
  - AI-assisted diff review via your configured agent binary (opt-in via `--ai`)
- **Updated AI agent config templates (v2.1.5)** — Codex and Gemini settings templates now use the newer model object shape, and the Gemini default model has been bumped to `gemini-3.5-flash`.
- **Theme template compatibility fix (v2.1.5)** — generated `AppTheme` now uses `CardThemeData` for light and dark themes so new projects match current Flutter material APIs.
- **Bug fix (v2.1.3)** — removed ANSI raw-mode arrow-key menu that caused `StdinException` on Windows. State management selection uses a plain numbered prompt, consistent across all terminals.

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

### Option 2: Run without activating

```bash
dart pub global run arcle:arcle --help
```

## 🚀 Quick Start

```bash
# Create a new project — numbered prompt picks state management
arcle create my_app

# Or skip the menu with an explicit flag (great for CI/CD)
arcle create my_app --state bloc
arcle create my_app --state getx
arcle create my_app --state riverpod

# Optional alias
arcle new my_app

# Add AI agent context after project creation (opt-in)
arcle configure-ai               # interactive wizard — Claude / Codex / Gemini / All
arcle agent-init                 # alias

# Pre-commit quality gate
arcle review                     # analyze + format + missing-tests scan (fast)
arcle review --test              # also run flutter test
arcle review --coverage          # flutter test --coverage + report %
arcle review --ai                # AI-assisted diff review
arcle -r                         # shortcut

# Add a feature
arcle feature auth
arcle feat auth                  # alias

# Build APK
arcle build apk --debug
arcle build apk --release
arcle br                         # shortcut for release
arcle bd                         # shortcut for debug

# Persist version + environment before build
arcle build apk --release --env prod --version-name 1.2.0 --version-code 12

# Validate project health
arcle doctor
arcle doctor --fix

# Structural verification
arcle verify
arcle verify --check-features    # check feature layer completeness
arcle verify --check-assets      # check pubspec asset paths exist
arcle verify --check-l10n        # check feature translation key coverage
arcle verify --check-16kb        # build release APK + static 16 KB page-size checks
arcle verify --full              # run all checks at once

# Localization — add / remove individual locales
arcle add locale en              # Add English (sets up infra on first run)
arcle add locale bn              # Add Bengali
arcle add loc --fr               # Short form — add French
arcle delete locale bn           # Remove Bengali locale
arcle del loc --my               # Short form remove
```

## 📝 Commands

| Command | Description | Alias |
|---|---|---|
| `arcle create <name>` | Create a new Flutter project with Clean Architecture | `arcle new` |
| `arcle init` | Scaffold Clean Architecture in an existing project | `arcle setup` |
| `arcle feature <name>` | Generate feature data/domain/presentation layers | `arcle feat` |
| `arcle configure-ai` | Add AI agent context files to an existing project | `arcle agent-init` |
| `arcle review` | Pre-commit quality gate (analyze, format, missing tests) | `arcle audit`, `arcle -r` |
| `arcle doctor` | Validate ARCLE project health and safe repairs | `arcle health` |
| `arcle verify` | Run analyze/test/codegen verification | `arcle ver` |
| `arcle verify --check-features` | Check every feature module has all required ARCLE layer files | |
| `arcle verify --check-assets` | Check every pubspec.yaml asset path exists on disk | |
| `arcle verify --check-l10n` | Check every feature has its translation key | |
| `arcle verify --check-16kb` | Build a release APK and run static 16 KB page-size checks | |
| `arcle verify --full` | Run all structural checks in a single pass | |
| `arcle auto-gen-di` | Regenerate DI and refresh dependencies (BLoC) | `arcle autodi` |
| `arcle gen-di` | Regenerate DI files only (BLoC) | `arcle di` |
| `arcle build apk` | Build APK in debug or release mode | `arcle b`, `arcle br`, `arcle bd` |
| `arcle gen-doc` | Generate project documentation | `arcle docs` |
| `arcle add locale <code>` | Add a locale (e.g. `en`, `my`, `fr`) | `arcle add loc --<code>` |
| `arcle delete locale <code>` | Remove a locale | `arcle del locale`, `arcle del loc --<code>` |

### `arcle review` flags

| Flag | Default | Description |
|---|---|---|
| `--skip-analyze` | on | Skip `dart analyze` |
| `--skip-format` | on | Skip `dart format` check |
| `--skip-missing-tests` | on | Skip missing-tests scan |
| `--test` | **off** | Run `flutter test` (opt-in) |
| `--coverage` | off | Run `flutter test --coverage` + show % (implies `--test`) |
| `--ai` | off | AI-assisted diff review via configured agent |
| `--staged` | off | Diff only staged changes (`git diff --staged`) |
| `--path` | cwd | Target project directory |

## State Management

ARCLE includes templates and generators for three state management solutions:

### BLoC (Business Logic Component)
- Event-driven architecture with predictable state management
- Automatic DI generation using `GetIt` and `Injectable`
- Requires `build_runner` — run `arcle auto-gen-di` after adding features
- Best for: Complex apps with multiple features and events

### GetX
- Lightweight, reactive state management with bindings
- No `build_runner` needed
- Best for: Quick prototyping and small to medium apps

### Riverpod
- Type-safe provider-based state management
- No context needed, functional approach
- Best for: Apps requiring strong typing and immutability

## 🤖 AI Agent Configuration

`arcle create` generates only the Flutter Clean Architecture structure. To add AI agent context files run this from your project root after creation:

```bash
arcle configure-ai   # interactive wizard — pick Claude / Codex / Gemini / All / Skip
```

This writes:
- `.ai/` — shared context files (`settings.yaml`, `project-context.md`, `architecture-rules.md`, `coding-rules.md`, `security-rules.md`, `permissions.yaml`)
- `.claude/` — Claude Code integration (`CLAUDE.md`, `settings.json`)
- `.codex/` — OpenAI Codex integration (`instructions.md`, `settings.json`)
- `.gemini/` — Google Gemini integration (`GEMINI.md`, `settings.json`)
- `scripts/` — setup and doctor scripts for your team

State management is read from `arcle.yaml` automatically. Use `--force` to overwrite existing config.

## ✅ Requirements

- **Dart SDK**: `>=3.7.0 <4.0.0`
- **Flutter**: 3.29.3 or higher
- **Operating System**: macOS, Linux, or Windows
- **Terminal**: bash, sh, zsh, PowerShell, or Windows Terminal

## Platform Notes

- **Android:** ARCLE automatically configures Gradle build files with SDK versions (minSdk 21, compileSdk 35) and desugaring support for modern Java features. APK building is fully supported via `arcle build apk`.
- **iOS:** ARCLE automatically configures the iOS deployment target (13.0+) in Podfile and generates essential permission descriptions in Info.plist for camera, photos, microphone, location, calendar, and contacts access.
- Generated notification and permission services include platform guards so unsupported platforms fail safely instead of crashing.
- **iOS Release Builds:** Remember to configure Apple signing in Xcode, set your Team ID, and manage provisioning profiles before building for distribution.
- Web is safe for shared app code, but local notifications and runtime permissions are intentionally treated as unsupported by default.

## Build Behavior

- `arcle build apk --version-name ... --version-code ...` rewrites the target project's `pubspec.yaml` version field before building
- `arcle build apk --env prod|stag|local` rewrites `lib/core/env/env_factory.dart` default environment before building
- These build changes are persistent in the target Flutter project

## 🧪 Troubleshooting

### Command Not Found: arcle

```bash
dart pub global activate arcle

# Linux/macOS — add to ~/.bashrc or ~/.zshrc
export PATH="$PATH:$HOME/.pub-cache/bin"

# Windows — add to System Environment Variables
%APPDATA%\Pub\Cache\bin
```

### Flutter SDK Not Found

```bash
flutter --version
which flutter   # or 'where flutter' on Windows
```

### Build Failures

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
│   │   ├── di/
│   │   ├── env/
│   │   ├── error_handler/
│   │   ├── response_handler/
│   │   ├── localization/
│   │   ├── route_handler/
│   │   ├── session_manager/
│   │   ├── theme_handler/
│   │   ├── notifications/
│   │   ├── permissions/
│   │   ├── utils/
│   │   └── common_widgets/
│   └── features/
│       ├── demo/                       # Demo feature (included!)
│       │   ├── data/
│       │   ├── domain/
│       │   └── presentation/
│       └── settings/                   # Settings feature (included!)
├── assets/
│   ├── images/
│   ├── icons/
│   └── langs/
│       ├── en.json
│       └── bn.json
├── test/
└── pubspec.yaml
```

## 📋 Feature Structure by State Management

```
BLoC:
lib/features/feature_name/presentation/
├── pages/   bloc/  widgets/
│            ├── feature_name_bloc.dart
│            ├── feature_name_event.dart
│            └── feature_name_state.dart

GetX:
lib/features/feature_name/presentation/
├── pages/   controller/  bindings/  widgets/

Riverpod:
lib/features/feature_name/presentation/
├── pages/   providers/  state/  widgets/
```

## 🌟 Features

- 📦 Full project scaffolding with Clean Architecture
- 🎯 Interactive state management selection (numbered prompt, works on all terminals)
- 🧩 Feature generation (data/domain/presentation layers)
- 🔄 Automatic DI wiring (BLoC/GetIt/Injectable)
- 📱 Build APK (debug and release modes)
- 📚 Documentation generation
- 🎨 Pre-configured theming system
- 🌐 API client setup with Dio and error handling
- 🌍 Per-locale management with `arcle add locale` and `arcle delete locale`
- 🔍 Deep project analysis with `arcle verify --full`
- 🤖 Optional AI agent context (Claude Code, Codex, Gemini) via `arcle configure-ai`
- 🧠 Universal responsive `Dimensions` class via `dart:ui` PlatformDispatcher
- ✅ Pre-commit quality gate with `arcle review`

## 🎓 Toolchain

- Dart SDK: `>=3.7.0 <4.0.0`
- Flutter: 3.29.3+ (stable channel recommended)

See `TOOLCHAIN.md` for release-specific versions and environment setup details.

## 🗺️ Roadmap

- [ ] Add support for more state management options (Provider, Redux)
- [ ] Generate unit tests automatically
- [ ] Add GraphQL support
- [ ] Generate widget tests
- [ ] Add Firebase integration option
- [ ] Generate CI/CD configuration
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
- BLoC, GetX, Riverpod library maintainers
- Clean Architecture community
- All contributors

## ⭐ Star History

If ARCLE helps you, consider giving it a star! ⭐

**Happy Coding! 🚀**
