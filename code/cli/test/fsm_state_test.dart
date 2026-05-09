import 'dart:io';

import 'package:inquiry_cli/modules/fsm/commands/state.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('fsm_state_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  /// Creates a minimal test workspace with .inquiry/state.yaml and
  /// assets/fsm/transition_contract.yaml.
  void setupWorkspace({
    required String state,
    String? issue,
    String? apeName,
    String? apeState,
  }) {
    // .inquiry/state.yaml
    Directory('${tempDir.path}/.inquiry').createSync(recursive: true);
    final buf = StringBuffer();
    buf.writeln('state: $state');
    buf.writeln('issue: ${issue != null ? '"$issue"' : 'null'}');
    if (apeName != null) {
      buf.writeln('ape:');
      buf.writeln('  name: $apeName');
      buf.writeln('  state: ${apeState ?? 'null'}');
    } else {
      buf.writeln('ape: null');
    }
    File('${tempDir.path}/.inquiry/state.yaml')
        .writeAsStringSync(buf.toString());

    // Copy real contract from project assets
    final contractSource = File('assets/fsm/transition_contract.yaml');
    final contractDir = Directory('${tempDir.path}/assets/fsm');
    contractDir.createSync(recursive: true);
    contractSource.copySync('${contractDir.path}/transition_contract.yaml');

    // Copy APE YAMLs
    final apesDir = Directory('${tempDir.path}/assets/apes');
    apesDir.createSync(recursive: true);
    for (final name in ['socrates', 'descartes', 'basho', 'darwin']) {
      final src = File('assets/apes/$name.yaml');
      if (src.existsSync()) {
        src.copySync('${apesDir.path}/$name.yaml');
      }
    }

    // Copy state instruction YAMLs
    final statesDir = Directory('${tempDir.path}/assets/fsm/states');
    statesDir.createSync(recursive: true);
    for (final name in ['idle', 'analyze', 'plan', 'execute', 'end', 'evolution']) {
      final src = File('assets/fsm/states/$name.yaml');
      if (src.existsSync()) {
        src.copySync('${statesDir.path}/$name.yaml');
      }
    }
  }

  group('FsmStateCommand', () {
    group('JSON output structure', () {
      test('returns state, task, transitions, apes, and instructions', () async {
        setupWorkspace(state: 'ANALYZE', issue: '145');

        final command = FsmStateCommand(FsmStateInput(
          workingDirectory: tempDir.path,
        ));
        final result = await command.execute();
        final json = result.toJson();

        expect(json['state'], equals('ANALYZE'));
        expect(json['issue'], equals('145'));
        expect(json['transitions'], isList);
        expect(json['apes'], isList);
        expect(json['instructions'], isA<String>());
      });

      test('returns operational contract sourced from state assets', () async {
        setupWorkspace(state: 'EXECUTE', issue: '145');

        final command = FsmStateCommand(FsmStateInput(
          workingDirectory: tempDir.path,
        ));
        final result = await command.execute();
        final json = result.toJson();
        final operationalContract =
            json['operational_contract'] as Map<String, dynamic>?;

        expect(operationalContract, isNotNull);
        expect(
          operationalContract!['instructions'],
          contains('Implement the plan phase by phase under its formal constraints.'),
        );
        expect(
          operationalContract['constraints'],
          contains('Follow plan.md phases in order'),
        );
        expect(
          operationalContract['allowed_actions'],
          contains('Edit code files'),
        );
      });

      test('IDLE state has no task', () async {
        setupWorkspace(state: 'IDLE');

        final command = FsmStateCommand(FsmStateInput(
          workingDirectory: tempDir.path,
        ));
        final result = await command.execute();
        final json = result.toJson();

        expect(json['state'], equals('IDLE'));
        expect(json['issue'], isNull);
      });
    });

    group('valid transitions', () {
      test('ANALYZE includes complete_analysis and block', () async {
        setupWorkspace(state: 'ANALYZE', issue: '145');

        final command = FsmStateCommand(FsmStateInput(
          workingDirectory: tempDir.path,
        ));
        final result = await command.execute();
        final transitions = result.toJson()['transitions'] as List;
        final events = transitions.map((t) => t['event']).toList();

        expect(events, contains('complete_analysis'));
        expect(events, contains('block'));
        expect(events, isNot(contains('approve_plan')));
      });

      test('IDLE includes start_analyze only', () async {
        setupWorkspace(state: 'IDLE');

        final command = FsmStateCommand(FsmStateInput(
          workingDirectory: tempDir.path,
        ));
        final result = await command.execute();
        final transitions = result.toJson()['transitions'] as List;
        final events = transitions.map((t) => t['event']).toList();

        expect(events, contains('start_analyze'));
        expect(events, isNot(contains('complete_analysis')));
      });

      test('each transition has event only', () async {
        setupWorkspace(state: 'PLAN', issue: '145');

        final command = FsmStateCommand(FsmStateInput(
          workingDirectory: tempDir.path,
        ));
        final result = await command.execute();
        final transitions = result.toJson()['transitions'] as List;

        for (final t in transitions) {
          expect(t, contains('event'));
          expect(t.keys, isNot(contains('next_state')));
        }
      });
    });

    group('active APEs', () {
      test('ANALYZE has socrates running', () async {
        setupWorkspace(state: 'ANALYZE', issue: '145');

        final command = FsmStateCommand(FsmStateInput(
          workingDirectory: tempDir.path,
        ));
        final result = await command.execute();
        final apes = result.toJson()['apes'] as List;

        expect(apes, hasLength(1));
        expect(apes[0]['name'], equals('socrates'));
        expect(apes[0]['status'], equals('RUNNING'));
      });

      test('IDLE has dewey active', () async {
        setupWorkspace(state: 'IDLE');

        final command = FsmStateCommand(FsmStateInput(
          workingDirectory: tempDir.path,
        ));
        final result = await command.execute();
        final apes = result.toJson()['apes'] as List;

        expect(apes, hasLength(1));
        expect(apes.first['name'], equals('dewey'));
      });

      test('PLAN has descartes running', () async {
        setupWorkspace(state: 'PLAN', issue: '145');

        final command = FsmStateCommand(FsmStateInput(
          workingDirectory: tempDir.path,
        ));
        final result = await command.execute();
        final apes = result.toJson()['apes'] as List;

        expect(apes, hasLength(1));
        expect(apes[0]['name'], equals('descartes'));
      });

      test('EXECUTE has basho running', () async {
        setupWorkspace(state: 'EXECUTE', issue: '145');

        final command = FsmStateCommand(FsmStateInput(
          workingDirectory: tempDir.path,
        ));
        final result = await command.execute();
        final apes = result.toJson()['apes'] as List;

        expect(apes, hasLength(1));
        expect(apes[0]['name'], equals('basho'));
      });

      test('EVOLUTION has darwin running', () async {
        setupWorkspace(state: 'EVOLUTION', issue: '145');

        final command = FsmStateCommand(FsmStateInput(
          workingDirectory: tempDir.path,
        ));
        final result = await command.execute();
        final apes = result.toJson()['apes'] as List;

        expect(apes, hasLength(1));
        expect(apes[0]['name'], equals('darwin'));
      });
    });

    group('instructions', () {
      test('ANALYZE instructions describe the mission', () async {
        setupWorkspace(state: 'ANALYZE', issue: '145');

        final command = FsmStateCommand(FsmStateInput(
          workingDirectory: tempDir.path,
        ));
        final result = await command.execute();

        expect(result.toJson()['instructions'], contains('Investigate'));
        expect(result.toJson()['instructions'], contains('diagnosis.md'));
      });

      test('IDLE instructions describe TRIAGE issue creation and DONE handoff', () async {
        setupWorkspace(state: 'IDLE');

        final command = FsmStateCommand(FsmStateInput(
          workingDirectory: tempDir.path,
        ));
        final result = await command.execute();

        expect(result.toJson()['instructions'], contains('TRIAGE'));
        expect(result.toJson()['instructions'], contains('DONE'));
        expect(result.toJson()['instructions'], contains('issue-create'));
        expect(result.toJson()['instructions'], contains('issue-start'));
        expect(result.toJson()['instructions'], contains('start_analyze'));
      });
    });

    group('missing workspace', () {
      test('defaults to IDLE when .inquiry/state.yaml missing', () async {
        // No setupWorkspace — but need contract and state YAMLs
        final contractDir = Directory('${tempDir.path}/assets/fsm');
        contractDir.createSync(recursive: true);
        final contractSource = File('assets/fsm/transition_contract.yaml');
        contractSource.copySync('${contractDir.path}/transition_contract.yaml');

        final statesDir = Directory('${tempDir.path}/assets/fsm/states');
        statesDir.createSync(recursive: true);
        for (final name in ['idle', 'analyze', 'plan', 'execute', 'end', 'evolution']) {
          final src = File('assets/fsm/states/$name.yaml');
          if (src.existsSync()) {
            src.copySync('${statesDir.path}/$name.yaml');
          }
        }

        final command = FsmStateCommand(FsmStateInput(
          workingDirectory: tempDir.path,
        ));
        final result = await command.execute();

        expect(result.toJson()['state'], equals('IDLE'));
        expect(result.toJson()['issue'], isNull);
      });
    });

    group('toText()', () {
      test('returns formatted text output', () async {
        setupWorkspace(state: 'ANALYZE', issue: '145');

        final command = FsmStateCommand(FsmStateInput(
          workingDirectory: tempDir.path,
        ));
        final result = await command.execute();
        final text = result.toText();

        expect(text, isNotNull);
        expect(text, contains('ANALYZE'));
      });
    });

    group('ape field in JSON', () {
      test('includes ape info when APE is active', () async {
        setupWorkspace(
          state: 'ANALYZE',
          issue: '145',
          apeName: 'socrates',
          apeState: 'clarification',
        );

        final command = FsmStateCommand(FsmStateInput(
          workingDirectory: tempDir.path,
        ));
        final result = await command.execute();
        final json = result.toJson();

        expect(json['ape'], isNotNull);
        expect(json['ape']['name'], equals('socrates'));
        expect(json['ape']['state'], equals('clarification'));
        expect(json['ape']['transitions'], isList);
      });

      test('ape transitions match current sub-state', () async {
        setupWorkspace(
          state: 'PLAN',
          issue: '145',
          apeName: 'descartes',
          apeState: 'decomposition',
        );

        final command = FsmStateCommand(FsmStateInput(
          workingDirectory: tempDir.path,
        ));
        final result = await command.execute();
        final ape = result.toJson()['ape'] as Map<String, dynamic>;
        final transitions = ape['transitions'] as List;
        final events = transitions.map((t) => t['event']).toList();

        expect(events, contains('next'));
      });

      test('omits ape field when no APE active', () async {
        setupWorkspace(state: 'IDLE');

        final command = FsmStateCommand(FsmStateInput(
          workingDirectory: tempDir.path,
        ));
        final result = await command.execute();
        final json = result.toJson();

        expect(json.containsKey('ape'), isFalse);
      });

      test('ape _DONE has no transitions list', () async {
        setupWorkspace(
          state: 'ANALYZE',
          issue: '145',
          apeName: 'socrates',
          apeState: '_DONE',
        );

        final command = FsmStateCommand(FsmStateInput(
          workingDirectory: tempDir.path,
        ));
        final result = await command.execute();
        final ape = result.toJson()['ape'] as Map<String, dynamic>;

        expect(ape['name'], equals('socrates'));
        expect(ape['state'], equals('_DONE'));
        // _DONE should have no transitions (findState returns null for _DONE)
        expect(ape.containsKey('transitions'), isFalse);
      });
    });

    group('completion_authority', () {
      test('ANALYZE has completion_authority: user', () async {
        setupWorkspace(state: 'ANALYZE', issue: '145');

        final command = FsmStateCommand(FsmStateInput(
          workingDirectory: tempDir.path,
        ));
        final result = await command.execute();
        final json = result.toJson();

        expect(json['completion_authority'], equals('user'));
      });

      test('PLAN has completion_authority: user', () async {
        setupWorkspace(state: 'PLAN', issue: '145');

        final command = FsmStateCommand(FsmStateInput(
          workingDirectory: tempDir.path,
        ));
        final result = await command.execute();
        final json = result.toJson();

        expect(json['completion_authority'], equals('user'));
      });

      test('END has completion_authority: automatic', () async {
        setupWorkspace(state: 'END', issue: '145');

        final command = FsmStateCommand(FsmStateInput(
          workingDirectory: tempDir.path,
        ));
        final result = await command.execute();
        final json = result.toJson();

        expect(json['completion_authority'], equals('automatic'));
      });

      test('EVOLUTION has completion_authority: automatic', () async {
        setupWorkspace(state: 'EVOLUTION', issue: '145');

        final command = FsmStateCommand(FsmStateInput(
          workingDirectory: tempDir.path,
        ));
        final result = await command.execute();
        final json = result.toJson();

        expect(json['completion_authority'], equals('automatic'));
      });

      test('IDLE has completion_authority: user', () async {
        setupWorkspace(state: 'IDLE');

        final command = FsmStateCommand(FsmStateInput(
          workingDirectory: tempDir.path,
        ));
        final result = await command.execute();
        final json = result.toJson();

        expect(json['completion_authority'], equals('user'));
      });
    });

    group('END transition filtering by config.yaml', () {
      test('END with evolution disabled shows only pr_ready_no_evolution',
          () async {
        setupWorkspace(state: 'END', issue: '145');
        // config.yaml with evolution.enabled: false
        File('${tempDir.path}/.inquiry/config.yaml')
            .writeAsStringSync('evolution:\n  enabled: false\n');

        final command = FsmStateCommand(FsmStateInput(
          workingDirectory: tempDir.path,
        ));
        final result = await command.execute();
        final transitions = result.toJson()['transitions'] as List;
        final events = transitions.map((t) => t['event']).toList();

        expect(events, contains('pr_ready_no_evolution'));
        expect(events, isNot(contains('pr_ready')));
      });

      test('END with evolution enabled shows only pr_ready', () async {
        setupWorkspace(state: 'END', issue: '145');
        // config.yaml with evolution.enabled: true
        File('${tempDir.path}/.inquiry/config.yaml')
            .writeAsStringSync('evolution:\n  enabled: true\n');

        final command = FsmStateCommand(FsmStateInput(
          workingDirectory: tempDir.path,
        ));
        final result = await command.execute();
        final transitions = result.toJson()['transitions'] as List;
        final events = transitions.map((t) => t['event']).toList();

        expect(events, contains('pr_ready'));
        expect(events, isNot(contains('pr_ready_no_evolution')));
      });

      test('END without config.yaml defaults to pr_ready_no_evolution',
          () async {
        setupWorkspace(state: 'END', issue: '145');
        // No config.yaml file

        final command = FsmStateCommand(FsmStateInput(
          workingDirectory: tempDir.path,
        ));
        final result = await command.execute();
        final transitions = result.toJson()['transitions'] as List;
        final events = transitions.map((t) => t['event']).toList();

        expect(events, contains('pr_ready_no_evolution'));
        expect(events, isNot(contains('pr_ready')));
      });
    });
  });
}
