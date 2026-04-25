import { EventEmitter } from 'events';
import * as path from 'path';
import * as os from 'os';

const INSTALL_BASE_URL = 'https://inquiry.si14bm.com';

export function getInstallScriptUrl(platform: string): { url: string; filename: string } {
  if (platform === 'win32') {
    return { url: `${INSTALL_BASE_URL}/install.ps1`, filename: 'inquiry-install.ps1' };
  }
  if (platform === 'linux') {
    return { url: `${INSTALL_BASE_URL}/install.sh`, filename: 'inquiry-install.sh' };
  }
  throw new Error(`Unsupported platform: ${platform}`);
}

export function getRunCommand(platform: string, scriptPath: string): { shell: string; args: string[] } {
  if (platform === 'win32') {
    return {
      shell: 'powershell',
      args: ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', scriptPath],
    };
  }
  if (platform === 'linux') {
    return {
      shell: 'bash',
      args: [scriptPath],
    };
  }
  throw new Error(`Unsupported platform: ${platform}`);
}

interface ChildProcessLike {
  stdout: EventEmitter;
  stderr: EventEmitter;
  on(event: string, listener: (...args: any[]) => void): void;
  kill(): void;
}

interface CancellationTokenLike {
  onCancellationRequested(listener: () => void): void;
}

export interface InstallerDeps {
  platform: string;
  spawn(cmd: string, args: string[]): ChildProcessLike;
  downloadFile(url: string, destPath: string): Promise<void>;
  withProgress(
    options: { location: number; title: string; cancellable: boolean },
    task: (progress: { report(value: { message?: string }): void }, token: CancellationTokenLike) => Promise<void>,
  ): Promise<void>;
  tmpdir(): string;
}

function defaultDownloadFile(url: string, destPath: string): Promise<void> {
  return new Promise((resolve, reject) => {
    const https = require('https');
    const fs = require('fs');
    const file = fs.createWriteStream(destPath);
    https.get(url, (res: any) => {
      if (res.statusCode !== 200) {
        file.close();
        fs.unlinkSync(destPath);
        reject(new Error(`Download failed: HTTP ${res.statusCode}`));
        return;
      }
      res.pipe(file);
      file.on('finish', () => { file.close(resolve); });
    }).on('error', (err: Error) => {
      file.close();
      try { fs.unlinkSync(destPath); } catch { /* ignore */ }
      reject(err);
    });
  });
}

export async function installInquiryCli(deps?: Partial<InstallerDeps>): Promise<void> {
  const platform = deps?.platform ?? process.platform;
  const spawn = deps?.spawn ?? ((cmd: string, args: string[]) => {
    const cp = require('child_process');
    return cp.spawn(cmd, args);
  });
  const downloadFile = deps?.downloadFile ?? defaultDownloadFile;
  const tmpdir = deps?.tmpdir ?? (() => os.tmpdir());
  const withProgress = deps?.withProgress ?? (() => {
    const vscode = require('vscode');
    return vscode.window.withProgress.bind(vscode.window);
  })();

  const { url, filename } = getInstallScriptUrl(platform);
  const scriptPath = path.join(tmpdir(), filename);

  await withProgress(
    { location: 15, title: 'Installing Inquiry CLI...', cancellable: true },
    async (progress: { report(value: { message?: string }): void }, token: CancellationTokenLike) => {
      progress.report({ message: 'Downloading installer...' });
      await downloadFile(url, scriptPath);

      progress.report({ message: 'Running installer...' });
      const { shell, args } = getRunCommand(platform, scriptPath);

      return new Promise<void>((resolve, reject) => {
        const proc = spawn(shell, args);

        token.onCancellationRequested(() => {
          proc.kill();
          reject(new Error('Installation cancelled'));
        });

        proc.stdout.on('data', (data: Buffer | string) => {
          const lines = data.toString().split('\n');
          for (const line of lines) {
            const trimmed = line.trim();
            if (trimmed.startsWith('>>>')) {
              const message = trimmed.slice(3).trim();
              progress.report({ message });
            }
          }
        });

        proc.on('close', (code: number) => {
          if (code === 0) {
            resolve();
          } else {
            reject(new Error(`Install failed (exit ${code})`));
          }
        });
      });
    },
  );
}
