/// `iq ape transition --event <e>` — validates and executes APE internal transition.
library;

import 'dart:io';

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;

import '../../../assets.dart';
import '../ape_definition.dart';
import '../inquiry_state.dart';

// ─── Input ──────────────────────────────────────────────────────────────────

class ApeTransitionInput extends Input {
  final String event;
  final String workingDirectory;

  ApeTransitionInput({required this.event, required this.workingDirectory});

  factory ApeTransitionInput.fromCliRequest(CliRequest req) {
    final event = req.flagString('event', aliases: const ['e']);
    if (event == null || event.trim().isEmpty) {
      throw ArgumentError('Usage: iq ape transition --event <event>');
    }
    return ApeTransitionInput(
      event: event,
      workingDirectory: Directory.current.path,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'event': event,
    'workingDirectory': workingDirectory,
  };
}

// ─── Output ─────────────────────────────────────────────────────────────────

class ApeTransitionOutput extends Output {
  final String apeName;
  final String from;
  final String event;
  final String to;

  ApeTransitionOutput({
    required this.apeName,
    required this.from,
    required this.event,
    required this.to,
  });

  @override
  Map<String, dynamic> toJson() => {
    'ape': apeName,
    'from': from,
    'event': event,
    'to': to,
  };

  @override
  int get exitCode => ExitCode.ok;

  @override
  String? toText() => '$apeName: $from --$event--> $to';
}

// ─── Command ────────────────────────────────────────────────────────────────

class ApeTransitionCommand implements Command<ApeTransitionInput, ApeTransitionOutput> {
  @override
  final ApeTransitionInput input;
  final Assets? _assets;

  ApeTransitionCommand(this.input, {Assets? assets}) : _assets = assets;

  @override
  String? validate() {
    if (input.event.trim().isEmpty) {
      return 'Event is required. Usage: iq ape transition --event <event>';
    }
    return null;
  }

  @override
  Future<ApeTransitionOutput> execute() async {
    final inquiryState = InquiryState.load(input.workingDirectory);

    if (inquiryState.apeName == null) {
      throw StateError('NO_ACTIVE_APE: No APE is active in state ${inquiryState.state}');
    }

    final currentApeState = inquiryState.apeState;
    if (currentApeState == '_DONE') {
      throw StateError(
        'APE_COMPLETED: "${inquiryState.apeName}" has already completed (_DONE). '
        'Transition the main FSM to advance.',
      );
    }

    // Load APE definition
    final yamlPath = _resolveApePath(inquiryState.apeName!);
    final yamlFile = File(yamlPath);
    if (!yamlFile.existsSync()) {
      throw StateError(
        'APE_NOT_FOUND: No definition for "${inquiryState.apeName}" at $yamlPath',
      );
    }

    final definition = ApeDefinition.parse(yamlFile.readAsStringSync());
    final fromState = currentApeState ?? definition.initialState;
    final stateObj = definition.findState(fromState);

    if (stateObj == null) {
      throw StateError(
        'INVALID_APE_STATE: "${inquiryState.apeName}" has no state "$fromState"',
      );
    }

    // Find matching transition
    ApeTransition? match;
    for (final t in stateObj.transitions) {
      if (t.event == input.event) {
        match = t;
        break;
      }
    }

    if (match == null) {
      final valid = stateObj.transitions.map((t) => t.event).join(', ');
      throw StateError(
        'INVALID_APE_EVENT: "${input.event}" is not valid from '
        '"${inquiryState.apeName}:$fromState". Valid events: [$valid]',
      );
    }

    // Write the new sub-state
    final newState = inquiryState.copyWith(apeState: match.to);
    newState.save(input.workingDirectory);

    return ApeTransitionOutput(
      apeName: inquiryState.apeName!,
      from: fromState,
      event: input.event,
      to: match.to,
    );
  }

  String _resolveApePath(String name) {
    if (_assets != null) {
      return _assets.path('apes/$name.yaml');
    }
    return p.join(input.workingDirectory, 'assets', 'apes', '$name.yaml');
  }
}
