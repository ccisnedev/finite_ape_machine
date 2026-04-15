/// Public API for the `ape` CLI.
///
/// [runApe] is the single entry point — called by `bin/main.dart` and by tests.
library;

import 'package:modular_cli_sdk/modular_cli_sdk.dart';

/// Configures the CLI, registers all commands, and dispatches [args].
///
/// Returns a process exit code.
Future<int> runApe(List<String> args) async {
  final cli = ModularCli();

  return cli.run(args);
}
