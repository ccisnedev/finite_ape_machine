import 'dart:io';

import 'package:inquiry_cli/modules/ape/commands/state.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory tmpDir;

  setUp(() {
    tmpDir = Directory.systemTemp.createTempSync('ape_state_test_');
    Directory(p.join(tmpDir.path, '.inquiry')).createSync(recursive: true);

    // Copy APE YAML assets
    final apesDir = Directory(p.join(tmpDir.path, 'assets', 'apes'));
    apesDir.createSync(recursive: true);
    for (final name in ['socrates', 'descartes', 'basho', 'darwin']) {
      File('assets/apes/$name.yaml')
          .copySync(p.join(apesDir.path, '$name.yaml'));
    }
  });

  tearDown(() {
    tmpDir.deleteSync(recursive: true);
  });

  void writeState({
    required String state,
    String? issue,
    String? apeName,
    String? apeState,
  }) {
    final buf = StringBuffer();
    buf.writeln('state: $state');
    buf.writeln(issue != null ? 'issue: "$issue"' : 'issue: null');
    if (apeName != null) {
      buf.writeln('ape:');
      buf.writeln('  name: $apeName');
      buf.writeln('  state: ${apeState ?? "null"}');
    } else {
      buf.writeln('ape: null');
    }
    File(p.join(tmpDir.path, '.inquiry', 'state.yaml'))
        .writeAsStringSync(buf.toString());
  }

  group('ApeStateCommand', () {
    test('returns null ape when no APE active', () async {
      writeState(state: 'IDLE');

      final cmd = ApeStateCommand(
        ApeStateInput(workingDirectory: tmpDir.path),
      );
      final result = await cmd.execute();

      expect(result.apeName, isNull);
      expect(result.toJson(), equals({'ape': null}));
      expect(result.toText(), equals('No active APE'));
    });

    test('returns APE name, state, and transitions', () async {
      writeState(
        state: 'ANALYZE',
        issue: '145',
        apeName: 'socrates',
        apeState: 'clarification',
      );

      final cmd = ApeStateCommand(
        ApeStateInput(workingDirectory: tmpDir.path),
      );
      final result = await cmd.execute();

      expect(result.apeName, equals('socrates'));
      expect(result.apeState, equals('clarification'));
      expect(result.transitions, isNotEmpty);

      // clarification should have 'next' and 'skip' events
      final events = result.transitions.map((t) => t['event']).toList();
      expect(events, contains('next'));
    });

    test('returns _DONE with no transitions', () async {
      writeState(
        state: 'ANALYZE',
        issue: '145',
        apeName: 'socrates',
        apeState: '_DONE',
      );

      final cmd = ApeStateCommand(
        ApeStateInput(workingDirectory: tmpDir.path),
      );
      final result = await cmd.execute();

      expect(result.apeName, equals('socrates'));
      expect(result.apeState, equals('_DONE'));
      expect(result.transitions, isEmpty);
    });

    test('basho in implement state has valid transitions', () async {
      writeState(
        state: 'EXECUTE',
        issue: '145',
        apeName: 'basho',
        apeState: 'implement',
      );

      final cmd = ApeStateCommand(
        ApeStateInput(workingDirectory: tmpDir.path),
      );
      final result = await cmd.execute();

      expect(result.apeName, equals('basho'));
      expect(result.apeState, equals('implement'));
      final events = result.transitions.map((t) => t['event']).toList();
      expect(events, contains('next'));
    });

    test('toText formats output correctly', () async {
      writeState(
        state: 'PLAN',
        issue: '145',
        apeName: 'descartes',
        apeState: 'decomposition',
      );

      final cmd = ApeStateCommand(
        ApeStateInput(workingDirectory: tmpDir.path),
      );
      final result = await cmd.execute();
      final text = result.toText()!;

      expect(text, contains('APE: descartes'));
      expect(text, contains('State: decomposition'));
      expect(text, contains('Transitions:'));
    });

    test('toJson includes ape object with transitions', () async {
      writeState(
        state: 'EVOLUTION',
        issue: '145',
        apeName: 'darwin',
        apeState: 'observe',
      );

      final cmd = ApeStateCommand(
        ApeStateInput(workingDirectory: tmpDir.path),
      );
      final result = await cmd.execute();
      final json = result.toJson();

      expect(json['ape'], isA<Map>());
      expect(json['ape']['name'], equals('darwin'));
      expect(json['ape']['state'], equals('observe'));
      expect(json['ape']['transitions'], isList);
    });

    test('handles missing APE YAML gracefully', () async {
      // Delete the YAML file
      File(p.join(tmpDir.path, 'assets', 'apes', 'socrates.yaml'))
          .deleteSync();

      writeState(
        state: 'ANALYZE',
        issue: '145',
        apeName: 'socrates',
        apeState: 'clarification',
      );

      final cmd = ApeStateCommand(
        ApeStateInput(workingDirectory: tmpDir.path),
      );
      final result = await cmd.execute();

      expect(result.apeName, equals('socrates'));
      expect(result.apeState, equals('clarification'));
      expect(result.transitions, isEmpty);
    });
  });
}
