class ReadmeTemplates {
  static String coreReadme() => '''
# Core

This folder is shared across all features.

- Keep logic here framework-agnostic.
- Keep third-party packages at the edge.
- Each file includes guidance comments to reduce boilerplate.
''';

  static String commonWidgetsReadme() => '''
# Common Widgets

Place shared widgets here (buttons, loaders, error views).
Keep them dumb and reusable.
''';
}
