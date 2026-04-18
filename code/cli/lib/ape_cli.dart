/// Public API for the `ape` CLI.
///
/// [runApe] is the single entry point — called by `bin/main.dart` and by tests.
library;

import 'dart:io';

import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;

import 'assets.dart';
import 'commands/doctor.dart';
import 'commands/init.dart';
import 'commands/target_clean.dart';
import 'commands/target_get.dart';
import 'commands/tui.dart';
import 'commands/uninstall.dart';
import 'commands/upgrade.dart';
import 'commands/version.dart';
import 'targets/all_adapters.dart';
import 'targets/deployer.dart';

/// Configures the CLI, registers all commands, and dispatches [args].
///
/// Returns a process exit code.
Future<int> runApe(List<String> args) async {
  final cli = ModularCli();

  // TUI: Display FSM diagram when invoked without arguments.
  // Must be registered first to catch empty route.
  cli.command<TuiInput, TuiOutput>(
    '',
    (req) => TuiCommand(TuiInput.fromCliRequest(req)),
    description: 'Display APE status and FSM diagram',
  );

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

  cli.command<DoctorInput, DoctorOutput>(
    'doctor',
    (req) => DoctorCommand(DoctorInput.fromCliRequest(req)),
    description: 'Verify prerequisites (ape, git, gh, gh auth, gh copilot)',
  );

  cli.command<UpgradeInput, UpgradeOutput>(
    'upgrade',
    (req) => UpgradeCommand(UpgradeInput.fromCliRequest(req)),
    description: 'Download and install the latest APE release',
  );

  final deployer = TargetDeployer(
    assets: Assets(
      root: p.dirname(p.dirname(Platform.resolvedExecutable)),
    ),
    adapters: deployAdapters,
    homeDir: Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        '',
  );

  final cleaner = TargetDeployer(
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
      description: 'Deploy APE agents and skills to Copilot',
    );
    m.command<TargetCleanInput, TargetCleanOutput>(
      'clean',
      (req) => TargetCleanCommand(
        TargetCleanInput.fromCliRequest(req),
        deployer: cleaner,
      ),
      description: 'Remove deployed APE files from all targets',
    );
  });

  cli.command<UninstallInput, UninstallOutput>(
    'uninstall',
    (req) => UninstallCommand(
      UninstallInput.fromCliRequest(req),
      deployer: cleaner,
    ),
    description: 'Remove APE CLI from the system',
  );

  return cli.run(args);
}
