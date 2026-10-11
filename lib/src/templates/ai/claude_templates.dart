import '../../state_management.dart';

class ClaudeTemplates {
  static String claudeMd(
    String projectName,
    StateManagement state, [
    NetworkClient network = NetworkClient.dio,
  ]) => '''
# CLAUDE.md — ARCLE Project Instructions

This file is read by Claude Code automatically when working in this project.

## Project Overview

**$projectName** is a Flutter application built with ARCLE CLI following Clean Architecture.

- **State Management**: ${state.label}
- **Architecture**: Clean Architecture (data / domain / presentation)
- **Routing**: Named route handler
- **API**: ${network.isHttp ? 'HTTP client' : 'Dio client'} with error/response handlers

## Key Commands

```bash
# Run the app
flutter run

# Add a new feature
arcle feature <name>

# Run all checks
arcle verify --full

# Build release APK
arcle build apk --release

# Add a locale
arcle add locale <code>
```

## Architecture Rules

Read `.ai/architecture-rules.md` before making changes to the layer structure.

## Coding Rules

Read `.ai/coding-rules.md` for naming conventions and standards.

## Security Rules

Read `.ai/security-rules.md` before handling tokens, secrets, or user data.

## Work Tracking

After finishing any unit of work (a feature, a bug fix, a refactor), log it:

```bash
arcle history add --summary "<what changed>" --agent claude
# or, when the work is scoped to one feature:
arcle history add --feature <feature_name> --summary "<what changed>" --agent claude
```

This appends a row to root `docs/HISTORY.md` and, with `--feature`, to
`lib/features/<feature_name>/docs/<feature_name>_history.md` as well — so the
user can see full project history at the root and per-feature history inside
each feature module. Check `docs/PLAN.md` (and the feature's own
`<feature_name>_plan.md`/`<feature_name>_history.md` under its `docs/`
folder) for context before starting new work.

## Do Not

- ❌ Add hardcoded API keys or secrets to source files
- ❌ Import data layer from presentation layer
- ❌ Use `print()` — use Logger utility
- ❌ Hardcode pixel values — use `Dimensions` utility
- ❌ Delete files without confirmation

## Preferences

- Use single quotes for strings
- Use `const` constructors wherever possible
- Use trailing commas in multi-line expressions
- Use package imports (`package:<app>/...`), not relative `../` for cross-feature imports
''';

  static String claudeSettings() => r'''
{
  "permissions": {
    "allow": [
      "Read(**)",
      "Edit(**)",
      "Write(**)",
      "Bash(flutter analyze)",
      "Bash(flutter pub get)",
      "Bash(dart format .)",
      "Bash(flutter test)",
      "Bash(arcle history add*)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force)"
    ]
  }
}
''';
}
