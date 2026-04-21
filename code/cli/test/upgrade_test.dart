import 'package:test/test.dart';

import 'package:inquiry_cli/modules/global/commands/upgrade.dart';
import 'package:inquiry_cli/modules/global/commands/version.dart';

void main() {
  group('inquiry upgrade', () {
    test('UpgradeInput serializes correctly', () {
      final input = UpgradeInput(installDir: '/fake/dir');
      expect(input.toJson(), {'installDir': '/fake/dir'});
    });

    test('UpgradeOutput reports no upgrade when already latest', () {
      final output = UpgradeOutput(
        message: 'Already on the latest version',
        previousVersion: inquiryVersion,
        newVersion: inquiryVersion,
        upgraded: false,
      );
      expect(output.exitCode, 0);
      expect(output.upgraded, isFalse);
      expect(output.toJson()['message'], contains('latest'));
    });

    test('UpgradeOutput reports successful upgrade', () {
      final output = UpgradeOutput(
        message: 'Upgraded from 0.0.1 to 0.0.2',
        previousVersion: '0.0.1',
        newVersion: '0.0.2',
        upgraded: true,
      );
      expect(output.exitCode, 0);
      expect(output.upgraded, isTrue);
      expect(output.previousVersion, '0.0.1');
      expect(output.newVersion, '0.0.2');
    });

    test('toText() returns checkmark message when upgraded', () {
      final output = UpgradeOutput(
        message: 'Upgraded from 0.0.1 to 0.0.2',
        previousVersion: '0.0.1',
        newVersion: '0.0.2',
        upgraded: true,
      );
      expect(output.toText(), contains('✓'));
      expect(output.toText(), contains('0.0.1'));
      expect(output.toText(), contains('0.0.2'));
    });

    test('toText() returns plain message when not upgraded', () {
      final output = UpgradeOutput(
        message: 'Already on the latest version',
        previousVersion: '0.0.2',
        newVersion: '0.0.2',
        upgraded: false,
      );
      expect(output.toText(), equals('Already on the latest version'));
    });
  });
}
