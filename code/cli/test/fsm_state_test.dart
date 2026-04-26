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

      test('each transition has event and next_state', () async {
        setupWorkspace(state: 'PLAN', issue: '145');

        final command = FsmStateCommand(FsmStateInput(
          workingDirectory: tempDir.path,
        ));
        final result = await command.execute();
        final transitions = result.toJson()['transitions'] as List;

        for (final t in transitions) {
          expect(t, contains('event'));
          expect(t, contains('next_state'));
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

      test('IDLE has no active APEs', () async {
        setupWorkspace(state: 'IDLE');

        final command = FsmStateCommand(FsmStateInput(
          workingDirectory: tempDir.path,
        ));
        final result = await command.execute();
        final apes = result.toJson()['apes'] as List;

        expect(apes, isEmpty);
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
      test('ANALYZE instructions reference socrates', () async {
        setupWorkspace(state: 'ANALYZE', issue: '145');

        final command = FsmStateCommand(FsmStateInput(
          workingDirectory: tempDir.path,
        ));
        final result = await command.execute();

        expect(result.toJson()['instructions'], contains('socrates'));
      });

      test('IDLE instructions mention start_analyze', () async {
        setupWorkspace(state: 'IDLE');

        final command = FsmStateCommand(FsmStateInput(
          workingDirectory: tempDir.path,
        ));
        final result = await command.execute();

        expect(result.toJson()['instructions'], contains('start_analyze'));
      });
    });

    group('missing workspace', () {
      test('defaults to IDLE when .inquiry/state.yaml missing', () async {
        // No setupWorkspace — but need contract
        final contractDir = Directory('${tempDir.path}/assets/fsm');
        contractDir.createSync(recursive: true);
        final contractSource = File('assets/fsm/transition_contract.yaml');
        contractSource.copySync('${contractDir.path}/transition_contract.yaml');

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
  });
}
