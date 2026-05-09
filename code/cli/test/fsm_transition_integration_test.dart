import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:inquiry_cli/modules/fsm/commands/transition.dart';

void main() {
  group('state transition integration', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('ape_state_integration_');
      _copyContractFromWorkspace(tempDir.path);
      _initGitRepo(tempDir.path, branch: '51-idle-execution-guardrails');
      _writeState(tempDir.path, 'IDLE', issue: '51');
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

    test('IDLE leaves only after the explicit-start handoff is prepared',
        () async {
      _writeState(tempDir.path, 'IDLE', issue: '51');

      final blocked = await StateTransitionCommand(
        StateTransitionInput(
          currentState: null,
          event: 'start_analyze',
          workingDirectory: tempDir.path,
        ),
        branchProvider: (_) async => 'main',
      ).execute();

      expect(blocked.allowed, isFalse);
      expect(blocked.nextState, isNull);
      expect(
        File(p.join(tempDir.path, '.inquiry', 'state.yaml')).readAsStringSync(),
        contains('state: IDLE'),
      );

      final allowed = await StateTransitionCommand(
        StateTransitionInput(
          currentState: null,
          event: 'start_analyze',
          workingDirectory: tempDir.path,
        ),
        branchProvider: (_) async => '51-idle-execution-guardrails',
      ).execute();

      expect(allowed.allowed, isTrue);
      expect(allowed.nextState, 'ANALYZE');
      expect(allowed.promptFragmentId, 'idle_to_analyze');
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

      final analysisCommitsBefore = _commitCount(tempDir.path);
      _writeDiagnosis(tempDir.path, branch, 'diagnosis ready');
      final t2 = await transition('complete_analysis');
      expect(t2.allowed, isTrue);
      expect(t2.nextState, 'PLAN');
      expect(t2.promptFragmentId, isNotNull);
      expect(_commitCount(tempDir.path), analysisCommitsBefore + 1);
      current = t2.nextState!;

      final planCommitsBefore = _commitCount(tempDir.path);
      _writePlan(tempDir.path, branch, '# plan\n');
      final t3 = await transition('approve_plan');
      expect(t3.allowed, isTrue);
      expect(t3.nextState, 'EXECUTE');
      expect(t3.promptFragmentId, isNotNull);
      expect(_commitCount(tempDir.path), planCommitsBefore + 1);
      current = t3.nextState!;

      final t4 = await transition('finish_execute');
      expect(t4.allowed, isTrue);
      expect(t4.nextState, 'END');
      expect(t4.promptFragmentId, isNotNull);
      current = t4.nextState!;

      final t5 = await transition('pr_ready');
      expect(t5.allowed, isTrue);
      expect(t5.nextState, 'EVOLUTION');
      expect(t5.promptFragmentId, isNotNull);

      current = t5.nextState!;

      final t6 = await transition('finish_evolution');
      expect(t6.allowed, isTrue);
      expect(t6.nextState, 'IDLE');
      expect(t6.promptFragmentId, isNotNull);
    });
  });
}

void _writeState(String root, String state, {String? issue}) {
  final file = File(p.join(root, '.inquiry', 'state.yaml'));
  file.createSync(recursive: true);
  final issueLine = issue != null ? 'issue: "$issue"' : 'issue: null';
  file.writeAsStringSync('state: $state\n$issueLine\n');
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

void _writeDiagnosis(String root, String branch, String content) {
  final file = File(
    p.join(root, 'cleanrooms', branch, 'analyze', 'diagnosis.md'),
  );
  file.createSync(recursive: true);
  file.writeAsStringSync(content);
}

void _writePlan(String root, String branch, String content) {
  final file = File(p.join(root, 'cleanrooms', branch, 'plan.md'));
  file.createSync(recursive: true);
  file.writeAsStringSync(content);
}

void _initGitRepo(String root, {required String branch}) {
  _git(root, ['init']);
  _git(root, ['config', 'user.email', 'test@test.com']);
  _git(root, ['config', 'user.name', 'Test']);
  File(p.join(root, '.gitkeep')).writeAsStringSync('');
  _git(root, ['add', '.']);
  _git(root, ['commit', '-m', 'init']);
  _git(root, ['checkout', '-b', branch]);
}

int _commitCount(String root) {
  final result = _git(root, ['rev-list', '--count', 'HEAD']);
  return int.parse(result.stdout.trim());
}

ProcessResult _git(String root, List<String> args) {
  final result = Process.runSync('git', args, workingDirectory: root);
  if (result.exitCode != 0) {
    fail('git ${args.join(' ')} failed: ${result.stderr}');
  }
  return result;
}
