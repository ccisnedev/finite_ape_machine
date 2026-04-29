/// Shared utility for checking the latest available version from GitHub releases.
library;

import 'dart:convert';
import 'dart:io';

const String _repo = 'ccisnedev/inquiry';

/// Result of a version check against GitHub releases.
class VersionCheckResult {
  final String? latestVersion;
  final bool updateAvailable;
  final String? error;

  const VersionCheckResult({
    this.latestVersion,
    required this.updateAvailable,
    this.error,
  });
}

/// Checks if a newer version is available on GitHub releases.
///
/// Returns [VersionCheckResult] with [updateAvailable] = true if
/// [currentVersion] differs from the latest release tag.
/// Silent on network failures — returns [updateAvailable] = false.
Future<VersionCheckResult> checkLatestVersion({
  required String currentVersion,
  HttpClient? httpClient,
}) async {
  final client = httpClient ?? HttpClient();
  try {
    client.connectionTimeout = const Duration(seconds: 5);
    final releaseUrl = Uri.parse(
      'https://api.github.com/repos/$_repo/releases/latest',
    );
    final request = await client.getUrl(releaseUrl);
    request.headers.set('Accept', 'application/vnd.github+json');
    request.headers.set('User-Agent', 'inquiry-cli/$currentVersion');
    final response = await request.close();

    if (response.statusCode != 200) {
      await response.drain<void>();
      return const VersionCheckResult(updateAvailable: false);
    }

    final body = await response.transform(utf8.decoder).join();
    final release = jsonDecode(body) as Map<String, dynamic>;
    final tagName = release['tag_name'] as String;
    final latestVersion =
        tagName.startsWith('v') ? tagName.substring(1) : tagName;

    final hasUpdate = latestVersion != currentVersion;
    return VersionCheckResult(
      latestVersion: latestVersion,
      updateAvailable: hasUpdate,
    );
  } catch (_) {
    // Network failure, timeout, DNS, etc. — silent.
    return const VersionCheckResult(updateAvailable: false);
  } finally {
    if (httpClient == null) client.close();
  }
}
