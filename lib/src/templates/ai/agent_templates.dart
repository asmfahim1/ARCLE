import '../../state_management.dart';

class AgentTemplates {
  static String settingsYaml(StateManagement state) => '''
# ARCLE AI Agent Settings
# This file is read by all configured AI agents to understand project preferences.
# Edit freely — ARCLE will never overwrite this file after initial creation.

architecture:
  clean_architecture: true

state_management:
  type: ${state.id}   # bloc | getx | riverpod

routing:
  type: go_router

localization:
  enabled: true

responsive_ui:
  enabled: true

testing:
  enabled: true

ai:
  auto_generate_tests: true
  auto_generate_docs: true
''';

  static String projectContext(String projectName, StateManagement state) {
    final diDesc = _diDescription(state);
    final stateSpecific = _stateSpecificDirLabel(state);
    return '''
# Project Context

## Project: $projectName

This project was scaffolded with [ARCLE CLI](https://github.com/asmfahim1/ARCLE) and follows Clean Architecture principles.

## Architecture

- **Pattern**: Clean Architecture
- **State Management**: ${state.label}
- **Routing**: Named routes via route_handler
- **DI**: $diDesc
- **Localization**: flutter_localizations with JSON assets

## Directory Structure

```
lib/
├── app/          → App widget entry point
├── core/         → Shared infrastructure (DI, API, env, theme, utils, widgets)
│   ├── api_client/
│   ├── di/
│   ├── env/
│   ├── localization/
│   ├── route_handler/
│   ├── session_manager/
│   ├── theme_handler/
│   ├── notifications/
│   ├── permissions/
│   ├── utils/
│   └── common_widgets/
└── features/     → Feature modules (data / domain / presentation)
```

## Feature Module Structure

Each feature follows the same three-layer structure:
```
features/<name>/
├── data/
│   ├── model/
│   ├── source/
│   └── repository/
├── domain/
│   ├── entity/
│   ├── repository/
│   └── usecase/
└── presentation/
    ├── pages/
    ├── widgets/
    └── $stateSpecific/
```

## Rules for AI Agents

- Always respect the Clean Architecture layer boundaries
- Never import domain/presentation layers from data
- Keep business logic in domain usecases
- Use the Dimensions class for all UI measurements
- Follow existing naming conventions
- See .ai/coding-rules.md and .ai/architecture-rules.md for detailed rules
''';
  }

  static String architectureRules(StateManagement state) {
    final stateSpecificLabel = _stateSpecificPresentationLabel(state);
    final stateSpecificRules = _stateArchitectureRules(state);
    return '''
# Architecture Rules

## Clean Architecture Layers

### Data Layer
- Contains: Models, Remote/Local Data Sources, Repository Implementations
- Can depend on: Domain layer interfaces only
- Must NOT import: Presentation layer

### Domain Layer
- Contains: Entities, Repository Interfaces, Use Cases
- Must NOT depend on: Data or Presentation layers
- Pure Dart only — no Flutter imports

### Presentation Layer
- Contains: Pages, Widgets, $stateSpecificLabel
- Can depend on: Domain layer only
- Must NOT import: Data layer directly

## Dependency Flow

```
Presentation → Domain ← Data
```

## Naming Conventions

| Layer | File suffix |
|---|---|
| Model | `_model.dart` |
| Entity | `_entity.dart` |
| Repository Interface | `_repository.dart` |
| Repository Implementation | `_repository_impl.dart` |
| Remote Source | `_remote_source.dart` |
| Use Case | `_usecase.dart` |
| Screen | `_screen.dart` |
| Widget | `_card.dart` / `_widget.dart` |

## State Management Rules

$stateSpecificRules

## General Rules

- One feature = one directory under lib/features/
- Do not put business logic in Widgets or Pages
- Use Result<T> / Either for error handling
- Repository interfaces live in domain, implementations in data
''';
  }

  static String codingRules(StateManagement state) {
    final stateRules = _stateCodingRules(state);
    return '''
# Coding Rules

## Dart & Flutter Standards

- Use `package:` imports everywhere (never relative `../` for cross-feature imports)
- Prefer `const` constructors wherever possible
- Use `final` for all fields and local variables unless mutation is required
- No `print()` statements — use the Logger utility
- Always declare return types on functions
- Use trailing commas in multi-line lists and parameters
- Prefer single quotes for strings

## Widget Rules

- All widgets must have a `key` parameter in the constructor
- Use `super.key` via `super parameters`
- Avoid unnecessary `Container` wrappers — use `SizedBox`, `Padding`, `ColoredBox`
- Use `Dimensions` utility for all padding, margin, font sizes, and radii — never hardcode pixel values

## Repository Pattern

- Use cases call repository interfaces (not implementations)
- Repositories return `Either<Failure, T>` using the `Result` type alias
- Never throw exceptions from repositories — convert to Failures

## State Management: ${state.label}

$stateRules

## Testing

- Unit tests for all use cases and repositories
- Widget tests for all screens
- Mock repositories using Mockito or manual fakes
- Test file naming: `<name>_test.dart` mirrors source `<name>.dart`

## File Organization

- One class per file
- File name matches class name in snake_case
- Group related utilities in `core/utils/`
- Group shared widgets in `core/common_widgets/`
''';
  }

  static String securityRules() => '''
# Security Rules

These rules apply to ALL code written in this project, including AI-generated code.

## Secrets & Credentials

- ❌ No API keys, tokens, passwords, or secrets in source code
- ❌ No secrets in comments
- ✅ Use environment configuration via `lib/core/env/` for all environment-specific values
- ✅ Use `flutter_secure_storage` or `shared_preferences` with encryption for sensitive local data

## Token Handling

- Store tokens only in `SessionManager` (never in plain variables or local state)
- Tokens must not be logged
- Implement token refresh logic in `DioClient` interceptors
- Clear session on logout from `SessionManager`

## API Security

- All API calls must go through `ApiService` (never raw `http` calls)
- Validate SSL certificates — do not disable certificate verification
- Use HTTPS endpoints only in staging and production environments
- Apply request timeouts in `DioClient`

## Logging Restrictions

- Never log sensitive user data (PII, credentials, tokens)
- Use the `Logger` utility — never `print()`
- In release mode, logging should be disabled or filtered

## Input Validation

- Validate all user inputs using `AppValidators` before sending to APIs
- Sanitize strings before displaying in UI
- Never trust client-side data on the backend

## Permissions

- Request only permissions that are strictly needed
- Explain why permissions are needed before requesting
- Handle denied permissions gracefully — never crash

## OWASP Mobile Top 10 Guidelines

- M1: Improper Platform Usage → Use platform APIs correctly, respect permission model
- M2: Insecure Data Storage → Use `SessionManager`, never plaintext storage for secrets
- M3: Insecure Communication → HTTPS only, certificate pinning recommended for production
- M4: Insecure Authentication → Implement refresh tokens, expiry checks
- M5: Insufficient Cryptography → Use platform-provided crypto, not custom implementations
- M9: Reverse Engineering → Enable code obfuscation in release builds
''';

  static String permissionsYaml() => '''
# AI Agent Permissions
# Controls what AI agents are allowed to do in this project.
# Edit this file to tighten or loosen restrictions per your workflow.

agents:
  # Allow agents to create new files
  create_files: true

  # Allow agents to modify existing files
  modify_files: true

  # Prevent agents from deleting files (recommended: keep false)
  delete_files: false

  # Allow agents to run read-only commands (flutter analyze, dart format --output)
  run_readonly_commands: true

  # Prevent agents from running build or deploy commands without confirmation
  run_build_commands: false

  # Prevent agents from modifying CI/CD configuration
  modify_ci_config: false

  # Prevent agents from modifying environment files
  modify_env_files: false
''';

  // ── Private helpers ──────────────────────────────────────────────────────

  static String _diDescription(StateManagement state) {
    switch (state) {
      case StateManagement.bloc:
        return 'GetIt + Injectable (code-generated)';
      case StateManagement.getx:
        return 'GetX dependency injection via Get.put / Get.lazyPut';
      case StateManagement.riverpod:
        return 'Riverpod providers (flutter_riverpod)';
    }
  }

  static String _stateSpecificDirLabel(StateManagement state) {
    switch (state) {
      case StateManagement.bloc:
        return 'bloc/';
      case StateManagement.getx:
        return 'controller/';
      case StateManagement.riverpod:
        return 'provider/';
    }
  }

  static String _stateSpecificPresentationLabel(StateManagement state) {
    switch (state) {
      case StateManagement.bloc:
        return 'BLoC classes (events, states, bloc)';
      case StateManagement.getx:
        return 'GetX Controllers';
      case StateManagement.riverpod:
        return 'Riverpod Providers / Notifiers';
    }
  }

  static String _stateArchitectureRules(StateManagement state) {
    switch (state) {
      case StateManagement.bloc:
        return '''- Each feature has its own Bloc: `<Feature>Bloc`, `<Feature>Event`, `<Feature>State`
- Blocs live in `presentation/bloc/`
- Blocs call use cases, never repositories directly
- Use `BlocProvider` at the route level
- State classes extend `Equatable` for comparison''';
      case StateManagement.getx:
        return '''- Each feature has a `<Feature>Controller` extending `GetxController`
- Controllers live in `presentation/controller/`
- Controllers call use cases, never repositories directly
- Use `Get.lazyPut` for controller registration
- Reactive state via `.obs` variables''';
      case StateManagement.riverpod:
        return '''- Each feature has a `<Feature>Provider` or `<Feature>Notifier`
- Providers live in `presentation/provider/`
- Providers call use cases, never repositories directly
- Use `ref.read` in event handlers, `ref.watch` in build methods
- State classes extend `Equatable` for comparison''';
    }
  }

  static String _stateCodingRules(StateManagement state) {
    switch (state) {
      case StateManagement.bloc:
        return '''- Create a Bloc per feature: `<Feature>Bloc` with `<Feature>Event` and `<Feature>State`
- Emit new states instead of mutating existing ones
- Use `BlocConsumer` for combined listen + build
- Use `BlocListener` for side effects (navigation, snackbars)
- Bloc files go in `presentation/bloc/`''';
      case StateManagement.getx:
        return '''- Create one Controller per screen/feature: `<Feature>Controller`
- Use `.obs` for reactive state variables
- Register controllers with `Get.lazyPut(() => Controller())`
- Use `Obx(()=> ...)` or `GetX<Controller>` for reactive widgets
- Controller files go in `presentation/controller/`''';
      case StateManagement.riverpod:
        return '''- Use `StateNotifierProvider` or `AsyncNotifierProvider` for async state
- Keep providers small and focused on one responsibility
- Use `ref.watch` in `build()`, `ref.read` in callbacks
- Override providers in tests for clean unit testing
- Provider files go in `presentation/provider/`''';
    }
  }
}
