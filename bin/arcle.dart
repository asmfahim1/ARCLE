import 'dart:io';

import 'package:arcle/arcle.dart';

Future<void> main(List<String> args) async {
  final code = await run(args);
  exit(code);
}
