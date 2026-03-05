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
- Build APKs from the CLI

## Installation

```bash
dart pub global activate arcle
```

Make sure your pub cache bin folder is on PATH.

## Quick Start

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

## Commands

- `arcle create <name>`: Create a new Flutter project with Clean Architecture
- `arcle init`: Scaffold Clean Architecture in an existing project
- `arcle feature <name>`: Generate feature data/domain/presentation layers
- `arcle auto-gen-di`: Regenerate DI and refresh dependencies (BLoC)
- `arcle gen-di`: Regenerate DI files only (BLoC)
- `arcle build apk`: Build APK in debug or release mode
- `arcle gen-doc`: Generate project documentation

## State Management

- BLoC: Event/State pattern with GetIt + Injectable support
- GetX: Lightweight reactive controllers with bindings
- Riverpod: Provider-based state and DI

## Toolchain

- Dart SDK: `^3.5.4`
- Flutter: stable channel recommended

See `TOOLCHAIN.md` for release-specific versions.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to your branch
5. Open a pull request

## License

MIT License. See [LICENSE](LICENSE).