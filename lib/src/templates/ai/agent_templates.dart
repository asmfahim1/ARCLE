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
│   ├── network/
│   ├── services/
│   ├── di/
│   ├── env/
│   ├── localization/
│   ├── route_handler/
│   ├── theme_manager/
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

## Mandatory Workflow for AI Agents

Every configured AI agent (Claude, Codex, Gemini) must follow this lifecycle:

1. **Context & Discovery**: Inspect `git status --short --branch`, recent diffs, `docs/PLAN.md`, and recent entries in `docs/HISTORY.md`. Read all applicable rules in `.ai/`.
2. **Task Planning**: Define goal, scope, acceptance criteria, dependencies, and risks. Scale plan depth to task size.
3. **UI & Clean Architecture**: Investigate ARCLE core elements first (`lib/core/common_widgets/`, `theme_manager/`, `utils/`, `localization/`, `services/`). Reuse existing core widgets (`CommonButton`, `CommonTextField`, `CommonDropdown`, `CommonCheckbox`, `CommonLoader`, etc.) before writing custom one-offs. Ask developer permission before adding any external packages. Follow `Dimensions`, `AppColors`, and architectural layer contracts.
4. **Verification**: Run `dart format .`, `flutter analyze`, and `flutter test`. Report checks truthfully as PASS, FAIL, SKIPPED, or NOT RUN. Review final git diff.
5. **Work Tracking**: Log completed work using `arcle history add` (or with `--feature <name>`).
6. **Agent Switching**: Resume from verified state, active plan, and recent history when switching agents.
7. **Completion Report**: Report what changed, reusable findings, verification results, and remaining risks.

See `.ai/coding-rules.md`, `.ai/architecture-rules.md`, and `.ai/security-rules.md` for detailed rules.
''';
  }

  static String architectureRules(StateManagement state) {
    final stateSpecificLabel = _stateSpecificPresentationLabel(state);
    final stateSpecificRules = _stateArchitectureRules(state);
    return '''
# Architecture Rules

## Clean Architecture Layers

### Data Layer
- Contains: Models (`_model.dart`), Remote/Local Data Sources (`_remote_source.dart`), Repository Implementations (`_repository_impl.dart`)
- Can depend on: Domain layer interfaces only
- Must NOT import: Presentation layer

### Domain Layer
- Contains: Entities (`_entity.dart`), Repository Interfaces (`_repository.dart`), Use Cases (`_usecase.dart`)
- Must NOT depend on: Data or Presentation layers
- Pure Dart only — no Flutter imports (except foundational annotations where strictly necessary)

### Presentation Layer
- Contains: Pages (`_screen.dart`), Widgets (`_widget.dart`), $stateSpecificLabel
- Can depend on: Domain layer use cases only
- Must NOT import: Data layer directly (no models or datasources in presentation)

## Core Architectural Contracts

- **Dependency Flow**: `Presentation → Domain ← Data`
- **Focused Use Cases**: One use case class per distinct business operation. Keep business logic in domain use cases, never in widgets or presentation controllers.
- **Model vs Entity Separation**: Data transfer objects / API response models live in `data/model/` and serialize via `fromJson`/`toJson`. Domain entities live in `domain/entity/` and represent core business concepts without serialization baggage.
- **Independent Lifecycles**: Separate screen-level controllers, BLoCs, providers, or notifiers when independent responsibilities and lifecycles justify it.
- **Repository Pattern**: Repository interfaces live in `domain/repository/`, implementations live in `data/repository/`. Return `Either<Failure, T>` using the `Result` type alias. Never throw unhandled exceptions from repositories.

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

- One feature = one directory under `lib/features/`
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

## UI & Design System — Mandatory Core Element Reuse

Before designing or building ANY UI screen, form, card, or component:
1. **Investigate ARCLE Core Elements First**: You MUST inspect `lib/core/` to see what ARCLE provides before writing custom widgets or screen markup from scratch:
   - `lib/core/common_widgets/`: `CommonButton`, `CommonTextField`, `CommonDropdown`, `CommonCheckbox`, `CommonLoader` (circular & shimmer), `CommonImageContainer`, `CommonAppBar`, `CommonBottomSheet`, `CommonDialog`, `CommonSnackbar`, `PaginatedListView`, and `SvgIcon`.
   - `lib/core/theme_manager/`: `AppColors` (semantic & dynamic theme helpers), `Dimensions` (responsive sizing & spacing), and `AppTheme`.
   - `lib/core/localization/`: Localization extension (`context.tr('key')` / `AppLocalizations`) and JSON translation keys.
   - `lib/core/utils/`: `AppValidators` for form validation, `AppDialogs` for user feedback, helpers, and formatters.
   - `lib/core/services/`: `PrefManager` and `SessionManager` for persistence and session state.
2. **Reuse Before Creating (Example: Forms & Screens)**:
   - When asked to create a screen (such as a login screen with dropdown, textfields, remember-me checkbox, and login button), you MUST check `lib/core/common_widgets/` first and use `CommonDropdown`, `CommonTextField`, `CommonCheckbox`, `CommonButton`, and `CommonLoader` instead of writing raw `DropdownButton`, `TextField`, `Checkbox`, `ElevatedButton`, or creating custom one-offs.
   - If existing core elements can fulfill the design requirement, ALWAYS use them.
3. **Permission Gate for New External Packages**:
   - If the developer's design requirement genuinely cannot be fulfilled by ARCLE's existing core elements and requires a third-party package or new library:
     - DO NOT unilaterally add dependencies to `pubspec.yaml`.
     - You MUST ask the developer for explicit permission first, explaining why the package is needed and confirming it is secure, well-maintained, and minimal.
     - Only after the developer grants permission may you import the package and proceed with the commanded design.
4. **Dimensions Utility**: ALWAYS use the project's `Dimensions` utility (`Dimensions.height()`, `Dimensions.width()`, `Dimensions.radius()`, `Dimensions.font()`, `Dimensions.allPadding()`, etc.) for all UI sizing, padding, margin, font sizes, and radii. NEVER hardcode raw pixel values.
5. **AppColors & Themes**: ALWAYS use `AppColors` and dynamic theme helpers (`AppColors.primary(context)`, `AppColors.surface(context)`, `AppColors.textPrimary(context)`, etc.). Never scatter hardcoded Color values across widgets.
6. **Figma & Visual References**: Match layout, dimensions, typography, spacing, colors, and component states. Compare results against references and disclose any unresolved differences. Never claim pixel-perfect accuracy without actual comparison.

## Screen Componentization Rule (Mandatory)

A `_screen.dart` file must stay thin and declarative:
1. **One class per screen**: the screen's `build()` method must only compose named sub-widgets (`SomeSection(...)`, `SomeCard(...)`) — it must NOT contain large inline widget trees, private `_buildX()` helper methods, or multi-level nested `Column`/`Row`/`ListView` blocks.
2. **Extract sub-widgets**: any widget-returning piece used only by that screen goes into its own class under that feature's `presentation/widgets/<name>_widget.dart` (or `_card.dart`), never left inline in the screen file.
3. **Extract enums/constants**: any screen-specific enum, constant, or static lookup table goes under that feature's `presentation/resources/`, never declared inside the screen file.
4. **Extract logic**: formatting, mapping, filtering, or any non-trivial computation goes into the `<Feature>Controller` (or a `presentation/utils/` helper for pure UI-only logic) — the screen only calls it, never implements it inline.
5. When asked to "create a new screen," check `presentation/widgets/`, `presentation/resources/`, and the controller first for reusable pieces before writing new ones, and place any new reusable piece in those folders rather than inside the screen class.


## Widget Rules

- All widgets must have a `key` parameter in the constructor
- Use `super.key` via super parameters
- Avoid unnecessary `Container` wrappers — use `SizedBox`, `Padding`, `ColoredBox`

## Verification & Quality Standards

- Before completing any task, run:
  1. `dart format .`
  2. `flutter analyze`
  3. `flutter test`
- Report each verification check as `PASS`, `FAIL`, `SKIPPED`, or `NOT RUN`. Never claim a check passed without executing it.
- Inspect the final `git diff` for accidental changes or generated-file churn.

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
