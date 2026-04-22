/// Linux implementation of [PlatformOps].
///
/// Uses tar for archive extraction and shell environment for variables.
library;

import 'dart:io';

import 'package:path/path.dart' as p;

import 'platform_ops.dart';

/// Concrete [PlatformOps] for Linux.
class LinuxPlatformOps implements PlatformOps {
  @override
  String get binaryName => 'inquiry';

  @override
  String get assetName => 'inquiry-linux-x64.tar.gz';

  @override
  Future<void> expandArchive(String archivePath, String destDir) async {
    final result = await Process.run('tar', [
      'xzf',
      archivePath,
      '-C',
      destDir,
    ]);
    if (result.exitCode != 0) {
      throw ProcessException(
        'tar',
        ['xzf', archivePath],
        'Failed to extract archive: ${result.stderr}',
        result.exitCode,
      );
    }
  }

  @override
  String? getEnvVariable(String name) {
    return Platform.environment[name];
  }

  @override
  Future<void> setEnvVariable(String name, String value) async {
    // On Linux, persistent env vars require modifying shell profiles.
    // This is a no-op at runtime — print guidance instead.
    // The install.sh script handles PATH setup during installation.
  }

  @override
  Future<void> selfReplace(
    String newBinaryPath,
    String currentBinaryPath,
  ) async {
    // Linux allows overwriting a running binary via rename + copy.
    final bakPath = '$currentBinaryPath.bak';
    File(currentBinaryPath).renameSync(bakPath);
    File(newBinaryPath).copySync(currentBinaryPath);

    // Make executable
    await Process.run('chmod', ['+x', currentBinaryPath]);

    // Clean up
    try {
      File(bakPath).deleteSync();
    } on FileSystemException {
      // Best effort
    }
  }

  @override
  Future<void> runPostInstall(String installDir) async {
    await Process.run(p.join(installDir, 'bin', binaryName), [
      'target',
      'get',
    ]);
  }

  @override
  Future<void> scheduleDeletion(String dir) async {
    // On Linux, the running binary is not locked — delete directly.
    await Process.start('rm', ['-rf', dir], mode: ProcessStartMode.detached);
  }
}
