import * as assert from 'assert';
import * as path from 'path';
import { getAssetName, getInstallDir, installInquiryCli, InstallerDeps } from '../../src/installer';

describe('getAssetName', () => {
  it('returns zip on win32', () => {
    assert.strictEqual(getAssetName('win32'), 'inquiry-windows-x64.zip');
  });

  it('returns tar.gz on linux', () => {
    assert.strictEqual(getAssetName('linux'), 'inquiry-linux-x64.tar.gz');
  });

  it('throws on unsupported platform', () => {
    assert.throws(() => getAssetName('darwin'), /Unsupported platform: darwin/);
  });
});

describe('getInstallDir', () => {
  it('returns LOCALAPPDATA path on win32', () => {
    const dir = getInstallDir('win32');
    assert.ok(dir.includes('inquiry'));
  });

  it('returns home/.inquiry on linux', () => {
    const dir = getInstallDir('linux');
    assert.ok(dir.endsWith('.inquiry'));
  });

  it('throws on unsupported platform', () => {
    assert.throws(() => getInstallDir('darwin'), /Unsupported platform: darwin/);
  });
});

describe('installInquiryCli', () => {
  const tick = () => new Promise(r => setTimeout(r, 0));

  function baseDeps(platform: string): InstallerDeps {
    return {
      platform,
      tmpdir: () => (platform === 'win32' ? 'C:\\temp' : '/tmp'),
      fetchJson: async () => ({
        tag_name: 'v1.0.0',
        assets: [
          { name: 'inquiry-windows-x64.zip', browser_download_url: 'https://github.com/dl/win.zip' },
          { name: 'inquiry-linux-x64.tar.gz', browser_download_url: 'https://github.com/dl/linux.tar.gz' },
        ],
      }),
      downloadFile: async () => {},
      extractZip: async () => {},
      extractTarGz: async () => {},
      execFile: async () => 'v1.0.0',
      mkdirp: async () => {},
      rmrf: async () => {},
      writeFile: async () => {},
      chmod: async () => {},
      symlink: async () => {},
      getEnvPath: () => '',
      setEnvPath: () => {},
      withProgress: async (_opts, task) => {
        const progress = { report: () => {} };
        const token = { onCancellationRequested: () => {} };
        await task(progress, token);
      },
    };
  }

  it('fetches release, downloads zip, and extracts on win32', async () => {
    let downloadedUrl = '';
    let extractedPath = '';
    let wroteIqCmd = false;
    const reports: string[] = [];

    const deps: InstallerDeps = {
      ...baseDeps('win32'),
      downloadFile: async (url) => { downloadedUrl = url; },
      extractZip: async (p) => { extractedPath = p; },
      writeFile: async (f) => { if (f.endsWith('iq.cmd')) { wroteIqCmd = true; } },
      withProgress: async (_opts, task) => {
        const progress = { report: (v: { message?: string }) => { if (v.message) { reports.push(v.message); } } };
        const token = { onCancellationRequested: () => {} };
        await task(progress, token);
      },
    };

    await installInquiryCli(deps);
    assert.strictEqual(downloadedUrl, 'https://github.com/dl/win.zip');
    assert.ok(extractedPath.endsWith('.zip'));
    assert.ok(wroteIqCmd, 'should create iq.cmd');
    assert.ok(reports.includes('Fetching latest release...'));
    assert.ok(reports.some(r => r.startsWith('Downloading')));
    assert.ok(reports.includes('Extracting...'));
  });

  it('fetches release, downloads tar.gz, and extracts on linux', async () => {
    let downloadedUrl = '';
    let extractedTar = false;
    let chmodCalled = false;
    let symlinkTargets: string[] = [];

    const deps: InstallerDeps = {
      ...baseDeps('linux'),
      downloadFile: async (url) => { downloadedUrl = url; },
      extractTarGz: async () => { extractedTar = true; },
      chmod: async () => { chmodCalled = true; },
      symlink: async (_t, l) => { symlinkTargets.push(l); },
    };

    await installInquiryCli(deps);
    assert.strictEqual(downloadedUrl, 'https://github.com/dl/linux.tar.gz');
    assert.ok(extractedTar);
    assert.ok(chmodCalled);
    assert.ok(symlinkTargets.some(l => l.includes('inquiry')));
    assert.ok(symlinkTargets.some(l => l.includes('iq')));
  });

  it('throws when asset not found in release', async () => {
    const deps: InstallerDeps = {
      ...baseDeps('win32'),
      fetchJson: async () => ({ tag_name: 'v1.0.0', assets: [] }),
    };

    await assert.rejects(() => installInquiryCli(deps), /No inquiry-windows-x64.zip asset found/);
  });

  it('rejects on download failure', async () => {
    const deps: InstallerDeps = {
      ...baseDeps('win32'),
      downloadFile: async () => { throw new Error('Network error'); },
    };

    await assert.rejects(() => installInquiryCli(deps), /Network error/);
  });

  it('rejects on cancellation', async () => {
    let cancelFn: (() => void) | undefined;
    const deps: InstallerDeps = {
      ...baseDeps('win32'),
      fetchJson: async () => {
        cancelFn!();
        return { tag_name: 'v1.0.0', assets: [{ name: 'inquiry-windows-x64.zip', browser_download_url: 'x' }] };
      },
      withProgress: async (_opts, task) => {
        const progress = { report: () => {} };
        const token = { onCancellationRequested: (fn: () => void) => { cancelFn = fn; } };
        await task(progress, token);
      },
    };

    await assert.rejects(() => installInquiryCli(deps), /Installation cancelled/);
  });

  it('adds bin dir to process PATH', async () => {
    let newPath = '';
    const deps: InstallerDeps = {
      ...baseDeps('win32'),
      getEnvPath: () => 'C:\\existing',
      setEnvPath: (p) => { newPath = p; },
    };

    await installInquiryCli(deps);
    assert.ok(newPath.includes('inquiry'));
    assert.ok(newPath.includes('C:\\existing'));
  });

  it('runs target get and version after install', async () => {
    const commands: string[][] = [];
    const deps: InstallerDeps = {
      ...baseDeps('win32'),
      execFile: async (_cmd, args) => { commands.push(args); return 'v1.0.0'; },
    };

    await installInquiryCli(deps);
    assert.ok(commands.some(c => c.includes('target') && c.includes('get')));
    assert.ok(commands.some(c => c.includes('version')));
  });
});
