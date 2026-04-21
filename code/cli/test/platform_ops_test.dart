import 'package:test/test.dart';

import 'package:inquiry_cli/targets/platform_ops.dart';

/// A fake [PlatformOps] for testing. Records calls and returns
/// configurable values without touching the real OS.
class FakePlatformOps implements PlatformOps {
  final String fakeBinaryName;
  final String fakeAssetName;
  final String? fakeEnvValue;

  final List<String> calls = [];

  FakePlatformOps({
    this.fakeBinaryName = 'ape-fake',
    this.fakeAssetName = 'ape-fake.zip',
    this.fakeEnvValue,
  });

  @override
  String get binaryName => fakeBinaryName;

  @override
  String get assetName => fakeAssetName;

  @override
  Future<void> expandArchive(String archivePath, String destDir) async {
    calls.add('expandArchive($archivePath, $destDir)');
  }

  @override
  String? getEnvVariable(String name) {
    calls.add('getEnvVariable($name)');
    return fakeEnvValue;
  }

  @override
  Future<void> setEnvVariable(String name, String value) async {
    calls.add('setEnvVariable($name, $value)');
  }

  @override
  Future<void> selfReplace(
    String newBinaryPath,
    String currentBinaryPath,
  ) async {
    calls.add('selfReplace($newBinaryPath, $currentBinaryPath)');
  }

  @override
  Future<void> runPostInstall(String installDir) async {
    calls.add('runPostInstall($installDir)');
  }

  @override
  void scheduleDeletion(String dir) {
    calls.add('scheduleDeletion($dir)');
  }
}

void main() {
  group('PlatformOps contract', () {
    late FakePlatformOps fake;

    setUp(() {
      fake = FakePlatformOps();
    });

    test('FakePlatformOps implements all methods', () {
      // If this compiles, the fake satisfies the interface.
      final PlatformOps ops = fake;
      expect(ops, isA<PlatformOps>());
    });

    test('binaryName returns non-empty string', () {
      expect(fake.binaryName, isNotEmpty);
    });

    test('assetName returns non-empty string', () {
      expect(fake.assetName, isNotEmpty);
    });

    test('expandArchive is callable and records call', () async {
      await fake.expandArchive('/tmp/archive.zip', '/tmp/dest');
      expect(fake.calls, contains('expandArchive(/tmp/archive.zip, /tmp/dest)'));
    });

    test('getEnvVariable returns configured value', () {
      final ops = FakePlatformOps(fakeEnvValue: 'C:\\Users\\bin');
      final result = ops.getEnvVariable('PATH');
      expect(result, equals('C:\\Users\\bin'));
      expect(ops.calls, contains('getEnvVariable(PATH)'));
    });

    test('getEnvVariable returns null when not configured', () {
      expect(fake.getEnvVariable('NONEXISTENT'), isNull);
    });

    test('setEnvVariable completes without error', () async {
      await fake.setEnvVariable('PATH', '/usr/local/bin');
      expect(fake.calls, contains('setEnvVariable(PATH, /usr/local/bin)'));
    });

    test('selfReplace completes without error', () async {
      await fake.selfReplace('/new/ape', '/old/ape');
      expect(fake.calls, contains('selfReplace(/new/ape, /old/ape)'));
    });

    test('runPostInstall completes without error', () async {
      await fake.runPostInstall('/opt/ape');
      expect(fake.calls, contains('runPostInstall(/opt/ape)'));
    });

    test('scheduleDeletion records call', () {
      fake.scheduleDeletion('/tmp/ape_dir');
      expect(fake.calls, contains('scheduleDeletion(/tmp/ape_dir)'));
    });
  });

  group('PlatformOps.current()', () {
    test('returns a non-null PlatformOps instance', () {
      final ops = PlatformOps.current();
      expect(ops, isA<PlatformOps>());
      expect(ops.binaryName, isNotEmpty);
      expect(ops.assetName, isNotEmpty);
    });
  });
}
