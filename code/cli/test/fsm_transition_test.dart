import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:inquiry_cli/modules/fsm/commands/transition.dart';

void main() {
  group('state transition command', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('ape_state_transition_');
      _writeContract(tempDir.path);
      _writeState(tempDir.path, 'IDLE');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('rejects illegal transition IDLE + go_execute', () async {
      final input = StateTransitionInput(
        currentState: 'IDLE',
        event: 'go_execute',
        workingDirectory: tempDir.path,
      );
      final command = StateTransitionCommand(
        input,
        branchProvider: (_) async => 'main',
      );

      final output = await command.execute();

      expect(output.allowed, isFalse);
      expect(output.exitCode, 64);
      expect(output.message, contains('forbidden'));
    });

    test('returns prompt descriptor for ANALYZE -> PLAN', () async {
      _writeState(tempDir.path, 'ANALYZE', issue: '51');

      final input = StateTransitionInput(
        currentState: null,
        event: 'complete_analysis',
        workingDirectory: tempDir.path,
      );
      final command = StateTransitionCommand(
        input,
        branchProvider: (_) async => '51-idle-execution-guardrails',
      );

      final output = await command.execute();

      expect(output.allowed, isTrue);
      expect(output.nextState, 'PLAN');
      expect(output.promptFragmentId, 'analyze_to_plan');
      expect(output.requiredRole, 'DESCARTES');
      expect(output.operationsExecuted, contains('update_state'));

      // Verify state.yaml was actually updated
      final stateContent = File(
        p.join(tempDir.path, '.inquiry', 'state.yaml'),
      ).readAsStringSync();
      expect(stateContent, contains('state: PLAN'));
    });

    test('fails precheck when commitment needs issue/branch and issue missing',
        () async {
      _writeState(tempDir.path, 'PLAN');

      final input = StateTransitionInput(
        currentState: null,
        event: 'approve_plan',
        workingDirectory: tempDir.path,
      );
      final command = StateTransitionCommand(
        input,
        branchProvider: (_) async => '51-idle-execution-guardrails',
      );

      final output = await command.execute();

      expect(output.allowed, isFalse);
      expect(output.exitCode, 7);
      expect(output.message, contains('ERROR_PRECONDITION_ISSUE_FIRST'));
    });

    test('allows IDLE exploration transition without issue context', () async {
      _writeState(tempDir.path, 'IDLE');

      final input = StateTransitionInput(
        currentState: null,
        event: 'start_analyze',
        workingDirectory: tempDir.path,
      );
      final command = StateTransitionCommand(
        input,
        branchProvider: (_) async => 'main',
      );

      final output = await command.execute();

      expect(output.allowed, isTrue);
      expect(output.exitCode, 0);
      expect(output.nextState, 'ANALYZE');
      expect(output.promptFragmentId, 'idle_to_analyze');
    });

    test('blocks commitment transition on main branch', () async {
      _writeState(tempDir.path, 'PLAN', issue: '51');

      final input = StateTransitionInput(
        currentState: null,
        event: 'approve_plan',
        workingDirectory: tempDir.path,
      );
      final command = StateTransitionCommand(
        input,
        branchProvider: (_) async => 'main',
      );

      final output = await command.execute();

      expect(output.allowed, isFalse);
      expect(output.exitCode, 7);
      expect(output.message, contains('ERROR_PRECONDITION_BRANCH_POLICY'));
    });

    test('routes EXECUTE through END before PR creation', () async {
      _writeState(tempDir.path, 'EXECUTE', issue: '51');

      final output = await StateTransitionCommand(
        StateTransitionInput(
          currentState: null,
          event: 'finish_execute',
          workingDirectory: tempDir.path,
        ),
        branchProvider: (_) async => '51-idle-execution-guardrails',
      ).execute();

      expect(output.allowed, isTrue);
      expect(output.nextState, 'END');
      expect(output.promptFragmentId, 'execute_to_end');
      expect(output.requiredRole, 'APE');
    });

    test('allows END to create PR and enter EVOLUTION', () async {
      _writeState(tempDir.path, 'END', issue: '51');

      final output = await StateTransitionCommand(
        StateTransitionInput(
          currentState: null,
          event: 'pr_ready',
          workingDirectory: tempDir.path,
        ),
        branchProvider: (_) async => '51-idle-execution-guardrails',
      ).execute();

      expect(output.allowed, isTrue);
      expect(output.nextState, 'EVOLUTION');
      expect(output.promptFragmentId, 'end_to_evolution');
      expect(output.requiredRole, 'DARWIN');
    });
  });
}

void _writeState(String root, String state, {String? issue}) {
  final file = File(p.join(root, '.inquiry', 'state.yaml'));
  file.createSync(recursive: true);
  final issueLine = issue != null ? 'issue: "$issue"' : 'issue: null';
  file.writeAsStringSync('state: $state\n$issueLine\n');
}

void _writeContract(String root) {
  final source = File(
    p.join(
      Directory.current.path,
      'assets',
      'fsm',
      'transition_contract.yaml',
    ),
  );
  final file = File(p.join(root, 'assets', 'fsm', 'transition_contract.yaml'));
  file.createSync(recursive: true);
  file.writeAsStringSync(source.readAsStringSync());
}
