import 'package:arcle/arcle.dart';

/// Example demonstrating how to use the Arcle CLI
///
/// Arcle is a Flutter CLI tool that scaffolds Clean Architecture projects
/// with support for BLoC, GetX, or Riverpod state management.
void main(List<String> args) async {
  // Initialize and run the Arcle CLI
  final arcle = Arcle();
  await arcle.run(args);
}

/// Usage examples:
///
/// 1. Initialize a new project with Clean Architecture:
///    ```bash
///    arcle init -n my_app -s bloc
///    ```
///
/// 2. Create a new feature:
///    ```bash
///    arcle feature -n home -s bloc
///    ```
///
/// 3. Generate DI (Dependency Injection):
///    ```bash
///    arcle gen_di
///    ```
///
/// 4. Build the project with code generation:
///    ```bash
///    arcle build
///    ```
///
/// 5. Generate documentation:
///    ```bash
///    arcle gen_doc
///    ```
///
/// For more information about the available commands and options,
/// run: arcle --help
