import 'dart:io';

import 'package:inquiry_cli/modules/ape/commands/prompt.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory tmpDir;

  setUp(() {
    tmpDir = Directory.systemTemp.createTempSync('ape_prompt_test_');

    // Create .inquiry/state.yaml
    Directory(p.join(tmpDir.path, '.inquiry')).createSync();

    // Copy assets/apes/ from real assets
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

  void writeState(String state, {String? issue}) {
    File(p.join(tmpDir.path, '.inquiry', 'state.yaml')).writeAsStringSync(
      'state: $state\n'
      'issue: ${issue ?? 'null'}\n',
    );
  }

  void writeStateWithApe(String state, {
    String? issue,
    required String apeName,
    required String apeState,
  }) {
    File(p.join(tmpDir.path, '.inquiry', 'state.yaml')).writeAsStringSync(
      'state: $state\n'
      'issue: ${issue != null ? '"$issue"' : 'null'}\n'
      'ape:\n'
      '  name: $apeName\n'
      '  state: $apeState\n',
    );
  }

  group('ApePromptCommand', () {
    group('successful prompt assembly', () {
      test('socrates in ANALYZE returns base prompt', () async {
        writeState('ANALYZE', issue: '99');
        final cmd = ApePromptCommand(
          ApePromptInput(name: 'socrates', workingDirectory: tmpDir.path),
        );
        final result = await cmd.execute();

        expect(result.apeName, equals('socrates'));
        expect(result.fsmState, equals('ANALYZE'));
        expect(result.subState, isNull);
        expect(result.prompt, contains('SOCRATES'));
        expect(result.prompt, contains('Socratic method'));
      });

      test('socrates with sub-state clarification appends state prompt', () async {
        writeState('ANALYZE');
        final cmd = ApePromptCommand(
          ApePromptInput(
            name: 'socrates',
            subState: 'clarification',
            workingDirectory: tmpDir.path,
          ),
        );
        final result = await cmd.execute();

        expect(result.subState, equals('clarification'));
        expect(result.prompt, contains('SOCRATES'));
        expect(result.prompt, contains('Clarification questions'));
      });

      test('descartes in PLAN returns base prompt', () async {
        writeState('PLAN');
        final cmd = ApePromptCommand(
          ApePromptInput(name: 'descartes', workingDirectory: tmpDir.path),
        );
        final result = await cmd.execute();

        expect(result.apeName, equals('descartes'));
        expect(result.fsmState, equals('PLAN'));
        expect(result.prompt, contains('DESCARTES'));
        expect(result.prompt, contains('scientific method'));
      });

      test('basho in EXECUTE returns base prompt', () async {
        writeState('EXECUTE');
        final cmd = ApePromptCommand(
          ApePromptInput(name: 'basho', workingDirectory: tmpDir.path),
        );
        final result = await cmd.execute();

        expect(result.apeName, equals('basho'));
        expect(result.fsmState, equals('EXECUTE'));
        expect(result.prompt, contains('BASHŌ'));
      });

      test('basho in END is also active', () async {
        writeState('END');
        final cmd = ApePromptCommand(
          ApePromptInput(name: 'basho', workingDirectory: tmpDir.path),
        );
        final result = await cmd.execute();

        expect(result.apeName, equals('basho'));
        expect(result.fsmState, equals('END'));
      });

      test('darwin in EVOLUTION returns base prompt', () async {
        writeState('EVOLUTION');
        final cmd = ApePromptCommand(
          ApePromptInput(name: 'darwin', workingDirectory: tmpDir.path),
        );
        final result = await cmd.execute();

        expect(result.apeName, equals('darwin'));
        expect(result.fsmState, equals('EVOLUTION'));
        expect(result.prompt, contains('DARWIN'));
        expect(result.prompt, contains('natural selection'));
      });
    });

    group('MISSING_NAME', () {
      test('throws CommandException when name flag is null', () async {
        writeState('ANALYZE');
        final cmd = ApePromptCommand(
          ApePromptInput(name: null, workingDirectory: tmpDir.path),
        );

        expect(
          () => cmd.execute(),
          throwsA(
            isA<CommandException>()
                .having((e) => e.code, 'code', equals('MISSING_NAME'))
                .having((e) => e.exitCode, 'exitCode', equals(ExitCode.validationFailed)),
          ),
        );
      });
    });

    group('MISSING_NAME', () {
      test('throws CommandException when name flag is null', () async {
        writeState('ANALYZE');
        final cmd = ApePromptCommand(
          ApePromptInput(name: null, workingDirectory: tmpDir.path),
        );

        expect(
          () => cmd.execute(),
          throwsA(
            isA<CommandException>()
                .having((e) => e.code, 'code', equals('MISSING_NAME'))
                .having((e) => e.exitCode, 'exitCode', equals(ExitCode.validationFailed)),
          ),
        );
      });
    });

    group('APE_NOT_FOUND', () {
      test('throws for nonexistent APE', () async {
        writeState('ANALYZE');
        final cmd = ApePromptCommand(
          ApePromptInput(name: 'nonexistent', workingDirectory: tmpDir.path),
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

    group('APE_NOT_ACTIVE', () {
      test('socrates in EXECUTE throws not active', () async {
        writeState('EXECUTE');
        final cmd = ApePromptCommand(
          ApePromptInput(name: 'socrates', workingDirectory: tmpDir.path),
        );

        expect(
          () => cmd.execute(),
          throwsA(
            isA<CommandException>()
                .having((e) => e.code, 'code', equals('APE_NOT_ACTIVE'))
                .having((e) => e.exitCode, 'exitCode', equals(ExitCode.conflict)),
          ),
        );
      });

      test('descartes in ANALYZE throws not active', () async {
        writeState('ANALYZE');
        final cmd = ApePromptCommand(
          ApePromptInput(name: 'descartes', workingDirectory: tmpDir.path),
        );

        expect(
          () => cmd.execute(),
          throwsA(
            isA<CommandException>()
                .having((e) => e.code, 'code', equals('APE_NOT_ACTIVE'))
                .having((e) => e.exitCode, 'exitCode', equals(ExitCode.conflict)),
          ),
        );
      });

      test('any APE in IDLE throws not active', () async {
        writeState('IDLE');
        final cmd = ApePromptCommand(
          ApePromptInput(name: 'socrates', workingDirectory: tmpDir.path),
        );

        expect(
          () => cmd.execute(),
          throwsA(
            isA<CommandException>()
                .having((e) => e.code, 'code', equals('APE_NOT_ACTIVE'))
                .having((e) => e.exitCode, 'exitCode', equals(ExitCode.conflict)),
          ),
        );
      });
    });

    group('unknown sub-state', () {
      test('throws for invalid sub-state name', () async {
        writeState('ANALYZE');
        final cmd = ApePromptCommand(
          ApePromptInput(
            name: 'socrates',
            subState: 'nonexistent_state',
            workingDirectory: tmpDir.path,
          ),
        );

        expect(() => cmd.execute(), throwsA(isA<ArgumentError>()));
      });
    });

    group('output format', () {
      test('toJson includes all fields', () async {
        writeState('ANALYZE');
        final cmd = ApePromptCommand(
          ApePromptInput(
            name: 'socrates',
            subState: 'evidence',
            workingDirectory: tmpDir.path,
          ),
        );
        final result = await cmd.execute();
        final json = result.toJson();

        expect(json['ape'], equals('socrates'));
        expect(json['fsm_state'], equals('ANALYZE'));
        expect(json['sub_state'], equals('evidence'));
        expect(json['prompt'], isA<String>());
      });

      test('toText returns raw prompt', () async {
        writeState('PLAN');
        final cmd = ApePromptCommand(
          ApePromptInput(name: 'descartes', workingDirectory: tmpDir.path),
        );
        final result = await cmd.execute();

        expect(result.toText(), equals(result.prompt));
      });
    });

    group('missing .inquiry/state.yaml', () {
      test('defaults to IDLE when no state file exists', () async {
        // Delete the state file if it exists
        final stateFile = File(p.join(tmpDir.path, '.inquiry', 'state.yaml'));
        if (stateFile.existsSync()) stateFile.deleteSync();

        final cmd = ApePromptCommand(
          ApePromptInput(name: 'socrates', workingDirectory: tmpDir.path),
        );

        // In IDLE, no APE is active → should throw APE_NOT_ACTIVE
        expect(
          () => cmd.execute(),
          throwsA(
            isA<CommandException>()
                .having((e) => e.code, 'code', equals('APE_NOT_ACTIVE'))
                .having((e) => e.exitCode, 'exitCode', equals(ExitCode.conflict)),
          ),
        );
      });
    });

    group('validate', () {
      test('returns null for empty name (validation moved to execute)', () {
        final cmd = ApePromptCommand(
          ApePromptInput(name: '', workingDirectory: tmpDir.path),
        );
        expect(cmd.validate(), isNull);
      });

      test('returns null for valid name', () {
        final cmd = ApePromptCommand(
          ApePromptInput(name: 'socrates', workingDirectory: tmpDir.path),
        );
        expect(cmd.validate(), isNull);
      });
    });

    group('prompt fidelity — regression vs monolith', () {
      test('socrates prompt covers key Socratic method concepts', () async {
        writeState('ANALYZE');
        final cmd = ApePromptCommand(
          ApePromptInput(
            name: 'socrates',
            subState: 'clarification',
            workingDirectory: tmpDir.path,
          ),
        );
        final result = await cmd.execute();

        expect(result.prompt, contains('EPISTEMIC HUMILITY'));
        expect(result.prompt, contains('MIDWIFE OF IDEAS'));
        expect(result.prompt, contains('diagnosis.md'));
        expect(result.prompt, contains('Clarification questions'));
      });

      test('descartes prompt covers Cartesian method', () async {
        writeState('PLAN');
        final cmd = ApePromptCommand(
          ApePromptInput(
            name: 'descartes',
            subState: 'decomposition',
            workingDirectory: tmpDir.path,
          ),
        );
        final result = await cmd.execute();

        expect(result.prompt, contains('EVIDENCE'));
        expect(result.prompt, contains('DIVISION'));
        expect(result.prompt, contains('plan.md'));
        expect(result.prompt, contains('Division'));
      });

      test('basho prompt covers implementation principles', () async {
        writeState('EXECUTE');
        final cmd = ApePromptCommand(
          ApePromptInput(
            name: 'basho',
            subState: 'implement',
            workingDirectory: tmpDir.path,
          ),
        );
        final result = await cmd.execute();

        expect(result.prompt, contains('用の美'));
        expect(result.prompt, contains('NOTHING WASTED'));
        expect(result.prompt, contains('Implementation'));
      });

      test('darwin prompt covers evolution process', () async {
        writeState('EVOLUTION');
        final cmd = ApePromptCommand(
          ApePromptInput(
            name: 'darwin',
            subState: 'observe',
            workingDirectory: tmpDir.path,
          ),
        );
        final result = await cmd.execute();

        expect(result.prompt, contains('natural selection'));
        expect(result.prompt, contains('mutations.md'));
        expect(result.prompt, contains('Observation'));
      });
    });

    group('auto-read sub-state from state.yaml', () {
      test('reads ape.state when no --state flag', () async {
        writeStateWithApe('ANALYZE',
          issue: '145',
          apeName: 'socrates',
          apeState: 'evidence',
        );

        final cmd = ApePromptCommand(
          ApePromptInput(name: 'socrates', workingDirectory: tmpDir.path),
        );
        final result = await cmd.execute();

        expect(result.subState, equals('evidence'));
        expect(result.prompt, contains('Evidence'));
      });

      test('--state flag overrides ape.state from state.yaml', () async {
        writeStateWithApe('ANALYZE',
          issue: '145',
          apeName: 'socrates',
          apeState: 'evidence',
        );

        final cmd = ApePromptCommand(
          ApePromptInput(
            name: 'socrates',
            subState: 'clarification',
            workingDirectory: tmpDir.path,
          ),
        );
        final result = await cmd.execute();

        expect(result.subState, equals('clarification'));
        expect(result.prompt, contains('Clarification'));
      });

      test('works with basho ape sub-state', () async {
        writeStateWithApe('EXECUTE',
          issue: '145',
          apeName: 'basho',
          apeState: 'test',
        );

        final cmd = ApePromptCommand(
          ApePromptInput(name: 'basho', workingDirectory: tmpDir.path),
        );
        final result = await cmd.execute();

        expect(result.subState, equals('test'));
        expect(result.prompt, contains('Verification'));
      });
    });
  });
}
