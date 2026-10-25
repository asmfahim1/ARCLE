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

Place shared widgets here (buttons, loaders, text fields, dialogs, etc.).
Keep them dumb and reusable.
All common widgets are connected to `AppColors` (`lib/core/theme_manager/app_colors.dart`), supporting both Light and Dark themes dynamically.
''';
}
