/// Doctor command — verifies prerequisites and target deployment.
///
/// Checks: inquiry version, git, gh, gh auth, .inquiry/ init, target deployment.
library;

import 'dart:io';

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;

import '../../../assets.dart';
import '../../../src/version.dart' as version_lib;
import '../../../src/version_check.dart';
import '../../../targets/copilot_adapter.dart';
import '../../../targets/target_adapter.dart';

/// Function type for running external processes.
///
/// Allows injection of a mock for testing.
typedef ProcessRunner =
    Future<ProcessResult> Function(
      String executable,
      List<String> arguments, {
      String? workingDirectory,
    });

/// Result of a single prerequisite check.
class DoctorCheck {
  final String name;
  final bool passed;
  final String? version;
  final String? error;
  final String? remediation;

  DoctorCheck({
    required this.name,
    required this.passed,
    this.version,
    this.error,
    this.remediation,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'passed': passed,
    if (version != null) 'version': version,
    if (error != null) 'error': error,
    if (remediation != null) 'remediation': remediation,
  };
}

/// Result of checking a target's deployment status.
class TargetCheck {
  final String targetName;
  final bool agentExists;
  final List<String> missingSkills;
  final int totalSkills;
  final String? error;

  TargetCheck({
    required this.targetName,
    required this.agentExists,
    required this.missingSkills,
    required this.totalSkills,
    this.error,
  });

  bool get passed => agentExists && missingSkills.isEmpty && error == null;

  Map<String, dynamic> toJson() => {
    'targetName': targetName,
    'agentExists': agentExists,
    'missingSkills': missingSkills,
    'totalSkills': totalSkills,
    if (error != null) 'error': error,
  };
}

/// Input for the doctor command.
///
/// Accepts an optional `--fix` flag to auto-remediate failures.
class DoctorInput extends Input {
  final bool fix;

  DoctorInput({this.fix = false});

  factory DoctorInput.fromCliRequest(CliRequest req) => DoctorInput(
    fix: req.flagBool('fix'),
  );

  @override
  Map<String, dynamic> toJson() => {'fix': fix};
}

/// Output for the doctor command.
class DoctorOutput extends Output {
  final List<DoctorCheck> checks;
  final List<TargetCheck> targetChecks;
  final bool passed;

  DoctorOutput({
    required this.checks,
    this.targetChecks = const [],
    required this.passed,
  });

  @override
  Map<String, dynamic> toJson() => {
    'checks': checks.map((c) => c.toJson()).toList(),
    'targetChecks': targetChecks.map((c) => c.toJson()).toList(),
    'passed': passed,
  };

  @override
  int get exitCode => passed ? ExitCode.ok : ExitCode.genericError;

  /// Returns formatted checkmarks for text mode (like flutter doctor).
  @override
  String? toText() {
    final buffer = StringBuffer('Checking prerequisites...\n');
    for (final check in checks) {
      final icon = check.passed ? '✓' : '✗';
      final suffix = check.version ?? check.error ?? '';
      if (suffix.isNotEmpty) {
        buffer.writeln('  $icon ${check.name} $suffix');
      } else {
        buffer.writeln('  $icon ${check.name}');
      }
      if (!check.passed && check.remediation != null) {
        buffer.writeln("    → ${check.remediation}");
      }
    }

    if (targetChecks.isNotEmpty) {
      buffer.writeln('Checking targets...');
      for (final tc in targetChecks) {
        if (tc.error != null) {
          buffer.writeln('  ✗ ${tc.targetName}: ${tc.error}');
        } else if (tc.passed) {
          final deployed = tc.totalSkills - tc.missingSkills.length;
          buffer.writeln(
            '  ✓ ${tc.targetName}: agent + $deployed skills deployed',
          );
        } else {
          if (!tc.agentExists) {
            buffer.writeln('  ✗ ${tc.targetName}: agent not deployed');
          } else {
            buffer.writeln('  ✓ ${tc.targetName}: agent deployed');
          }
          if (tc.missingSkills.isNotEmpty) {
            buffer.writeln(
              '  ✗ ${tc.targetName}: missing skills: '
              '${tc.missingSkills.join(', ')}',
            );
          }
          buffer.writeln("    → Run 'inquiry target get' to deploy");
        }
      }
    }

    buffer.writeln();
    buffer.write(passed ? 'All checks passed.' : 'Some checks failed.');
    return buffer.toString();
  }
}

/// Abstraction for filesystem operations (testable).
abstract class FileSystemOps {
  bool fileExists(String path);
  bool directoryExists(String path);
  String homeDirectory();
}

/// Production implementation using dart:io.
class RealFileSystemOps implements FileSystemOps {
  @override
  bool fileExists(String path) => File(path).existsSync();

  @override
  bool directoryExists(String path) => Directory(path).existsSync();

  @override
  String homeDirectory() {
    final home =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home != null && home.isNotEmpty) return home;
    return Directory.current.path;
  }
}

/// Command that verifies all prerequisites and target deployment.
class DoctorCommand implements Command<DoctorInput, DoctorOutput> {
  @override
  final DoctorInput input;

  final ProcessRunner _runProcess;
  final FileSystemOps _fileSystem;
  final Assets? _assets;
  final List<TargetAdapter> _activeAdapters;
  final Future<VersionCheckResult> Function({required String currentVersion})?
      _versionChecker;

  /// Current Inquiry version (injected for testability).
  final String inquiryVersion;

  DoctorCommand(
    this.input, {
    ProcessRunner? runProcess,
    String? inquiryVersionOverride,
    FileSystemOps? fileSystemOps,
    Assets? assets,
    List<TargetAdapter>? activeAdapters,
    Future<VersionCheckResult> Function({required String currentVersion})?
        versionChecker,
  }) : _runProcess = runProcess ?? Process.run,
       _fileSystem = fileSystemOps ?? RealFileSystemOps(),
       _assets = assets,
       _activeAdapters = activeAdapters ?? [CopilotAdapter()],
       _versionChecker = versionChecker,
       inquiryVersion = inquiryVersionOverride ?? version_lib.inquiryVersion;

  @override
  String? validate() => null;

  @override
  Future<DoctorOutput> execute() async {
    final checks = <DoctorCheck>[];
    var prereqPassed = true;

    // Check 1: APE version (always passes, internal)
    checks.add(DoctorCheck(name: 'inquiry', passed: true, version: inquiryVersion));

    // Check 2: git --version
    final gitCheck = await _checkCommand(
      name: 'git',
      executable: 'git',
      arguments: ['--version'],
      versionExtractor: _extractGitVersion,
    );
    checks.add(gitCheck);
    if (!gitCheck.passed) {
      prereqPassed = false;
      return DoctorOutput(checks: checks, passed: false);
    }

    // Check 3: gh --version
    final ghCheck = await _checkCommand(
      name: 'gh',
      executable: 'gh',
      arguments: ['--version'],
      versionExtractor: _extractGhVersion,
    );
    checks.add(ghCheck);
    if (!ghCheck.passed) {
      prereqPassed = false;
      return DoctorOutput(checks: checks, passed: false);
    }

    // Check 4: gh auth status
    final authCheck = await _checkCommand(
      name: 'gh auth',
      executable: 'gh',
      arguments: ['auth', 'status'],
      versionExtractor: (_) => null,
    );
    checks.add(authCheck);
    if (!authCheck.passed) {
      prereqPassed = false;
    }

    // Check 5: .inquiry/ directory (init)
    final initExists = _fileSystem.directoryExists('.inquiry');
    if (!initExists) {
      checks.add(
        DoctorCheck(
          name: 'inquiry init',
          passed: false,
          error: 'not initialized',
          remediation: "Run 'inquiry init' to initialize",
        ),
      );
      prereqPassed = false;
    }

    // Check 6: Internal assets integrity
    final assetCheck = _checkInternalAssets();
    if (assetCheck != null) {
      checks.add(assetCheck);
      if (!assetCheck.passed) {
        if (input.fix) {
          final fixResult = await _fixAssets();
          checks.add(fixResult);
          if (fixResult.passed) {
            // Re-check after fix
            final recheck = _checkInternalAssets();
            if (recheck == null || recheck.passed) {
              // Remove the failed check, it's been fixed
              checks.remove(assetCheck);
            } else {
              prereqPassed = false;
            }
          } else {
            prereqPassed = false;
          }
        } else {
          prereqPassed = false;
        }
      }
    }

    // Check 7: Version check (non-blocking)
    final versionCheck = await _checkVersion();
    if (versionCheck != null) {
      checks.add(versionCheck);
    }

    // Target checks
    final targetChecks = <TargetCheck>[];
    for (final adapter in _activeAdapters) {
      targetChecks.add(_verifyTarget(adapter));
    }

    final targetsPassed = targetChecks.every((tc) => tc.passed);

    return DoctorOutput(
      checks: checks,
      targetChecks: targetChecks,
      passed: prereqPassed && targetsPassed,
    );
  }

  /// Discovers expected skills from the asset tree.
  List<String> _getExpectedSkills() {
    if (_assets == null) return [];
    try {
      return _assets.listDirectory('skills');
    } catch (_) {
      return [];
    }
  }

  /// Verifies a single target adapter's deployment.
  TargetCheck _verifyTarget(TargetAdapter adapter) {
    final homeDir = _fileSystem.homeDirectory();
    final expectedSkills = _getExpectedSkills();

    // Check agent
    final agentPath = p.join(adapter.agentDirectory(homeDir), 'inquiry.agent.md');
    final agentExists = _fileSystem.fileExists(agentPath);

    // Check skills
    final missingSkills = <String>[];
    for (final skill in expectedSkills) {
      final skillPath = p.join(
        adapter.skillsDirectory(homeDir),
        skill,
        'SKILL.md',
      );
      if (!_fileSystem.fileExists(skillPath)) {
        missingSkills.add(skill);
      }
    }

    return TargetCheck(
      targetName: adapter.name,
      agentExists: agentExists,
      missingSkills: missingSkills,
      totalSkills: expectedSkills.length,
    );
  }

  /// Checks that all expected internal assets exist on disk.
  ///
  /// Returns null if no [_assets] is available (cannot verify).
  DoctorCheck? _checkInternalAssets() {
    if (_assets == null) return null;

    final missing = <String>[];

    // FSM state instruction files
    const stateFiles = ['idle', 'analyze', 'plan', 'execute', 'end', 'evolution'];
    for (final state in stateFiles) {
      final path = _assets.path('fsm/states/$state.yaml');
      if (!File(path).existsSync()) {
        missing.add('fsm/states/$state.yaml');
      }
    }

    // APE definition files
    const apeFiles = ['socrates', 'socrates-idle', 'descartes', 'basho', 'darwin'];
    for (final ape in apeFiles) {
      final path = _assets.path('apes/$ape.yaml');
      if (!File(path).existsSync()) {
        missing.add('apes/$ape.yaml');
      }
    }

    // Transition contract
    final contractPath = _assets.path('fsm/transition_contract.yaml');
    if (!File(contractPath).existsSync()) {
      missing.add('fsm/transition_contract.yaml');
    }

    // Skills
    try {
      final skills = _assets.listDirectory('skills');
      for (final skill in skills) {
        final path = _assets.path('skills/$skill/SKILL.md');
        if (!File(path).existsSync()) {
          missing.add('skills/$skill/SKILL.md');
        }
      }
    } catch (_) {
      missing.add('skills/ (directory missing)');
    }

    if (missing.isEmpty) {
      return DoctorCheck(name: 'assets', passed: true);
    }

    return DoctorCheck(
      name: 'assets',
      passed: false,
      error: '${missing.length} missing: ${missing.join(', ')}',
      remediation: "Run 'iq doctor --fix' to restore missing assets",
    );
  }

  /// Downloads and restores missing assets from the current version's release.
  Future<DoctorCheck> _fixAssets() async {
    if (_assets == null) {
      return DoctorCheck(
        name: 'fix',
        passed: false,
        error: 'Cannot determine asset location',
      );
    }

    try {
      stderr.writeln('Downloading assets for v$inquiryVersion...');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final assetName = Platform.isWindows
          ? 'inquiry-windows-x64.zip'
          : 'inquiry-linux-x64.tar.gz';

      final downloadUrl = Uri.parse(
        'https://github.com/ccisnedev/inquiry/releases/download/v$inquiryVersion/$assetName',
      );

      final request = await client.getUrl(downloadUrl);
      request.headers.set('User-Agent', 'inquiry-cli/$inquiryVersion');
      request.followRedirects = true;
      final response = await request.close();

      if (response.statusCode != 200) {
        await response.drain<void>();
        client.close();
        return DoctorCheck(
          name: 'fix',
          passed: false,
          error: 'Failed to download assets (HTTP ${response.statusCode})',
        );
      }

      // Save to temp and extract
      final tempDir = Directory.systemTemp.createTempSync('iq_fix_');
      final archiveFile = File(p.join(tempDir.path, assetName));
      final sink = archiveFile.openWrite();
      await response.pipe(sink);
      client.close();

      // Extract to the asset root's parent (which is the install dir)
      final installDir = p.dirname(_assets.path(''));
      // Remove trailing 'assets' from path to get install root
      final installRoot = installDir.endsWith('assets${p.separator}') ||
              installDir.endsWith('assets')
          ? p.dirname(installDir)
          : p.dirname(p.dirname(installDir));

      stderr.writeln('Extracting to: $installRoot');

      if (Platform.isWindows) {
        final result = await Process.run('powershell', [
          '-NoProfile',
          '-Command',
          'Expand-Archive',
          '-Path', archiveFile.path,
          '-DestinationPath', installRoot,
          '-Force',
        ]);
        if (result.exitCode != 0) {
          tempDir.deleteSync(recursive: true);
          return DoctorCheck(
            name: 'fix',
            passed: false,
            error: 'Extraction failed: ${result.stderr}',
          );
        }
      } else {
        final result = await Process.run('tar', [
          '-xzf', archiveFile.path,
          '-C', installRoot,
        ]);
        if (result.exitCode != 0) {
          tempDir.deleteSync(recursive: true);
          return DoctorCheck(
            name: 'fix',
            passed: false,
            error: 'Extraction failed: ${result.stderr}',
          );
        }
      }

      tempDir.deleteSync(recursive: true);
      stderr.writeln('✓ Assets restored successfully');
      return DoctorCheck(name: 'fix', passed: true, version: 'restored');
    } on Exception catch (e) {
      return DoctorCheck(
        name: 'fix',
        passed: false,
        error: 'Fix failed: $e',
      );
    }
  }

  /// Checks if a newer version is available. Non-blocking.
  ///
  /// Returns a passing check with update info, or null on failure/timeout.
  Future<DoctorCheck?> _checkVersion() async {
    try {
      final checker = _versionChecker ??
          ({required String currentVersion}) =>
              checkLatestVersion(currentVersion: currentVersion);
      final result = await checker(currentVersion: inquiryVersion);
      if (result.updateAvailable && result.latestVersion != null) {
        return DoctorCheck(
          name: 'update',
          passed: true,
          version: '${result.latestVersion} available',
          remediation: "Run 'iq upgrade' to update",
        );
      }
      return null; // No update, no check to show
    } catch (_) {
      return null; // Silent on failure
    }
  }

  /// Runs a command and returns a [DoctorCheck] with the result.
  Future<DoctorCheck> _checkCommand({
    required String name,
    required String executable,
    required List<String> arguments,
    required String? Function(String stdout) versionExtractor,
  }) async {
    try {
      final result = await _runProcess(executable, arguments);
      if (result.exitCode == 0) {
        final version = versionExtractor(result.stdout.toString());
        return DoctorCheck(name: name, passed: true, version: version);
      } else {
        return DoctorCheck(
          name: name,
          passed: false,
          error: result.stderr.toString().trim(),
        );
      }
    } catch (e) {
      return DoctorCheck(name: name, passed: false, error: e.toString());
    }
  }

  /// Extracts version from "git version X.Y.Z".
  String? _extractGitVersion(String stdout) {
    final match = RegExp(r'git version (\d+\.\d+\.\d+)').firstMatch(stdout);
    return match?.group(1);
  }

  /// Extracts version from "gh version X.Y.Z (...)".
  String? _extractGhVersion(String stdout) {
    final match = RegExp(r'gh version (\d+\.\d+\.\d+)').firstMatch(stdout);
    return match?.group(1);
  }
}
