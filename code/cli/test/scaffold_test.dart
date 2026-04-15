import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:test/test.dart';

void main() {
  group('CLI scaffold', () {
    test('responds to a registered command with exit code 0', () async {
      final cli = ModularCli();
      cli.command<PingInput, PingOutput>(
        'ping',
        (req) => PingCommand(PingInput.fromCliRequest(req)),
        description: 'Ping test',
      );

      final code = await cli.run(['ping']);
      expect(code, ExitCode.ok);
    });

    test('returns exit code 64 for unknown command', () async {
      final cli = ModularCli();

      final code = await cli.run(['nonexistent']);
      expect(code, ExitCode.invalidUsage);
    });
  });
}

// ─── Dummy command for scaffold validation ──────────────────────────────────

class PingInput extends Input {
  PingInput();
  factory PingInput.fromCliRequest(CliRequest req) => PingInput();

  @override
  Map<String, dynamic> toJson() => {};
}

class PingOutput extends Output {
  PingOutput();

  @override
  Map<String, dynamic> toJson() => {'pong': true};

  @override
  int get exitCode => ExitCode.ok;
}

class PingCommand implements Command<PingInput, PingOutput> {
  @override
  final PingInput input;
  PingCommand(this.input);

  @override
  String? validate() => null;

  @override
  Future<PingOutput> execute() async => PingOutput();
}
