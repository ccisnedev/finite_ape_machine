import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:inquiry_cli/fsm_contract.dart';

void main() {
  late FsmContract contract;

  setUpAll(() {
    final yamlPath = p.join(
      Directory.current.path,
      'assets',
      'fsm',
      'transition_contract.yaml',
    );
    final yamlContent = File(yamlPath).readAsStringSync();
    contract = parseFsmContract(yamlContent);
  });

  test('matrix is total for all known states and events', () {
    expect(() => contract.assertMatrixIsTotal(), returnsNormally);

    for (final state in contract.states) {
      for (final event in contract.events) {
        expect(
          contract.transitions.containsKey((state, event)),
          isTrue,
          reason: 'Missing transition for ${state.value} + ${event.value}',
        );
      }
    }
  });

  test('IDLE + go_execute is rejected as illegal transition', () {
    final transition = contract.transitionFor(FsmState.idle, FsmEvent.goExecute);

    expect(transition.allowed, isFalse);
    expect(transition.to, isNull);
    expect(transition.reason, contains('forbidden'));
  });

  test('allowed transitions include operations contract fields', () {
    final transition = contract.transitionFor(
      FsmState.analyze,
      FsmEvent.completeAnalysis,
    );

    expect(transition.allowed, isTrue);
    expect(transition.to, FsmState.plan);
    expect(transition.operations, isNotNull);
    expect(transition.operations!.prechecks, contains('issue_selected_or_created'));
    expect(transition.operations!.commitPolicy, 'stage_only');
    expect(transition.operations!.promptFragmentId, 'analyze_to_plan');
  });

  test('preconditions contract exists for irreversible actions', () {
    expect(contract.preconditions.keys, contains('issue_selected'));
    expect(contract.preconditions.keys, contains('feature_branch_selected'));
    expect(contract.preconditions.keys, contains('pr_created'));
  });

  test('prompt fragment contract exists for key transition', () {
    expect(contract.promptFragments.keys, contains('plan_to_execute'));
    final fragment = contract.promptFragments['plan_to_execute']!;
    expect(fragment.role, 'BASHO');
    expect(fragment.skill, 'issue-start');
    expect(fragment.template, 'execute.phase');
  });

  test('fails closed when allowed transition misses prompt fragment', () {
    final invalidYaml = '''
metadata:
  version: "1.0.0"
  description: "invalid"
states: [IDLE]
events: [start_analyze]
transitions:
  - from: IDLE
    event: start_analyze
    to: IDLE
    allowed: true
    operations:
      prechecks: []
      effects: [noop]
      artifacts: []
      commit_policy: none
      prompt_fragment_id: missing_prompt
prompt_fragments:
  idle_to_analyze:
    role: SOCRATES
    skill: memory-read
    template: "analyze.clarification"
''';

    expect(
      () => parseFsmContract(invalidYaml),
      throwsA(isA<StateError>()),
    );
  });
}
