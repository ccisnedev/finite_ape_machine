/// Public API for the `inquiry` CLI.
///
/// [runInquiry] is the single entry point — called by `bin/main.dart` and by tests.
library;

import 'dart:io';

import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;

import 'assets.dart';
import 'modules/global/global_builder.dart';
import 'modules/state/state_builder.dart';
import 'modules/target/target_builder.dart';
import 'targets/all_adapters.dart';
import 'targets/deployer.dart';

/// Configures the CLI, registers all commands, and dispatches [args].
///
/// Returns a process exit code.
Future<int> runInquiry(List<String> args) async {
  final cli = ModularCli();

  final deployer = TargetDeployer(
    assets: Assets(root: p.dirname(p.dirname(Platform.resolvedExecutable))),
    adapters: deployAdapters,
    homeDir:
        Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        '',
  );

  final cleaner = TargetDeployer(
    assets: Assets(root: p.dirname(p.dirname(Platform.resolvedExecutable))),
    adapters: allAdapters,
    homeDir:
        Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        '',
  );

  cli.module('', (m) => buildGlobalModule(m, cleaner: cleaner));
  cli.module('target', (m) => buildTargetModule(m, deployer: deployer, cleaner: cleaner));
  cli.module('state', (m) => buildStateModule(m));

  return cli.run(args);
}
