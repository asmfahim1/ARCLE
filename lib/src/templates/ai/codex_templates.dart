import '../../state_management.dart';

class CodexTemplates {
  static String instructionsMd(String projectName, StateManagement state) =>
      '''
# Codex Instructions — $projectName

This file provides context and instructions for OpenAI Codex when working on this project.

## Architecture

Clean Architecture Flutter project using ${state.label} state management.

Layers: data → domain ← presentation

## Standards

- See `.ai/coding-rules.md` for code style
- See `.ai/architecture-rules.md` for layer rules
- See `.ai/security-rules.md` for security requirements

## Constraints

- Do NOT add secrets to source code
- Do NOT cross layer boundaries (e.g., importing data from presentation)
- Use `Dimensions` for all UI sizing
- Use `Logger` instead of `print()`
''';

  static String codexSettings(StateManagement state) => r'''
{
  "model": {
    "name": "gpt-5.6"
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
