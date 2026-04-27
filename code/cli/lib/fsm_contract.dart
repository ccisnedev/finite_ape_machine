library;

import 'package:yaml/yaml.dart';

enum FsmState {
  idle('IDLE'),
  analyze('ANALYZE'),
  plan('PLAN'),
  execute('EXECUTE'),
  end('END'),
  evolution('EVOLUTION');

  const FsmState(this.value);
  final String value;

  static FsmState fromValue(String value) {
    return FsmState.values.firstWhere(
      (state) => state.value == value,
      orElse: () => throw ArgumentError('Unknown state: $value'),
    );
  }
}

enum FsmEvent {
  startAnalyze('start_analyze'),
  completeAnalysis('complete_analysis'),
  approvePlan('approve_plan'),
  finishExecute('finish_execute'),
  prReady('pr_ready'),
  prReadyNoEvolution('pr_ready_no_evolution'),
  finishEvolution('finish_evolution'),
  block('block'),
  goExecute('go_execute');

  const FsmEvent(this.value);
  final String value;

  static FsmEvent fromValue(String value) {
    return FsmEvent.values.firstWhere(
      (event) => event.value == value,
      orElse: () => throw ArgumentError('Unknown event: $value'),
    );
  }
}

class TransitionOperations {
  final List<String> prechecks;
  final List<String> effects;
  final List<String> artifacts;
  final String commitPolicy;
  final String promptFragmentId;

  const TransitionOperations({
    required this.prechecks,
    required this.effects,
    required this.artifacts,
    required this.commitPolicy,
    required this.promptFragmentId,
  });
}

class FsmTransition {
  final FsmState from;
  final FsmEvent event;
  final FsmState? to;
  final bool allowed;
  final String? reason;
  final TransitionOperations? operations;

  const FsmTransition({
    required this.from,
    required this.event,
    required this.to,
    required this.allowed,
    this.reason,
    this.operations,
  });
}

class PreconditionsContract {
  final String description;
  final String kind;

  const PreconditionsContract({required this.description, required this.kind});
}

class PromptFragmentContract {
  final String role;
  final String template;
  final String skill;

  const PromptFragmentContract({
    required this.role,
    required this.template,
    required this.skill,
  });
}

class FsmContract {
  final String version;
  final String description;
  final List<FsmState> states;
  final List<FsmEvent> events;
  final Map<(FsmState, FsmEvent), FsmTransition> transitions;
  final Map<String, PreconditionsContract> preconditions;
  final Map<String, PromptFragmentContract> promptFragments;
  final Map<FsmState, String> completionAuthority;

  const FsmContract({
    required this.version,
    required this.description,
    required this.states,
    required this.events,
    required this.transitions,
    required this.preconditions,
    required this.promptFragments,
    required this.completionAuthority,
  });

  FsmTransition transitionFor(FsmState state, FsmEvent event) {
    final transition = transitions[(state, event)];
    if (transition == null) {
      throw StateError('Missing transition: ${state.value} + ${event.value}');
    }
    return transition;
  }

  void assertMatrixIsTotal() {
    for (final state in states) {
      for (final event in events) {
        if (!transitions.containsKey((state, event))) {
          throw StateError('Missing transition: ${state.value} + ${event.value}');
        }
      }
    }
  }

  void assertAllowedTransitionsHavePromptFragments() {
    for (final transition in transitions.values.where((t) => t.allowed)) {
      final promptId = transition.operations?.promptFragmentId ?? '';
      if (promptId.isEmpty) {
        throw StateError(
          'Allowed transition ${transition.from.value} + ${transition.event.value} is missing prompt_fragment_id',
        );
      }
      if (!promptFragments.containsKey(promptId)) {
        throw StateError(
          'Missing prompt fragment "$promptId" for transition ${transition.from.value} + ${transition.event.value}',
        );
      }
    }
  }
}

FsmContract parseFsmContract(String yamlContent) {
  final root = loadYaml(yamlContent) as YamlMap;

  final metadata = root['metadata'] as YamlMap;
  final states = (root['states'] as YamlList)
      .cast<String>()
      .map(FsmState.fromValue)
      .toList(growable: false);
  final events = (root['events'] as YamlList)
      .cast<String>()
      .map(FsmEvent.fromValue)
      .toList(growable: false);

  final parsedTransitions = <(FsmState, FsmEvent), FsmTransition>{};
  final transitions = (root['transitions'] as YamlList).cast<YamlMap>();

  for (final transitionMap in transitions) {
    final from = FsmState.fromValue(transitionMap['from'] as String);
    final event = FsmEvent.fromValue(transitionMap['event'] as String);
    final allowed = transitionMap['allowed'] as bool;
    final rawTo = transitionMap['to'] as String;

    TransitionOperations? operations;
    final operationsMap = transitionMap['operations'];
    if (operationsMap is YamlMap) {
      operations = TransitionOperations(
        prechecks:
            (operationsMap['prechecks'] as YamlList?)
                ?.cast<String>()
                .toList(growable: false) ??
            const [],
        effects:
            (operationsMap['effects'] as YamlList?)
                ?.cast<String>()
                .toList(growable: false) ??
            const [],
        artifacts:
            (operationsMap['artifacts'] as YamlList?)
                ?.cast<String>()
                .toList(growable: false) ??
            const [],
        commitPolicy: (operationsMap['commit_policy'] as String?) ?? 'none',
        promptFragmentId: (operationsMap['prompt_fragment_id'] as String?) ?? '',
      );
    }

    final transition = FsmTransition(
      from: from,
      event: event,
      to: rawTo == 'ILLEGAL' ? null : FsmState.fromValue(rawTo),
      allowed: allowed,
      reason: transitionMap['reason'] as String?,
      operations: operations,
    );

    parsedTransitions[(from, event)] = transition;
  }

  final parsedPreconditions = <String, PreconditionsContract>{};
  final preconditions = (root['preconditions'] as YamlMap?) ?? YamlMap();
  for (final entry in preconditions.entries) {
    final key = entry.key as String;
    final value = entry.value as YamlMap;
    parsedPreconditions[key] = PreconditionsContract(
      description: value['description'] as String,
      kind: value['kind'] as String,
    );
  }

  final parsedPromptFragments = <String, PromptFragmentContract>{};
  final fragments = (root['prompt_fragments'] as YamlMap?) ?? YamlMap();
  for (final entry in fragments.entries) {
    final key = entry.key as String;
    final value = entry.value as YamlMap;
    parsedPromptFragments[key] = PromptFragmentContract(
      role: value['role'] as String,
      template: value['template'] as String,
      skill: (value['skill'] as String?) ?? 'none',
    );
  }

  final parsedCompletionAuthority = <FsmState, String>{};
  final completionAuth = (root['completion_authority'] as YamlMap?) ?? YamlMap();
  for (final entry in completionAuth.entries) {
    final state = FsmState.fromValue(entry.key as String);
    parsedCompletionAuthority[state] = entry.value as String;
  }

  final contract = FsmContract(
    version: metadata['version'] as String,
    description: metadata['description'] as String,
    states: states,
    events: events,
    transitions: parsedTransitions,
    preconditions: parsedPreconditions,
    promptFragments: parsedPromptFragments,
    completionAuthority: parsedCompletionAuthority,
  );

  contract.assertMatrixIsTotal();
  contract.assertAllowedTransitionsHavePromptFragments();
  return contract;
}
