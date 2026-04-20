import * as assert from 'assert';
import { EventEmitter } from 'events';
import { getInstallCommand, installApeCli, InstallerDeps } from '../../src/installer';

function createMockProcess() {
  const proc = {
    stdout: new EventEmitter(),
    stderr: new EventEmitter(),
    on: (event: string, listener: (...args: any[]) => void) => {
      (proc as any)._events = (proc as any)._events || {};
      (proc as any)._events[event] = listener;
    },
    kill: () => { (proc as any)._killed = true; },
    _killed: false,
    _events: {} as Record<string, (...args: any[]) => void>,
    emit_close: (code: number) => { (proc as any)._events['close'](code); },
  };
  return proc;
}

function createMockWithProgress() {
  return async <T>(
    _options: { location: number; title: string; cancellable: boolean },
    task: (progress: { report(value: { message?: string }): void }, token: { onCancellationRequested(listener: () => void): void }) => Promise<T>,
  ): Promise<T> => {
    const reports: { message?: string }[] = [];
    const progress = { report: (value: { message?: string }) => { reports.push(value); } };
    let cancelListener: (() => void) | undefined;
    const token = { onCancellationRequested: (listener: () => void) => { cancelListener = listener; } };
    const result = task(progress, token);
    (createMockWithProgress as any)._reports = reports;
    (createMockWithProgress as any)._cancelListener = cancelListener;
    return result;
  };
}

describe('getInstallCommand', () => {
  it('returns powershell command on win32', () => {
    const cmd = getInstallCommand('win32');
    assert.strictEqual(cmd.shell, 'powershell');
    assert.deepStrictEqual(cmd.args, [
      '-NoProfile', '-Command',
      'irm https://www.ccisne.dev/finite_ape_machine/install.ps1 | iex',
    ]);
  });

  it('returns bash command on linux', () => {
    const cmd = getInstallCommand('linux');
    assert.strictEqual(cmd.shell, 'bash');
    assert.deepStrictEqual(cmd.args, [
      '-c', 'curl -fsSL https://www.ccisne.dev/finite_ape_machine/install.sh | bash',
    ]);
  });

  it('throws on unsupported platform', () => {
    assert.throws(() => getInstallCommand('darwin'), /Unsupported platform: darwin/);
  });
});

describe('installApeCli', () => {
  it('spawns powershell on win32', async () => {
    const mockProc = createMockProcess();
    let spawnedCmd = '';
    let spawnedArgs: string[] = [];

    const deps: InstallerDeps = {
      platform: 'win32',
      spawn: (cmd, args) => { spawnedCmd = cmd; spawnedArgs = args; return mockProc; },
      withProgress: async (_opts, task) => {
        const reports: { message?: string }[] = [];
        const progress = { report: (v: { message?: string }) => { reports.push(v); } };
        const token = { onCancellationRequested: () => {} };
        const promise = task(progress, token);
        mockProc.stdout.emit('data', '>>> Downloading...\n');
        mockProc.emit_close(0);
        await promise;
        assert.strictEqual(reports.length, 1);
        assert.strictEqual(reports[0].message, 'Downloading...');
      },
    };

    await installApeCli(deps);
    assert.strictEqual(spawnedCmd, 'powershell');
    assert.deepStrictEqual(spawnedArgs, [
      '-NoProfile', '-Command',
      'irm https://www.ccisne.dev/finite_ape_machine/install.ps1 | iex',
    ]);
  });

  it('spawns bash on linux', async () => {
    const mockProc = createMockProcess();
    let spawnedCmd = '';

    const deps: InstallerDeps = {
      platform: 'linux',
      spawn: (cmd, args) => { spawnedCmd = cmd; return mockProc; },
      withProgress: async (_opts, task) => {
        const progress = { report: () => {} };
        const token = { onCancellationRequested: () => {} };
        const promise = task(progress, token);
        mockProc.emit_close(0);
        await promise;
      },
    };

    await installApeCli(deps);
    assert.strictEqual(spawnedCmd, 'bash');
  });

  it('rejects on non-zero exit code', async () => {
    const mockProc = createMockProcess();

    const deps: InstallerDeps = {
      platform: 'win32',
      spawn: () => mockProc,
      withProgress: async (_opts, task) => {
        const progress = { report: () => {} };
        const token = { onCancellationRequested: () => {} };
        const promise = task(progress, token);
        mockProc.emit_close(1);
        return promise;
      },
    };

    await assert.rejects(() => installApeCli(deps), /Install failed \(exit 1\)/);
  });

  it('kills process on cancellation', async () => {
    const mockProc = createMockProcess();

    const deps: InstallerDeps = {
      platform: 'win32',
      spawn: () => mockProc,
      withProgress: async (_opts, task) => {
        const progress = { report: () => {} };
        let cancelFn: (() => void) | undefined;
        const token = { onCancellationRequested: (listener: () => void) => { cancelFn = listener; } };
        const promise = task(progress, token);
        cancelFn!();
        try { await promise; } catch { /* expected */ }
      },
    };

    try {
      await installApeCli(deps);
    } catch {
      // expected rejection from cancellation
    }
    assert.strictEqual(mockProc._killed, true);
  });

  it('reports multiple progress milestones', async () => {
    const mockProc = createMockProcess();
    const reports: { message?: string }[] = [];

    const deps: InstallerDeps = {
      platform: 'linux',
      spawn: () => mockProc,
      withProgress: async (_opts, task) => {
        const progress = { report: (v: { message?: string }) => { reports.push(v); } };
        const token = { onCancellationRequested: () => {} };
        const promise = task(progress, token);
        mockProc.stdout.emit('data', '>>> Fetching...\n>>> Downloading...\n>>> Extracting...\n');
        mockProc.emit_close(0);
        await promise;
      },
    };

    await installApeCli(deps);
    assert.strictEqual(reports.length, 3);
    assert.strictEqual(reports[0].message, 'Fetching...');
    assert.strictEqual(reports[1].message, 'Downloading...');
    assert.strictEqual(reports[2].message, 'Extracting...');
  });
});
