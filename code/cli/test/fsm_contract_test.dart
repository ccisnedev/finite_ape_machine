import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:inquiry_cli/fsm_contract.dart';
import 'package:inquiry_cli/modules/ape/operational_contract.dart';

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
    expect(contract.states, contains(FsmState.end));

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

  test('state assets expose phase-owned operational contract for every FSM state', () {
    final loader = OperationalContractLoader(
      workingDirectory: Directory.current.path,
    );

    for (final state in FsmState.values) {
      final operationalContract = loader.load(state);

      expect(
        operationalContract.toJson()['state'],
        equals(state.value),
        reason: 'Operational contract should keep the owning FSM state visible',
      );
      expect(
        operationalContract.instructions,
        isNotEmpty,
        reason: 'Operational contract for ${state.value} should expose instructions',
      );
      expect(
        operationalContract.constraints,
        isNotEmpty,
        reason: 'Operational contract for ${state.value} should expose constraints',
      );
      expect(
        operationalContract.allowedActions,
        isNotEmpty,
        reason: 'Operational contract for ${state.value} should expose allowed actions',
      );
    }
  });

  test('IDLE + go_execute is rejected as illegal transition', () {
    final transition = contract.transitionFor(FsmState.idle, FsmEvent.goExecute);

    expect(transition.allowed, isFalse);
    expect(transition.to, isNull);
    expect(transition.reason, contains('forbidden'));
  });

  test('approval boundaries expose explicit commit policies', () {
    final analyzeTransition = contract.transitionFor(
      FsmState.analyze,
      FsmEvent.completeAnalysis,
    );
    final planTransition = contract.transitionFor(
      FsmState.plan,
      FsmEvent.approvePlan,
    );

    expect(analyzeTransition.allowed, isTrue);
    expect(analyzeTransition.to, FsmState.plan);
    expect(analyzeTransition.operations, isNotNull);
    expect(
      analyzeTransition.operations!.prechecks,
      contains('issue_selected_or_created'),
    );
    expect(
      analyzeTransition.operations!.commitPolicy,
      'commit_analysis_boundary',
    );
    expect(analyzeTransition.operations!.promptFragmentId, 'analyze_to_plan');

    expect(planTransition.allowed, isTrue);
    expect(planTransition.to, FsmState.execute);
    expect(planTransition.operations, isNotNull);
    expect(planTransition.operations!.prechecks, contains('plan_approved'));
    expect(
      planTransition.operations!.commitPolicy,
      'commit_plan_boundary',
    );
    expect(planTransition.operations!.promptFragmentId, 'plan_to_execute');
  });

  test('IDLE -> ANALYZE exposes only external handoff metadata', () {
    final idleTransition = contract.transitionFor(
      FsmState.idle,
      FsmEvent.startAnalyze,
    );

    expect(idleTransition.allowed, isTrue);
    expect(idleTransition.to, FsmState.analyze);
    expect(idleTransition.operations, isNotNull);
    expect(
      idleTransition.operations!.prechecks,
      equals(['issue_selected_or_created', 'feature_branch_selected']),
    );
    expect(idleTransition.operations!.promptFragmentId, 'idle_to_analyze');

    final issueReady = contract.preconditions['issue_selected_or_created']!;
    final branchReady = contract.preconditions['feature_branch_selected']!;
    expect(issueReady.description, contains('IDLE TRIAGE'));
    expect(branchReady.description, contains('issue-start'));

    final fragment = contract.promptFragments['idle_to_analyze']!;
    expect(fragment.role, 'SOCRATES');
    expect(fragment.skill, 'doc-read');
    expect(fragment.template, 'analyze.clarification');
  });

  test('EXECUTE passes through END before PR creation', () {
    final finishExecution = contract.transitionFor(
      FsmState.execute,
      FsmEvent.finishExecute,
    );
    final createPr = contract.transitionFor(FsmState.end, FsmEvent.prReady);
    final skipEvolution = contract.transitionFor(
      FsmState.end,
      FsmEvent.prReadyNoEvolution,
    );

    expect(finishExecution.allowed, isTrue);
    expect(finishExecution.to, FsmState.end);
    expect(finishExecution.operations!.promptFragmentId, 'execute_to_end');

    expect(createPr.allowed, isTrue);
    expect(createPr.to, FsmState.evolution);
    expect(createPr.operations!.promptFragmentId, 'end_to_evolution');

    expect(skipEvolution.allowed, isTrue);
    expect(skipEvolution.to, FsmState.idle);
    expect(skipEvolution.operations!.promptFragmentId, 'end_to_idle');
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
    skill: doc-read
    template: "analyze.clarification"
''';

    expect(
      () => parseFsmContract(invalidYaml),
      throwsA(isA<StateError>()),
    );
  });
}
