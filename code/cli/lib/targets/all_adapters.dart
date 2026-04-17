import 'claude_adapter.dart';
import 'codex_adapter.dart';
import 'copilot_adapter.dart';
import 'crush_adapter.dart';
import 'gemini_adapter.dart';
import 'target_adapter.dart';

/// All known adapters — used by [TargetDeployer.clean] for backward
/// compatibility (removes orphaned files from previous multi-target deploys).
final List<TargetAdapter> allAdapters = [
  CopilotAdapter(),
  ClaudeAdapter(),
  CodexAdapter(),
  CrushAdapter(),
  GeminiAdapter(),
];

/// Adapters that receive deploys in the current version.
/// For v0.0.x only Copilot is active (D20).
final List<TargetAdapter> deployAdapters = [
  CopilotAdapter(),
];
