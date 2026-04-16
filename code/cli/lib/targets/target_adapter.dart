import 'dart:io';

/// Abstract base class for target AI coding tool adapters.
///
/// Each adapter knows the global config paths for a specific AI coding tool.
abstract class TargetAdapter {
  /// Human-readable name of the target tool.
  String get name;

  /// Returns the base directory path for this target (e.g. `~/.claude`).
  String baseDirectory(String homeDir);

  /// Returns the directory path where skills should be deployed.
  String skillsDirectory(String homeDir);

  /// Returns the directory path where agents should be deployed.
  String agentDirectory(String homeDir);

  /// Whether this target's base directory exists on disk.
  bool exists(String homeDir) =>
      Directory(baseDirectory(homeDir)).existsSync();

  /// Names of other targets that make this one redundant.
  ///
  /// When any listed target exists, this adapter should be skipped
  /// during deploy (but still cleaned).
  List<String> get subsumedBy => const [];
}
