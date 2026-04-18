import 'dart:io';

import 'package:ape_cli/commands/doctor.dart';
import 'package:test/test.dart';

void main() {
  group('DoctorCommand', () {
    // Helper to create a fake ProcessRunner
    ProcessRunner fakeRunner({
      bool gitFails = false,
      bool ghFails = false,
      bool ghAuthFails = false,
      bool copilotFails = false,
      bool vscodeFails = false,
    }) {
      return (
        String executable,
        List<String> arguments, {
        String? workingDirectory,
      }) async {
        // git --version
        if (executable == 'git' && arguments.contains('--version')) {
          if (gitFails) {
            return ProcessResult(1, 1, '', 'git: command not found');
          }
          return ProcessResult(0, 0, 'git version 2.43.0', '');
        }

        // gh copilot --version (check before gh --version!)
        if (executable == 'gh' && arguments.contains('copilot')) {
          if (copilotFails) {
            return ProcessResult(
              1,
              1,
              '',
              'gh: "copilot" is not a gh command.',
            );
          }
          return ProcessResult(0, 0, 'gh copilot version 1.0.0', '');
        }

        // gh auth status
        if (executable == 'gh' && arguments.contains('auth')) {
          if (ghAuthFails) {
            return ProcessResult(
              1,
              1,
              '',
              'You are not logged into any GitHub hosts.',
            );
          }
          return ProcessResult(
            0,
            0,
            'Logged in to github.com as user (oauth_token)',
            '',
          );
        }

        // gh --version (after copilot and auth checks)
        if (executable == 'gh' && arguments.contains('--version')) {
          if (ghFails) {
            return ProcessResult(1, 1, '', 'gh: command not found');
          }
          return ProcessResult(0, 0, 'gh version 2.45.0 (2024-03-01)', '');
        }

        // code --list-extensions
        if (executable == 'code' && arguments.contains('--list-extensions')) {
          if (vscodeFails) {
            return ProcessResult(1, 1, '', 'code: command not found');
          }
          return ProcessResult(
            0,
            0,
            'GitHub.copilot\nGitHub.copilot-chat\nms-python.python\n',
            '',
          );
        }

        // Default: success
        return ProcessResult(0, 0, 'v1.0.0', '');
      };
    }

    test('all checks pass → exit 0', () async {
      final cmd = DoctorCommand(
        DoctorInput(),
        runProcess: fakeRunner(),
        apeVersionOverride: '0.0.9',
      );

      final output = await cmd.execute();

      expect(output.passed, isTrue);
      expect(output.exitCode, 0);
      expect(output.checks.length, 6);
      expect(output.checks.every((c) => c.passed), isTrue);
    });

    test('vscode copilot missing → exit 1', () async {
      final cmd = DoctorCommand(
        DoctorInput(),
        runProcess: fakeRunner(vscodeFails: true),
        apeVersionOverride: '0.0.9',
      );

      final output = await cmd.execute();

      expect(output.passed, isFalse);
      expect(output.exitCode, 1);

      final vscodeCheck = output.checks.firstWhere(
        (c) => c.name == 'vscode copilot',
      );
      expect(vscodeCheck.passed, isFalse);
    });

    test('git missing → exit 1, stopped at git', () async {
      final cmd = DoctorCommand(
        DoctorInput(),
        runProcess: fakeRunner(gitFails: true),
        apeVersionOverride: '0.0.9',
      );

      final output = await cmd.execute();

      expect(output.passed, isFalse);
      expect(output.exitCode, 1);

      final gitCheck = output.checks.firstWhere((c) => c.name == 'git');
      expect(gitCheck.passed, isFalse);
      expect(gitCheck.error, isNotNull);
    });

    test('gh missing → exit 1', () async {
      final cmd = DoctorCommand(
        DoctorInput(),
        runProcess: fakeRunner(ghFails: true),
        apeVersionOverride: '0.0.9',
      );

      final output = await cmd.execute();

      expect(output.passed, isFalse);
      expect(output.exitCode, 1);

      final ghCheck = output.checks.firstWhere((c) => c.name == 'gh');
      expect(ghCheck.passed, isFalse);
    });

    test('gh auth fails → exit 1', () async {
      final cmd = DoctorCommand(
        DoctorInput(),
        runProcess: fakeRunner(ghAuthFails: true),
        apeVersionOverride: '0.0.9',
      );

      final output = await cmd.execute();

      expect(output.passed, isFalse);
      expect(output.exitCode, 1);

      final authCheck = output.checks.firstWhere((c) => c.name == 'gh auth');
      expect(authCheck.passed, isFalse);
    });

    test('copilot missing → exit 1', () async {
      final cmd = DoctorCommand(
        DoctorInput(),
        runProcess: fakeRunner(copilotFails: true),
        apeVersionOverride: '0.0.9',
      );

      final output = await cmd.execute();

      expect(output.passed, isFalse);
      expect(output.exitCode, 1);

      final copilotCheck = output.checks.firstWhere(
        (c) => c.name == 'gh copilot',
      );
      expect(copilotCheck.passed, isFalse);
    });

    test('toJson() returns correct structure', () async {
      final cmd = DoctorCommand(
        DoctorInput(),
        runProcess: fakeRunner(),
        apeVersionOverride: '0.0.9',
      );

      final output = await cmd.execute();
      final json = output.toJson();

      expect(json, containsPair('passed', true));
      expect(json['checks'], isList);
      expect((json['checks'] as List).length, 6);

      final firstCheck = (json['checks'] as List).first as Map<String, dynamic>;
      expect(firstCheck, containsPair('name', 'ape'));
      expect(firstCheck, containsPair('passed', true));
      expect(firstCheck, containsPair('version', '0.0.9'));
    });

    test('DoctorInput.toJson() returns empty map', () {
      final input = DoctorInput();
      expect(input.toJson(), isEmpty);
    });

    test('DoctorCheck.toJson() includes error when present', () {
      final check = DoctorCheck(name: 'git', passed: false, error: 'not found');

      final json = check.toJson();

      expect(json, containsPair('name', 'git'));
      expect(json, containsPair('passed', false));
      expect(json, containsPair('error', 'not found'));
      expect(json.containsKey('version'), isFalse);
    });

    test('toText() returns formatted checkmarks when all pass', () async {
      final cmd = DoctorCommand(
        DoctorInput(),
        runProcess: fakeRunner(),
        apeVersionOverride: '0.0.10',
      );

      final output = await cmd.execute();
      final text = output.toText()!;

      expect(text, contains('Checking prerequisites...'));
      expect(text, contains('✓ ape'));
      expect(text, contains('✓ git'));
      expect(text, contains('✓ gh'));
      expect(text, contains('All checks passed.'));
    });

    test('toText() shows failure indicators when check fails', () async {
      final cmd = DoctorCommand(
        DoctorInput(),
        runProcess: fakeRunner(gitFails: true),
        apeVersionOverride: '0.0.10',
      );

      final output = await cmd.execute();
      final text = output.toText()!;

      expect(text, contains('✓ ape'));
      expect(text, contains('✗ git'));
      expect(text, contains('Some checks failed.'));
    });
  });
}
