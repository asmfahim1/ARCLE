library arcle;

import 'src/cli.dart';

/// Entry point for the Arcle CLI when used as a library.
Future<int> run(List<String> args) => Cli().run(args);
