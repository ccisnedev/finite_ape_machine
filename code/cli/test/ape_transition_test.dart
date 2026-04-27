import 'dart:io';

import 'package:inquiry_cli/modules/ape/commands/transition.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory tmpDir;

  setUp(() {
    tmpDir = Directory.systemTemp.createTempSync('ape_transition_test_');
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

  group('ApeTransitionCommand', () {
    group('successful transitions', () {
      test('socrates clarification --next--> assumptions', () async {
        writeState(
          state: 'ANALYZE',
          issue: '145',
          apeName: 'socrates',
          apeState: 'clarification',
        );

        final cmd = ApeTransitionCommand(
          ApeTransitionInput(event: 'next', workingDirectory: tmpDir.path),
        );
        final result = await cmd.execute();

        expect(result.apeName, equals('socrates'));
        expect(result.from, equals('clarification'));
        expect(result.event, equals('next'));
        expect(result.to, equals('assumptions'));
      });

      test('persists new ape state to state.yaml', () async {
        writeState(
          state: 'ANALYZE',
          issue: '145',
          apeName: 'socrates',
          apeState: 'clarification',
        );

        final cmd = ApeTransitionCommand(
          ApeTransitionInput(event: 'next', workingDirectory: tmpDir.path),
        );
        await cmd.execute();

        // Verify persisted
        final content = File(p.join(tmpDir.path, '.inquiry', 'state.yaml'))
            .readAsStringSync();
        expect(content, contains('state: assumptions'));
        // Main FSM state preserved
        expect(content, contains('state: ANALYZE'));
        expect(content, contains('issue: "145"'));
      });

      test('basho implement --next--> test', () async {
        writeState(
          state: 'EXECUTE',
          issue: '145',
          apeName: 'basho',
          apeState: 'implement',
        );

        final cmd = ApeTransitionCommand(
          ApeTransitionInput(event: 'next', workingDirectory: tmpDir.path),
        );
        final result = await cmd.execute();

        expect(result.from, equals('implement'));
        expect(result.to, equals('test'));
      });

      test('basho test --fail--> implement (loop back)', () async {
        writeState(
          state: 'EXECUTE',
          issue: '145',
          apeName: 'basho',
          apeState: 'test',
        );

        final cmd = ApeTransitionCommand(
          ApeTransitionInput(event: 'fail', workingDirectory: tmpDir.path),
        );
        final result = await cmd.execute();

        expect(result.from, equals('test'));
        expect(result.to, equals('implement'));
      });

      test('reaches _DONE sentinel', () async {
        writeState(
          state: 'ANALYZE',
          issue: '145',
          apeName: 'socrates',
          apeState: 'meta_reflection',
        );

        final cmd = ApeTransitionCommand(
          ApeTransitionInput(event: 'complete', workingDirectory: tmpDir.path),
        );
        final result = await cmd.execute();

        expect(result.to, equals('_DONE'));
      });

      test('descartes decomposition --next--> ordering', () async {
        writeState(
          state: 'PLAN',
          issue: '145',
          apeName: 'descartes',
          apeState: 'decomposition',
        );

        final cmd = ApeTransitionCommand(
          ApeTransitionInput(event: 'next', workingDirectory: tmpDir.path),
        );
        final result = await cmd.execute();

        expect(result.from, equals('decomposition'));
        expect(result.to, equals('ordering'));
      });

      test('back transition works', () async {
        writeState(
          state: 'ANALYZE',
          issue: '145',
          apeName: 'socrates',
          apeState: 'assumptions',
        );

        final cmd = ApeTransitionCommand(
          ApeTransitionInput(event: 'back', workingDirectory: tmpDir.path),
        );
        final result = await cmd.execute();

        expect(result.from, equals('assumptions'));
        expect(result.to, equals('clarification'));
      });
    });

    group('error cases', () {
      test('throws CommandException MISSING_EVENT when event flag is null', () async {
        writeState(state: 'ANALYZE', issue: '145', apeName: 'socrates', apeState: 'clarification');

        final cmd = ApeTransitionCommand(
          ApeTransitionInput(event: null, workingDirectory: tmpDir.path),
        );

        expect(
          () => cmd.execute(),
          throwsA(
            isA<CommandException>()
                .having((e) => e.code, 'code', equals('MISSING_EVENT'))
                .having((e) => e.exitCode, 'exitCode', equals(ExitCode.validationFailed)),
          ),
        );
      });

      test('throws NO_ACTIVE_APE when no APE in state', () async {
        writeState(state: 'IDLE');

        final cmd = ApeTransitionCommand(
          ApeTransitionInput(event: 'next', workingDirectory: tmpDir.path),
        );

        expect(
          () => cmd.execute(),
          throwsA(
            isA<CommandException>()
                .having((e) => e.code, 'code', equals('NO_ACTIVE_APE'))
                .having((e) => e.exitCode, 'exitCode', equals(ExitCode.conflict)),
          ),
        );
      });

      test('throws APE_COMPLETED when ape state is _DONE', () async {
        writeState(
          state: 'ANALYZE',
          issue: '145',
          apeName: 'socrates',
          apeState: '_DONE',
        );

        final cmd = ApeTransitionCommand(
          ApeTransitionInput(event: 'next', workingDirectory: tmpDir.path),
        );

        expect(
          () => cmd.execute(),
          throwsA(
            isA<CommandException>()
                .having((e) => e.code, 'code', equals('APE_COMPLETED'))
                .having((e) => e.exitCode, 'exitCode', equals(ExitCode.conflict)),
          ),
        );
      });

      test('throws INVALID_APE_EVENT for unknown event', () async {
        writeState(
          state: 'ANALYZE',
          issue: '145',
          apeName: 'socrates',
          apeState: 'clarification',
        );

        final cmd = ApeTransitionCommand(
          ApeTransitionInput(event: 'explode', workingDirectory: tmpDir.path),
        );

        expect(
          () => cmd.execute(),
          throwsA(
            isA<CommandException>()
                .having((e) => e.code, 'code', equals('INVALID_APE_EVENT'))
                .having((e) => e.exitCode, 'exitCode', equals(ExitCode.validationFailed)),
          ),
        );
      });

      test('throws APE_NOT_FOUND when YAML missing', () async {
        // Delete socrates YAML
        File(p.join(tmpDir.path, 'assets', 'apes', 'socrates.yaml'))
            .deleteSync();

        writeState(
          state: 'ANALYZE',
          issue: '145',
          apeName: 'socrates',
          apeState: 'clarification',
        );

        final cmd = ApeTransitionCommand(
          ApeTransitionInput(event: 'next', workingDirectory: tmpDir.path),
        );

        expect(
          () => cmd.execute(),
          throwsA(
            isA<CommandException>()
                .having((e) => e.code, 'code', equals('APE_NOT_FOUND'))
                .having((e) => e.exitCode, 'exitCode', equals(ExitCode.notFound)),
          ),
        );
      });
    });

    group('output format', () {
      test('toJson includes all fields', () async {
        writeState(
          state: 'PLAN',
          issue: '145',
          apeName: 'descartes',
          apeState: 'decomposition',
        );

        final cmd = ApeTransitionCommand(
          ApeTransitionInput(event: 'next', workingDirectory: tmpDir.path),
        );
        final result = await cmd.execute();
        final json = result.toJson();

        expect(json['ape'], equals('descartes'));
        expect(json['from'], equals('decomposition'));
        expect(json['event'], equals('next'));
        expect(json['to'], equals('ordering'));
      });

      test('toText returns readable string', () async {
        writeState(
          state: 'EXECUTE',
          issue: '145',
          apeName: 'basho',
          apeState: 'implement',
        );

        final cmd = ApeTransitionCommand(
          ApeTransitionInput(event: 'next', workingDirectory: tmpDir.path),
        );
        final result = await cmd.execute();

        expect(result.toText(), equals('basho: implement --next--> test'));
      });
    });
  });
}
