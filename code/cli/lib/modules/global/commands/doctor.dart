/// Doctor command — verifies prerequisites.
///
/// Checks: ape version, git, gh, gh auth.
library;

import 'dart:io';

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';

import '../../../src/version.dart' as version_lib;

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

  DoctorCheck({
    required this.name,
    required this.passed,
    this.version,
    this.error,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'passed': passed,
    if (version != null) 'version': version,
    if (error != null) 'error': error,
  };
}

/// Input for the doctor command.
///
/// No parameters required — doctor checks system state.
class DoctorInput extends Input {
  DoctorInput();

  factory DoctorInput.fromCliRequest(CliRequest req) => DoctorInput();

  @override
  Map<String, dynamic> toJson() => {};
}

/// Output for the doctor command.
class DoctorOutput extends Output {
  final List<DoctorCheck> checks;
  final bool passed;

  DoctorOutput({required this.checks, required this.passed});

  @override
  Map<String, dynamic> toJson() => {
    'checks': checks.map((c) => c.toJson()).toList(),
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
    }
    buffer.writeln();
    buffer.write(passed ? 'All checks passed.' : 'Some checks failed.');
    return buffer.toString();
  }
}

/// Command that verifies all prerequisites are installed.
class DoctorCommand implements Command<DoctorInput, DoctorOutput> {
  @override
  final DoctorInput input;

  final ProcessRunner _runProcess;

  /// Current APE version (injected for testability).
  final String apeVersion;

  DoctorCommand(
    this.input, {
    ProcessRunner? runProcess,
    String? apeVersionOverride,
  }) : _runProcess = runProcess ?? Process.run,
       apeVersion = apeVersionOverride ?? version_lib.apeVersion;

  @override
  String? validate() => null;

  @override
  Future<DoctorOutput> execute() async {
    final checks = <DoctorCheck>[];
    var allPassed = true;

    // Check 1: APE version (always passes, internal)
    checks.add(DoctorCheck(name: 'ape', passed: true, version: apeVersion));

    // Check 2: git --version
    final gitCheck = await _checkCommand(
      name: 'git',
      executable: 'git',
      arguments: ['--version'],
      versionExtractor: _extractGitVersion,
    );
    checks.add(gitCheck);
    if (!gitCheck.passed) {
      allPassed = false;
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
      allPassed = false;
      return DoctorOutput(checks: checks, passed: false);
    }

    // Check 4: gh auth status
    final authCheck = await _checkCommand(
      name: 'gh auth',
      executable: 'gh',
      arguments: ['auth', 'status'],
      versionExtractor: (_) => null, // No version for auth
    );
    checks.add(authCheck);
    if (!authCheck.passed) {
      allPassed = false;
    }

    return DoctorOutput(checks: checks, passed: allPassed);
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
