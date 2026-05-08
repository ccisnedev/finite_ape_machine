import 'dart:io';

import 'package:inquiry_cli/assets.dart';
import 'package:inquiry_cli/modules/global/commands/doctor.dart';
import 'package:inquiry_cli/src/version_check.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

/// Mock filesystem for testing doctor target checks.
class MockFileSystemOps implements FileSystemOps {
  final Map<String, bool> _files = {};
  final Map<String, bool> _dirs = {};
  String _home = '/home/testuser';

  void setFileExists(String path, bool exists) => _files[path] = exists;
  void setDirectoryExists(String path, bool exists) => _dirs[path] = exists;
  void setHome(String home) => _home = home;

  @override
  bool fileExists(String path) => _files[path] ?? false;

  @override
  bool directoryExists(String path) => _dirs[path] ?? false;

  @override
  String homeDirectory() => _home;
}

void main() {
  group('DoctorCommand', () {
    // Helper to create a fake ProcessRunner
    ProcessRunner fakeRunner({
      bool gitFails = false,
      bool ghFails = false,
      bool ghAuthFails = false,
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

        // gh --version
        if (executable == 'gh' && arguments.contains('--version')) {
          if (ghFails) {
            return ProcessResult(1, 1, '', 'gh: command not found');
          }
          return ProcessResult(0, 0, 'gh version 2.45.0 (2024-03-01)', '');
        }

        // Default: success
        return ProcessResult(0, 0, 'v1.0.0', '');
      };
    }

    /// Creates a mock FS where .inquiry/ exists and all targets are deployed.
    MockFileSystemOps allPassFs(String home, List<String> skills) {
      final fs = MockFileSystemOps()..setHome(home);
      fs.setDirectoryExists('.inquiry', true);
      fs.setFileExists(p.join(home, '.copilot', 'agents', 'inquiry.agent.md'), true);
      for (final skill in skills) {
        fs.setFileExists(
          p.join(home, '.copilot', 'skills', skill, 'SKILL.md'),
          true,
        );
      }
      return fs;
    }

    /// Creates a temp Assets directory with the given skill names.
    late Directory tempDir;
    late Assets testAssets;
    final testSkills = ['doc-read', 'doc-write', 'inquiry-install', 'issue-start', 'issue-end'];

    Assets seedAssets(Directory root, {required List<String> apes}) {
      final skillsDir = Directory(p.join(root.path, 'assets', 'skills'));
      for (final skill in testSkills) {
        final skillDir = Directory(p.join(skillsDir.path, skill));
        skillDir.createSync(recursive: true);
        File(p.join(skillDir.path, 'SKILL.md')).writeAsStringSync('---\nname: $skill\n---');
      }

      final agentsDir = Directory(p.join(root.path, 'assets', 'agents'));
      agentsDir.createSync(recursive: true);
      File(p.join(agentsDir.path, 'inquiry.agent.md')).writeAsStringSync('# Agent');

      final apesDir = Directory(p.join(root.path, 'assets', 'apes'));
      apesDir.createSync(recursive: true);
      for (final ape in apes) {
        File(p.join(apesDir.path, '$ape.yaml')).writeAsStringSync('name: $ape\n');
      }

      final statesDir = Directory(p.join(root.path, 'assets', 'fsm', 'states'));
      statesDir.createSync(recursive: true);
      for (final state in ['idle', 'analyze', 'plan', 'execute', 'end', 'evolution']) {
        File(p.join(statesDir.path, '$state.yaml')).writeAsStringSync('name: $state\ninstructions: "test"\n');
      }

      final fsmDir = Directory(p.join(root.path, 'assets', 'fsm'));
      File(p.join(fsmDir.path, 'transition_contract.yaml')).writeAsStringSync('metadata:\n  version: "1.0.0"\n');

      return Assets(root: root.path);
    }

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('doctor_test_');
      testAssets = seedAssets(
        tempDir,
        apes: ['socrates', 'socrates-idle', 'dewey', 'descartes', 'basho', 'darwin'],
      );
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    DoctorCommand makeCmd({
      ProcessRunner? runProcess,
      String version = '0.0.9',
      MockFileSystemOps? fs,
      Assets? assets,
    }) {
      return DoctorCommand(
        DoctorInput(),
        runProcess: runProcess ?? fakeRunner(),
        inquiryVersionOverride: version,
        fileSystemOps: fs ?? allPassFs('/home/testuser', testSkills),
        assets: assets ?? testAssets,
        versionChecker: ({required String currentVersion}) async =>
            const VersionCheckResult(updateAvailable: false),
      );
    }

    test('all checks pass → exit 0', () async {
      final cmd = makeCmd();
      final output = await cmd.execute();

      expect(output.passed, isTrue);
      expect(output.exitCode, 0);
      expect(output.checks.length, 5);
      expect(output.checks.every((c) => c.passed), isTrue);
    });

    test('assets check reports missing dewey when bundled APEs omit it', () async {
      final customDir = Directory.systemTemp.createTempSync('doctor_missing_dewey_');
      addTearDown(() {
        customDir.deleteSync(recursive: true);
      });

      final cmd = makeCmd(
        assets: seedAssets(
          customDir,
          apes: ['socrates', 'socrates-idle', 'descartes', 'basho', 'darwin'],
        ),
      );
      final output = await cmd.execute();
      final assetsCheck = output.checks.firstWhere((c) => c.name == 'assets');

      expect(assetsCheck.error ?? '', contains('apes/dewey.yaml'));
      expect(assetsCheck.error ?? '', isNot(contains('apes/socrates-idle.yaml')));
    });

    test('assets check does not require socrates-idle when dewey is present', () async {
      final customDir = Directory.systemTemp.createTempSync('doctor_without_socrates_idle_');
      addTearDown(() {
        customDir.deleteSync(recursive: true);
      });

      final cmd = makeCmd(
        assets: seedAssets(
          customDir,
          apes: ['socrates', 'dewey', 'descartes', 'basho', 'darwin'],
        ),
      );
      final output = await cmd.execute();
      final assetsCheck = output.checks.firstWhere((c) => c.name == 'assets');

      expect(assetsCheck.error ?? '', isNot(contains('apes/socrates-idle.yaml')));
      expect(assetsCheck.passed, isTrue);
    });

    test('git missing → exit 1, stopped at git', () async {
      final cmd = makeCmd(runProcess: fakeRunner(gitFails: true));
      final output = await cmd.execute();

      expect(output.passed, isFalse);
      expect(output.exitCode, 1);

      final gitCheck = output.checks.firstWhere((c) => c.name == 'git');
      expect(gitCheck.passed, isFalse);
      expect(gitCheck.error, isNotNull);
    });

    test('gh missing → exit 1', () async {
      final cmd = makeCmd(runProcess: fakeRunner(ghFails: true));
      final output = await cmd.execute();

      expect(output.passed, isFalse);
      expect(output.exitCode, 1);

      final ghCheck = output.checks.firstWhere((c) => c.name == 'gh');
      expect(ghCheck.passed, isFalse);
    });

    test('gh auth fails → exit 1', () async {
      final cmd = makeCmd(runProcess: fakeRunner(ghAuthFails: true));
      final output = await cmd.execute();

      expect(output.passed, isFalse);
      expect(output.exitCode, 1);

      final authCheck = output.checks.firstWhere((c) => c.name == 'gh auth');
      expect(authCheck.passed, isFalse);
    });

    test('toJson() returns correct structure', () async {
      final cmd = makeCmd();
      final output = await cmd.execute();
      final json = output.toJson();

      expect(json, containsPair('passed', true));
      expect(json['checks'], isList);
      expect((json['checks'] as List).length, 5);
      expect(json['targetChecks'], isList);
      expect((json['targetChecks'] as List).length, 1);

      final firstCheck = (json['checks'] as List).first as Map<String, dynamic>;
      expect(firstCheck, containsPair('name', 'inquiry'));
      expect(firstCheck, containsPair('passed', true));
      expect(firstCheck, containsPair('version', '0.0.9'));
    });

    test('DoctorInput.toJson() returns fix field', () {
      final input = DoctorInput();
      expect(input.toJson(), equals({'fix': false}));
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
      final cmd = makeCmd(version: '0.0.10');
      final output = await cmd.execute();
      final text = output.toText()!;

      expect(text, contains('Checking prerequisites...'));
      expect(text, contains('✓ inquiry'));
      expect(text, contains('✓ git'));
      expect(text, contains('✓ gh'));
      expect(text, contains('All checks passed.'));
    });

    test('toText() shows failure indicators when check fails', () async {
      final cmd = makeCmd(runProcess: fakeRunner(gitFails: true));
      final output = await cmd.execute();
      final text = output.toText()!;

      expect(text, contains('✓ inquiry'));
      expect(text, contains('✗ git'));
      expect(text, contains('Some checks failed.'));
    });

    group('Target verification', () {
      test('Scenario A: all targets deployed → exit 0', () async {
        final cmd = makeCmd();
        final output = await cmd.execute();

        expect(output.passed, isTrue);
        expect(output.exitCode, 0);
        expect(output.targetChecks.length, 1);
        expect(output.targetChecks.first.passed, isTrue);
        expect(output.targetChecks.first.agentExists, isTrue);
        expect(output.targetChecks.first.missingSkills, isEmpty);

        final text = output.toText()!;
        expect(text, contains('Checking targets...'));
        expect(text, contains('✓ copilot: agent + 5 skills deployed'));
        expect(text, contains('All checks passed.'));
      });

      test('Scenario B: nothing deployed → exit 1', () async {
        final fs = MockFileSystemOps()..setHome('/home/testuser');
        fs.setDirectoryExists('.inquiry', true);
        // Agent and skills do NOT exist

        final cmd = makeCmd(fs: fs);
        final output = await cmd.execute();

        expect(output.passed, isFalse);
        expect(output.exitCode, 1);
        expect(output.targetChecks.first.agentExists, isFalse);
        expect(output.targetChecks.first.missingSkills,
            unorderedEquals(testSkills));

        final text = output.toText()!;
        expect(text, contains('✗ copilot: agent not deployed'));
        expect(text, contains('✗ copilot: missing skills:'));
        expect(text, contains("Run 'inquiry target get' to deploy"));
        expect(text, contains('Some checks failed.'));
      });

      test('Scenario C: no .inquiry/ directory → exit 1', () async {
        final fs = MockFileSystemOps()..setHome('/home/testuser');
        // .inquiry does NOT exist, targets do NOT exist

        final cmd = makeCmd(fs: fs);
        final output = await cmd.execute();

        expect(output.passed, isFalse);
        expect(output.exitCode, 1);

        // Init check failed
        final initCheck = output.checks.firstWhere(
          (c) => c.name == 'inquiry init',
        );
        expect(initCheck.passed, isFalse);

        final text = output.toText()!;
        expect(text, contains('✗ inquiry init'));
        expect(text, contains("Run 'inquiry init' to initialize"));
        expect(text, contains('✗ copilot: agent not deployed'));
        expect(text, contains("Run 'inquiry target get' to deploy"));
      });

      test('Scenario D: partial deployment → exit 1', () async {
        final fs = MockFileSystemOps()..setHome('/home/testuser');
        fs.setDirectoryExists('.inquiry', true);
        fs.setFileExists(
          p.join('/home/testuser', '.copilot', 'agents', 'inquiry.agent.md'),
          true,
        );
        // Deploy only 4 of 5 skills
        for (final skill in ['doc-write', 'inquiry-install', 'issue-start', 'issue-end']) {
          fs.setFileExists(
            p.join('/home/testuser', '.copilot', 'skills', skill, 'SKILL.md'),
            true,
          );
        }
        // doc-read is MISSING

        final cmd = makeCmd(fs: fs);
        final output = await cmd.execute();

        expect(output.passed, isFalse);
        expect(output.exitCode, 1);
        expect(output.targetChecks.first.agentExists, isTrue);
        expect(output.targetChecks.first.missingSkills, ['doc-read']);

        final text = output.toText()!;
        expect(text, contains('✓ copilot: agent deployed'));
        expect(text, contains('✗ copilot: missing skills: doc-read'));
        expect(text, contains("Run 'inquiry target get' to deploy"));
      });

      test('TargetCheck.toJson() includes all fields', () {
        final check = TargetCheck(
          targetName: 'copilot',
          agentExists: true,
          missingSkills: ['doc-read'],
          totalSkills: 5,
        );

        final json = check.toJson();
        expect(json['targetName'], 'copilot');
        expect(json['agentExists'], true);
        expect(json['missingSkills'], ['doc-read']);
        expect(json['totalSkills'], 5);
        expect(json.containsKey('error'), isFalse);
      });

      test('TargetCheck.passed is true when agent exists and no missing skills', () {
        final passing = TargetCheck(
          targetName: 'copilot',
          agentExists: true,
          missingSkills: [],
          totalSkills: 4,
        );
        expect(passing.passed, isTrue);

        final failing = TargetCheck(
          targetName: 'copilot',
          agentExists: false,
          missingSkills: ['x'],
          totalSkills: 1,
        );
        expect(failing.passed, isFalse);
      });

      test('DoctorCheck.toJson() includes remediation when present', () {
        final check = DoctorCheck(
          name: 'ape init',
          passed: false,
          error: 'not initialized',
          remediation: "Run 'ape init' to initialize",
        );

        final json = check.toJson();
        expect(json['remediation'], "Run 'ape init' to initialize");
      });

      test('no assets available → targets still checked, 0 skills expected', () async {
        final fs = allPassFs('/home/testuser', []);
        // Assets with empty skills dir
        final emptyTempDir = Directory.systemTemp.createTempSync('empty_assets_');
        Directory(p.join(emptyTempDir.path, 'assets', 'skills')).createSync(recursive: true);
        final emptyAssets = Assets(root: emptyTempDir.path);

        final cmd = makeCmd(fs: fs, assets: emptyAssets);
        final output = await cmd.execute();

        // Agent exists, 0 skills expected → passes
        expect(output.targetChecks.first.totalSkills, 0);
        expect(output.targetChecks.first.agentExists, isTrue);
        expect(output.targetChecks.first.passed, isTrue);

        emptyTempDir.deleteSync(recursive: true);
      });
    });
  });
}
