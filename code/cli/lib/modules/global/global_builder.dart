import 'package:modular_cli_sdk/modular_cli_sdk.dart';

import '../../assets.dart';
import 'commands/doctor.dart';
import 'commands/init.dart';
import 'commands/tui.dart';
import 'commands/uninstall.dart';
import 'commands/upgrade.dart';
import 'commands/version.dart';
import '../../targets/deployer.dart';

void buildGlobalModule(
  ModuleBuilder m, {
  required TargetDeployer cleaner,
  Assets? assets,
}) {
  m.command<TuiInput, TuiOutput>(
    '',
    (req) => TuiCommand(TuiInput.fromCliRequest(req)),
    description: 'Display Inquiry status and FSM diagram',
  );

  m.command<InitInput, InitOutput>(
    'init',
    (req) => InitCommand(InitInput.fromCliRequest(req)),
    description: 'Initialize a new .inquiry/ workspace',
  );

  m.command<VersionInput, VersionOutput>(
    'version',
    (req) => VersionCommand(VersionInput.fromCliRequest(req)),
    description: 'Print the current CLI version',
  );

  m.command<DoctorInput, DoctorOutput>(
    'doctor',
    (req) => DoctorCommand(DoctorInput.fromCliRequest(req), assets: assets),
    description: 'Verify prerequisites (inquiry, git, gh, gh auth, gh copilot)',
  );

  m.command<UpgradeInput, UpgradeOutput>(
    'upgrade',
    (req) => UpgradeCommand(UpgradeInput.fromCliRequest(req)),
    description: 'Download and install the latest Inquiry release',
  );

  m.command<UninstallInput, UninstallOutput>(
    'uninstall',
    (req) => UninstallCommand(
      UninstallInput.fromCliRequest(req),
      deployer: cleaner,
    ),
    description: 'Remove Inquiry CLI from the system',
  );
}
