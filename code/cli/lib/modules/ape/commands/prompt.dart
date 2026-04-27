/// `iq ape prompt <name>` — assembles a sub-agent prompt from YAML + FSM state.
///
/// Reads the YAML definition from `assets/apes/<name>.yaml`,
/// verifies the sub-agent is active in the current FSM state,
/// and returns the assembled prompt (base + optional sub-state).
library;

import 'dart:io';

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;

import '../../../assets.dart';
import '../../../fsm_contract.dart';
import '../ape_definition.dart';
import '../inquiry_state.dart';

// ─── Input ──────────────────────────────────────────────────────────────────

class ApePromptInput extends Input {
  final String? name;
  final String? subState;
  final String workingDirectory;

  ApePromptInput({
    required this.name,
    this.subState,
    required this.workingDirectory,
  });

  factory ApePromptInput.fromCliRequest(CliRequest req) {
    return ApePromptInput(
      name: req.flagString('name', aliases: const ['n']),
      subState: req.flagString('state', aliases: const ['s']),
      workingDirectory: Directory.current.path,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (subState != null) 'subState': subState,
    'workingDirectory': workingDirectory,
  };
}

// ─── Output ─────────────────────────────────────────────────────────────────

class ApePromptOutput extends Output {
  final String apeName;
  final String fsmState;
  final String? subState;
  final String prompt;

  ApePromptOutput({
    required this.apeName,
    required this.fsmState,
    this.subState,
    required this.prompt,
  });

  @override
  Map<String, dynamic> toJson() => {
    'ape': apeName,
    'fsm_state': fsmState,
    if (subState != null) 'sub_state': subState,
    'prompt': prompt,
  };

  @override
  int get exitCode => ExitCode.ok;

  @override
  String? toText() => prompt;
}

// ─── Command ────────────────────────────────────────────────────────────────

/// Assembles a sub-agent prompt from its YAML definition + current FSM state.
class ApePromptCommand implements Command<ApePromptInput, ApePromptOutput> {
  @override
  final ApePromptInput input;
  final Assets? _assets;

  ApePromptCommand(this.input, {Assets? assets}) : _assets = assets;

  /// Maps FSM states to their active sub-agent names.
  static const _stateApes = <FsmState, List<String>>{
    FsmState.idle: [],
    FsmState.analyze: ['socrates'],
    FsmState.plan: ['descartes'],
    FsmState.execute: ['basho'],
    FsmState.end: ['basho'],
    FsmState.evolution: ['darwin'],
  };

  @override
  String? validate() => null;

  @override
  Future<ApePromptOutput> execute() async {
    if (input.name == null || input.name!.trim().isEmpty) {
      throw CommandException(
        code: 'MISSING_NAME',
        message: 'Missing required flag --name. Usage: iq ape prompt --name <name>',
        exitCode: ExitCode.validationFailed,
      );
    }
    final inquiry = InquiryState.load(input.workingDirectory);
    final currentState = FsmState.fromValue(
      inquiry.state.trim().toUpperCase(),
    );

    // Verify the APE exists
    final yamlPath = _resolveApePath(input.name!);
    final yamlFile = File(yamlPath);
    if (!yamlFile.existsSync()) {
      throw CommandException(
        code: 'APE_NOT_FOUND',
        message: 'No definition found for "${input.name!}" at $yamlPath',
        exitCode: ExitCode.notFound,
      );
    }

    // Verify the APE is active in the current FSM state
    final activeApes = _stateApes[currentState] ?? [];
    if (!activeApes.contains(input.name!)) {
      throw CommandException(
        code: 'APE_NOT_ACTIVE',
        message: '"${input.name!}" is not active in state '
            '${currentState.value}. Active APEs: ${activeApes.join(', ')}',
        exitCode: ExitCode.conflict,
      );
    }

    // Resolve sub-state: explicit flag > state.yaml > null
    final resolvedSubState = input.subState ?? inquiry.apeState;

    // Parse and assemble
    final definition = ApeDefinition.parse(yamlFile.readAsStringSync());
    final prompt = definition.assemblePrompt(stateName: resolvedSubState);

    return ApePromptOutput(
      apeName: input.name!,
      fsmState: currentState.value,
      subState: resolvedSubState,
      prompt: prompt,
    );
  }

  String _resolveApePath(String name) {
    if (_assets != null) {
      return _assets.path('apes/$name.yaml');
    }
    return p.join(input.workingDirectory, 'assets', 'apes', '$name.yaml');
  }

}
