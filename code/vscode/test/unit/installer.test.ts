import * as assert from 'assert';
import { EventEmitter } from 'events';
import { getInstallScriptUrl, getRunCommand, installInquiryCli, InstallerDeps } from '../../src/installer';

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

describe('getInstallScriptUrl', () => {
  it('returns ps1 URL on win32', () => {
    const result = getInstallScriptUrl('win32');
    assert.strictEqual(result.url, 'https://www.si14bm.com/inquiry/install.ps1');
    assert.strictEqual(result.filename, 'inquiry-install.ps1');
  });

  it('returns sh URL on linux', () => {
    const result = getInstallScriptUrl('linux');
    assert.strictEqual(result.url, 'https://www.si14bm.com/inquiry/install.sh');
    assert.strictEqual(result.filename, 'inquiry-install.sh');
  });

  it('throws on unsupported platform', () => {
    assert.throws(() => getInstallScriptUrl('darwin'), /Unsupported platform: darwin/);
  });
});

describe('getRunCommand', () => {
  it('returns powershell -File on win32', () => {
    const cmd = getRunCommand('win32', 'C:\\temp\\inquiry-install.ps1');
    assert.strictEqual(cmd.shell, 'powershell');
    assert.deepStrictEqual(cmd.args, [
      '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', 'C:\\temp\\inquiry-install.ps1',
    ]);
  });

  it('returns bash on linux', () => {
    const cmd = getRunCommand('linux', '/tmp/inquiry-install.sh');
    assert.strictEqual(cmd.shell, 'bash');
    assert.deepStrictEqual(cmd.args, ['/tmp/inquiry-install.sh']);
  });

  it('throws on unsupported platform', () => {
    assert.throws(() => getRunCommand('darwin', '/tmp/x'), /Unsupported platform: darwin/);
  });
});

describe('installInquiryCli', () => {
  const tick = () => new Promise(r => setTimeout(r, 0));

  it('downloads then spawns powershell -File on win32', async () => {
    const mockProc = createMockProcess();
    let spawnedCmd = '';
    let spawnedArgs: string[] = [];
    let downloadedUrl = '';
    let downloadedDest = '';

    const deps: InstallerDeps = {
      platform: 'win32',
      tmpdir: () => 'C:\\temp',
      downloadFile: async (url, dest) => { downloadedUrl = url; downloadedDest = dest; },
      spawn: (cmd, args) => { spawnedCmd = cmd; spawnedArgs = args; return mockProc; },
      withProgress: async (_opts, task) => {
        const reports: { message?: string }[] = [];
        const progress = { report: (v: { message?: string }) => { reports.push(v); } };
        const token = { onCancellationRequested: () => {} };
        const promise = task(progress, token);
        await tick();
        mockProc.stdout.emit('data', '>>> Installing...\n');
        mockProc.emit_close(0);
        await promise;
        assert.ok(reports.some(r => r.message === 'Downloading installer...'));
        assert.ok(reports.some(r => r.message === 'Running installer...'));
        assert.ok(reports.some(r => r.message === 'Installing...'));
      },
    };

    await installInquiryCli(deps);
    assert.strictEqual(downloadedUrl, 'https://www.si14bm.com/inquiry/install.ps1');
    assert.strictEqual(downloadedDest, 'C:\\temp\\inquiry-install.ps1');
    assert.strictEqual(spawnedCmd, 'powershell');
    assert.deepStrictEqual(spawnedArgs, [
      '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', 'C:\\temp\\inquiry-install.ps1',
    ]);
  });

  it('downloads then spawns bash on linux', async () => {
    const mockProc = createMockProcess();
    let spawnedCmd = '';
    let downloadedUrl = '';

    const deps: InstallerDeps = {
      platform: 'linux',
      tmpdir: () => '/tmp',
      downloadFile: async (url) => { downloadedUrl = url; },
      spawn: (cmd) => { spawnedCmd = cmd; return mockProc; },
      withProgress: async (_opts, task) => {
        const progress = { report: () => {} };
        const token = { onCancellationRequested: () => {} };
        const promise = task(progress, token);
        await tick();
        mockProc.emit_close(0);
        await promise;
      },
    };

    await installInquiryCli(deps);
    assert.strictEqual(downloadedUrl, 'https://www.si14bm.com/inquiry/install.sh');
    assert.strictEqual(spawnedCmd, 'bash');
  });

  it('rejects on non-zero exit code', async () => {
    const mockProc = createMockProcess();

    const deps: InstallerDeps = {
      platform: 'win32',
      tmpdir: () => 'C:\\temp',
      downloadFile: async () => {},
      spawn: () => mockProc,
      withProgress: async (_opts, task) => {
        const progress = { report: () => {} };
        const token = { onCancellationRequested: () => {} };
        const promise = task(progress, token);
        await tick();
        mockProc.emit_close(1);
        return promise;
      },
    };

    await assert.rejects(() => installInquiryCli(deps), /Install failed \(exit 1\)/);
  });

  it('rejects on download failure', async () => {
    const deps: InstallerDeps = {
      platform: 'win32',
      tmpdir: () => 'C:\\temp',
      downloadFile: async () => { throw new Error('Network error'); },
      spawn: () => { throw new Error('should not spawn'); },
      withProgress: async (_opts, task) => {
        const progress = { report: () => {} };
        const token = { onCancellationRequested: () => {} };
        return task(progress, token);
      },
    };

    await assert.rejects(() => installInquiryCli(deps), /Network error/);
  });

  it('kills process on cancellation', async () => {
    const mockProc = createMockProcess();

    const deps: InstallerDeps = {
      platform: 'win32',
      tmpdir: () => 'C:\\temp',
      downloadFile: async () => {},
      spawn: () => mockProc,
      withProgress: async (_opts, task) => {
        const progress = { report: () => {} };
        let cancelFn: (() => void) | undefined;
        const token = { onCancellationRequested: (listener: () => void) => { cancelFn = listener; } };
        const promise = task(progress, token);
        await tick();
        cancelFn!();
        try { await promise; } catch { /* expected */ }
      },
    };

    try {
      await installInquiryCli(deps);
    } catch {
      // expected rejection from cancellation
    }
    assert.strictEqual(mockProc._killed, true);
  });

  it('reports multiple progress milestones from stdout', async () => {
    const mockProc = createMockProcess();
    const reports: { message?: string }[] = [];

    const deps: InstallerDeps = {
      platform: 'linux',
      tmpdir: () => '/tmp',
      downloadFile: async () => {},
      spawn: () => mockProc,
      withProgress: async (_opts, task) => {
        const progress = { report: (v: { message?: string }) => { reports.push(v); } };
        const token = { onCancellationRequested: () => {} };
        const promise = task(progress, token);
        await tick();
        mockProc.stdout.emit('data', '>>> Fetching...\n>>> Downloading...\n>>> Extracting...\n');
        mockProc.emit_close(0);
        await promise;
      },
    };

    await installInquiryCli(deps);
    // 2 built-in reports (Downloading installer..., Running installer...) + 3 from stdout
    assert.ok(reports.some(r => r.message === 'Fetching...'));
    assert.ok(reports.some(r => r.message === 'Downloading...'));
    assert.ok(reports.some(r => r.message === 'Extracting...'));
  });
});
