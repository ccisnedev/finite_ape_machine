/// `ape uninstall` — removes APE CLI from the system.
///
/// 1. Cleans all deployed targets (agents + skills).
/// 2. Removes ape\bin\ from the user PATH.
/// 3. Spawns a background process to delete the install directory.
library;

import 'dart:io';

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;

import '../../../targets/deployer.dart';
import '../../../targets/platform_ops.dart';

// ─── Input ──────────────────────────────────────────────────────────────────

class UninstallInput extends Input {
  final String installDir;

  UninstallInput({required this.installDir});

  factory UninstallInput.fromCliRequest(CliRequest req) {
    final installDir = p.dirname(p.dirname(Platform.resolvedExecutable));
    return UninstallInput(installDir: installDir);
  }

  @override
  Map<String, dynamic> toJson() => {'installDir': installDir};
}

// ─── Output ─────────────────────────────────────────────────────────────────

class UninstallOutput extends Output {
  final String message;

  UninstallOutput({required this.message});

  @override
  Map<String, dynamic> toJson() => {'message': message};

  @override
  int get exitCode => ExitCode.ok;
}

// ─── Command ────────────────────────────────────────────────────────────────

class UninstallCommand implements Command<UninstallInput, UninstallOutput> {
  @override
  final UninstallInput input;
  final TargetDeployer deployer;
  final PlatformOps platformOps;

  UninstallCommand(
    this.input, {
    required this.deployer,
    PlatformOps? platformOps,
  }) : platformOps = platformOps ?? PlatformOps.current();

  @override
  String? validate() => null;

  @override
  Future<UninstallOutput> execute() async {
    // 1. Clean all targets
    deployer.clean();

    // 2. Remove ape\bin\ from user PATH (via PlatformOps)
    _removeFromPath(p.join(input.installDir, 'bin'));

    // 3. Spawn background process to delete install directory
    platformOps.scheduleDeletion(input.installDir);

    return UninstallOutput(
      message: 'APE uninstalled. Restart your terminal to apply PATH changes.',
    );
  }

  void _removeFromPath(String binDir) {
    final userPath = platformOps.getEnvVariable('PATH') ?? '';
    final parts = userPath
        .split(Platform.isWindows ? ';' : ':')
        .where((p) => p.isNotEmpty)
        .where((p) => !_pathEquals(p, binDir))
        .toList();
    final newPath = parts.join(Platform.isWindows ? ';' : ':');

    if (newPath != userPath) {
      platformOps.setEnvVariable('PATH', newPath);
    }
  }

  bool _pathEquals(String a, String b) =>
      p.normalize(a).toLowerCase() == p.normalize(b).toLowerCase();
}
