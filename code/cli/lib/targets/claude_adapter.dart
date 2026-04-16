import 'package:path/path.dart' as p;

import 'target_adapter.dart';

class ClaudeAdapter extends TargetAdapter {
  @override
  String get name => 'claude';

  @override
  String baseDirectory(String homeDir) => p.join(homeDir, '.claude');

  @override
  String skillsDirectory(String homeDir) =>
      p.join(homeDir, '.claude', 'skills');

  @override
  String agentDirectory(String homeDir) =>
      p.join(homeDir, '.claude', 'agents');
}
