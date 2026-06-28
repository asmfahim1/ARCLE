## 2.1.3

### Changes

- **Removed arrow-key TUI menu** — state management selection reverts to the simple numbered prompt (`1. BLoC / 2. GetX / 3. Riverpod`). The ANSI raw-mode approach caused `StdinException` on Windows terminals and added unnecessary complexity. The `--state` flag continues to work as before for non-interactive use.
- `interactive_menu.dart` removed. `configure-ai` agent selection also uses a numbered prompt.

## 2.1.2

### Documentation

- Updated README to reflect v2.1.x commands — removed unreachable commands, added `arcle configure-ai` and `arcle review` sections, updated "What's New" from 2.0.0 to 2.1.x.

## 2.1.1

### Bug Fixes

- **Fixed crash on Windows when launching the arrow-key state selection menu** — `StdinException: Error setting terminal echo mode` was thrown on certain Windows terminals (cmd.exe, some PowerShell hosts) that report `stdin.hasTerminal = true` but do not support raw mode. Raw-mode setup now happens before any rendering; `StdinException` is caught in `select()` and silently falls back to the numbered list (`1. BLoC / 2. Riverpod / 3. GetX`).

## 2.1.0

### Improvements

- **Decoupled AI scaffolding from `arcle create`** — default project creation now generates only the Flutter Clean Architecture structure. AI agent config (`.ai/`, `.claude/`, `.codex/`, `.gemini/`, `scripts/`) is no longer generated automatically.
- **New command: `arcle configure-ai`** (alias: `arcle agent-init`) — interactive one-question wizard to scaffold AI agent context files for an existing project. Detects state management from `arcle.yaml`; prompts if not found. Supports Claude Code, OpenAI Codex, Google Gemini, or all three.
- **Arrow-key TUI menu for state management selection** — replaced the text-based prompt (typing `bloc`/`getx`/`riverpod`) with an ANSI arrow-key navigable menu. Falls back to a numbered list automatically in CI/CD and non-TTY environments. The `--state` flag still bypasses the menu for scripted use.
- **New command: `arcle review`** (aliases: `arcle audit`, `arcle -r`) — pre-commit quality gate that runs:
  - `dart analyze` — static analysis
  - `dart format --output=none --set-exit-if-changed` — format check
  - Missing-tests scan — checks only files changed in the current git diff; warns on any `lib/` file with no `test/` counterpart
  - `flutter test` (opt-in via `--test`)
  - `flutter test --coverage` with percentage report (opt-in via `--coverage`)
  - AI-assisted diff review via configured agent binary (opt-in via `--ai`)

## 2.0.0

**ARCLE Agentic Flutter Development Platform**

### New Commands

- `arcle agent add <claude|codex|gemini|custom>` — scaffold agent-specific config files (`.claude/`, `.codex/`, `.gemini/`, `.custom-agent/`)
- `arcle agent remove <agent>` — remove an agent configuration directory
- `arcle agent switch <agent>` — set `active_agent` in `.ai/settings.yaml`
- `arcle agent list` — list all configured AI agents in the project
- `arcle agent validate` — validate that all required `.ai/` files exist
- `arcle ai init [--state]` — generate `.ai/` project context & rules directory
- `arcle ai sync` — sync `.ai/settings.yaml` state from `arcle.yaml`
- `arcle ai validate` — check all required `.ai/` config files
- `arcle ai doctor` — diagnose AI configuration health
- `arcle upgrade [--force]` — upgrade an existing ARCLE project to v2.0.0 (SDK, analysis, dimensions, `.ai/`, scripts)

### Project Scaffolding

- New projects now include `.ai/` directory with 6 AI agent context files: `settings.yaml`, `project-context.md`, `architecture-rules.md`, `coding-rules.md`, `security-rules.md`, `permissions.yaml`
- New projects now include Claude Code integration (`.claude/CLAUDE.md`, `.claude/settings.json`)
- New projects now include OpenAI Codex integration (`.codex/instructions.md`, `.codex/settings.json`)
- New projects now include Gemini integration (`.gemini/GEMINI.md`, `.gemini/settings.json`)
- New projects now include `scripts/setup.sh`, `scripts/setup.ps1`, `scripts/doctor.sh`, `scripts/doctor.ps1`

### Breaking Changes

- Replaced `DimensionsTemplates.dimensions(state)` with universal `DimensionsTemplates.dimensions()` — new implementation uses `dart:ui` PlatformDispatcher directly (works for all state management, no GetX dependency)
- Updated `analysis_options.yaml` template: replaced `prefer_relative_imports` with `always_use_package_imports`, added `avoid_unnecessary_containers`, `prefer_single_quotes`, `unnecessary_const`, `unnecessary_new`
- Minimum Dart SDK raised from `^3.5.4` to `>=3.7.0 <4.0.0`

### Improvements

- Generated project `pubspec.yaml` SDK constraint is now automatically set to `>=3.7.0 <4.0.0`
- `buildCommonProjectFiles` now accepts `projectName` parameter for proper AI context generation

## 1.0.4

- Reworked localization management around dedicated top-level commands:
  - `arcle add locale <code>` adds a single locale to the project; on first use it creates the localization infrastructure, and on later calls it appends the locale to the existing setup.
  - `arcle delete locale <code>` removes a single locale's JSON file, updates `supportedLocales` / `isSupported` in `app_strings.dart`, removes the GetX locale section when applicable, and cleans the `assets/langs/` pubspec entry when the last locale is removed.
- Added localization command aliases: `arcle add loc <code>`, `arcle delete loc <code>`, `arcle del locale <code>`, and `arcle del loc --<code>`.
- Added `--<code>` flag shorthand for locale commands such as `arcle add loc --my` and `arcle del loc --my`.
- `add locale` now supports any ISO 639-1 locale code, with built-in country-code mappings for 60+ languages; unknown locales receive English-value placeholder JSON so the app stays runnable while translations are filled in.
- Updated localization injection so feature keys are added to every JSON file under `assets/langs/` and every `// arcle:keys_*` marker in `getx_localization.dart`.
- Added `arcle verify --check-features` to scan every module under `lib/features/` and report missing data, domain, or presentation layer files for the project's state management.
- Added `arcle verify --check-assets` to verify that every asset path declared in `pubspec.yaml` exists on disk.
- Added `arcle verify --check-l10n` to verify that each feature has its `{feature}_title` translation key present in `assets/langs/en.json` (BLoC/Riverpod) or `lib/core/localization/getx_localization.dart` (GetX).
- Added `arcle verify --full` to run `--check-features`, `--check-assets`, and `--check-l10n` in a single pass.

## 1.0.3

**Platform Configuration Improvements:**
- **[CRITICAL FIX]** Added automatic iOS Podfile configuration with minimum deployment target of iOS 13.0.
- **[CRITICAL FIX]** Added automatic iOS Info.plist generation with essential permission descriptions (camera, photos, microphone, location, contacts, calendar).
- **[CRITICAL FIX]** Added post-install hooks to Podfile to ensure consistent iOS build settings across all targets.
- **[CRITICAL FIX]** Fixed iOS builds that would previously fail due to missing Info.plist permission descriptions.
- Added automatic iOS deployment target enforcement to prevent compatibility issues.
- Updated iOS configuration to match Android's rigorous platform setup standard.
- Both Android and iOS are now configured equally during project creation for production-ready apps.
- Created comprehensive `PLATFORM_CONFIGURATION_GUIDE.md` with setup details, checklists, and troubleshooting.

**Build & DI Improvements:**
- Added persistent build version updates in `arcle build apk` with `--version-name` and `--version-code`, which rewrite the target project's `pubspec.yaml`.
- Added persistent environment updates in `arcle build apk --env prod|stag|local`, which rewrite the target project's `lib/core/env/env_factory.dart`.
- Added static 16 KB Android APK compatibility checks with `arcle verify --check-16kb`.
- Added separated `gen-di` and `auto-gen-di` commands with clear documentation on when/why to use each.
- Added comprehensive DI_COMMANDS_GUIDE.md explaining command differences and use cases.

**Developer Experience:**
- Added optional short command aliases such as `new`, `feat`, `health`, `autodi`, `di`, `docs`, `ver`, `b`, `br`, and `bd` while keeping all existing commands unchanged.
- Platform configuration status now shown during project creation (Android & iOS setup feedback).

## 1.0.2

- Added `doctor` command for ARCLE project health checks.
- Added `doctor --fix` for safe ARCLE-owned repairs.
- Added `verify` command to run analyze, test, and BLoC codegen verification.
- Added generated `core/utils/date_formatter.dart` with UTC/local conversion and UX-friendly date helpers.
- Added automatic `intl` dependency injection to generated projects.
- Updated generated notification service to be platform-safe across Android, iOS, macOS, and unsupported platforms.
- Updated generated permission service to use platform-aware permission handling and safe fallbacks.
- Updated README with platform notes for Android, iOS, macOS, and web behavior.
- Removed generated `lib/features/README.md` from new projects across all state management options.

## 1.0.1

- Fixed pubspec description length.
- Added usage example.
