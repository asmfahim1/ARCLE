# ARCLE CLI

**A production-ready CLI that accelerates Flutter development with Clean Architecture, multiple state management options, fast scaffolding, and repeatable workflows.**

[![Pub Version](https://img.shields.io/pub/v/arcle?color=blue&logo=dart)](https://pub.dev/packages/arcle)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-blue)](LICENSE)

---

## Table of Contents

- [Why ARCLE](#why-arcle)
- [Features](#features)
- [State Management Support](#state-management-support)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Commands](#commands)
- [Project Structure](#project-structure)
- [Feature Generation](#feature-generation)
- [Configuration](#configuration)
- [Toolchain](#toolchain)
- [Contributing](#contributing)

---

## Why ARCLE

ARCLE removes the repetitive setup work required to start and maintain clean, scalable Flutter projects.

- 🚀 **Zero to Production** - Create a fully structured project in seconds
- 🏗️ **Clean Architecture** - Data, Domain, and Presentation layers out of the box
- 🔄 **Multiple State Management** - Choose BLoC, GetX, or Riverpod
- 📦 **Feature-First** - Generate complete feature modules with one command
- 🔧 **DI Wiring** - Automatic dependency injection setup
- 📱 **Build Ready** - APK builds with smart naming

---

## Features

| Feature | Description |
|---------|-------------|
| **Project Scaffolding** | Create new Flutter projects with Clean Architecture |
| **Feature Generation** | Generate complete feature modules (data/domain/presentation) |
| **State Management** | Support for BLoC, GetX, and Riverpod |
| **Dependency Injection** | Auto-configured DI with GetIt (BLoC) or Riverpod providers |
| **Routing** | Pre-configured routing with route observer |
| **Localization** | Multi-language support with JSON translations |
| **Theme Management** | Light/Dark theme switching built-in |
| **API Client** | Dio-based HTTP client with interceptors |
| **Session Management** | Secure token storage and management |
| **Common Widgets** | Reusable UI components library |
| **APK Builds** | Debug/Release builds with smart renaming |
| **Documentation** | Generate project documentation |

---

## State Management Support

### BLoC
- Full BLoC pattern with Events, States, and Blocs
- GetIt + Injectable for dependency injection
- Equatable for value comparison
- Code generation with build_runner

### GetX
- GetX controllers with reactive observables
- Bindings for lazy dependency loading
- Built-in GetX navigation and localization
- No code generation required

### Riverpod
- StateNotifier pattern with immutable states
- Provider-based dependency injection
- ProviderScope for scoped state
- ProviderLogger for debugging
- Type-safe and testable

---

## Installation

```bash
dart pub global activate arcle
```

Make sure `~/.pub-cache/bin` is in your PATH.

---

## Quick Start

### Create a New Project

```bash
# Create with interactive state selection
arcle create my_app

# Create with specific state management
arcle create my_app --state bloc
arcle create my_app --state getx
arcle create my_app --state riverpod

# Create with organization identifier
arcle create my_app --state riverpod --org com.example
```

### Add Features

```bash
# Generate a complete feature module
arcle feature auth
arcle feature products
arcle feature payments
```

### Build APK

```bash
# Debug build
arcle build apk --debug

# Release build
arcle build apk --release

# Interactive mode (prompts for debug/release)
arcle build apk
```

---

## Commands

| Command | Description |
|---------|-------------|
| `arcle create <name>` | Create a new Flutter project with Clean Architecture |
| `arcle init` | Scaffold Clean Architecture in an existing project |
| `arcle feature <name>` | Generate a complete feature module |
| `arcle auto-gen-di` | Regenerate DI and refresh dependencies (BLoC only) |
| `arcle gen-di` | Regenerate DI files only (BLoC only) |
| `arcle build apk` | Build APK (debug or release) |
| `arcle gen-doc` | Generate project documentation (Word or PDF) |

### Command Options

#### `create`
```bash
arcle create <project_name> [options]

Options:
  -s, --state          State management (bloc, getx, riverpod)
  -p, --path           Directory to create the project in
  --org                Organization identifier for Flutter
  --state-version      Version constraint for state package
  --no-flutter-create  Skip flutter create, scaffold only
  -f, --force          Overwrite existing files
  -i, --interactive    Prompt for missing values (default: true)
```

#### `feature`
```bash
arcle feature <feature_name> [options]

Options:
  -f, --force          Overwrite existing files
```

#### `build`
```bash
arcle build apk [options]

Options:
  -r, --release        Build in release mode
  -d, --debug          Build in debug mode
  -p, --path           Directory of a Flutter project

Examples:
  arcle build apk              # Interactive mode selection
  arcle build apk --release    # Build release APK
  arcle build apk --debug      # Build debug APK
```

---

## Project Structure

```
lib/
├── app/
│   └── app.dart                    # Main App widget
├── bootstrap.dart                  # App initialization
├── main.dart                       # Entry point
├── core/
│   ├── api_client/                 # Dio HTTP client
│   ├── common_widgets/             # Reusable UI components
│   ├── di/                         # Dependency injection
│   ├── env/                        # Environment configs
│   ├── error_handler/              # Error handling
│   ├── localization/               # App strings
│   ├── notifications/              # Push/local notifications
│   ├── permissions/                # Runtime permissions
│   ├── response_handler/           # API response handling
│   ├── route_handler/              # Navigation
│   ├── session_manager/            # Auth/token storage
│   ├── theme_handler/              # Theme configuration
│   └── utils/                      # Utilities and helpers
└── features/
    ├── demo/                       # Demo feature (login + users)
    └── settings/                   # App settings feature
```

### Feature Structure

Each feature follows Clean Architecture:

```
features/<feature_name>/
├── data/
│   ├── model/                      # Data models (DTOs)
│   ├── repository/                 # Repository implementations
│   └── source/                     # Remote/local data sources
├── domain/
│   ├── entity/                     # Business entities
│   ├── repository/                 # Repository contracts
│   └── usecase/                    # Use cases
└── presentation/
    ├── pages/                      # Screen widgets
    ├── widgets/                    # Feature-specific widgets
    └── [state]/                    # BLoC/Controller/Providers
```

---

## Feature Generation

When you run `arcle feature <name>`, ARCLE generates:

### Files Created
- **Model** - Data transfer object with JSON serialization
- **Entity** - Clean domain entity
- **Repository Contract** - Abstract repository interface
- **Repository Implementation** - Concrete implementation
- **Remote Source** - API data source
- **Use Case** - Business logic
- **State** - Feature state (BLoC State/Riverpod State)
- **Controller/BLoC/Provider** - State management
- **Screen** - UI widget
- **Card Widget** - List item widget

### Auto-Updates
- **Routes** - Adds route to app_routes.dart
- **Router** - Adds case to router
- **DI** - Adds providers (BLoC/Riverpod)
- **Endpoints** - Adds API endpoint
- **Localization** - Adds translation keys

---

## Configuration

ARCLE creates an `arcle.yaml` file in your project root:

```yaml
state: riverpod
created_at: 2024-01-15T10:30:00.000Z
```

This file is used by subsequent commands to know which state management solution to use.

---

## Toolchain

Exact Flutter and Dart versions for the current release are listed in `TOOLCHAIN.md`.

### Requirements
- Dart SDK: ^3.5.4
- Flutter: Latest stable recommended

---

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting PRs.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Made with ❤️ for the Flutter community
