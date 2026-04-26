/// Parses sub-agent YAML definitions from `assets/apes/`.
library;

import 'package:yaml/yaml.dart';

class ApeTransition {
  final String event;
  final String to;

  const ApeTransition({required this.event, required this.to});
}

class ApeState {
  final String name;
  final String description;
  final String prompt;
  final List<ApeTransition> transitions;

  const ApeState({
    required this.name,
    required this.description,
    required this.prompt,
    required this.transitions,
  });
}

class ApeDefinition {
  final String name;
  final String version;
  final String description;
  final String basePrompt;
  final String initialState;
  final List<ApeState> states;

  const ApeDefinition({
    required this.name,
    required this.version,
    required this.description,
    required this.basePrompt,
    required this.initialState,
    required this.states,
  });

  /// Look up a state by name. Returns null if not found.
  ApeState? findState(String stateName) {
    for (final s in states) {
      if (s.name == stateName) return s;
    }
    return null;
  }

  /// Assemble the full prompt for a given sub-state.
  ///
  /// Returns `basePrompt + "\n\n" + state.prompt`.
  /// If [stateName] is null, returns only the base prompt.
  String assemblePrompt({String? stateName}) {
    if (stateName == null) return basePrompt;

    final state = states.firstWhere(
      (s) => s.name == stateName,
      orElse: () => throw ArgumentError('Unknown state: $stateName for APE $name'),
    );

    return '$basePrompt\n\n${state.prompt}';
  }

  /// Parse a YAML string into an [ApeDefinition].
  static ApeDefinition parse(String yamlContent) {
    final root = loadYaml(yamlContent) as YamlMap;

    final name = root['name'] as String;
    final version = root['version'] as String;
    final description = root['description'] as String;
    final basePrompt = root['base_prompt'] as String;
    final initialState = root['initial_state'] as String;

    final statesMap = root['states'] as YamlMap;
    final states = <ApeState>[];
    for (final entry in statesMap.entries) {
      final stateName = entry.key as String;
      final stateMap = entry.value as YamlMap;

      final transitionsList = <ApeTransition>[];
      final rawTransitions = stateMap['transitions'] as YamlList?;
      if (rawTransitions != null) {
        for (final t in rawTransitions) {
          final tMap = t as YamlMap;
          transitionsList.add(ApeTransition(
            event: tMap['event'] as String,
            to: tMap['to'] as String,
          ));
        }
      }

      states.add(ApeState(
        name: stateName,
        description: stateMap['description'] as String,
        prompt: stateMap['prompt'] as String,
        transitions: transitionsList,
      ));
    }

    return ApeDefinition(
      name: name,
      version: version,
      description: description,
      basePrompt: basePrompt,
      initialState: initialState,
      states: states,
    );
  }
}
