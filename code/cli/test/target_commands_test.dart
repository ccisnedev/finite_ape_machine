import 'dart:io';

import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:ape_cli/assets.dart';
import 'package:ape_cli/modules/target/commands/get.dart';
import 'package:ape_cli/modules/target/commands/clean.dart';
import 'package:ape_cli/targets/deployer.dart';
import 'package:ape_cli/targets/target_adapter.dart';

class _FakeAdapter extends TargetAdapter {
  @override
  String get name => 'fake';

  @override
  String baseDirectory(String homeDir) => p.join(homeDir, '.fake');

  @override
  String skillsDirectory(String homeDir) => p.join(homeDir, '.fake', 'skills');

  @override
  String agentDirectory(String homeDir) => p.join(homeDir, '.fake', 'agents');
}

void main() {
  late Directory tempDir;
  late Directory homeDir;
  late TargetDeployer deployer;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('ape_target_cmd_test_');
    homeDir = Directory(p.join(tempDir.path, 'home'))..createSync();

    // Create asset files
    final skillDir = Directory(
      p.join(tempDir.path, 'assets', 'skills', 'memory-read'),
    );
    skillDir.createSync(recursive: true);
    File(p.join(skillDir.path, 'SKILL.md')).writeAsStringSync('# Memory Read');

    final agentDir = Directory(p.join(tempDir.path, 'assets', 'agents'));
    agentDir.createSync(recursive: true);
    File(
      p.join(agentDir.path, 'ape.agent.md'),
    ).writeAsStringSync('# APE Agent');

    deployer = TargetDeployer(
      assets: Assets(root: tempDir.path),
      adapters: [_FakeAdapter()],
      homeDir: homeDir.path,
    );
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('ape target get', () {
    test('exits 0 and deploys files to all targets', () async {
      final command = TargetGetCommand(TargetGetInput(), deployer: deployer);

      final output = await command.execute();

      expect(output.exitCode, ExitCode.ok);
      expect(
        File(
          p.join(homeDir.path, '.fake', 'skills', 'memory-read', 'SKILL.md'),
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          p.join(homeDir.path, '.fake', 'agents', 'ape.agent.md'),
        ).existsSync(),
        isTrue,
      );
    });

    test('exits 0 on idempotent re-run', () async {
      final command = TargetGetCommand(TargetGetInput(), deployer: deployer);

      await command.execute();
      final output = await command.execute();

      expect(output.exitCode, ExitCode.ok);
    });
  });

  group('ape target clean', () {
    test('exits 0 and removes deployed files', () async {
      // Deploy first
      deployer.deploy();

      final command = TargetCleanCommand(
        TargetCleanInput(),
        deployer: deployer,
      );

      final output = await command.execute();

      expect(output.exitCode, ExitCode.ok);
      expect(
        Directory(p.join(homeDir.path, '.fake', 'skills')).existsSync(),
        isFalse,
      );
    });

    test('exits 0 when nothing to clean', () async {
      final command = TargetCleanCommand(
        TargetCleanInput(),
        deployer: deployer,
      );

      final output = await command.execute();

      expect(output.exitCode, ExitCode.ok);
    });
  });
}
