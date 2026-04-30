import 'dart:io';

/// Returns the current git branch name for [workingDirectory].
///
/// Returns an empty string if git is unavailable or not in a repository.
String getCurrentBranch(String workingDirectory) {
  try {
    final result = Process.runSync(
      'git',
      ['rev-parse', '--abbrev-ref', 'HEAD'],
      workingDirectory: workingDirectory,
    );
    if (result.exitCode != 0) return '';
    return (result.stdout as String).trim();
  } catch (_) {
    return '';
  }
}
