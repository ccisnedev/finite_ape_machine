library;

import 'dart:io';

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../../../fsm_contract.dart';

typedef BranchProvider = Future<String> Function(String workingDirectory);

class StateTransitionInput extends Input {
  final String? currentState;
  final String? event;
  final String workingDirectory;

  StateTransitionInput({
    required this.currentState,
    required this.event,
    required this.workingDirectory,
  });

  factory StateTransitionInput.fromCliRequest(CliRequest req) {
    return StateTransitionInput(
      currentState: req.flagString('state', aliases: const ['s']),
      event: req.flagString('event', aliases: const ['e']),
      workingDirectory: Directory.current.path,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'currentState': currentState,
    'event': event,
    'workingDirectory': workingDirectory,
  };
}

class StateTransitionOutput extends Output {
  final bool allowed;
  final String currentState;
  final String event;
  final String? nextState;
  final List<String> operationsExecuted;
  final String? promptFragmentId;
  final String? requiredRole;
  final String? requiredSkill;
  final String message;
  final int code;

  StateTransitionOutput({
    required this.allowed,
    required this.currentState,
    required this.event,
    required this.nextState,
    required this.operationsExecuted,
    required this.promptFragmentId,
    required this.requiredRole,
    required this.requiredSkill,
    required this.message,
    required this.code,
  });

  @override
  Map<String, dynamic> toJson() => {
    'allowed': allowed,
    'current_state': currentState,
    'event': event,
    'next_state': nextState,
    'operations_executed': operationsExecuted,
    'prompt_fragment_id': promptFragmentId,
    'required_role': requiredRole,
    'required_skill': requiredSkill,
    'message': message,
  };

  @override
  int get exitCode => code;

  @override
  String? toText() => message;
}

class StateTransitionCommand
    implements Command<StateTransitionInput, StateTransitionOutput> {
  @override
  final StateTransitionInput input;
  final BranchProvider branchProvider;

  StateTransitionCommand(this.input, {BranchProvider? branchProvider})
    : branchProvider = branchProvider ?? _defaultBranchProvider;

  @override
  String? validate() => null;

  @override
  Future<StateTransitionOutput> execute() async {
    if (input.event == null || input.event!.trim().isEmpty) {
      throw CommandException(
        code: 'MISSING_EVENT',
        message: 'Missing required flag --event for state transition',
        exitCode: ExitCode.validationFailed,
      );
    }

    final contractPath = p.join(
      input.workingDirectory,
      'assets',
      'fsm',
      'transition_contract.yaml',
    );
    final contract = parseFsmContract(File(contractPath).readAsStringSync());

    final current =
        input.currentState != null
            ? FsmState.fromValue(input.currentState!.trim().toUpperCase())
            : _loadCurrentState(input.workingDirectory);
    final event = FsmEvent.fromValue(input.event!.trim().toLowerCase());

    final transition = contract.transitionFor(current, event);
    if (!transition.allowed) {
      return StateTransitionOutput(
        allowed: false,
        currentState: current.value,
        event: event.value,
        nextState: null,
        operationsExecuted: const ['validate_transition'],
        promptFragmentId: null,
        requiredRole: null,
        requiredSkill: null,
        message: transition.reason ?? 'Illegal transition',
        code: ExitCode.invalidUsage,
      );
    }

    final precheckResult = await _validatePreconditions(
      transition,
      input.workingDirectory,
    );
    if (precheckResult != null) {
      return StateTransitionOutput(
        allowed: false,
        currentState: current.value,
        event: event.value,
        nextState: null,
        operationsExecuted: const ['validate_transition', 'validate_prechecks'],
        promptFragmentId: null,
        requiredRole: null,
        requiredSkill: null,
        message: precheckResult,
        code: ExitCode.validationFailed,
      );
    }

    final operations = transition.operations;
    final promptId = operations?.promptFragmentId;
    final prompt =
        promptId != null ? contract.promptFragments[promptId] : null;

    return StateTransitionOutput(
      allowed: true,
      currentState: current.value,
      event: event.value,
      nextState: transition.to?.value,
      operationsExecuted: <String>[
        'validate_transition',
        'validate_prechecks',
        ...(operations?.effects ?? const <String>[]),
      ],
      promptFragmentId: promptId,
      requiredRole: prompt?.role,
      requiredSkill: prompt?.skill,
      message:
          'Transition ${current.value} --${event.value}--> ${transition.to?.value}',
      code: ExitCode.ok,
    );
  }

  Future<String?> _validatePreconditions(
    FsmTransition transition,
    String workingDirectory,
  ) async {
    final prechecks = transition.operations?.prechecks ?? const <String>[];
    final branch = await branchProvider(workingDirectory);
    final issueSelected = _isIssueSelected(workingDirectory);

    if ((prechecks.contains('issue_selected') ||
            prechecks.contains('issue_selected_or_created')) &&
        !issueSelected) {
      return 'ERROR_PRECONDITION_ISSUE_FIRST: Create/select issue before commitment actions';
    }

    if (prechecks.contains('feature_branch_selected') &&
        (branch == 'main' || branch == 'master' || branch.isEmpty)) {
      return 'ERROR_PRECONDITION_BRANCH_POLICY: Use issue-linked feature branch, not main';
    }

    return null;
  }

  bool _isIssueSelected(String workingDirectory) {
    final contextPath = p.join(workingDirectory, '.ape', 'context.yaml');
    final contextFile = File(contextPath);
    if (!contextFile.existsSync()) return false;

    final yaml = loadYaml(contextFile.readAsStringSync());
    if (yaml is! YamlMap) return false;

    final issue = yaml['issue'];
    if (issue == null) return false;

    if (issue is String) return issue.trim().isNotEmpty;
    if (issue is int) return issue > 0;
    if (issue is YamlMap) {
      final id = issue['id'] ?? issue['number'];
      if (id is int) return id > 0;
      if (id is String) return id.trim().isNotEmpty;
    }

    return false;
  }

  FsmState _loadCurrentState(String workingDirectory) {
    final statePath = p.join(workingDirectory, '.ape', 'state.yaml');
    final file = File(statePath);
    if (!file.existsSync()) {
      return FsmState.idle;
    }

    final yaml = loadYaml(file.readAsStringSync());
    if (yaml is! YamlMap) return FsmState.idle;
    final cycle = yaml['cycle'];
    if (cycle is! YamlMap) return FsmState.idle;
    final phase = cycle['phase'];
    if (phase is! String || phase.trim().isEmpty) return FsmState.idle;
    return FsmState.fromValue(phase.trim().toUpperCase());
  }

  static Future<String> _defaultBranchProvider(String workingDirectory) async {
    final result = await Process.run(
      'git',
      ['rev-parse', '--abbrev-ref', 'HEAD'],
      workingDirectory: workingDirectory,
    );
    if (result.exitCode != 0) return '';
    return result.stdout.toString().trim();
  }
}
