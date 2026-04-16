import 'package:path/path.dart' as p;

import 'target_adapter.dart';

class CrushAdapter extends TargetAdapter {
  @override
  String get name => 'crush';

  @override
  String baseDirectory(String homeDir) =>
      p.join(homeDir, '.config', 'crush');

  @override
  String skillsDirectory(String homeDir) =>
      p.join(homeDir, '.config', 'crush', 'skills');

  @override
  String agentDirectory(String homeDir) =>
      p.join(homeDir, '.config', 'crush', 'agents');
}
