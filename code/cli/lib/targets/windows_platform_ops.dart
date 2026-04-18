/// Windows implementation of [PlatformOps].
///
/// Uses PowerShell for archive extraction and environment variable management.
library;

import 'dart:io';

import 'package:path/path.dart' as p;

import 'platform_ops.dart';

/// Concrete [PlatformOps] for Windows.
class WindowsPlatformOps implements PlatformOps {
  @override
  String get binaryName => 'ape.exe';

  @override
  String get assetName => 'ape-windows-x64.zip';

  @override
  Future<void> expandArchive(String archivePath, String destDir) async {
    final result = await Process.run('powershell', [
      '-NoProfile',
      '-Command',
      'Expand-Archive -Path "$archivePath" -DestinationPath "$destDir" -Force',
    ]);
    if (result.exitCode != 0) {
      throw ProcessException(
        'powershell',
        ['Expand-Archive'],
        'Failed to extract archive: ${result.stderr}',
        result.exitCode,
      );
    }
  }

  @override
  String? getEnvVariable(String name) {
    final result = Process.runSync('powershell', [
      '-NoProfile',
      '-Command',
      '[System.Environment]::GetEnvironmentVariable("$name", "User")',
    ]);
    if (result.exitCode != 0) return null;
    final value = (result.stdout as String).trim();
    return value.isEmpty ? null : value;
  }

  @override
  Future<void> setEnvVariable(String name, String value) async {
    Process.runSync('powershell', [
      '-NoProfile',
      '-Command',
      '[System.Environment]::SetEnvironmentVariable("$name", "$value", "User")',
    ]);
  }

  @override
  Future<void> selfReplace(
    String newBinaryPath,
    String currentBinaryPath,
  ) async {
    final bakPath = '$currentBinaryPath.bak';
    final bakFile = File(bakPath);

    // Clean up leftover .bak from a previous upgrade
    if (bakFile.existsSync()) bakFile.deleteSync();

    // Rename the running exe — Windows allows renaming a locked file
    File(currentBinaryPath).renameSync(bakPath);

    // Copy the new binary into place
    File(newBinaryPath).copySync(currentBinaryPath);

    // Best-effort cleanup
    try {
      if (bakFile.existsSync()) bakFile.deleteSync();
    } on FileSystemException {
      // Still locked — will be cleaned up on next upgrade
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
  void scheduleDeletion(String dir) {
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
}
