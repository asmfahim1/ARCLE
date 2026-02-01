# ARCLE CLI

**A focused CLI that accelerates Flutter development with clean architecture, fast scaffolding, and repeatable workflows.**

[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](LICENSE)

---

## Table of Contents
- [Why ARCLE](#why-arcle)
- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Commands](#commands)
- [Toolchain](#toolchain)

---

## Why ARCLE

ARCLE removes the repetitive setup work required to start and maintain clean, scalable Flutter projects.  
Use it to scaffold architecture, generate features, and keep dependency injection in sync while you focus on product delivery.

---

## Features

- Clean Architecture scaffolding for new or existing projects
- Feature generation with data, domain, and presentation layers
- Riverpod-first DI generation with ProviderContainer wiring
- Automated dependency updates during scaffolding
- APK builds in debug or release with smart renaming
- Documentation generation for your project

---

## Installation

```bash
dart pub global activate arcle
```

---

## Quick Start

```bash
# Create a new project
arcle create my_app

# Generate a feature
arcle feature payments

# Refresh dependency injection
arcle auto-gen-di

# Build an APK
arcle build --mode release
```

---

## Commands

- `arcle create <project_name>`: create a new Flutter project + clean architecture
- `arcle init`: scaffold clean architecture in an existing project
- `arcle feature <feature_name>`: generate a feature module
- `arcle auto-gen-di`: regenerate DI and refresh dependencies
- `arcle gen-di`: regenerate DI only
- `arcle build --mode release`: build APK (debug or release)
- `arcle gen-doc`: generate project documentation

---

## Toolchain

Exact Flutter and Dart versions for the current release are listed in `TOOLCHAIN.md`.
