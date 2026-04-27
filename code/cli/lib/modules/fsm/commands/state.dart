library;

import 'dart:convert';
import 'dart:io';

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../../../assets.dart';
import '../../../fsm_contract.dart';
import '../../ape/ape_definition.dart';
import '../../ape/inquiry_state.dart';

class FsmStateInput extends Input {
  final String workingDirectory;

  FsmStateInput({required this.workingDirectory});

  factory FsmStateInput.fromCliRequest(CliRequest req) {
    return FsmStateInput(workingDirectory: Directory.current.path);
  }

  @override
  Map<String, dynamic> toJson() => {'workingDirectory': workingDirectory};
}

class FsmStateOutput extends Output {
  final String state;
  final String? issue;
  final List<Map<String, String>> transitions;
  final List<Map<String, String>> apes;
  final String instructions;
  final Map<String, dynamic>? ape;
  final String completionAuthority;

  FsmStateOutput({
    required this.state,
    required this.issue,
    required this.transitions,
    required this.apes,
    required this.instructions,
    this.ape,
    required this.completionAuthority,
  });

  @override
  Map<String, dynamic> toJson() => {
    'state': state,
    'issue': issue,
    'completion_authority': completionAuthority,
    'transitions': transitions,
    'apes': apes,
    'instructions': instructions,
    if (ape != null) 'ape': ape,
  };

  @override
  int get exitCode => 0;

  @override
  String? toText() {
    final buf = StringBuffer();
    buf.writeln('State: $state');
    if (issue != null) buf.writeln('Issue: $issue');

    if (apes.isNotEmpty) {
      buf.writeln('APEs:  ${apes.map((a) => a['name']).join(', ')}');
    }

    if (transitions.isNotEmpty) {
      buf.writeln('Valid transitions:');
      for (final t in transitions) {
        buf.writeln('  --${t['event']}');
      }
    }
    return buf.toString().trimRight();
  }

  String toJsonString() => const JsonEncoder.withIndent('  ').convert(toJson());
}

class FsmStateCommand implements Command<FsmStateInput, FsmStateOutput> {
  @override
  final FsmStateInput input;
  final Assets? _assets;

  FsmStateCommand(this.input, {Assets? assets}) : _assets = assets;

  @override
  String? validate() => null;

  @override
  Future<FsmStateOutput> execute() async {
    final inquiry = InquiryState.load(input.workingDirectory);
    final currentState = FsmState.fromValue(
      inquiry.state.trim().toUpperCase(),
    );

    final contractPath = _assets != null
        ? _assets.path('fsm/transition_contract.yaml')
        : p.join(input.workingDirectory, 'assets', 'fsm', 'transition_contract.yaml');
    final contract = parseFsmContract(File(contractPath).readAsStringSync());

    final validTransitions = _computeTransitions(
      contract, currentState, input.workingDirectory);
    final activeApes = _computeApes(currentState);
    final instructions = _computeInstructions(currentState);
    final apeInfo = _computeApeInfo(inquiry);
    final completionAuthority =
        contract.completionAuthority[currentState] ?? 'user';

    return FsmStateOutput(
      state: currentState.value,
      issue: inquiry.issue,
      transitions: validTransitions,
      apes: activeApes,
      instructions: instructions,
      ape: apeInfo,
      completionAuthority: completionAuthority,
    );
  }

  List<Map<String, String>> _computeTransitions(
    FsmContract contract,
    FsmState state,
    String workingDirectory,
  ) {
    final result = <Map<String, String>>[];
    for (final event in contract.events) {
      final transition = contract.transitions[(state, event)];
      if (transition != null && transition.allowed && transition.to != null) {
        result.add({
          'event': event.value,
        });
      }
    }

    // Filter END transitions based on evolution.enabled in config.yaml
    if (state == FsmState.end) {
      final evolutionEnabled = _readEvolutionEnabled(workingDirectory);
      if (evolutionEnabled) {
        result.removeWhere((t) => t['event'] == 'pr_ready_no_evolution');
      } else {
        result.removeWhere((t) => t['event'] == 'pr_ready');
      }
    }

    return result;
  }

  bool _readEvolutionEnabled(String workingDirectory) {
    final configFile = File(p.join(workingDirectory, '.inquiry', 'config.yaml'));
    if (!configFile.existsSync()) return false;
    try {
      final yaml = loadYaml(configFile.readAsStringSync());
      if (yaml is YamlMap) {
        final evolution = yaml['evolution'];
        if (evolution is YamlMap) {
          return evolution['enabled'] == true;
        }
      }
    } catch (_) {
      // If config is malformed, default to no evolution
    }
    return false;
  }

  static const _stateApes = <FsmState, List<Map<String, String>>>{
    FsmState.idle: [{'name': 'socrates-idle', 'status': 'RUNNING'}],
    FsmState.analyze: [{'name': 'socrates', 'status': 'RUNNING'}],
    FsmState.plan: [{'name': 'descartes', 'status': 'RUNNING'}],
    FsmState.execute: [{'name': 'basho', 'status': 'RUNNING'}],
    FsmState.end: [{'name': 'basho', 'status': 'RUNNING'}],
    FsmState.evolution: [{'name': 'darwin', 'status': 'RUNNING'}],
  };

  List<Map<String, String>> _computeApes(FsmState state) {
    return _stateApes[state] ?? [];
  }

  static const _stateInstructions = <FsmState, String>{
    FsmState.idle:
        'Evaluate what work merits inquiry. Understand the problem, search for existing issues, create or select an issue, prepare the branch.',
    FsmState.analyze:
        'Investigate the problem through structured questioning. Challenge assumptions, gather evidence, explore perspectives. Produce diagnosis.md.',
    FsmState.plan:
        'Design an experimental plan from the diagnosis. Divide into phases, order by dependencies, define verification for each. Produce plan.md.',
    FsmState.execute:
        'Implement the plan phase by phase under its formal constraints. Each phase produces tested code and a commit.',
    FsmState.end:
        'Review the execution. Create the pull request.',
    FsmState.evolution:
        'Evaluate the completed cycle. Observe what worked, what deviated, what can improve. Create improvement issues.',
  };

  String _computeInstructions(FsmState state) {
    return _stateInstructions[state] ?? 'Unknown state: ${state.value}';
  }

  /// Build `ape` info from InquiryState + APE YAML definition.
  Map<String, dynamic>? _computeApeInfo(InquiryState inquiry) {
    if (inquiry.apeName == null) return null;

    final name = inquiry.apeName!;
    final subState = inquiry.apeState;
    final result = <String, dynamic>{'name': name, 'state': subState};

    try {
      final yamlPath = _assets != null
          ? _assets.path('apes/$name.yaml')
          : p.join(input.workingDirectory, 'assets', 'apes', '$name.yaml');
      final content = File(yamlPath).readAsStringSync();
      final def = ApeDefinition.parse(content);
      if (subState != null) {
        final apeState = def.findState(subState);
        if (apeState != null) {
          result['transitions'] = apeState.transitions
              .map((t) => {'event': t.event})
              .toList();
        }
      }
    } catch (_) {
      // APE YAML not found — return partial info
    }

    return result;
  }
}
