import 'dart:io';

import 'package:test/test.dart';

import 'package:inquiry_cli/modules/global/commands/init.dart';

void main() {
  group('InitCommand', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('inquiry_init_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    // ─── Step 1: docs directory detection ──────────────────────────────

    group('docs directory detection', () {
      test('uses existing docs/ directory', () async {
        Directory('${tempDir.path}/docs').createSync();

        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        await command.execute();

        expect(Directory('${tempDir.path}/docs/cleanrooms').existsSync(), isTrue);
      });

      test('uses existing doc/ directory', () async {
        Directory('${tempDir.path}/doc').createSync();

        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        await command.execute();

        expect(Directory('${tempDir.path}/doc/cleanrooms').existsSync(), isTrue);
      });

      test('prefers docs/ when both doc/ and docs/ exist', () async {
        Directory('${tempDir.path}/doc').createSync();
        Directory('${tempDir.path}/docs').createSync();

        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        await command.execute();

        expect(Directory('${tempDir.path}/docs/cleanrooms').existsSync(), isTrue);
        expect(Directory('${tempDir.path}/doc/cleanrooms').existsSync(), isFalse);
      });

      test('creates docs/ when neither doc/ nor docs/ exist', () async {
        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        await command.execute();

        expect(Directory('${tempDir.path}/docs').existsSync(), isTrue);
        expect(Directory('${tempDir.path}/docs/cleanrooms').existsSync(), isTrue);
      });
    });

    // ─── Step 2: cleanrooms/ directory ───────────────────────────────────

    group('cleanrooms/ directory', () {
      test('creates {docs}/cleanrooms/ if it does not exist', () async {
        Directory('${tempDir.path}/docs').createSync();

        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        await command.execute();

        expect(Directory('${tempDir.path}/docs/cleanrooms').existsSync(), isTrue);
      });

      test('skips {docs}/cleanrooms/ creation if already exists', () async {
        Directory('${tempDir.path}/docs/cleanrooms').createSync(recursive: true);
        // Put a marker file to verify directory is not recreated/destroyed
        File('${tempDir.path}/docs/cleanrooms/marker.md').writeAsStringSync('x');

        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        await command.execute();

        expect(
          File('${tempDir.path}/docs/cleanrooms/marker.md').existsSync(),
          isTrue,
        );
      });
    });

    // ─── Step 3: .gitignore ───────────────────────────────────────────

    group('.gitignore management', () {
      test(
        'creates .gitignore with .inquiry/ entry if no .gitignore exists',
        () async {
          final command = InitCommand(
            InitInput(workingDirectory: tempDir.path),
          );
          await command.execute();

          final gitignore = File('${tempDir.path}/.gitignore');
          expect(gitignore.existsSync(), isTrue);
          expect(gitignore.readAsStringSync(), contains('.inquiry/'));
        },
      );

      test('appends .inquiry/ to existing .gitignore that lacks it', () async {
        File('${tempDir.path}/.gitignore').writeAsStringSync('node_modules/\n');

        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        await command.execute();

        final content = File('${tempDir.path}/.gitignore').readAsStringSync();
        expect(content, contains('node_modules/'));
        expect(content, contains('.inquiry/'));
      });

      test('does not modify .gitignore if .inquiry/ already present', () async {
        final original = 'node_modules/\n.inquiry/\nbuild/\n';
        File('${tempDir.path}/.gitignore').writeAsStringSync(original);

        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        await command.execute();

        final content = File('${tempDir.path}/.gitignore').readAsStringSync();
        expect(content, equals(original));
      });
    });

    // ─── Step 4: .inquiry/state.yaml ──────────────────────────────────────

    group('.inquiry/state.yaml', () {
      test('creates .inquiry/state.yaml with initial IDLE state', () async {
        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        await command.execute();

        final stateFile = File('${tempDir.path}/.inquiry/state.yaml');
        expect(stateFile.existsSync(), isTrue);

        final content = stateFile.readAsStringSync();
        expect(content, contains('phase: IDLE'));
        expect(content, contains('task: null'));
      });

      test('skips .inquiry/state.yaml if already exists', () async {
        Directory('${tempDir.path}/.inquiry').createSync();
        File(
          '${tempDir.path}/.inquiry/state.yaml',
        ).writeAsStringSync('phase: ANALYZE\ntask: "042-something"\n');

        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        await command.execute();

        final content = File(
          '${tempDir.path}/.inquiry/state.yaml',
        ).readAsStringSync();
        expect(content, contains('phase: ANALYZE'));
        expect(content, contains('042-something'));
      });
    });

    // ─── Step 5: .inquiry/config.yaml ─────────────────────────────────────

    group('.inquiry/config.yaml', () {
      test('creates .inquiry/config.yaml with default config', () async {
        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        await command.execute();

        final configFile = File('${tempDir.path}/.inquiry/config.yaml');
        expect(configFile.existsSync(), isTrue);

        final content = configFile.readAsStringSync();
        expect(content, contains('evolution:'));
        expect(content, contains('enabled: false'));
      });

      test('skips .inquiry/config.yaml if already exists', () async {
        Directory('${tempDir.path}/.inquiry').createSync();
        File(
          '${tempDir.path}/.inquiry/config.yaml',
        ).writeAsStringSync('evolution:\n  enabled: true\n');

        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        await command.execute();

        final content = File(
          '${tempDir.path}/.inquiry/config.yaml',
        ).readAsStringSync();
        expect(content, contains('enabled: true'));
      });
    });

    // ─── Step 6: .inquiry/mutations.md ──────────────────────────────────

    group('.inquiry/mutations.md', () {
      test('creates .inquiry/mutations.md with header template', () async {
        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        await command.execute();

        final mutationsFile = File('${tempDir.path}/.inquiry/mutations.md');
        expect(mutationsFile.existsSync(), isTrue);

        final content = mutationsFile.readAsStringSync();
        expect(content, contains('# Mutations'));
        expect(content, contains('Notes for DARWIN'));
      });

      test('skips .inquiry/mutations.md if already exists', () async {
        Directory('${tempDir.path}/.inquiry').createSync();
        File(
          '${tempDir.path}/.inquiry/mutations.md',
        ).writeAsStringSync('# Mutations\n\n- My custom note\n');

        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        await command.execute();

        final content = File(
          '${tempDir.path}/.inquiry/mutations.md',
        ).readAsStringSync();
        expect(content, contains('My custom note'));
      });
    });

    // ─── Idempotency ──────────────────────────────────────────────────

    group('idempotency', () {
      test('running init twice produces same result', () async {
        final command = InitCommand(InitInput(workingDirectory: tempDir.path));

        await command.execute();
        // Capture state after first run
        final stateAfterFirst = File(
          '${tempDir.path}/.inquiry/state.yaml',
        ).readAsStringSync();
        final gitignoreAfterFirst = File(
          '${tempDir.path}/.gitignore',
        ).readAsStringSync();
        final configAfterFirst = File(
          '${tempDir.path}/.inquiry/config.yaml',
        ).readAsStringSync();
        final mutationsAfterFirst = File(
          '${tempDir.path}/.inquiry/mutations.md',
        ).readAsStringSync();

        await command.execute();
        // Verify state unchanged after second run
        final stateAfterSecond = File(
          '${tempDir.path}/.inquiry/state.yaml',
        ).readAsStringSync();
        final gitignoreAfterSecond = File(
          '${tempDir.path}/.gitignore',
        ).readAsStringSync();
        final configAfterSecond = File(
          '${tempDir.path}/.inquiry/config.yaml',
        ).readAsStringSync();
        final mutationsAfterSecond = File(
          '${tempDir.path}/.inquiry/mutations.md',
        ).readAsStringSync();

        expect(stateAfterSecond, equals(stateAfterFirst));
        expect(gitignoreAfterSecond, equals(gitignoreAfterFirst));
        expect(configAfterSecond, equals(configAfterFirst));
        expect(mutationsAfterSecond, equals(mutationsAfterFirst));
        expect(Directory('${tempDir.path}/docs/cleanrooms').existsSync(), isTrue);
      });
    });

    // ─── Output ───────────────────────────────────────────────────────

    group('output', () {
      test('exit code is always 0', () async {
        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        final output = await command.execute();
        expect(output.exitCode, 0);
      });
    });
  });
}
