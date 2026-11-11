import '../../state_management.dart';

class CodexTemplates {
  /// Primary instruction generator for OpenAI Codex (.codex/CODEX.md).
  static String codexMd(String projectName, StateManagement state) => '''
# CODEX.md — Mandatory ARCLE Development Workflow Rules

This file is the mandatory entry point for OpenAI Codex in **$projectName**.
Before starting any task-specific investigation or code modifications, you MUST read this file and the applicable shared rules in `.ai/`.

## 1. Mandatory Shared Rule Loading

Before any task-specific work:
1. Read `.ai/project-context.md` for architecture overview, layer boundaries, and directory layout.
2. Read `.ai/architecture-rules.md` for layer contracts, dependency flow, and state management rules.
3. Read `.ai/coding-rules.md` for code style, widget design, and design system standards.
4. Read `.ai/security-rules.md` for secrets, tokens, and input validation.

If any of these rule files are missing, run `arcle ai init` or `arcle configure-ai` to restore them, and report the missing files to the user before proceeding.

## 2. Project Discovery & Context

Before making any changes:
- Inspect `git status --short --branch` and recent diffs.
- Preserve all existing user modifications.
- Inspect `docs/PLAN.md` and recent entries in `docs/HISTORY.md` (and feature-level `lib/features/<feature_name>/docs/` if working on a specific feature).
- Identify the project's actual state management (${state.label}), routing, DI, and conventions before editing.
- Verify files, APIs, commands, and packages before relying on them.

## 3. Task Planning

- Identify the task goal, scope, acceptance criteria, dependencies, and material risks.
- Record any supplied Jira or task ID; never invent task IDs or claim unperformed actions.
- Plan before implementation: scale planning depth to task complexity (Small, Normal, Complex).
- Update the plan if the implementation reveals scope or architectural changes.
- Resume from verified state when continuing work across sessions or agents.

## 4. UI & Design System — Mandatory Core Element Reuse

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
4. **Dimensions & Theme Tokens**:
   - ALWAYS use `Dimensions` (`Dimensions.height()`, `Dimensions.width()`, `Dimensions.radius()`, `Dimensions.font()`, `Dimensions.allPadding()`, etc.) for all measurements, margins, padding, and font sizes. NEVER hardcode raw numeric pixel values.
   - ALWAYS use `AppColors` and dynamic theme helpers (`AppColors.primary(context)`, `AppColors.surface(context)`, etc.). Never scatter hardcoded Color values across widgets.
5. **Figma & Visual References**: Match layout, dimensions, typography, spacing, colors, and component states. Compare results against references and disclose any unresolved differences. Never claim pixel-perfect accuracy without actual comparison.

## 5. Clean Architecture Standards

- Strictly enforce layer boundaries: `Presentation → Domain ← Data`.
- **Data Layer**: Models (`_model.dart`), sources (`_remote_source.dart`), and repository implementations (`_repository_impl.dart`). Can only depend on Domain interfaces. Must NEVER import Presentation.
- **Domain Layer**: Pure Dart only. Entities (`_entity.dart`), repository interfaces (`_repository.dart`), use cases (`_usecase.dart`). Must NEVER depend on Data or Presentation layers.
- **Presentation Layer**: Pages, widgets, and state holders (${state.label}). Can only depend on Domain use cases. Must NEVER import Data layer directly.
- Use focused use cases for distinct business operations. Separate screen-level controllers/blocs/providers when independent lifecycles justify it.
- Keep API response models separate from domain entities.
- Follow existing dependency injection, routing, repository, mapping, and error-handling conventions.

## 6. Coding & Security Standards

- Use the project `Logger` utility — NEVER use `print()`.
- Use `const` constructors wherever possible, `final` for immutable bindings, and single quotes for strings.
- Use `package:` imports everywhere; never use relative `../` imports across features.
- NEVER hardcode API keys, secrets, tokens, or credentials in source code or logs.
- Store tokens exclusively in `SessionManager`.
- Validate user inputs using `AppValidators`.
- Make the smallest complete change that satisfies the acceptance criteria.

## 7. Verification

Before declaring any task complete:
- Run formatting: `dart format .`
- Run static analysis: `flutter analyze`
- Run unit and widget tests: `flutter test`
- Report each check as `PASS`, `FAIL`, `SKIPPED`, or `NOT RUN` with actual results. Never claim a check passed without executing it.
- Review the final Git diff (`git diff`) for unintended changes or generated-file churn.

## 8. Work Tracking & History

After finishing any unit of work (feature, fix, refactor):
```bash
arcle history add --summary "<what changed>" --agent codex
# or for a feature-scoped change:
arcle history add --feature <feature_name> --summary "<what changed>" --agent codex
```
- Record actual timestamps and duration only when reliable timing is available.
- Never invent timestamps, duration, or token usage metrics.
- Keep `docs/PLAN.md` and `docs/HISTORY.md` updated.

## 9. Agent Switching & Continuation

- When continuing work started by another agent (Claude, Gemini, or Codex), inspect the active plan, recent history entries, Git status, and remaining acceptance criteria before resuming.
- Resume from the verified state rather than repeating already resolved investigations.

## 10. Completion Report

Concisely report:
1. What changed and affected files
2. Decisions and reusable findings
3. Verification results (`PASS`/`FAIL`/`SKIPPED`/`NOT RUN`)
4. Plan, history, and documentation files updated
5. Any remaining risks, blockers, or unverified runtime behavior
''';

  /// Legacy alias for backward compatibility.
  static String instructionsMd(String projectName, StateManagement state) =>
      codexMd(projectName, state);

  static String codexSettings(StateManagement state) => r'''
{
  "model": {
    "name": "gpt-5.6"
  },
  "context_files": [
    ".codex/CODEX.md",
    ".ai/settings.yaml",
    ".ai/project-context.md",
    ".ai/architecture-rules.md",
    ".ai/coding-rules.md",
    ".ai/security-rules.md"
  ]
}
''';
}
