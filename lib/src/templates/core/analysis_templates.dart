class AnalysisTemplates {
  static String analysisOptions() => '''
# Flutter analysis configuration for production-grade apps.
#
# Quick usage:
# - Static analysis: `flutter analyze`
# - Auto-fix safe lints: `dart fix --apply`
# - Format: `dart format .`
#
# Notes:
# - Prefer fixing warnings instead of suppressing them.
# - Keep generated files excluded to reduce noise.
# - Tighten rules gradually if you are migrating a legacy codebase.

include: package:flutter_lints/flutter.yaml

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/*.mocks.dart"
    - "**/*.gen.dart"
    - "**/generated_plugin_registrant.dart"
    - "build/**"
    - ".dart_tool/**"

linter:
  rules:
    # API design and readability
    always_declare_return_types: true
    avoid_types_as_parameter_names: true
    directives_ordering: true
    prefer_relative_imports: true
    require_trailing_commas: true
    sort_constructors_first: true

    # Safety and correctness
    avoid_print: true
    avoid_void_async: true
    cancel_subscriptions: true
    close_sinks: true
    no_logic_in_create_state: true
    unawaited_futures: true
    use_build_context_synchronously: true
    use_key_in_widget_constructors: true

    # Performance and immutability
    prefer_const_constructors: true
    prefer_const_constructors_in_immutables: true
    prefer_const_declarations: true
    prefer_const_literals_to_create_immutables: true
    prefer_final_fields: true
    prefer_final_locals: true
    sized_box_for_whitespace: true
    use_super_parameters: true
''';
}
