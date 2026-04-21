import 'package:test/test.dart';

import 'package:inquiry_cli/targets/all_adapters.dart';

void main() {
  group('TargetAdapter implementations', () {
    for (final adapter in allAdapters) {
      test('${adapter.name} returns non-empty skillsDirectory', () {
        final skillsDir = adapter.skillsDirectory('/home/user');
        expect(skillsDir, isNotEmpty);
      });

      test('${adapter.name} returns non-empty agentDirectory', () {
        final agentDir = adapter.agentDirectory('/home/user');
        expect(agentDir, isNotEmpty);
      });

      test('${adapter.name} returns non-empty baseDirectory', () {
        final baseDir = adapter.baseDirectory('/home/user');
        expect(baseDir, isNotEmpty);
      });

      test('${adapter.name} has a valid name', () {
        expect(adapter.name, isNotEmpty);
      });

      test('${adapter.name} skillsDirectory contains home dir', () {
        final skillsDir = adapter.skillsDirectory('/home/user');
        expect(skillsDir, startsWith('/home/user'));
      });

      test('${adapter.name} agentDirectory contains home dir', () {
        final agentDir = adapter.agentDirectory('/home/user');
        expect(agentDir, startsWith('/home/user'));
      });

      test('${adapter.name} baseDirectory contains home dir', () {
        final baseDir = adapter.baseDirectory('/home/user');
        expect(baseDir, startsWith('/home/user'));
      });
    }
  });

  group('allAdapters registry', () {
    test('returns exactly 5 adapters', () {
      expect(allAdapters, hasLength(5));
    });

    test('each adapter has a unique name', () {
      final names = allAdapters.map((a) => a.name).toSet();
      expect(names, hasLength(5));
    });
  });

  group('deployAdapters registry', () {
    test('returns exactly 1 adapter', () {
      expect(deployAdapters, hasLength(1));
    });

    test('only contains copilot', () {
      expect(deployAdapters.single.name, equals('copilot'));
    });
  });
}
