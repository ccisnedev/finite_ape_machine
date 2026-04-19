import 'package:modular_cli_sdk/modular_cli_sdk.dart';

import 'commands/transition.dart';

void buildStateModule(ModuleBuilder m) {
  m.command<StateTransitionInput, StateTransitionOutput>(
    'transition',
    (req) => StateTransitionCommand(StateTransitionInput.fromCliRequest(req)),
    description:
        'Run deterministic FSM transition by --event (optional --state)',
  );
}
