/// Executes FSM transition side-effects that touch `.inquiry/`.
///
/// Effects like `push_branch`, `create_pull_request`, `generate_plan` etc.
/// are skill-side and NOT executed here — they are reported in the transition
/// output for the agent/skill to handle.
library;

import 'dart:io';

import 'package:path/path.dart' as p;

import '../../src/git_utils.dart';

import '../ape/ape_definition.dart';
import '../ape/inquiry_state.dart';
import '../../assets.dart';

/// CLI-side effects that modify `.inquiry/` files.
const cliEffects = {
  'update_state',
  'reset_mutations',
  'snapshot_metrics',
  'close_cycle',
  'collect_metrics',
  'open_analysis_context',
};

class EffectExecutor {
  final String workingDirectory;
  final Assets? _assets;

  EffectExecutor({required this.workingDirectory, Assets? assets}) : _assets = assets;

  String get _inquiryDir => p.join(workingDirectory, '.inquiry');

  /// Maps FSM states to their active sub-agent names.
  static const _stateApes = <String, String>{
    'IDLE': 'dewey',
    'ANALYZE': 'socrates',
    'PLAN': 'descartes',
    'EXECUTE': 'basho',
    'END': 'basho',
    'EVOLUTION': 'darwin',
  };

  /// Update `.inquiry/state.yaml` with [newState], including APE auto-activation.
  ///
  /// If the new state has an associated APE, loads its YAML to find `initial_state`
  /// and writes `ape: {name, state}`. Otherwise clears the `ape:` field.
  void updateState(String newState, {String? issue}) {
    final currentState = InquiryState.load(workingDirectory);
    String? resolvedIssue = issue;

    if (newState == 'IDLE') {
      resolvedIssue = null;
    } else {
      resolvedIssue ??= currentState.issue;
    }

    // Auto-activate APE
    String? apeName;
    String? apeInitialState;
    final ape = _stateApes[newState];
    if (ape != null) {
      apeName = ape;
      if (currentState.apeName == ape && currentState.apeState != null) {
        apeInitialState = currentState.apeState;
      } else {
        apeInitialState = _resolveInitialState(ape);
      }
    }

    final updated = InquiryState(
      state: newState,
      issue: resolvedIssue,
      apeName: apeName,
      apeState: apeInitialState,
    );
    updated.save(workingDirectory);
  }

  /// Create `cleanrooms/<branch>/analyze/index.md` and `confirmed.md` for ANALYZE phase.
  void openAnalysisContext() {
    final branch = _getCurrentBranch();
    if (branch.isEmpty) return;

    final issue = InquiryState.load(workingDirectory).issue ?? '';
    final cleanroomDir = p.join(workingDirectory, 'cleanrooms', branch, 'analyze');
    final dir = Directory(cleanroomDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final today = DateTime.now().toIso8601String().substring(0, 10);

    final indexFile = File(p.join(cleanroomDir, 'index.md'));
    if (!indexFile.existsSync()) {
      indexFile.writeAsStringSync(
        '# Analyze Phase — Index\n'
        '\n'
        '**Issue:** #$issue\n'
        '**Branch:** $branch\n'
        '**Phase:** ANALYZE\n'
        '**Status:** In progress\n'
        '\n'
        '---\n'
        '\n'
        '## Documents\n'
        '\n'
        '| # | File | Title | Status | Tags |\n'
        '|---|------|-------|--------|------|\n'
        '| 1 | confirmed.md | Confirmed findings | active | findings, confirmed |\n',
      );
    }

    final confirmedFile = File(p.join(cleanroomDir, 'confirmed.md'));
    if (!confirmedFile.existsSync()) {
      confirmedFile.writeAsStringSync(
        '---\n'
        'id: confirmed\n'
        'title: "Confirmed findings"\n'
        'date: $today\n'
        'status: active\n'
        'tags: [findings, confirmed]\n'
        'author: socrates\n'
        '---\n'
        '\n'
        '# Confirmed Findings\n'
        '\n'
        '> Living document. Update as findings are confirmed, revised, or invalidated.\n'
        '> Format: ## F<N>: <title> — CONFIRMED|REVISED|INVALIDATED\n',
      );
    }
  }

  String _getCurrentBranch() {
    return getCurrentBranch(workingDirectory);
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

  /// Resolve the initial_state for an APE by loading its YAML definition.
  String? _resolveInitialState(String apeName) {
    try {
      final yamlPath = _assets != null
          ? _assets.path('apes/$apeName.yaml')
          : p.join(workingDirectory, 'assets', 'apes', '$apeName.yaml');
      final content = File(yamlPath).readAsStringSync();
      final def = ApeDefinition.parse(content);
      return def.initialState;
    } catch (_) {
      return null;
    }
  }

  /// Create/overwrite `.inquiry/metrics_snapshot.yaml` with current state.
  void snapshotMetrics() {
    final current = InquiryState.load(workingDirectory);

    final issueLine =
        current.issue != null ? 'issue: "${current.issue}"' : 'issue: null';
    final snapshot = File(p.join(_inquiryDir, 'metrics_snapshot.yaml'));
    snapshot.writeAsStringSync(
      'snapshot_at: "${DateTime.now().toUtc().toIso8601String()}"\n'
      'state: ${current.state}\n'
      '$issueLine\n',
    );
  }

  /// Reset state to IDLE and clear issue.
  void closeCycle() {
    updateState('IDLE');
  }

  /// Append a cycle completion entry to `.inquiry/metrics.yaml`.
  void collectMetrics() {
    final current = InquiryState.load(workingDirectory);

    final issueLine =
        current.issue != null ? 'issue: "${current.issue}"' : 'issue: null';
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
        case 'open_analysis_context':
          openAnalysisContext();
          executed.add(effect);
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
