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

import '../targets/deployer.dart';

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

  UninstallCommand(this.input, {required this.deployer});

  @override
  String? validate() => null;

  @override
  Future<UninstallOutput> execute() async {
    // 1. Clean all targets
    deployer.clean();

    // 2. Remove ape\bin\ from user PATH
    _removeFromPath(p.join(input.installDir, 'bin'));

    // 3. Spawn background process to delete install directory
    _scheduleDirectoryDeletion(input.installDir);

    return UninstallOutput(
      message: 'APE uninstalled. Restart your terminal to apply PATH changes.',
    );
  }

  void _removeFromPath(String binDir) {
    final userPath = _getEnvironmentVariable('PATH', 'User') ?? '';
    final parts = userPath
        .split(';')
        .where((p) => p.isNotEmpty)
        .where((p) => !_pathEquals(p, binDir))
        .toList();
    final newPath = parts.join(';');

    if (newPath != userPath) {
      _setEnvironmentVariable('PATH', newPath, 'User');
    }
  }

  void _scheduleDirectoryDeletion(String dir) {
    // Rename the running exe so the directory can be deleted.
    final currentExe = File(Platform.resolvedExecutable);
    final bakPath = '${Platform.resolvedExecutable}.bak';
    try {
      currentExe.renameSync(bakPath);
    } on FileSystemException {
      // Best effort — may already be renamed
    }

    // Spawn a detached cmd process that waits 2 seconds then deletes.
    Process.start('cmd', [
      '/c',
      'timeout /t 2 /nobreak >nul & rmdir /s /q "$dir"',
    ], mode: ProcessStartMode.detached);
  }

  bool _pathEquals(String a, String b) =>
      p.normalize(a).toLowerCase() == p.normalize(b).toLowerCase();

  // Wrappers for testability — PowerShell is the reliable way to
  // read/write user-scoped environment variables on Windows.

  String? _getEnvironmentVariable(String name, String scope) {
    final result = Process.runSync('powershell', [
      '-NoProfile',
      '-Command',
      '[System.Environment]::GetEnvironmentVariable("$name", "$scope")',
    ]);
    if (result.exitCode != 0) return null;
    final value = (result.stdout as String).trim();
    return value.isEmpty ? null : value;
  }

  void _setEnvironmentVariable(String name, String value, String scope) {
    Process.runSync('powershell', [
      '-NoProfile',
      '-Command',
      '[System.Environment]::SetEnvironmentVariable("$name", "$value", "$scope")',
    ]);
  }
}
