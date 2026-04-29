import * as path from 'path';
import * as os from 'os';

const GITHUB_REPO = 'ccisnedev/inquiry';
const RELEASES_URL = `https://api.github.com/repos/${GITHUB_REPO}/releases/latest`;

export function getAssetName(platform: string): string {
  if (platform === 'win32') { return 'inquiry-windows-x64.zip'; }
  if (platform === 'linux') { return 'inquiry-linux-x64.tar.gz'; }
  throw new Error(`Unsupported platform: ${platform}`);
}

export function getInstallDir(platform: string): string {
  if (platform === 'win32') {
    return path.join(process.env.LOCALAPPDATA || path.join(os.homedir(), 'AppData', 'Local'), 'inquiry');
  }
  if (platform === 'linux') {
    return path.join(os.homedir(), '.inquiry');
  }
  throw new Error(`Unsupported platform: ${platform}`);
}

interface CancellationTokenLike {
  onCancellationRequested(listener: () => void): void;
  isCancellationRequested?: boolean;
}

export interface InstallerDeps {
  platform: string;
  fetchJson(url: string): Promise<any>;
  downloadFile(url: string, destPath: string): Promise<void>;
  extractZip(zipPath: string, destDir: string): Promise<void>;
  extractTarGz(tarPath: string, destDir: string): Promise<void>;
  execFile(cmd: string, args: string[]): Promise<string>;
  mkdirp(dir: string): Promise<void>;
  rmrf(dir: string): Promise<void>;
  writeFile(filePath: string, content: string): Promise<void>;
  chmod(filePath: string, mode: string): Promise<void>;
  symlink(target: string, linkPath: string): Promise<void>;
  getEnvPath(): string;
  setEnvPath(newPath: string): void;
  withProgress(
    options: { location: number; title: string; cancellable: boolean },
    task: (progress: { report(value: { message?: string }): void }, token: CancellationTokenLike) => Promise<void>,
  ): Promise<void>;
  tmpdir(): string;
}

function defaultFetchJson(url: string): Promise<any> {
  return new Promise((resolve, reject) => {
    const https = require('https');
    const options = { headers: { 'Accept': 'application/vnd.github+json', 'User-Agent': 'inquiry-vscode' } };
    https.get(url, options, (res: any) => {
      if (res.statusCode !== 200) {
        reject(new Error(`GitHub API request failed: HTTP ${res.statusCode}`));
        return;
      }
      let data = '';
      res.on('data', (chunk: string) => { data += chunk; });
      res.on('end', () => {
        try { resolve(JSON.parse(data)); } catch (e) { reject(new Error('Invalid JSON from GitHub API')); }
      });
    }).on('error', (err: Error) => reject(err));
  });
}

function defaultDownloadFile(url: string, destPath: string): Promise<void> {
  return new Promise((resolve, reject) => {
    const https = require('https');
    const fs = require('fs');
    const options = { headers: { 'User-Agent': 'inquiry-vscode' } };

    const doRequest = (requestUrl: string) => {
      https.get(requestUrl, options, (res: any) => {
        // Follow redirects (GitHub asset URLs redirect)
        if (res.statusCode === 301 || res.statusCode === 302) {
          doRequest(res.headers.location);
          return;
        }
        if (res.statusCode !== 200) {
          reject(new Error(`Download failed: HTTP ${res.statusCode}`));
          return;
        }
        const file = fs.createWriteStream(destPath);
        res.pipe(file);
        file.on('finish', () => { file.close(resolve); });
        file.on('error', (err: Error) => {
          try { fs.unlinkSync(destPath); } catch { /* ignore */ }
          reject(err);
        });
      }).on('error', (err: Error) => {
        try { fs.unlinkSync(destPath); } catch { /* ignore */ }
        reject(err);
      });
    };
    doRequest(url);
  });
}

async function defaultExtractZip(zipPath: string, destDir: string): Promise<void> {
  const { execFile } = require('child_process');
  const { promisify } = require('util');
  const exec = promisify(execFile);
  await exec('powershell', [
    '-NoProfile', '-Command',
    `Expand-Archive -Path '${zipPath}' -DestinationPath '${destDir}' -Force`,
  ]);
}

async function defaultExtractTarGz(tarPath: string, destDir: string): Promise<void> {
  const { execFile } = require('child_process');
  const { promisify } = require('util');
  const exec = promisify(execFile);
  await exec('tar', ['xzf', tarPath, '-C', destDir]);
}

async function defaultExecFile(cmd: string, args: string[]): Promise<string> {
  const { execFile } = require('child_process');
  const { promisify } = require('util');
  const exec = promisify(execFile);
  const { stdout } = await exec(cmd, args);
  return stdout.toString().trim();
}

export async function installInquiryCli(deps?: Partial<InstallerDeps>): Promise<void> {
  const platform = deps?.platform ?? process.platform;
  const fetchJson = deps?.fetchJson ?? defaultFetchJson;
  const downloadFile = deps?.downloadFile ?? defaultDownloadFile;
  const extractZip = deps?.extractZip ?? defaultExtractZip;
  const extractTarGz = deps?.extractTarGz ?? defaultExtractTarGz;
  const execFileFn = deps?.execFile ?? defaultExecFile;
  const tmpdir = deps?.tmpdir ?? (() => os.tmpdir());
  const withProgress = deps?.withProgress ?? (() => {
    const vscode = require('vscode');
    return vscode.window.withProgress.bind(vscode.window);
  })();

  const fs = require('fs').promises;
  const mkdirp = deps?.mkdirp ?? ((dir: string) => fs.mkdir(dir, { recursive: true }));
  const rmrf = deps?.rmrf ?? ((dir: string) => fs.rm(dir, { recursive: true, force: true }));
  const writeFile = deps?.writeFile ?? ((f: string, c: string) => fs.writeFile(f, c, 'utf8'));
  const chmod = deps?.chmod ?? ((f: string, m: string) => fs.chmod(f, m));
  const symlink = deps?.symlink ?? ((target: string, linkPath: string) =>
    fs.symlink(target, linkPath).catch(async () => {
      try { await fs.unlink(linkPath); } catch { /* ignore */ }
      return fs.symlink(target, linkPath);
    }));
  const getEnvPath = deps?.getEnvPath ?? (() => process.env.PATH || '');
  const setEnvPath = deps?.setEnvPath ?? ((p: string) => { process.env.PATH = p; });

  const installDir = getInstallDir(platform);
  const binDir = path.join(installDir, 'bin');
  const assetName = getAssetName(platform);

  await withProgress(
    { location: 15, title: 'Installing Inquiry CLI...', cancellable: true },
    async (progress: { report(value: { message?: string }): void }, token: CancellationTokenLike) => {
      let cancelled = false;
      token.onCancellationRequested(() => { cancelled = true; });

      // 1. Fetch latest release
      progress.report({ message: 'Fetching latest release...' });
      const release = await fetchJson(RELEASES_URL);
      const asset = release.assets?.find((a: any) => a.name === assetName);
      if (!asset) {
        throw new Error(`No ${assetName} asset found in release ${release.tag_name}`);
      }
      if (cancelled) { throw new Error('Installation cancelled'); }

      // 2. Download asset
      progress.report({ message: `Downloading ${release.tag_name}...` });
      const tempFile = path.join(tmpdir(), `inquiry-${release.tag_name}${platform === 'win32' ? '.zip' : '.tar.gz'}`);
      await downloadFile(asset.browser_download_url, tempFile);
      if (cancelled) { throw new Error('Installation cancelled'); }

      // 3. Clean previous installation
      progress.report({ message: 'Preparing installation directory...' });
      await rmrf(installDir);
      await mkdirp(installDir);

      // 4. Extract
      progress.report({ message: 'Extracting...' });
      if (platform === 'win32') {
        await extractZip(tempFile, installDir);
      } else {
        await extractTarGz(tempFile, installDir);
      }
      // Clean temp file
      try { const fss = require('fs'); fss.unlinkSync(tempFile); } catch { /* ignore */ }

      // 5. Platform-specific setup
      if (platform === 'win32') {
        // Create iq.cmd shim
        progress.report({ message: 'Creating iq alias...' });
        await writeFile(path.join(binDir, 'iq.cmd'), '@"%~dp0inquiry.exe" %*');

        // Add to user PATH via PowerShell
        progress.report({ message: 'Updating PATH...' });
        try {
          await execFileFn('powershell', [
            '-NoProfile', '-Command',
            `$p = [Environment]::GetEnvironmentVariable('PATH','User'); if ($p -notlike '*${binDir}*') { [Environment]::SetEnvironmentVariable('PATH', "$p;${binDir}", 'User') }`,
          ]);
        } catch { /* non-fatal: user can restart terminal */ }
      } else {
        // Linux: make binary executable and create symlinks
        await chmod(path.join(binDir, 'inquiry'), '755');

        const linkDir = path.join(os.homedir(), '.local', 'bin');
        await mkdirp(linkDir);
        await symlink(path.join(binDir, 'inquiry'), path.join(linkDir, 'inquiry'));
        await symlink(path.join(binDir, 'inquiry'), path.join(linkDir, 'iq'));
      }

      // Ensure bin is in current process PATH
      const currentPath = getEnvPath();
      if (!currentPath.includes(binDir)) {
        setEnvPath(`${binDir}${path.delimiter}${currentPath}`);
      }

      // 6. Deploy to active target
      progress.report({ message: 'Deploying to active target...' });
      const binaryPath = path.join(binDir, platform === 'win32' ? 'inquiry.exe' : 'inquiry');
      try {
        await execFileFn(binaryPath, ['target', 'get']);
      } catch { /* non-fatal */ }

      // 7. Verify
      progress.report({ message: 'Verifying installation...' });
      const version = await execFileFn(binaryPath, ['version']);
      progress.report({ message: `Installed ${version}` });
    },
  );
}
