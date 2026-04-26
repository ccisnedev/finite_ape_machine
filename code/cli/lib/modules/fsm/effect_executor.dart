/// Executes FSM transition side-effects that touch `.inquiry/`.
///
/// Effects like `push_branch`, `create_pull_request`, `generate_plan` etc.
/// are skill-side and NOT executed here — they are reported in the transition
/// output for the agent/skill to handle.
library;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// CLI-side effects that modify `.inquiry/` files.
const cliEffects = {
  'update_state',
  'reset_mutations',
  'snapshot_metrics',
  'close_cycle',
  'collect_metrics',
};

class EffectExecutor {
  final String workingDirectory;

  EffectExecutor({required this.workingDirectory});

  String get _inquiryDir => p.join(workingDirectory, '.inquiry');

  /// Update `.inquiry/state.yaml` with [newState].
  ///
  /// If [issue] is provided, updates the issue field.
  /// If [newState] is `IDLE`, clears the issue.
  /// Otherwise preserves the existing issue.
  void updateState(String newState, {String? issue}) {
    final file = File(p.join(_inquiryDir, 'state.yaml'));
    String? resolvedIssue = issue;

    if (newState == 'IDLE') {
      resolvedIssue = null;
    } else if (resolvedIssue == null && file.existsSync()) {
      // Preserve existing issue
      final yaml = loadYaml(file.readAsStringSync());
      if (yaml is YamlMap) {
        final existing = yaml['issue'];
        if (existing is String && existing.isNotEmpty) {
          resolvedIssue = existing;
        } else if (existing is int) {
          resolvedIssue = existing.toString();
        }
      }
    }

    final issueLine =
        resolvedIssue != null ? 'issue: "$resolvedIssue"' : 'issue: null';
    file.writeAsStringSync('state: $newState\n$issueLine\n');
  }

  /// Reset `.inquiry/mutations.md` to empty template.
  void resetMutations() {
    final file = File(p.join(_inquiryDir, 'mutations.md'));
    file.writeAsStringSync(
      '# Mutations\n'
      '\n'
      'Notes for DARWIN. Write observations about the current cycle here.\n'
      'This file is read during EVOLUTION and cleared afterwards.\n',
    );
  }

  /// Create/overwrite `.inquiry/metrics_snapshot.yaml` with current state.
  void snapshotMetrics() {
    final stateFile = File(p.join(_inquiryDir, 'state.yaml'));
    String currentState = 'IDLE';
    String? currentIssue;

    if (stateFile.existsSync()) {
      final yaml = loadYaml(stateFile.readAsStringSync());
      if (yaml is YamlMap) {
        final s = yaml['state'];
        if (s is String) currentState = s;
        final i = yaml['issue'];
        if (i is String && i.isNotEmpty) currentIssue = i;
        if (i is int) currentIssue = i.toString();
      }
    }

    final issueLine =
        currentIssue != null ? 'issue: "$currentIssue"' : 'issue: null';
    final snapshot = File(p.join(_inquiryDir, 'metrics_snapshot.yaml'));
    snapshot.writeAsStringSync(
      'snapshot_at: "${DateTime.now().toUtc().toIso8601String()}"\n'
      'state: $currentState\n'
      '$issueLine\n',
    );
  }

  /// Reset state to IDLE and clear issue.
  void closeCycle() {
    updateState('IDLE');
  }

  /// Append a cycle completion entry to `.inquiry/metrics.yaml`.
  void collectMetrics() {
    final stateFile = File(p.join(_inquiryDir, 'state.yaml'));
    String? currentIssue;

    if (stateFile.existsSync()) {
      final yaml = loadYaml(stateFile.readAsStringSync());
      if (yaml is YamlMap) {
        final i = yaml['issue'];
        if (i is String && i.isNotEmpty) currentIssue = i;
        if (i is int) currentIssue = i.toString();
      }
    }

    final issueLine =
        currentIssue != null ? 'issue: "$currentIssue"' : 'issue: null';
    final entry =
        '  - $issueLine\n'
        '    completed_at: "${DateTime.now().toUtc().toIso8601String()}"\n';

    final metricsFile = File(p.join(_inquiryDir, 'metrics.yaml'));
    if (metricsFile.existsSync()) {
      metricsFile.writeAsStringSync(entry, mode: FileMode.append);
    } else {
      metricsFile.writeAsStringSync('cycles:\n$entry');
    }
  }

  /// Execute all CLI-side effects for a transition.
  ///
  /// Always executes `update_state` first (every valid transition updates state).
  /// Then executes any CLI-side effects from [effects].
  /// Skill-side effects (git, PR, analysis context, etc.) are skipped.
  ///
  /// Returns the list of effects actually executed.
  List<String> executeAll({
    required List<String> effects,
    required String newState,
    String? issue,
  }) {
    final executed = <String>[];

    // Always update state on valid transition
    updateState(newState, issue: issue);
    executed.add('update_state');

    for (final effect in effects) {
      switch (effect) {
        case 'reset_mutations':
          resetMutations();
          executed.add(effect);
        case 'snapshot_metrics':
          snapshotMetrics();
          executed.add(effect);
        case 'close_cycle':
          closeCycle();
          executed.add(effect);
        case 'collect_metrics':
          collectMetrics();
          executed.add(effect);
        // Skill-side effects — not executed by CLI
        default:
          break;
      }
    }

    return executed;
  }
}
