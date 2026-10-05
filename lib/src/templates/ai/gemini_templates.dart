import '../../state_management.dart';

class GeminiTemplates {
  static String geminiMd(String projectName, StateManagement state) => '''
# GEMINI.md — Project Context for Gemini

This file provides Gemini with context about the Flutter project structure.

## Project: $projectName

Built with ARCLE CLI. Uses Clean Architecture with ${state.label}.

## File Structure

```
lib/
├── app/
├── core/         ← shared infrastructure
└── features/     ← feature modules (data/domain/presentation)
```

## Important Rules

- Follow Clean Architecture layer boundaries
- Use Dimensions utility for all UI sizing
- No secrets in source code
- Use Logger instead of print()
- See .ai/ directory for full rules

## Work Tracking

After finishing any unit of work, log it:

```bash
arcle history add --summary "<what changed>" --agent gemini
# or, when the work is scoped to one feature:
arcle history add --feature <feature_name> --summary "<what changed>" --agent gemini
```

This updates root `docs/HISTORY.md` and, with `--feature`, the feature's own
`lib/features/<feature_name>/docs/<feature_name>_history.md`. Check
`docs/PLAN.md` for project context before starting new work.
''';

  static String geminiSettings(StateManagement state) => r'''
{
  "model": {
    "name": "gemini-3.5-flash"
  },
  "context_files": [
    ".ai/settings.yaml",
    ".ai/project-context.md",
    ".ai/architecture-rules.md",
    ".ai/coding-rules.md",
    ".ai/security-rules.md"
  ]
}
''';
}
