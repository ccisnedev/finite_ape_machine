import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:inquiry_cli/assets.dart';
import 'package:inquiry_cli/targets/deployer.dart';
import 'package:inquiry_cli/targets/target_adapter.dart';

class FakeAdapter extends TargetAdapter {
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
  late Assets assets;
  late FakeAdapter adapter;
  late TargetDeployer deployer;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('ape_deployer_test_');
    homeDir = Directory(p.join(tempDir.path, 'home'))..createSync();

    // Create asset files
    final skillDir = Directory(
      p.join(tempDir.path, 'assets', 'skills', 'memory-read'),
    );
    skillDir.createSync(recursive: true);
    File(p.join(skillDir.path, 'SKILL.md')).writeAsStringSync('# Memory Read');

    final skillDir2 = Directory(
      p.join(tempDir.path, 'assets', 'skills', 'memory-write'),
    );
    skillDir2.createSync(recursive: true);
    File(
      p.join(skillDir2.path, 'SKILL.md'),
    ).writeAsStringSync('# Memory Write');

    final agentDir = Directory(p.join(tempDir.path, 'assets', 'agents'));
    agentDir.createSync(recursive: true);
    File(
      p.join(agentDir.path, 'inquiry.agent.md'),
    ).writeAsStringSync('# APE Agent');

    assets = Assets(root: tempDir.path);
    adapter = FakeAdapter();
    deployer = TargetDeployer(
      assets: assets,
      adapters: [adapter],
      homeDir: homeDir.path,
    );
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('TargetDeployer', () {
    test('deploy copies skills to each adapter skillsDirectory', () {
      deployer.deploy();

      final skillFile = File(
        p.join(homeDir.path, '.fake', 'skills', 'memory-read', 'SKILL.md'),
      );
      expect(skillFile.existsSync(), isTrue);
      expect(skillFile.readAsStringSync(), '# Memory Read');

      final skillFile2 = File(
        p.join(homeDir.path, '.fake', 'skills', 'memory-write', 'SKILL.md'),
      );
      expect(skillFile2.existsSync(), isTrue);
      expect(skillFile2.readAsStringSync(), '# Memory Write');
    });

    test('deploy copies agent to each adapter agentDirectory', () {
      deployer.deploy();

      final agentFile = File(
        p.join(homeDir.path, '.fake', 'agents', 'inquiry.agent.md'),
      );
      expect(agentFile.existsSync(), isTrue);
      expect(agentFile.readAsStringSync(), '# APE Agent');
    });

    test('deploy is idempotent — second run produces same result', () {
      deployer.deploy();
      deployer.deploy();

      final skillFile = File(
        p.join(homeDir.path, '.fake', 'skills', 'memory-read', 'SKILL.md'),
      );
      expect(skillFile.existsSync(), isTrue);
      expect(skillFile.readAsStringSync(), '# Memory Read');
    });

    test('deploy cleans before deploying (D18)', () {
      deployer.deploy();

      // Create an extra file that shouldn't survive redeploy
      final extraFile = File(
        p.join(homeDir.path, '.fake', 'skills', 'stale-skill', 'SKILL.md'),
      );
      extraFile.parent.createSync(recursive: true);
      extraFile.writeAsStringSync('# Stale');

      deployer.deploy();

      expect(extraFile.existsSync(), isFalse);
    });

    test('clean removes deployed files from all adapters', () {
      deployer.deploy();
      deployer.clean();

      final skillsDir = Directory(p.join(homeDir.path, '.fake', 'skills'));
      final agentsDir = Directory(p.join(homeDir.path, '.fake', 'agents'));
      expect(skillsDir.existsSync(), isFalse);
      expect(agentsDir.existsSync(), isFalse);
    });

    test('clean does not fail if nothing was deployed', () {
      expect(() => deployer.clean(), returnsNormally);
    });

    test('deploy works with all 5 real adapters', () {
      final allDeployer = TargetDeployer(
        assets: assets,
        adapters: [
          FakeAdapter(),
          // Use a second fake with different name to verify multi-adapter
          _SecondFakeAdapter(),
        ],
        homeDir: homeDir.path,
      );

      allDeployer.deploy();

      // Verify both adapters received files
      expect(
        File(
          p.join(homeDir.path, '.fake', 'skills', 'memory-read', 'SKILL.md'),
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          p.join(homeDir.path, '.fake2', 'skills', 'memory-read', 'SKILL.md'),
        ).existsSync(),
        isTrue,
      );
    });
  });
}

class _SecondFakeAdapter extends TargetAdapter {
  @override
  String get name => 'fake2';

  @override
  String baseDirectory(String homeDir) => p.join(homeDir, '.fake2');

  @override
  String skillsDirectory(String homeDir) => p.join(homeDir, '.fake2', 'skills');

  @override
  String agentDirectory(String homeDir) => p.join(homeDir, '.fake2', 'agents');
}
