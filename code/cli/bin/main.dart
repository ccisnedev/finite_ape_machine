/// Entry point for the `ape` CLI.
///
/// Delegates immediately to [runApe] to keep the binary thin and testable.
library;

import 'dart:io';

import 'package:ape_cli/ape_cli.dart';

Future<void> main(List<String> args) async {
  final code = await runApe(args);
  exit(code);
}
