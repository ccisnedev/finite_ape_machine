/// `ape target clean` — removes deployed APE files from all targets.
library;

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';

import '../../../targets/deployer.dart';

// ─── Input ──────────────────────────────────────────────────────────────────

class TargetCleanInput extends Input {
  TargetCleanInput();

  factory TargetCleanInput.fromCliRequest(CliRequest req) => TargetCleanInput();

  @override
  Map<String, dynamic> toJson() => {};
}

// ─── Output ─────────────────────────────────────────────────────────────────

class TargetCleanOutput extends Output {
  final String message;

  TargetCleanOutput({required this.message});

  @override
  Map<String, dynamic> toJson() => {'message': message};

  @override
  int get exitCode => ExitCode.ok;
}

// ─── Command ────────────────────────────────────────────────────────────────

class TargetCleanCommand
    implements Command<TargetCleanInput, TargetCleanOutput> {
  @override
  final TargetCleanInput input;
  final TargetDeployer deployer;

  TargetCleanCommand(this.input, {required this.deployer});

  @override
  String? validate() => null;

  @override
  Future<TargetCleanOutput> execute() async {
    deployer.clean();
    return TargetCleanOutput(message: 'APE cleaned from all targets');
  }
}
