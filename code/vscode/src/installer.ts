import { EventEmitter } from 'events';

export function getInstallCommand(platform: string): { shell: string; args: string[] } {
  if (platform === 'win32') {
    return {
      shell: 'powershell',
      args: ['-NoProfile', '-Command', 'irm https://www.ccisne.dev/finite_ape_machine/install.ps1 | iex'],
    };
  }
  if (platform === 'linux') {
    return {
      shell: 'bash',
      args: ['-c', 'curl -fsSL https://www.ccisne.dev/finite_ape_machine/install.sh | bash'],
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
  withProgress(
    options: { location: number; title: string; cancellable: boolean },
    task: (progress: { report(value: { message?: string }): void }, token: CancellationTokenLike) => Promise<void>,
  ): Promise<void>;
}

export async function installApeCli(deps?: Partial<InstallerDeps>): Promise<void> {
  const platform = deps?.platform ?? process.platform;
  const spawn = deps?.spawn ?? ((cmd: string, args: string[]) => {
    const cp = require('child_process');
    return cp.spawn(cmd, args);
  });
  const withProgress = deps?.withProgress ?? (() => {
    const vscode = require('vscode');
    return vscode.window.withProgress.bind(vscode.window);
  })();

  const { shell, args } = getInstallCommand(platform);

  await withProgress(
    { location: 15, title: 'Installing APE CLI...', cancellable: true },
    (progress: { report(value: { message?: string }): void }, token: CancellationTokenLike) => {
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
