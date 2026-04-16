import 'package:path/path.dart' as p;

import 'target_adapter.dart';

class GeminiAdapter extends TargetAdapter {
  @override
  String get name => 'gemini';

  @override
  String baseDirectory(String homeDir) => p.join(homeDir, '.gemini');

  @override
  String skillsDirectory(String homeDir) =>
      p.join(homeDir, '.gemini', 'skills');

  @override
  String agentDirectory(String homeDir) =>
      p.join(homeDir, '.gemini', 'agents');
}
