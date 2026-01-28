class ReadmeTemplates {
  static String coreReadme() => '''
# Core

This folder is shared across all features.

- Keep logic here framework-agnostic.
- Keep third-party packages at the edge.
- Each file includes guidance comments to reduce boilerplate.
''';

  static String featuresReadme() => '''
# Features

Create each feature with `data`, `domain`, and `presentation` layers.

Example:
- features/demo/data
- features/demo/domain
- features/demo/presentation
- features/your_feature/data
- features/your_feature/domain
- features/your_feature/presentation
''';

  static String commonWidgetsReadme() => '''
# Common Widgets

Place shared widgets here (buttons, loaders, error views).
Keep them dumb and reusable.
''';
}
