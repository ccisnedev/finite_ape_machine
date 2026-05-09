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
        p.join(tempDir.path, 'assets', 'skills', 'doc-read'),
      );
      skillsDir.createSync(recursive: true);
      File(p.join(skillsDir.path, 'SKILL.md')).writeAsStringSync('# Skill');

      final skillsDir2 = Directory(
        p.join(tempDir.path, 'assets', 'skills', 'doc-write'),
      );
      skillsDir2.createSync(recursive: true);
      File(p.join(skillsDir2.path, 'SKILL.md')).writeAsStringSync('# Skill 2');

      final assets = Assets(root: tempDir.path);
      final dirs = assets.listDirectory('skills');

      expect(dirs, unorderedEquals(['doc-read', 'doc-write']));
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

    test('reads skills/doc-read/SKILL.md', () {
      final content = assets.loadString('skills/doc-read/SKILL.md');
      expect(content, contains('doc-read'));
      expect(content, isNotEmpty);
    });

    test('reads skills/doc-write/SKILL.md', () {
      final content = assets.loadString('skills/doc-write/SKILL.md');
      expect(content, contains('doc-write'));
      expect(content, isNotEmpty);
    });

    test('reads skills/issue-end/SKILL.md', () {
      final content = assets.loadString('skills/issue-end/SKILL.md');
      expect(content, contains('issue-end'));
      expect(content, contains('EXECUTE'));
      expect(content, isNotEmpty);
    });

    test('reads skills/issue-create/SKILL.md for TRIAGE issue creation', () {
      final content = assets.loadString('skills/issue-create/SKILL.md');
      expect(content, contains('issue-create'));
      expect(content, contains('TRIAGE'));
      expect(content, isNotEmpty);
    });

    test('reads skills/issue-start/SKILL.md as operational handoff only', () {
      final content = assets.loadString('skills/issue-start/SKILL.md');
      expect(content, contains('issue already exists'));
      expect(content, contains('start_analyze'));
      expect(content, contains('cleanrooms/<NNN>-<slug>/analyze/'));
      expect(content, isNot(contains('gh issue create')));
      expect(content, isNotEmpty);
    });

    test('standard APE identity assets do not own runtime contract markers', () {
      final disallowedMarkers = {
        'socrates': ['output_dir', 'confirmed_doc', 'index_file', 'doc-write'],
        'descartes': ['analysis_input', 'plan_file', 'Commit:'],
        'basho': ['retrospective.md'],
      };

      for (final entry in disallowedMarkers.entries) {
        final content = assets.loadString('apes/${entry.key}.yaml');
        for (final marker in entry.value) {
          expect(
            content,
            isNot(contains(marker)),
            reason:
                '${entry.key}.yaml should leave "$marker" to runtime-owned prompt surfaces',
          );
        }
      }
    });

    test('listDirectory skills returns all skill directories', () {
      final dirs = assets.listDirectory('skills');
      expect(
        dirs,
        unorderedEquals([
          'doc-read',
          'doc-write',
          'inquiry-install',
          'issue-create',
          'issue-end',
          'issue-start',
        ]),
      );
    });
  });
}
