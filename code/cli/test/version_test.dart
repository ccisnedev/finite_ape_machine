import 'package:test/test.dart';

import 'package:ape_cli/commands/version.dart';

void main() {
  group('ape version', () {
    test('returns current version string', () async {
      final command = VersionCommand(VersionInput());
      final output = await command.execute();

      expect(output.exitCode, 0);
      expect(output.version, apeVersion);
      expect(output.version, isNotEmpty);
    });

    test('version matches expected format', () {
      expect(apeVersion, matches(RegExp(r'^\d+\.\d+\.\d+$')));
    });
  });
}
