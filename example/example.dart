import 'package:arcle/arcle.dart';

/// Example demonstrating how to use the Arcle CLI
///
/// Arcle is a Flutter CLI tool that scaffolds Clean Architecture projects
/// with support for BLoC, GetX, or Riverpod state management.
void main(List<String> args) async {
  // Run the Arcle CLI
  await run(args);
}

/// Usage examples:
///
/// 1. Initialize a new project with Clean Architecture:
///    ```bash
///    arcle create my_app --state bloc
///    ```
///
/// 2. Scaffold Clean Architecture in an existing project:
///    ```bash
///    arcle init --state bloc
///    ```
///
/// 3. Create a new feature:
///    ```bash
///    arcle feature home --state bloc
///    ```
///
/// 4. Generate DI (Dependency Injection):
///    ```bash
///    arcle gen-di
///    ```
///
/// 5. Build release APK with security features:
///    ```bash
///    arcle build apk --release
///    ```
///
/// 6. Generate documentation:
///    ```bash
///    arcle gen-doc
///    ```
///
/// For more information about the available commands and options,
/// run: arcle --help
