import 'package:test/test.dart';

import 'package:inquiry_cli/modules/global/commands/version.dart';

void main() {
  group('inquiry version', () {
    test('returns current version string', () async {
      final command = VersionCommand(VersionInput());
      final output = await command.execute();

      expect(output.exitCode, 0);
      expect(output.version, inquiryVersion);
      expect(output.version, isNotEmpty);
    });

    test('version matches expected format', () {
      expect(inquiryVersion, matches(RegExp(r'^\d+\.\d+\.\d+$')));
    });
  });
}
