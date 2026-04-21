import 'dart:io';

import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:inquiry_cli/assets.dart';
import 'package:inquiry_cli/modules/global/commands/uninstall.dart';
import 'package:inquiry_cli/targets/deployer.dart';
import 'package:inquiry_cli/targets/target_adapter.dart';

import 'platform_ops_test.dart' show FakePlatformOps;

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
    tempDir = Directory.systemTemp.createTempSync('ape_uninstall_test_');
    homeDir = Directory(p.join(tempDir.path, 'home'))..createSync();

    final skillDir = Directory(
      p.join(tempDir.path, 'assets', 'skills', 'memory-read'),
    );
    skillDir.createSync(recursive: true);
    File(p.join(skillDir.path, 'SKILL.md')).writeAsStringSync('# Memory Read');

    final agentDir = Directory(p.join(tempDir.path, 'assets', 'agents'));
    agentDir.createSync(recursive: true);
    File(
      p.join(agentDir.path, 'inquiry.agent.md'),
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

  group('UninstallCommand', () {
    test('cleans deployed targets', () async {
      deployer.deploy();

      expect(
        File(
          p.join(homeDir.path, '.fake', 'skills', 'memory-read', 'SKILL.md'),
        ).existsSync(),
        isTrue,
      );

      final command = UninstallCommand(
        UninstallInput(installDir: tempDir.path),
        deployer: deployer,
        platformOps: FakePlatformOps(),
      );

      final output = await command.execute();

      expect(output.exitCode, ExitCode.ok);
      expect(output.message, contains('uninstalled'));

      // Targets should be cleaned
      expect(
        Directory(p.join(homeDir.path, '.fake', 'skills')).existsSync(),
        isFalse,
      );
      expect(
        Directory(p.join(homeDir.path, '.fake', 'agents')).existsSync(),
        isFalse,
      );
    });

    test('exits 0 when nothing was deployed', () async {
      final command = UninstallCommand(
        UninstallInput(installDir: tempDir.path),
        deployer: deployer,
        platformOps: FakePlatformOps(),
      );

      final output = await command.execute();
      expect(output.exitCode, ExitCode.ok);
    });
  });
}
