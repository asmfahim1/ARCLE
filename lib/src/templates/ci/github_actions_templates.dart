class GithubActionsTemplates {
  GithubActionsTemplates._();

  static String workflow({
    required String branch,
    required bool runTest,
    required bool runCoverage,
    required String build,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('name: CI');
    buffer.writeln();
    buffer.writeln('on:');
    buffer.writeln('  push:');
    buffer.writeln('    branches: [ $branch ]');
    buffer.writeln('  pull_request:');
    buffer.writeln('    branches: [ $branch ]');
    buffer.writeln();
    buffer.writeln('jobs:');
    buffer.writeln('  analyze:');
    buffer.writeln('    runs-on: ubuntu-latest');
    buffer.writeln('    steps:');
    buffer.writeln('      - uses: actions/checkout@v4');
    buffer.writeln('      - uses: subosito/flutter-action@v2');
    buffer.writeln('        with:');
    buffer.writeln("          channel: 'stable'");
    buffer.writeln('      - run: flutter pub get');
    buffer.writeln('      - run: dart analyze');
    buffer.writeln(
      '      - run: dart format --output=none --set-exit-if-changed .',
    );

    if (runTest || runCoverage) {
      buffer.writeln();
      buffer.writeln('  test:');
      buffer.writeln('    needs: analyze');
      buffer.writeln('    runs-on: ubuntu-latest');
      buffer.writeln('    steps:');
      buffer.writeln('      - uses: actions/checkout@v4');
      buffer.writeln('      - uses: subosito/flutter-action@v2');
      buffer.writeln('        with:');
      buffer.writeln("          channel: 'stable'");
      buffer.writeln('      - run: flutter pub get');
      buffer.writeln(
        runCoverage
            ? '      - run: flutter test --coverage'
            : '      - run: flutter test',
      );
      if (runCoverage) {
        buffer.writeln('      - uses: actions/upload-artifact@v4');
        buffer.writeln('        with:');
        buffer.writeln('          name: coverage-report');
        buffer.writeln('          path: coverage/lcov.info');
      }
    }

    if (build != 'none') {
      final needs = runTest || runCoverage ? 'test' : 'analyze';
      final buildCmd =
          build == 'appbundle'
              ? 'flutter build appbundle --release'
              : 'flutter build apk --release';
      final artifactPath =
          build == 'appbundle'
              ? 'build/app/outputs/bundle/release/app-release.aab'
              : 'build/app/outputs/flutter-apk/app-release.apk';

      buffer.writeln();
      buffer.writeln('  build:');
      buffer.writeln('    needs: $needs');
      buffer.writeln('    runs-on: ubuntu-latest');
      buffer.writeln('    steps:');
      buffer.writeln('      - uses: actions/checkout@v4');
      buffer.writeln('      - uses: subosito/flutter-action@v2');
      buffer.writeln('        with:');
      buffer.writeln("          channel: 'stable'");
      buffer.writeln('      - run: flutter pub get');
      buffer.writeln('      - run: $buildCmd');
      buffer.writeln('      - uses: actions/upload-artifact@v4');
      buffer.writeln('        with:');
      buffer.writeln('          name: $build');
      buffer.writeln('          path: $artifactPath');
    }

    return buffer.toString();
  }
}
