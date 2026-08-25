class GitlabCiTemplates {
  GitlabCiTemplates._();

  static String pipeline({
    required String branch,
    required bool runTest,
    required bool runCoverage,
    required String build,
  }) {
    final buffer = StringBuffer();
    final stages = [
      'analyze',
      if (runTest || runCoverage) 'test',
      if (build != 'none') 'build',
    ];

    buffer.writeln('image: ghcr.io/cirruslabs/flutter:stable');
    buffer.writeln();
    buffer.writeln('stages:');
    for (final stage in stages) {
      buffer.writeln('  - $stage');
    }
    buffer.writeln();
    buffer.writeln('analyze:');
    buffer.writeln('  stage: analyze');
    buffer.writeln('  script:');
    buffer.writeln('    - flutter pub get');
    buffer.writeln('    - dart analyze');
    buffer.writeln('    - dart format --output=none --set-exit-if-changed .');
    buffer.writeln('  only:');
    buffer.writeln('    - $branch');
    buffer.writeln('    - merge_requests');

    if (runTest || runCoverage) {
      buffer.writeln();
      buffer.writeln('test:');
      buffer.writeln('  stage: test');
      buffer.writeln('  script:');
      buffer.writeln('    - flutter pub get');
      buffer.writeln(
        runCoverage ? '    - flutter test --coverage' : '    - flutter test',
      );
      if (runCoverage) {
        buffer.writeln("  coverage: '/lines\\.*: \\d+\\.\\d+\\%/'");
        buffer.writeln('  artifacts:');
        buffer.writeln('    paths:');
        buffer.writeln('      - coverage/');
      }
      buffer.writeln('  only:');
      buffer.writeln('    - $branch');
      buffer.writeln('    - merge_requests');
    }

    if (build != 'none') {
      final buildCmd =
          build == 'appbundle'
              ? 'flutter build appbundle --release'
              : 'flutter build apk --release';
      final artifactPath =
          build == 'appbundle'
              ? 'build/app/outputs/bundle/release/app-release.aab'
              : 'build/app/outputs/flutter-apk/app-release.apk';

      buffer.writeln();
      buffer.writeln('build_$build:');
      buffer.writeln('  stage: build');
      buffer.writeln('  script:');
      buffer.writeln('    - flutter pub get');
      buffer.writeln('    - $buildCmd');
      buffer.writeln('  artifacts:');
      buffer.writeln('    paths:');
      buffer.writeln('      - $artifactPath');
      buffer.writeln('  only:');
      buffer.writeln('    - $branch');
    }

    return buffer.toString();
  }
}
