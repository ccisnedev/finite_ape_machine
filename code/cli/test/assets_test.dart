import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:inquiry_cli/assets.dart';

void main() {
  group('Assets', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('ape_assets_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    test('path resolves under assets/', () {
      final assets = Assets(root: tempDir.path);
      final resolved = assets.path('agents/inquiry.agent.md');

      expect(
        resolved,
        p.join(tempDir.path, 'assets', 'agents', 'inquiry.agent.md'),
      );
    });

    test('loadString reads file content relative to root', () {
      final assetsDir = Directory(p.join(tempDir.path, 'assets', 'agents'));
      assetsDir.createSync(recursive: true);
      final file = File(p.join(assetsDir.path, 'inquiry.agent.md'));
      file.writeAsStringSync('# APE Agent');

      final assets = Assets(root: tempDir.path);
      final content = assets.loadString('agents/inquiry.agent.md');

      expect(content, '# APE Agent');
    });

    test('loadString throws FileSystemException for missing file', () {
      final assets = Assets(root: tempDir.path);

      expect(
        () => assets.loadString('nonexistent.md'),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('listDirectory returns relative paths of files in a directory', () {
      final skillsDir = Directory(
        p.join(tempDir.path, 'assets', 'skills', 'memory-read'),
      );
      skillsDir.createSync(recursive: true);
      File(p.join(skillsDir.path, 'SKILL.md')).writeAsStringSync('# Skill');

      final skillsDir2 = Directory(
        p.join(tempDir.path, 'assets', 'skills', 'memory-write'),
      );
      skillsDir2.createSync(recursive: true);
      File(p.join(skillsDir2.path, 'SKILL.md')).writeAsStringSync('# Skill 2');

      final assets = Assets(root: tempDir.path);
      final dirs = assets.listDirectory('skills');

      expect(dirs, unorderedEquals(['memory-read', 'memory-write']));
    });
  });

  group('Assets integration (real files)', () {
    late Assets assets;

    setUp(() {
      assets = Assets(root: Directory.current.path);
    });

    test('reads agents/inquiry.agent.md', () {
      final content = assets.loadString('agents/inquiry.agent.md');
      expect(content, contains('APE'));
      expect(content, isNotEmpty);
    });

    test('reads skills/memory-read/SKILL.md', () {
      final content = assets.loadString('skills/memory-read/SKILL.md');
      expect(content, contains('memory'));
      expect(content, isNotEmpty);
    });

    test('reads skills/memory-write/SKILL.md', () {
      final content = assets.loadString('skills/memory-write/SKILL.md');
      expect(content, contains('memory'));
      expect(content, isNotEmpty);
    });

    test('reads skills/issue-end/SKILL.md', () {
      final content = assets.loadString('skills/issue-end/SKILL.md');
      expect(content, contains('issue-end'));
      expect(content, contains('EXECUTE'));
      expect(content, isNotEmpty);
    });

    test('listDirectory skills returns all skill directories', () {
      final dirs = assets.listDirectory('skills');
      expect(
        dirs,
        unorderedEquals([
          'issue-end',
          'issue-start',
          'memory-read',
          'memory-write',
        ]),
      );
    });
  });
}
