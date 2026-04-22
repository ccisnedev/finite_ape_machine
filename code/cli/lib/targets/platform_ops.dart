/// Cross-platform abstraction for OS-specific shell operations.
///
/// PlatformOps wraps operations that differ between Windows and Linux:
/// archive extraction, environment variables, binary replacement, etc.
///
/// Path manipulation is NOT part of this abstraction — use `package:path`.
library;

import 'dart:io' show Platform;

import 'linux_platform_ops.dart';
import 'windows_platform_ops.dart';

/// Abstract contract for platform-specific operations.
///
/// Implementations: [WindowsPlatformOps], [LinuxPlatformOps].
/// For tests: create a fake that implements this class.
abstract class PlatformOps {
  /// The compiled binary name for this platform (e.g. `inquiry.exe` or `inquiry`).
  String get binaryName;

  /// The release asset name for this platform (e.g. `inquiry-windows-x64.zip`).
  String get assetName;

  /// Extract an archive to [destDir].
  ///
  /// Windows: PowerShell `Expand-Archive`.
  /// Linux: `tar xzf`.
  Future<void> expandArchive(String archivePath, String destDir);

  /// Read a system environment variable. Returns `null` if not set.
  String? getEnvVariable(String name);

  /// Write a system environment variable.
  Future<void> setEnvVariable(String name, String value);

  /// Replace the currently running binary with a new one.
  ///
  /// Handles OS-specific locking and permission issues.
  Future<void> selfReplace(String newBinaryPath, String currentBinaryPath);

  /// Run post-install steps (e.g. `ape target get`) using the correct binary.
  Future<void> runPostInstall(String installDir);

  /// Schedule deletion of a directory after the current process exits.
  ///
  /// Windows: rename running exe, spawn detached `cmd /c timeout ... rmdir`.
  /// Linux: spawn detached `rm -rf`.
  Future<void> scheduleDeletion(String dir);

  /// Factory that returns the correct implementation for the current OS.
  factory PlatformOps.current() {
    if (Platform.isWindows) return WindowsPlatformOps();
    if (Platform.isLinux) return LinuxPlatformOps();
    throw UnsupportedError(
      'PlatformOps: unsupported OS "${Platform.operatingSystem}"',
    );
  }
}
