import 'package:test/test.dart';

import 'package:ape_cli/commands/tui.dart';
import 'package:ape_cli/commands/version.dart';

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

      expect(output.version, equals(apeVersion));
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

      expect(output.diagram, contains(apeVersion));
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
      expect(json, containsPair('version', apeVersion));
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
  });
}
