import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:inquiry_cli/modules/state/commands/transition.dart';

void main() {
  group('state transition integration', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('ape_state_integration_');
      Directory(p.join(tempDir.path, '.ape')).createSync(recursive: true);
      _copyContractFromWorkspace(tempDir.path);
      _writeContext(tempDir.path, 'issue: 51\n');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('incident replay is prevented: IDLE cannot go_execute directly', () async {
      _writeState(tempDir.path, 'IDLE');

      final command = StateTransitionCommand(
        StateTransitionInput(
          currentState: null,
          event: 'go_execute',
          workingDirectory: tempDir.path,
        ),
        branchProvider: (_) async => 'main',
      );

      final output = await command.execute();
      expect(output.allowed, isFalse);
      expect(output.exitCode, 64);
    });

    test('full cycle uses transition command on each step', () async {
      String current = 'IDLE';
      final branch = '51-idle-execution-guardrails';

      Future<StateTransitionOutput> transition(String event) {
        return StateTransitionCommand(
          StateTransitionInput(
            currentState: current,
            event: event,
            workingDirectory: tempDir.path,
          ),
          branchProvider: (_) async => branch,
        ).execute();
      }

      final t1 = await transition('start_analyze');
      expect(t1.allowed, isTrue);
      expect(t1.nextState, 'ANALYZE');
      expect(t1.promptFragmentId, isNotNull);
      current = t1.nextState!;

      final t2 = await transition('complete_analysis');
      expect(t2.allowed, isTrue);
      expect(t2.nextState, 'PLAN');
      expect(t2.promptFragmentId, isNotNull);
      current = t2.nextState!;

      final t3 = await transition('approve_plan');
      expect(t3.allowed, isTrue);
      expect(t3.nextState, 'EXECUTE');
      expect(t3.promptFragmentId, isNotNull);
      current = t3.nextState!;

      final t4 = await transition('finish_execute');
      expect(t4.allowed, isTrue);
      expect(t4.nextState, 'EVOLUTION');
      expect(t4.promptFragmentId, isNotNull);
      current = t4.nextState!;

      final t5 = await transition('finish_evolution');
      expect(t5.allowed, isTrue);
      expect(t5.nextState, 'IDLE');
      expect(t5.promptFragmentId, isNotNull);
    });
  });
}

void _writeState(String root, String state) {
  final file = File(p.join(root, '.ape', 'state.yaml'));
  file.createSync(recursive: true);
  file.writeAsStringSync('cycle:\n  phase: $state\n');
}

void _writeContext(String root, String content) {
  final file = File(p.join(root, '.ape', 'context.yaml'));
  file.createSync(recursive: true);
  file.writeAsStringSync(content);
}

void _copyContractFromWorkspace(String root) {
  final source = File(
    p.join(
      Directory.current.path,
      'assets',
      'fsm',
      'transition_contract.yaml',
    ),
  );
  final destination = File(p.join(root, 'assets', 'fsm', 'transition_contract.yaml'));
  destination.createSync(recursive: true);
  destination.writeAsStringSync(source.readAsStringSync());
}
