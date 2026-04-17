import 'package:path/path.dart' as p;

import 'target_adapter.dart';

class CopilotAdapter extends TargetAdapter {
  @override
  String get name => 'copilot';

  @override
  String baseDirectory(String homeDir) => p.join(homeDir, '.copilot');

  @override
  String skillsDirectory(String homeDir) =>
      p.join(homeDir, '.copilot', 'skills');

  @override
  String agentDirectory(String homeDir) =>
      p.join(homeDir, '.copilot', 'agents');
}
