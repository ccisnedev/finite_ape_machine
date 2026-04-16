import 'dart:io';

import 'package:path/path.dart' as p;

import '../assets.dart';
import 'target_adapter.dart';

/// Orchestrates deploying assets (skills + agents) to target tool directories.
class TargetDeployer {
  final Assets assets;
  final List<TargetAdapter> adapters;
  final String homeDir;

  TargetDeployer({
    required this.assets,
    required this.adapters,
    required this.homeDir,
  });

  /// Deploys all assets to eligible adapter directories.
  ///
  /// Idempotent: cleans all adapters before deploying (D18).
  /// Adapters subsumed by another existing target are skipped.
  void deploy() {
    clean();

    final active = effectiveAdapters;
    for (final adapter in active) {
      _deploySkills(adapter);
      _deployAgents(adapter);
    }
  }

  /// Removes all deployed files from **all** adapter directories,
  /// including subsumed targets.
  void clean() {
    for (final adapter in adapters) {
      _deleteDirectory(adapter.skillsDirectory(homeDir));
      _deleteDirectory(adapter.agentDirectory(homeDir));
    }
  }

  /// Returns the adapters that should receive a deploy.
  ///
  /// An adapter is excluded when every target listed in its [subsumedBy]
  /// exists on disk.
  List<TargetAdapter> get effectiveAdapters {
    final existingNames =
        adapters.where((a) => a.exists(homeDir)).map((a) => a.name).toSet();

    return adapters.where((adapter) {
      if (adapter.subsumedBy.isEmpty) return true;
      // Skip this adapter only if at least one subsuming target exists.
      return !adapter.subsumedBy.any(existingNames.contains);
    }).toList();
  }

  void _deploySkills(TargetAdapter adapter) {
    final skillNames = assets.listDirectory('skills');
    final targetSkillsDir = adapter.skillsDirectory(homeDir);

    for (final skillName in skillNames) {
      final content = assets.loadString('skills/$skillName/SKILL.md');
      final targetFile = File(p.join(targetSkillsDir, skillName, 'SKILL.md'));
      targetFile.parent.createSync(recursive: true);
      targetFile.writeAsStringSync(content);
    }
  }

  void _deployAgents(TargetAdapter adapter) {
    final agentsDir = Directory(assets.path('agents'));
    if (!agentsDir.existsSync()) return;

    final targetAgentDir = adapter.agentDirectory(homeDir);

    for (final entity in agentsDir.listSync().whereType<File>()) {
      final fileName = p.basename(entity.path);
      final content = entity.readAsStringSync();
      final targetFile = File(p.join(targetAgentDir, fileName));
      targetFile.parent.createSync(recursive: true);
      targetFile.writeAsStringSync(content);
    }
  }

  void _deleteDirectory(String path) {
    final dir = Directory(path);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  }
}
