import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:inquiry_cli/modules/state/commands/transition.dart';

void main() {
  group('state transition command', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('ape_state_transition_');
      _writeContract(tempDir.path);
      _writeState(tempDir.path, 'IDLE');
      Directory(p.join(tempDir.path, '.ape')).createSync(recursive: true);
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('rejects illegal transition IDLE + go_execute', () async {
      final input = StateTransitionInput(
        currentState: 'IDLE',
        event: 'go_execute',
        workingDirectory: tempDir.path,
      );
      final command = StateTransitionCommand(
        input,
        branchProvider: (_) async => 'main',
      );

      final output = await command.execute();

      expect(output.allowed, isFalse);
      expect(output.exitCode, 64);
      expect(output.message, contains('forbidden'));
    });

    test('returns prompt descriptor for ANALYZE -> PLAN', () async {
      _writeState(tempDir.path, 'ANALYZE');
      _writeContext(tempDir.path, 'issue: 51\n');

      final input = StateTransitionInput(
        currentState: null,
        event: 'complete_analysis',
        workingDirectory: tempDir.path,
      );
      final command = StateTransitionCommand(
        input,
        branchProvider: (_) async => '51-idle-execution-guardrails',
      );

      final output = await command.execute();

      expect(output.allowed, isTrue);
      expect(output.nextState, 'PLAN');
      expect(output.promptFragmentId, 'analyze_to_plan');
      expect(output.requiredRole, 'DESCARTES');
      expect(output.operationsExecuted, contains('generate_plan'));
    });

    test('fails precheck when commitment needs issue/branch and issue missing',
        () async {
      _writeState(tempDir.path, 'PLAN');

      final input = StateTransitionInput(
        currentState: null,
        event: 'approve_plan',
        workingDirectory: tempDir.path,
      );
      final command = StateTransitionCommand(
        input,
        branchProvider: (_) async => '51-idle-execution-guardrails',
      );

      final output = await command.execute();

      expect(output.allowed, isFalse);
      expect(output.exitCode, 7);
      expect(output.message, contains('ERROR_PRECONDITION_ISSUE_FIRST'));
    });

    test('allows IDLE exploration transition without issue context', () async {
      _writeState(tempDir.path, 'IDLE');

      final input = StateTransitionInput(
        currentState: null,
        event: 'start_analyze',
        workingDirectory: tempDir.path,
      );
      final command = StateTransitionCommand(
        input,
        branchProvider: (_) async => 'main',
      );

      final output = await command.execute();

      expect(output.allowed, isTrue);
      expect(output.exitCode, 0);
      expect(output.nextState, 'ANALYZE');
      expect(output.promptFragmentId, 'idle_to_analyze');
    });

    test('blocks commitment transition on main branch', () async {
      _writeState(tempDir.path, 'PLAN');
      _writeContext(tempDir.path, 'issue: 51\n');

      final input = StateTransitionInput(
        currentState: null,
        event: 'approve_plan',
        workingDirectory: tempDir.path,
      );
      final command = StateTransitionCommand(
        input,
        branchProvider: (_) async => 'main',
      );

      final output = await command.execute();

      expect(output.allowed, isFalse);
      expect(output.exitCode, 7);
      expect(output.message, contains('ERROR_PRECONDITION_BRANCH_POLICY'));
    });
  });
}

void _writeState(String root, String state) {
  final file = File(p.join(root, '.ape', 'state.yaml'));
  file.createSync(recursive: true);
  file.writeAsStringSync('cycle:\n  phase: $state\n');
}

void _writeContext(String root, String content) {
  final file = File(p.join(root, '.ape', 'context.yaml'));
  file.createSync(recursive: true);
  file.writeAsStringSync(content);
}

void _writeContract(String root) {
  final file = File(p.join(root, 'assets', 'fsm', 'transition_contract.yaml'));
  file.createSync(recursive: true);
  file.writeAsStringSync('''
metadata:
  version: "1.0.0"
  description: "APE FSM transition contract"
states: [IDLE, ANALYZE, PLAN, EXECUTE, EVOLUTION]
events: [start_analyze, complete_analysis, approve_plan, finish_execute, finish_evolution, block, go_execute]
transitions:
  - from: IDLE
    event: start_analyze
    to: ANALYZE
    allowed: true
    operations:
      prechecks: []
      effects: [open_analysis_context]
      artifacts: [analysis/index.md]
      commit_policy: none
      prompt_fragment_id: idle_to_analyze

  - from: IDLE
    event: complete_analysis
    to: ILLEGAL
    allowed: false
    reason: "IDLE cannot complete analysis before ANALYZE"

  - from: IDLE
    event: approve_plan
    to: ILLEGAL
    allowed: false
    reason: "IDLE cannot approve plan directly"

  - from: IDLE
    event: finish_execute
    to: ILLEGAL
    allowed: false
    reason: "IDLE cannot finish execute"

  - from: IDLE
    event: finish_evolution
    to: ILLEGAL
    allowed: false
    reason: "IDLE cannot finish evolution"

  - from: IDLE
    event: block
    to: IDLE
    allowed: true
    operations:
      prechecks: []
      effects: [noop]
      artifacts: []
      commit_policy: none
      prompt_fragment_id: idle_block

  - from: IDLE
    event: go_execute
    to: ILLEGAL
    allowed: false
    reason: "IDLE -> EXECUTE is forbidden"

  - from: ANALYZE
    event: start_analyze
    to: ANALYZE
    allowed: true
    operations:
      prechecks: []
      effects: [continue_analysis]
      artifacts: [analyze/notes.md]
      commit_policy: none
      prompt_fragment_id: analyze_continue

  - from: ANALYZE
    event: complete_analysis
    to: PLAN
    allowed: true
    operations:
      prechecks: [issue_selected_or_created, diagnosis_exists]
      effects: [generate_plan]
      artifacts: [plan.md]
      commit_policy: stage_only
      prompt_fragment_id: analyze_to_plan

  - from: ANALYZE
    event: approve_plan
    to: ILLEGAL
    allowed: false
    reason: "ANALYZE cannot jump to EXECUTE"

  - from: ANALYZE
    event: finish_execute
    to: ILLEGAL
    allowed: false
    reason: "ANALYZE cannot finish execute"

  - from: ANALYZE
    event: finish_evolution
    to: ILLEGAL
    allowed: false
    reason: "ANALYZE cannot finish evolution"

  - from: ANALYZE
    event: block
    to: IDLE
    allowed: true
    operations:
      prechecks: []
      effects: [pause_analysis]
      artifacts: []
      commit_policy: none
      prompt_fragment_id: analyze_to_idle

  - from: ANALYZE
    event: go_execute
    to: ILLEGAL
    allowed: false
    reason: "ANALYZE -> EXECUTE is forbidden without PLAN"

  - from: PLAN
    event: start_analyze
    to: ILLEGAL
    allowed: false
    reason: "PLAN cannot start analyze"

  - from: PLAN
    event: complete_analysis
    to: ILLEGAL
    allowed: false
    reason: "PLAN cannot complete analysis"

  - from: PLAN
    event: approve_plan
    to: EXECUTE
    allowed: true
    operations:
      prechecks: [issue_selected, feature_branch_selected, plan_approved]
      effects: [prepare_execute]
      artifacts: [execution_log.md]
      commit_policy: branch_required
      prompt_fragment_id: plan_to_execute

  - from: PLAN
    event: finish_execute
    to: ILLEGAL
    allowed: false
    reason: "PLAN cannot finish execute"

  - from: PLAN
    event: finish_evolution
    to: ILLEGAL
    allowed: false
    reason: "PLAN cannot finish evolution"

  - from: PLAN
    event: block
    to: IDLE
    allowed: true
    operations:
      prechecks: []
      effects: [pause_plan]
      artifacts: []
      commit_policy: none
      prompt_fragment_id: plan_to_idle

  - from: PLAN
    event: go_execute
    to: EXECUTE
    allowed: true
    operations:
      prechecks: [issue_selected, feature_branch_selected, plan_approved]
      effects: [prepare_execute]
      artifacts: [execution_log.md]
      commit_policy: branch_required
      prompt_fragment_id: plan_to_execute

  - from: EXECUTE
    event: start_analyze
    to: ILLEGAL
    allowed: false
    reason: "EXECUTE cannot start analyze"

  - from: EXECUTE
    event: complete_analysis
    to: ILLEGAL
    allowed: false
    reason: "EXECUTE cannot complete analysis"

  - from: EXECUTE
    event: approve_plan
    to: ILLEGAL
    allowed: false
    reason: "EXECUTE cannot approve plan"

  - from: EXECUTE
    event: finish_execute
    to: EVOLUTION
    allowed: true
    operations:
      prechecks: [issue_selected, feature_branch_selected, pr_created]
      effects: [finalize_execution]
      artifacts: [execution_summary.md]
      commit_policy: push_and_pr
      prompt_fragment_id: execute_to_evolution

  - from: EXECUTE
    event: finish_evolution
    to: ILLEGAL
    allowed: false
    reason: "EXECUTE cannot finish evolution"

  - from: EXECUTE
    event: block
    to: IDLE
    allowed: true
    operations:
      prechecks: []
      effects: [pause_execute]
      artifacts: []
      commit_policy: none
      prompt_fragment_id: execute_to_idle

  - from: EXECUTE
    event: go_execute
    to: EXECUTE
    allowed: true
    operations:
      prechecks: [issue_selected, feature_branch_selected]
      effects: [continue_execute]
      artifacts: []
      commit_policy: branch_required
      prompt_fragment_id: execute_continue

  - from: EVOLUTION
    event: start_analyze
    to: ILLEGAL
    allowed: false
    reason: "EVOLUTION cannot start analyze"

  - from: EVOLUTION
    event: complete_analysis
    to: ILLEGAL
    allowed: false
    reason: "EVOLUTION cannot complete analysis"

  - from: EVOLUTION
    event: approve_plan
    to: ILLEGAL
    allowed: false
    reason: "EVOLUTION cannot approve plan"

  - from: EVOLUTION
    event: finish_execute
    to: ILLEGAL
    allowed: false
    reason: "EVOLUTION cannot finish execute"

  - from: EVOLUTION
    event: finish_evolution
    to: IDLE
    allowed: true
    operations:
      prechecks: [retrospective_recorded]
      effects: [close_cycle]
      artifacts: [retrospective.md]
      commit_policy: none
      prompt_fragment_id: evolution_to_idle

  - from: EVOLUTION
    event: block
    to: IDLE
    allowed: true
    operations:
      prechecks: []
      effects: [pause_evolution]
      artifacts: []
      commit_policy: none
      prompt_fragment_id: evolution_to_idle

  - from: EVOLUTION
    event: go_execute
    to: ILLEGAL
    allowed: false
    reason: "EVOLUTION -> EXECUTE is forbidden"

preconditions:
  issue_selected_or_created:
    description: "Issue exists or has been created"
    kind: issue
  diagnosis_exists:
    description: "diagnosis.md exists for current issue"
    kind: filesystem
  issue_selected:
    description: "Issue selected in current context"
    kind: issue
  feature_branch_selected:
    description: "Current branch is issue-linked and not main"
    kind: git
  plan_approved:
    description: "User approved plan"
    kind: user-approval
  pr_created:
    description: "Pull request exists for issue branch"
    kind: github
  retrospective_recorded:
    description: "Retrospective document exists"
    kind: filesystem

prompt_fragments:
  idle_to_analyze: { role: SOCRATES, template: "analyze.clarification" }
  idle_block: { role: APE, template: "idle.blocked" }
  analyze_continue: { role: SOCRATES, template: "analyze.iterate" }
  analyze_to_plan: { role: DESCARTES, template: "plan.from_diagnosis" }
  analyze_to_idle: { role: APE, template: "analyze.pause" }
  plan_to_execute: { role: BASHO, template: "execute.phase" }
  plan_to_idle: { role: APE, template: "plan.pause" }
  execute_to_evolution: { role: DARWIN, template: "evolution.from_execution" }
  execute_to_idle: { role: APE, template: "execute.pause" }
  execute_continue: { role: BASHO, template: "execute.continue" }
  evolution_to_idle: { role: APE, template: "idle.resume" }
''');
}
