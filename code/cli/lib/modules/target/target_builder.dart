import 'package:modular_cli_sdk/modular_cli_sdk.dart';

import '../../targets/deployer.dart';
import 'commands/clean.dart';
import 'commands/get.dart';

void buildTargetModule(
  ModuleBuilder m, {
  required TargetDeployer deployer,
  required TargetDeployer cleaner,
}) {
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
}
