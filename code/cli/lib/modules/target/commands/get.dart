/// `ape target get` — deploys APE agents and skills to all targets.
///
/// Idempotent: cleans existing files before deploying (D18).
library;

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';

import '../../../targets/deployer.dart';

// ─── Input ──────────────────────────────────────────────────────────────────

class TargetGetInput extends Input {
  TargetGetInput();

  factory TargetGetInput.fromCliRequest(CliRequest req) => TargetGetInput();

  @override
  Map<String, dynamic> toJson() => {};
}

// ─── Output ─────────────────────────────────────────────────────────────────

class TargetGetOutput extends Output {
  final String message;

  TargetGetOutput({required this.message});

  @override
  Map<String, dynamic> toJson() => {'message': message};

  @override
  int get exitCode => ExitCode.ok;
}

// ─── Command ────────────────────────────────────────────────────────────────

class TargetGetCommand implements Command<TargetGetInput, TargetGetOutput> {
  @override
  final TargetGetInput input;
  final TargetDeployer deployer;

  TargetGetCommand(this.input, {required this.deployer});

  @override
  String? validate() => null;

  @override
  Future<TargetGetOutput> execute() async {
    deployer.deploy();
    return TargetGetOutput(message: 'APE deployed to Github Copilot');
  }
}
