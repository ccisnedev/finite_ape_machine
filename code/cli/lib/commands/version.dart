/// `ape version` — prints the current CLI version.
library;

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';

const String apeVersion = '0.0.6';

// ─── Input ──────────────────────────────────────────────────────────────────

class VersionInput extends Input {
  VersionInput();

  factory VersionInput.fromCliRequest(CliRequest req) => VersionInput();

  @override
  Map<String, dynamic> toJson() => {};
}

// ─── Output ─────────────────────────────────────────────────────────────────

class VersionOutput extends Output {
  final String version;

  VersionOutput({required this.version});

  @override
  Map<String, dynamic> toJson() => {'version': version};

  @override
  int get exitCode => ExitCode.ok;
}

// ─── Command ────────────────────────────────────────────────────────────────

class VersionCommand implements Command<VersionInput, VersionOutput> {
  @override
  final VersionInput input;

  VersionCommand(this.input);

  @override
  String? validate() => null;

  @override
  Future<VersionOutput> execute() async {
    return VersionOutput(version: apeVersion);
  }
}
