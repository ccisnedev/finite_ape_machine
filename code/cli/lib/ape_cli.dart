/// Public API for the `ape` CLI.
///
/// [runApe] is the single entry point — called by `bin/main.dart` and by tests.
library;

import 'dart:io';

import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;

import 'assets.dart';
import 'commands/init.dart';
import 'commands/target_clean.dart';
import 'commands/target_get.dart';
import 'commands/version.dart';
import 'targets/all_adapters.dart';
import 'targets/deployer.dart';

/// Configures the CLI, registers all commands, and dispatches [args].
///
/// Returns a process exit code.
Future<int> runApe(List<String> args) async {
  final cli = ModularCli();

  cli.command<InitInput, InitOutput>(
    'init',
    (req) => InitCommand(InitInput.fromCliRequest(req)),
    description: 'Initialize a new .ape/ workspace',
  );

  cli.command<VersionInput, VersionOutput>(
    'version',
    (req) => VersionCommand(VersionInput.fromCliRequest(req)),
    description: 'Print the current CLI version',
  );

  final deployer = TargetDeployer(
    assets: Assets(
      root: p.dirname(p.dirname(Platform.resolvedExecutable)),
    ),
    adapters: allAdapters,
    homeDir: Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        '',
  );

  cli.module('target', (m) {
    m.command<TargetGetInput, TargetGetOutput>(
      'get',
      (req) => TargetGetCommand(
        TargetGetInput.fromCliRequest(req),
        deployer: deployer,
      ),
      description: 'Deploy APE agents and skills to all targets',
    );
    m.command<TargetCleanInput, TargetCleanOutput>(
      'clean',
      (req) => TargetCleanCommand(
        TargetCleanInput.fromCliRequest(req),
        deployer: deployer,
      ),
      description: 'Remove deployed APE files from all targets',
    );
  });

  return cli.run(args);
}
