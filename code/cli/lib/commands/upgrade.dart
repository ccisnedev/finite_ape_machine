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

import 'version.dart';

const String _repo = 'ccisnedev/finite_ape_machine';
const String _assetName = 'ape-windows-x64.zip';

// ─── Input ──────────────────────────────────────────────────────────────────

class UpgradeInput extends Input {
  final String installDir;

  UpgradeInput({required this.installDir});

  factory UpgradeInput.fromCliRequest(CliRequest req) {
    final installDir =
        p.dirname(p.dirname(Platform.resolvedExecutable));
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
}

// ─── Command ────────────────────────────────────────────────────────────────

class UpgradeCommand implements Command<UpgradeInput, UpgradeOutput> {
  @override
  final UpgradeInput input;
  final HttpClient? httpClientOverride;

  UpgradeCommand(this.input, {this.httpClientOverride});

  @override
  String? validate() => null;

  @override
  Future<UpgradeOutput> execute() async {
    final client = httpClientOverride ?? HttpClient();
    try {
      // 1. Fetch latest release metadata
      final releaseUrl = Uri.parse(
          'https://api.github.com/repos/$_repo/releases/latest');
      final metaRequest = await client.getUrl(releaseUrl);
      metaRequest.headers.set('Accept', 'application/vnd.github+json');
      metaRequest.headers.set('User-Agent', 'ape-cli/$apeVersion');
      final metaResponse = await metaRequest.close();

      if (metaResponse.statusCode != 200) {
        return UpgradeOutput(
          message: 'Failed to fetch release info (HTTP ${metaResponse.statusCode})',
          previousVersion: apeVersion,
          newVersion: apeVersion,
          upgraded: false,
        );
      }

      final body = await metaResponse.transform(utf8.decoder).join();
      final release = jsonDecode(body) as Map<String, dynamic>;
      final tagName = release['tag_name'] as String;
      final latestVersion = tagName.startsWith('v') ? tagName.substring(1) : tagName;

      if (latestVersion == apeVersion) {
        return UpgradeOutput(
          message: 'Already on the latest version',
          previousVersion: apeVersion,
          newVersion: apeVersion,
          upgraded: false,
        );
      }

      // 2. Find the zip asset
      final assets = release['assets'] as List<dynamic>;
      final asset = assets.cast<Map<String, dynamic>>().firstWhere(
        (a) => (a['name'] as String) == _assetName,
        orElse: () => throw CommandException(
          code: 'ASSET_NOT_FOUND',
          message: 'No $_assetName asset in release $tagName',
          exitCode: ExitCode.notFound,
        ),
      );

      final downloadUrl = asset['browser_download_url'] as String;

      // 3. Download to temp
      final tempDir = Directory.systemTemp.createTempSync('ape_upgrade_');
      final zipFile = File(p.join(tempDir.path, _assetName));

      final dlRequest = await client.getUrl(Uri.parse(downloadUrl));
      dlRequest.headers.set('User-Agent', 'ape-cli/$apeVersion');
      final dlResponse = await dlRequest.close();

      // Follow redirect if needed
      final sink = zipFile.openWrite();
      await dlResponse.pipe(sink);

      // 4. Extract over current installation
      final installDir = input.installDir;
      final result = await Process.run(
        'powershell',
        [
          '-NoProfile',
          '-Command',
          'Expand-Archive -Path "${zipFile.path}" -DestinationPath "$installDir" -Force',
        ],
      );

      tempDir.deleteSync(recursive: true);

      if (result.exitCode != 0) {
        return UpgradeOutput(
          message: 'Failed to extract: ${result.stderr}',
          previousVersion: apeVersion,
          newVersion: latestVersion,
          upgraded: false,
        );
      }

      // 5. Redeploy targets using the new binary
      await Process.run(
        p.join(installDir, 'bin', 'ape.exe'),
        ['target', 'get'],
      );

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
