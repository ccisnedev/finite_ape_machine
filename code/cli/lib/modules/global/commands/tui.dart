/// `inquiry` (no args) — displays TUI with FSM diagram and version.
library;

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';

import '../../../src/version.dart';
import '../../../src/version_check.dart';

// ─── Input ──────────────────────────────────────────────────────────────────

/// Input for the TUI command.
///
/// No parameters required — displays static information.
class TuiInput extends Input {
  TuiInput();

  factory TuiInput.fromCliRequest(CliRequest req) => TuiInput();

  @override
  Map<String, dynamic> toJson() => {};
}

// ─── Output ─────────────────────────────────────────────────────────────────

/// Output for the TUI command.
class TuiOutput extends Output {
  final String version;
  final String diagram;

  TuiOutput({required this.version, required this.diagram});

  @override
  Map<String, dynamic> toJson() => {'version': version, 'diagram': diagram};

  @override
  int get exitCode => ExitCode.ok;

  /// Returns only the diagram for text mode (no field labels).
  @override
  String? toText() => diagram;
}

// ─── Command ────────────────────────────────────────────────────────────────

/// Command that displays the APE FSM diagram and version.
class TuiCommand implements Command<TuiInput, TuiOutput> {
  @override
  final TuiInput input;
  final Future<VersionCheckResult> Function({required String currentVersion})?
      _versionChecker;

  TuiCommand(this.input, {
    Future<VersionCheckResult> Function({required String currentVersion})?
        versionChecker,
  }) : _versionChecker = versionChecker;

  @override
  String? validate() => null;

  @override
  Future<TuiOutput> execute() async {
    var diagram = _buildDiagram(inquiryVersion);

    // Non-blocking version check
    try {
      final checker = _versionChecker ??
          ({required String currentVersion}) =>
              checkLatestVersion(currentVersion: currentVersion);
      final result = await checker(currentVersion: inquiryVersion);
      if (result.updateAvailable && result.latestVersion != null) {
        diagram += "\n\nUpdate available: $inquiryVersion → ${result.latestVersion}"
            " — run 'iq upgrade'";
      }
    } catch (_) {
      // Silent on failure
    }

    return TuiOutput(version: inquiryVersion, diagram: diagram);
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────────

/// Builds the FSM diagram with the given version.
String _buildDiagram(String version) {
  return '''
Inquiry v$version — powered by the Finite APE Machine

       ╭──────────────────────────╮
Idle → │ Analyze → Plan → Execute │ → End → [Evolution]
       ╰──────────────────────────╯

Commands: init, doctor, version
Run: inquiry --help''';
}
