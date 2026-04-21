/// `inquiry init` — initializes Inquiry in the working directory.
///
/// Seven idempotent steps:
/// 1. Detect docs directory (doc/ or docs/, prefer docs/)
/// 2. Create {docs}/issues/ if missing
/// 3. Add .inquiry/ to .gitignore
/// 4. Create .inquiry/state.yaml with IDLE state
/// 5. Create .inquiry/config.yaml with defaults
/// 6. Create .inquiry/mutations.md with header template
/// 7. Deploy inquiry.agent.md to active target
library;

import 'dart:io';

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;

// ─── Input ──────────────────────────────────────────────────────────────────

/// Carries the working directory where APE will be initialized.
///
/// Defaults to [Directory.current] when constructed from a [CliRequest],
/// but accepts an explicit path for testing.
class InitInput extends Input {
  final String workingDirectory;

  InitInput({required this.workingDirectory});

  factory InitInput.fromCliRequest(CliRequest req) =>
      InitInput(workingDirectory: Directory.current.path);

  @override
  Map<String, dynamic> toJson() => {'workingDirectory': workingDirectory};
}

// ─── Output ─────────────────────────────────────────────────────────────────

class InitOutput extends Output {
  final String message;
  final bool isCreated;

  InitOutput({required this.message, required this.isCreated});

  @override
  Map<String, dynamic> toJson() => {'message': message, 'created': isCreated};

  @override
  int get exitCode => ExitCode.ok;
}

// ─── Command ────────────────────────────────────────────────────────────────

/// Initializes Inquiry in [InitInput.workingDirectory].
///
/// Idempotent: running twice produces the same result.
class InitCommand implements Command<InitInput, InitOutput> {
  @override
  final InitInput input;

  InitCommand(this.input);

  @override
  String? validate() => null;

  @override
  Future<InitOutput> execute() async {
    final root = input.workingDirectory;
    final steps = <String>[];

    // Step 1: Detect docs directory
    final docsDir = _detectDocsDirectory(root);

    // Step 2: Create {docs}/issues/ if missing
    final issuesDir = Directory('$docsDir/issues');
    if (!issuesDir.existsSync()) {
      issuesDir.createSync(recursive: true);
      steps.add('Created ${_relative(root, issuesDir.path)}');
    }

    // Step 3: Add .inquiry/ to .gitignore
    _ensureGitignore(root, steps);

    // Step 4: Create .inquiry/state.yaml with IDLE state
    _ensureStateYaml(root, steps);

    // Step 5: Create .inquiry/config.yaml with defaults
    _ensureConfigYaml(root, steps);

    // Step 6: Create .inquiry/mutations.md with header template
    _ensureMutationsMd(root, steps);

    // Step 7: Deploy is handled by `inquiry target get` — not duplicated here.

    if (steps.isEmpty) {
      return InitOutput(
        message: 'Inquiry already initialized in $root',
        isCreated: false,
      );
    }

    return InitOutput(message: steps.join('\n'), isCreated: true);
  }

  /// Detects whether `doc/` or `docs/` exists. Prefers `docs/`.
  /// If neither exists, creates `docs/`.
  String _detectDocsDirectory(String root) {
    final docs = Directory('$root/docs');
    final doc = Directory('$root/doc');

    if (docs.existsSync()) return docs.path;
    if (doc.existsSync()) return doc.path;

    // Neither exists — create docs/
    docs.createSync();
    return docs.path;
  }

  /// Ensures `.inquiry/` is in `.gitignore`.
  void _ensureGitignore(String root, List<String> steps) {
    final gitignore = File('$root/.gitignore');

    if (gitignore.existsSync()) {
      final content = gitignore.readAsStringSync();
      if (!content.contains('.inquiry/')) {
        gitignore.writeAsStringSync('$content.inquiry/\n');
        steps.add('Added .inquiry/ to .gitignore');
      }
    } else {
      gitignore.writeAsStringSync('.inquiry/\n');
      steps.add('Created .gitignore with .inquiry/');
    }
  }

  /// Ensures `.inquiry/state.yaml` exists with IDLE state.
  void _ensureStateYaml(String root, List<String> steps) {
    final inquiryDir = Directory('$root/.inquiry');
    final stateFile = File('$root/.inquiry/state.yaml');

    if (!stateFile.existsSync()) {
      if (!inquiryDir.existsSync()) inquiryDir.createSync();
      stateFile.writeAsStringSync(
        'cycle:\n'
        '  phase: IDLE\n'
        '  task: null\n'
        '\n'
        'ready: []\n'
        'waiting: []\n'
        'complete: []\n',
      );
      steps.add('Created .inquiry/state.yaml');
    }
  }

  /// Ensures `.inquiry/config.yaml` exists with default configuration.
  void _ensureConfigYaml(String root, List<String> steps) {
    final configFile = File('$root/.inquiry/config.yaml');

    if (!configFile.existsSync()) {
      configFile.writeAsStringSync(
        'evolution:\n'
        '  enabled: false\n',
      );
      steps.add('Created .inquiry/config.yaml');
    }
  }

  /// Ensures `.inquiry/mutations.md` exists with header template.
  void _ensureMutationsMd(String root, List<String> steps) {
    final mutationsFile = File('$root/.inquiry/mutations.md');

    if (!mutationsFile.existsSync()) {
      mutationsFile.writeAsStringSync(
        '# Mutations\n'
        '\n'
        'Notes for DARWIN. Write observations about the current cycle here.\n'
        'This file is read during EVOLUTION and cleared afterwards.\n',
      );
      steps.add('Created .inquiry/mutations.md');
    }
  }

  String _relative(String root, String path) =>
      p.relative(path, from: root);
}
