import 'dart:io';

import 'package:test/test.dart';

import 'package:ape_cli/modules/global/commands/init.dart';

void main() {
  group('InitCommand', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('ape_init_test_');
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

        expect(Directory('${tempDir.path}/docs/issues').existsSync(), isTrue);
      });

      test('uses existing doc/ directory', () async {
        Directory('${tempDir.path}/doc').createSync();

        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        await command.execute();

        expect(Directory('${tempDir.path}/doc/issues').existsSync(), isTrue);
      });

      test('prefers docs/ when both doc/ and docs/ exist', () async {
        Directory('${tempDir.path}/doc').createSync();
        Directory('${tempDir.path}/docs').createSync();

        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        await command.execute();

        expect(Directory('${tempDir.path}/docs/issues').existsSync(), isTrue);
        expect(Directory('${tempDir.path}/doc/issues').existsSync(), isFalse);
      });

      test('creates docs/ when neither doc/ nor docs/ exist', () async {
        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        await command.execute();

        expect(Directory('${tempDir.path}/docs').existsSync(), isTrue);
        expect(Directory('${tempDir.path}/docs/issues').existsSync(), isTrue);
      });
    });

    // ─── Step 2: issues/ directory ────────────────────────────────────

    group('issues/ directory', () {
      test('creates {docs}/issues/ if it does not exist', () async {
        Directory('${tempDir.path}/docs').createSync();

        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        await command.execute();

        expect(Directory('${tempDir.path}/docs/issues').existsSync(), isTrue);
      });

      test('skips {docs}/issues/ creation if already exists', () async {
        Directory('${tempDir.path}/docs/issues').createSync(recursive: true);
        // Put a marker file to verify directory is not recreated/destroyed
        File('${tempDir.path}/docs/issues/marker.md').writeAsStringSync('x');

        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        await command.execute();

        expect(
          File('${tempDir.path}/docs/issues/marker.md').existsSync(),
          isTrue,
        );
      });
    });

    // ─── Step 3: .gitignore ───────────────────────────────────────────

    group('.gitignore management', () {
      test(
        'creates .gitignore with .ape/ entry if no .gitignore exists',
        () async {
          final command = InitCommand(
            InitInput(workingDirectory: tempDir.path),
          );
          await command.execute();

          final gitignore = File('${tempDir.path}/.gitignore');
          expect(gitignore.existsSync(), isTrue);
          expect(gitignore.readAsStringSync(), contains('.ape/'));
        },
      );

      test('appends .ape/ to existing .gitignore that lacks it', () async {
        File('${tempDir.path}/.gitignore').writeAsStringSync('node_modules/\n');

        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        await command.execute();

        final content = File('${tempDir.path}/.gitignore').readAsStringSync();
        expect(content, contains('node_modules/'));
        expect(content, contains('.ape/'));
      });

      test('does not modify .gitignore if .ape/ already present', () async {
        final original = 'node_modules/\n.ape/\nbuild/\n';
        File('${tempDir.path}/.gitignore').writeAsStringSync(original);

        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        await command.execute();

        final content = File('${tempDir.path}/.gitignore').readAsStringSync();
        expect(content, equals(original));
      });
    });

    // ─── Step 4: .ape/state.yaml ──────────────────────────────────────

    group('.ape/state.yaml', () {
      test('creates .ape/state.yaml with initial IDLE state', () async {
        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        await command.execute();

        final stateFile = File('${tempDir.path}/.ape/state.yaml');
        expect(stateFile.existsSync(), isTrue);

        final content = stateFile.readAsStringSync();
        expect(content, contains('phase: IDLE'));
        expect(content, contains('task: null'));
      });

      test('skips .ape/state.yaml if already exists', () async {
        Directory('${tempDir.path}/.ape').createSync();
        File(
          '${tempDir.path}/.ape/state.yaml',
        ).writeAsStringSync('phase: ANALYZE\ntask: "042-something"\n');

        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        await command.execute();

        final content = File(
          '${tempDir.path}/.ape/state.yaml',
        ).readAsStringSync();
        expect(content, contains('phase: ANALYZE'));
        expect(content, contains('042-something'));
      });
    });

    // ─── Idempotency ──────────────────────────────────────────────────

    group('idempotency', () {
      test('running init twice produces same result', () async {
        final command = InitCommand(InitInput(workingDirectory: tempDir.path));

        await command.execute();
        // Capture state after first run
        final stateAfterFirst = File(
          '${tempDir.path}/.ape/state.yaml',
        ).readAsStringSync();
        final gitignoreAfterFirst = File(
          '${tempDir.path}/.gitignore',
        ).readAsStringSync();

        await command.execute();
        // Verify state unchanged after second run
        final stateAfterSecond = File(
          '${tempDir.path}/.ape/state.yaml',
        ).readAsStringSync();
        final gitignoreAfterSecond = File(
          '${tempDir.path}/.gitignore',
        ).readAsStringSync();

        expect(stateAfterSecond, equals(stateAfterFirst));
        expect(gitignoreAfterSecond, equals(gitignoreAfterFirst));
        expect(Directory('${tempDir.path}/docs/issues').existsSync(), isTrue);
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
