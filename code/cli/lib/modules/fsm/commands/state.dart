library;

import 'dart:convert';
import 'dart:io';

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../../../assets.dart';
import '../../../fsm_contract.dart';

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

  FsmStateOutput({
    required this.state,
    required this.issue,
    required this.transitions,
    required this.apes,
    required this.instructions,
  });

  @override
  Map<String, dynamic> toJson() => {
    'state': state,
    'issue': issue,
    'transitions': transitions,
    'apes': apes,
    'instructions': instructions,
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
        buf.writeln('  --${t['event']}--> ${t['next_state']}');
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
    final currentState = _loadCurrentState(input.workingDirectory);
    final issue = _loadIssue(input.workingDirectory);

    final contractPath = _assets != null
        ? _assets.path('fsm/transition_contract.yaml')
        : p.join(input.workingDirectory, 'assets', 'fsm', 'transition_contract.yaml');
    final contract = parseFsmContract(File(contractPath).readAsStringSync());

    final validTransitions = _computeTransitions(contract, currentState);
    final activeApes = _computeApes(currentState);
    final instructions = _computeInstructions(currentState);

    return FsmStateOutput(
      state: currentState.value,
      issue: issue,
      transitions: validTransitions,
      apes: activeApes,
      instructions: instructions,
    );
  }

  List<Map<String, String>> _computeTransitions(
    FsmContract contract,
    FsmState state,
  ) {
    final result = <Map<String, String>>[];
    for (final event in contract.events) {
      final transition = contract.transitions[(state, event)];
      if (transition != null && transition.allowed && transition.to != null) {
        result.add({
          'event': event.value,
          'next_state': transition.to!.value,
        });
      }
    }
    return result;
  }

  static const _stateApes = <FsmState, List<Map<String, String>>>{
    FsmState.idle: [],
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
        'IDLE: No active cycle. Use `iq fsm transition --event start_analyze` to begin.',
    FsmState.analyze:
        'ANALYZE: socrates is investigating. Produce diagnosis.md, then `iq fsm transition --event complete_analysis`.',
    FsmState.plan:
        'PLAN: descartes is structuring the plan. Produce plan.md, then `iq fsm transition --event approve_plan`.',
    FsmState.execute:
        'EXECUTE: basho is implementing. Complete the work, then `iq fsm transition --event finish_execute`.',
    FsmState.end:
        'END: basho is finalizing. Create PR with `iq fsm transition --event pr_ready`.',
    FsmState.evolution:
        'EVOLUTION: darwin is reviewing mutations.md. Complete with `iq fsm transition --event finish_evolution`.',
  };

  String _computeInstructions(FsmState state) {
    return _stateInstructions[state] ?? 'Unknown state: ${state.value}';
  }

  FsmState _loadCurrentState(String workingDirectory) {
    final statePath = p.join(workingDirectory, '.inquiry', 'state.yaml');
    final file = File(statePath);
    if (!file.existsSync()) return FsmState.idle;

    final yaml = loadYaml(file.readAsStringSync());
    if (yaml is! YamlMap) return FsmState.idle;
    final phase = yaml['state'];
    if (phase is! String || phase.trim().isEmpty) return FsmState.idle;
    return FsmState.fromValue(phase.trim().toUpperCase());
  }

  String? _loadIssue(String workingDirectory) {
    final statePath = p.join(workingDirectory, '.inquiry', 'state.yaml');
    final file = File(statePath);
    if (!file.existsSync()) return null;

    final yaml = loadYaml(file.readAsStringSync());
    if (yaml is! YamlMap) return null;
    final task = yaml['issue'];
    if (task == null) return null;
    if (task is String) return task.isEmpty ? null : task;
    return task.toString();
  }
}
