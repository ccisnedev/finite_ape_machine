/// `ape upgrade` — downloads and installs the latest APE release.
///
/// Fetches the latest release from GitHub, downloads the zip,
/// extracts it over the current installation, and redeploys targets.
library;

import 'dart:convert';
import 'dart:io';

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;

import '../../../targets/platform_ops.dart';
import 'version.dart';

const String _repo = 'ccisnedev/finite_ape_machine';

// ─── Input ──────────────────────────────────────────────────────────────────

class UpgradeInput extends Input {
  final String installDir;

  UpgradeInput({required this.installDir});

  factory UpgradeInput.fromCliRequest(CliRequest req) {
    final installDir = p.dirname(p.dirname(Platform.resolvedExecutable));
    return UpgradeInput(installDir: installDir);
  }

  @override
  Map<String, dynamic> toJson() => {'installDir': installDir};
}

// ─── Output ─────────────────────────────────────────────────────────────────

class UpgradeOutput extends Output {
  final String message;
  final String previousVersion;
  final String newVersion;
  final bool upgraded;

  UpgradeOutput({
    required this.message,
    required this.previousVersion,
    required this.newVersion,
    required this.upgraded,
  });

  @override
  Map<String, dynamic> toJson() => {
    'message': message,
    'previousVersion': previousVersion,
    'newVersion': newVersion,
    'upgraded': upgraded,
  };

  @override
  int get exitCode => ExitCode.ok;

  /// Returns human-friendly upgrade status.
  @override
  String? toText() {
    if (!upgraded) return message;
    return '✓ Upgraded: $previousVersion → $newVersion';
  }
}

// ─── Command ────────────────────────────────────────────────────────────────

class UpgradeCommand implements Command<UpgradeInput, UpgradeOutput> {
  @override
  final UpgradeInput input;
  final PlatformOps platformOps;
  final HttpClient? httpClientOverride;

  UpgradeCommand(
    this.input, {
    PlatformOps? platformOps,
    this.httpClientOverride,
  }) : platformOps = platformOps ?? PlatformOps.current();

  @override
  String? validate() => null;

  @override
  Future<UpgradeOutput> execute() async {
    final client = httpClientOverride ?? HttpClient();
    try {
      // 1. Fetch latest release metadata
      stderr.writeln('Current version: $apeVersion');
      stderr.writeln('Checking for updates...');

      final releaseUrl = Uri.parse(
        'https://api.github.com/repos/$_repo/releases/latest',
      );
      final metaRequest = await client.getUrl(releaseUrl);
      metaRequest.headers.set('Accept', 'application/vnd.github+json');
      metaRequest.headers.set('User-Agent', 'ape-cli/$apeVersion');
      final metaResponse = await metaRequest.close();

      if (metaResponse.statusCode != 200) {
        return UpgradeOutput(
          message:
              'Failed to fetch release info (HTTP ${metaResponse.statusCode})',
          previousVersion: apeVersion,
          newVersion: apeVersion,
          upgraded: false,
        );
      }

      final body = await metaResponse.transform(utf8.decoder).join();
      final release = jsonDecode(body) as Map<String, dynamic>;
      final tagName = release['tag_name'] as String;
      final latestVersion = tagName.startsWith('v')
          ? tagName.substring(1)
          : tagName;

      stderr.writeln('Latest version available: $latestVersion');

      if (latestVersion == apeVersion) {
        return UpgradeOutput(
          message: 'Already on the latest version',
          previousVersion: apeVersion,
          newVersion: apeVersion,
          upgraded: false,
        );
      }

      stderr.writeln('Found v$latestVersion, downloading...');

      // 2. Find the asset for this platform
      final expectedAsset = platformOps.assetName;
      final assets = release['assets'] as List<dynamic>;
      final asset = assets.cast<Map<String, dynamic>>().firstWhere(
        (a) => (a['name'] as String) == expectedAsset,
        orElse: () => throw CommandException(
          code: 'ASSET_NOT_FOUND',
          message: 'No $expectedAsset asset in release $tagName',
          exitCode: ExitCode.notFound,
        ),
      );

      final downloadUrl = asset['browser_download_url'] as String;

      // 3. Download to temp
      final tempDir = Directory.systemTemp.createTempSync('ape_upgrade_');
      final zipFile = File(p.join(tempDir.path, expectedAsset));

      final dlRequest = await client.getUrl(Uri.parse(downloadUrl));
      dlRequest.headers.set('User-Agent', 'ape-cli/$apeVersion');
      final dlResponse = await dlRequest.close();

      // Follow redirect if needed
      stderr.writeln('Downloading asset: $expectedAsset');
      final sink = zipFile.openWrite();
      await dlResponse.pipe(sink);

      // 4. Extract over current installation via PlatformOps
      final installDir = input.installDir;
      stderr.writeln('Applying update in: $installDir');

      try {
        // Windows locks running executables — rename before extraction
        if (Platform.isWindows) {
          final bakFile = File('${Platform.resolvedExecutable}.bak');
          if (bakFile.existsSync()) bakFile.deleteSync();
          File(Platform.resolvedExecutable).renameSync(bakFile.path);
        }

        await platformOps.expandArchive(zipFile.path, installDir);

        // Best-effort cleanup of old binary
        if (Platform.isWindows) {
          try {
            final bakFile = File('${Platform.resolvedExecutable}.bak');
            if (bakFile.existsSync()) bakFile.deleteSync();
          } on FileSystemException {
            // Still locked — will be cleaned up on next upgrade
          }
        }
      } catch (e) {
        stderr.writeln('Upgrade failed during apply step: $e');
        tempDir.deleteSync(recursive: true);
        return UpgradeOutput(
          message: 'Failed to extract: $e',
          previousVersion: apeVersion,
          newVersion: latestVersion,
          upgraded: false,
        );
      }

      tempDir.deleteSync(recursive: true);

      // 5. Redeploy targets using the new binary
      stderr.writeln('Deploying targets...');
      await platformOps.runPostInstall(installDir);
      stderr.writeln('Upgrade completed successfully.');

      return UpgradeOutput(
        message: 'Upgraded from $apeVersion to $latestVersion',
        previousVersion: apeVersion,
        newVersion: latestVersion,
        upgraded: true,
      );
    } finally {
      if (httpClientOverride == null) client.close();
    }
  }
}
