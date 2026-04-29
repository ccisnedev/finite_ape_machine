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
  final String? event;
  final String workingDirectory;

  ApeTransitionInput({required this.event, required this.workingDirectory});

  factory ApeTransitionInput.fromCliRequest(CliRequest req) {
    return ApeTransitionInput(
      event: req.flagString('event', aliases: const ['e']),
      workingDirectory: Directory.current.path,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    if (event != null) 'event': event,
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
  String? validate() => null;

  @override
  Future<ApeTransitionOutput> execute() async {
    if (input.event == null || input.event!.trim().isEmpty) {
      throw CommandException(
        code: 'MISSING_EVENT',
        message: 'Missing required flag --event. Usage: iq ape transition --event <event>',
        exitCode: ExitCode.validationFailed,
      );
    }
    final inquiryState = InquiryState.load(input.workingDirectory);

    if (inquiryState.apeName == null) {
      throw CommandException(
        code: 'NO_ACTIVE_APE',
        message: 'No APE is active in state ${inquiryState.state}',
        exitCode: ExitCode.conflict,
      );
    }

    final currentApeState = inquiryState.apeState;
    if (currentApeState == '_DONE') {
      throw CommandException(
        code: 'APE_COMPLETED',
        message: '"${inquiryState.apeName}" has already completed (_DONE). '
            'Transition the main FSM to advance.',
        exitCode: ExitCode.conflict,
      );
    }

    // Load APE definition
    final yamlPath = _resolveApePath(inquiryState.apeName!);
    final yamlFile = File(yamlPath);
    if (!yamlFile.existsSync()) {
      throw CommandException(
        code: 'APE_NOT_FOUND',
        message: 'No definition for "${inquiryState.apeName}" at $yamlPath',
        exitCode: ExitCode.notFound,
      );
    }

    final definition = ApeDefinition.parse(yamlFile.readAsStringSync());
    final fromState = currentApeState ?? definition.initialState;
    final stateObj = definition.findState(fromState);

    if (stateObj == null) {
      throw CommandException(
        code: 'INVALID_APE_STATE',
        message: '"${inquiryState.apeName}" has no state "$fromState"',
        exitCode: ExitCode.conflict,
      );
    }

    // Find matching transition
    ApeTransition? match;
    for (final t in stateObj.transitions) {
      if (t.event == input.event!) {
        match = t;
        break;
      }
    }

    if (match == null) {
      final valid = stateObj.transitions.map((t) => t.event).join(', ');
      throw CommandException(
        code: 'INVALID_APE_EVENT',
        message: '"${input.event}" is not valid from '
            '"${inquiryState.apeName}:$fromState". Valid events: [$valid]',
        exitCode: ExitCode.validationFailed,
      );
    }

    // Gate: basho commit→implement requires a new commit
    if (inquiryState.apeName == 'basho' &&
        fromState == 'commit' &&
        match.to == 'implement') {
      final hasCommit = _hasUnpushedCommitSinceLastTransition();
      if (!hasCommit) {
        throw CommandException(
          code: 'COMMIT_REQUIRED',
          message: 'Cannot advance to next phase without committing. '
              'Commit your changes first, then retry.',
          exitCode: ExitCode.validationFailed,
        );
      }
    }

    // Write the new sub-state
    final newState = inquiryState.copyWith(apeState: match.to);
    newState.save(input.workingDirectory);

    return ApeTransitionOutput(
      apeName: inquiryState.apeName!,
      from: fromState,
      event: input.event!,
      to: match.to,
    );
  }

  String _resolveApePath(String name) {
    if (_assets != null) {
      return _assets.path('apes/$name.yaml');
    }
    return p.join(input.workingDirectory, 'assets', 'apes', '$name.yaml');
  }

  /// Check if there's at least one commit on the current branch since
  /// it diverged from the default branch (main or master).
  bool _hasUnpushedCommitSinceLastTransition() {
    try {
      // Determine default branch
      final defaultBranch = _resolveDefaultBranch();
      if (defaultBranch == null) {
        // No main/master found — can't validate, allow transition
        return true;
      }

      // Count commits on HEAD that are not on the default branch
      final result = Process.runSync(
        'git',
        ['rev-list', '--count', '$defaultBranch..HEAD'],
        workingDirectory: input.workingDirectory,
      );
      if (result.exitCode == 0) {
        final count = int.tryParse((result.stdout as String).trim()) ?? 0;
        return count > 0;
      }
      return true; // git failed — don't block
    } catch (_) {
      // If git fails, don't block — allow transition
      return true;
    }
  }

  String? _resolveDefaultBranch() {
    for (final branch in ['main', 'master']) {
      final result = Process.runSync(
        'git',
        ['rev-parse', '--verify', branch],
        workingDirectory: input.workingDirectory,
      );
      if (result.exitCode == 0) return branch;
    }
    return null;
  }
}
