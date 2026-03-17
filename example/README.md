# Arcle CLI - Usage Examples

Arcle is a powerful Flutter CLI tool that scaffolds Clean Architecture projects with built-in support for multiple state management patterns (BLoC, GetX, and Riverpod).

## Installation

First, install Arcle globally using pub:

```bash
dart pub global activate arcle
```

## Quick Start

### 1. Initialize a New Project

Create a new Flutter project with Clean Architecture:

```bash
arcle init -n my_awesome_app -s bloc
```

**Options:**
- `-n, --name`: Project name (required)
- `-s, --state-management`: State management library (`bloc`, `getx`, or `riverpod`)

### 2. Create a New Feature

Generate a new feature with complete structure:

```bash
arcle feature -n home -s bloc
```

This creates:
- Data layer (datasources, models, repositories)
- Domain layer (entities, repositories interface, use cases)
- Presentation layer (BLoC/Controller, pages, widgets)
- Routes
- Tests

### 3. Generate Dependency Injection

Auto-generate DI (GetIt, Riverpod, etc.) configuration:

```bash
arcle gen_di
```

### 4. Build Project

Generate all required files and run code generation:

```bash
arcle build
```

### 5. Generate Documentation

Create API documentation:

```bash
arcle gen_doc
```

## Supported State Management

- **BLoC**: Complete BLoC + Cubit setup with providers
- **GetX**: GetX controllers with dependency injection
- **Riverpod**: Riverpod providers with functional approach

## Project Structure

Arcle generates a complete Clean Architecture structure:

```
lib/
├── core/
│   ├── constants/
│   ├── di/
│   ├── routing/
│   ├── services/
│   └── utils/
└── features/
    ├── feature_name/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
```

## Learn More

- **GitHub**: https://github.com/asmfahim1/ARCLE
- **Issues**: https://github.com/asmfahim1/ARCLE/issues
- **Documentation**: https://github.com/asmfahim1/ARCLE#readme

## Features

✨ **Rapid Development**: Scaffold projects in seconds  
🏗️ **Clean Architecture**: Pre-configured structure  
🔄 **State Management**: BLoC, GetX, and Riverpod support  
🛣️ **Routing**: Automatic route generation  
🧪 **Testing**: Pre-configured test setup  
📚 **Code Generation**: Automatic DI and documentation
