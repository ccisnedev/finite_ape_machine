import 'package:test/test.dart';

import 'package:inquiry_cli/modules/global/commands/tui.dart';
import 'package:inquiry_cli/modules/global/commands/version.dart';

void main() {
  group('TUI Command', () {
    test('TuiInput.fromCliRequest() returns TuiInput', () {
      // TuiInput has no parameters
      final input = TuiInput();
      expect(input, isA<TuiInput>());
    });

    test('TuiOutput contains version string', () async {
      final cmd = TuiCommand(TuiInput());
      final output = await cmd.execute();

      expect(output.version, equals(inquiryVersion));
    });

    test('TuiOutput.diagram contains FSM states', () async {
      final cmd = TuiCommand(TuiInput());
      final output = await cmd.execute();

      expect(output.diagram, contains('IDLE'));
      expect(output.diagram, contains('Analyze'));
      expect(output.diagram, contains('Plan'));
      expect(output.diagram, contains('Execute'));
      expect(output.diagram, contains('EVOLUTION'));
    });

    test('TuiOutput.diagram contains version', () async {
      final cmd = TuiCommand(TuiInput());
      final output = await cmd.execute();

      expect(output.diagram, contains(inquiryVersion));
    });

    test('TuiOutput.exitCode is 0', () async {
      final cmd = TuiCommand(TuiInput());
      final output = await cmd.execute();

      expect(output.exitCode, equals(0));
    });

    test('TuiOutput.toJson() has expected structure', () async {
      final cmd = TuiCommand(TuiInput());
      final output = await cmd.execute();

      final json = output.toJson();
      expect(json, containsPair('version', inquiryVersion));
      expect(json, contains('diagram'));
      expect(json['diagram'], isA<String>());
    });

    test('TuiInput.toJson() returns empty map', () {
      final input = TuiInput();
      expect(input.toJson(), isEmpty);
    });

    test('TuiCommand.validate() returns null', () {
      final cmd = TuiCommand(TuiInput());
      expect(cmd.validate(), isNull);
    });

    test('TuiOutput.toText() returns diagram only', () async {
      final cmd = TuiCommand(TuiInput());
      final output = await cmd.execute();

      // toText() should return only the diagram, not field labels
      expect(output.toText(), equals(output.diagram));
      expect(output.toText(), isNot(contains('version:')));
      expect(output.toText(), isNot(contains('diagram:')));
    });
  });
}
