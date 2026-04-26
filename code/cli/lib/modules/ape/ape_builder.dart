import 'package:modular_cli_sdk/modular_cli_sdk.dart';

import '../../assets.dart';
import 'commands/prompt.dart';
import 'commands/state.dart';
import 'commands/transition.dart';

void buildApeModule(ModuleBuilder m, {Assets? assets}) {
  m.command<ApePromptInput, ApePromptOutput>(
    'prompt',
    (req) => ApePromptCommand(ApePromptInput.fromCliRequest(req), assets: assets),
    description: 'Assemble a sub-agent prompt from YAML + current FSM state',
  );

  m.command<ApeStateInput, ApeStateOutput>(
    'state',
    (req) => ApeStateCommand(ApeStateInput.fromCliRequest(req), assets: assets),
    description: 'Show current APE sub-state and valid internal transitions',
  );

  m.command<ApeTransitionInput, ApeTransitionOutput>(
    'transition',
    (req) => ApeTransitionCommand(ApeTransitionInput.fromCliRequest(req), assets: assets),
    description: 'Execute APE internal transition by --event',
  );
}
