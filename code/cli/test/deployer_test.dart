import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:ape_cli/assets.dart';
import 'package:ape_cli/targets/deployer.dart';
import 'package:ape_cli/targets/target_adapter.dart';

class FakeAdapter extends TargetAdapter {
  @override
  String get name => 'fake';

  @override
  String baseDirectory(String homeDir) => p.join(homeDir, '.fake');

  @override
  String skillsDirectory(String homeDir) =>
      p.join(homeDir, '.fake', 'skills');

  @override
  String agentDirectory(String homeDir) =>
      p.join(homeDir, '.fake', 'agents');
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
    final skillDir =
        Directory(p.join(tempDir.path, 'assets', 'skills', 'memory-read'));
    skillDir.createSync(recursive: true);
    File(p.join(skillDir.path, 'SKILL.md')).writeAsStringSync('# Memory Read');

    final skillDir2 =
        Directory(p.join(tempDir.path, 'assets', 'skills', 'memory-write'));
    skillDir2.createSync(recursive: true);
    File(p.join(skillDir2.path, 'SKILL.md'))
        .writeAsStringSync('# Memory Write');

    final agentDir =
        Directory(p.join(tempDir.path, 'assets', 'agents'));
    agentDir.createSync(recursive: true);
    File(p.join(agentDir.path, 'ape.agent.md'))
        .writeAsStringSync('# APE Agent');

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
          p.join(homeDir.path, '.fake', 'skills', 'memory-read', 'SKILL.md'));
      expect(skillFile.existsSync(), isTrue);
      expect(skillFile.readAsStringSync(), '# Memory Read');

      final skillFile2 = File(
          p.join(homeDir.path, '.fake', 'skills', 'memory-write', 'SKILL.md'));
      expect(skillFile2.existsSync(), isTrue);
      expect(skillFile2.readAsStringSync(), '# Memory Write');
    });

    test('deploy copies agent to each adapter agentDirectory', () {
      deployer.deploy();

      final agentFile =
          File(p.join(homeDir.path, '.fake', 'agents', 'ape.agent.md'));
      expect(agentFile.existsSync(), isTrue);
      expect(agentFile.readAsStringSync(), '# APE Agent');
    });

    test('deploy is idempotent — second run produces same result', () {
      deployer.deploy();
      deployer.deploy();

      final skillFile = File(
          p.join(homeDir.path, '.fake', 'skills', 'memory-read', 'SKILL.md'));
      expect(skillFile.existsSync(), isTrue);
      expect(skillFile.readAsStringSync(), '# Memory Read');
    });

    test('deploy cleans before deploying (D18)', () {
      deployer.deploy();

      // Create an extra file that shouldn't survive redeploy
      final extraFile = File(
          p.join(homeDir.path, '.fake', 'skills', 'stale-skill', 'SKILL.md'));
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
        File(p.join(homeDir.path, '.fake', 'skills', 'memory-read', 'SKILL.md'))
            .existsSync(),
        isTrue,
      );
      expect(
        File(p.join(
                homeDir.path, '.fake2', 'skills', 'memory-read', 'SKILL.md'))
            .existsSync(),
        isTrue,
      );
    });
  });

  group('effectiveAdapters — coexistence filtering', () {
    test('subsumed adapter is excluded when subsuming target exists', () {
      // Create the base directory for the subsuming target
      Directory(p.join(homeDir.path, '.primary')).createSync();

      final primary = _PrimaryAdapter();
      final subsumed = _SubsumedAdapter();
      final deployer = TargetDeployer(
        assets: assets,
        adapters: [primary, subsumed],
        homeDir: homeDir.path,
      );

      expect(
        deployer.effectiveAdapters.map((a) => a.name),
        equals(['primary']),
      );
    });

    test('subsumed adapter is included when subsuming target is absent', () {
      // Do NOT create .primary directory
      final primary = _PrimaryAdapter();
      final subsumed = _SubsumedAdapter();
      final deployer = TargetDeployer(
        assets: assets,
        adapters: [primary, subsumed],
        homeDir: homeDir.path,
      );

      expect(
        deployer.effectiveAdapters.map((a) => a.name),
        containsAll(['primary', 'subsumed']),
      );
    });

    test('deploy skips subsumed adapter but clean removes its files', () {
      // Create .primary base dir so subsumed gets excluded from deploy
      Directory(p.join(homeDir.path, '.primary')).createSync();

      final primary = _PrimaryAdapter();
      final subsumed = _SubsumedAdapter();
      final deployer = TargetDeployer(
        assets: assets,
        adapters: [primary, subsumed],
        homeDir: homeDir.path,
      );

      // Pre-populate subsumed target with old files
      final oldFile = File(
          p.join(homeDir.path, '.subsumed', 'skills', 'old', 'SKILL.md'));
      oldFile.parent.createSync(recursive: true);
      oldFile.writeAsStringSync('# Old');

      deployer.deploy();

      // Primary should have files
      expect(
        File(p.join(
                homeDir.path, '.primary', 'skills', 'memory-read', 'SKILL.md'))
            .existsSync(),
        isTrue,
      );

      // Subsumed should be cleaned (old files gone) and NOT re-populated
      expect(oldFile.existsSync(), isFalse);
      expect(
        Directory(p.join(homeDir.path, '.subsumed', 'skills')).existsSync(),
        isFalse,
      );
    });

    test('both adapters deploy when neither has base directory', () {
      // Neither .primary nor .subsumed exist
      final primary = _PrimaryAdapter();
      final subsumed = _SubsumedAdapter();
      final deployer = TargetDeployer(
        assets: assets,
        adapters: [primary, subsumed],
        homeDir: homeDir.path,
      );

      deployer.deploy();

      expect(
        File(p.join(
                homeDir.path, '.primary', 'skills', 'memory-read', 'SKILL.md'))
            .existsSync(),
        isTrue,
      );
      expect(
        File(p.join(homeDir.path, '.subsumed', 'skills', 'memory-read',
                'SKILL.md'))
            .existsSync(),
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
  String skillsDirectory(String homeDir) =>
      p.join(homeDir, '.fake2', 'skills');

  @override
  String agentDirectory(String homeDir) =>
      p.join(homeDir, '.fake2', 'agents');
}

class _PrimaryAdapter extends TargetAdapter {
  @override
  String get name => 'primary';

  @override
  String baseDirectory(String homeDir) => p.join(homeDir, '.primary');

  @override
  String skillsDirectory(String homeDir) =>
      p.join(homeDir, '.primary', 'skills');

  @override
  String agentDirectory(String homeDir) =>
      p.join(homeDir, '.primary', 'agents');
}

class _SubsumedAdapter extends TargetAdapter {
  @override
  String get name => 'subsumed';

  @override
  String baseDirectory(String homeDir) => p.join(homeDir, '.subsumed');

  @override
  String skillsDirectory(String homeDir) =>
      p.join(homeDir, '.subsumed', 'skills');

  @override
  String agentDirectory(String homeDir) =>
      p.join(homeDir, '.subsumed', 'agents');

  @override
  List<String> get subsumedBy => const ['primary'];
}
