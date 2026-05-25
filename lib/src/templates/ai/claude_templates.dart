import '../../state_management.dart';

class ClaudeTemplates {
  static String claudeMd(String projectName, StateManagement state) => '''
# CLAUDE.md — ARCLE Project Instructions

This file is read by Claude Code automatically when working in this project.

## Project Overview

**$projectName** is a Flutter application built with ARCLE CLI following Clean Architecture.

- **State Management**: ${state.label}
- **Architecture**: Clean Architecture (data / domain / presentation)
- **Routing**: Named route handler
- **API**: Dio client with interceptors

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
      "Bash(flutter test)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force)"
    ]
  }
}
''';
}
