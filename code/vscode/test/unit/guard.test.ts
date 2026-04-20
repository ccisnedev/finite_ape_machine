import * as assert from 'assert';
import * as path from 'path';
import { getApeBinaryPath, isApeInstalled, isApeWorkspace, getPlatform } from '../../src/guard';

describe('getApeBinaryPath', () => {
  it('returns LOCALAPPDATA path on win32', () => {
    const result = getApeBinaryPath('win32');
    const expected = path.join(process.env.LOCALAPPDATA!, 'ape', 'bin', 'ape.exe');
    assert.strictEqual(result, expected);
  });

  it('returns HOME path on linux', () => {
    const result = getApeBinaryPath('linux');
    const expected = path.join(process.env.HOME!, '.ape', 'bin', 'ape');
    assert.strictEqual(result, expected);
  });

  it('throws on unsupported platform', () => {
    assert.throws(() => getApeBinaryPath('darwin'), /Unsupported platform: darwin/);
  });
});

describe('isApeInstalled', () => {
  it('returns true when binary exists', () => {
    assert.strictEqual(isApeInstalled('win32', () => true), true);
  });

  it('returns false when binary missing', () => {
    assert.strictEqual(isApeInstalled('linux', () => false), false);
  });
});

describe('isApeWorkspace', () => {
  it('returns true when .ape/ exists', () => {
    const stub = (p: any) => p === path.join('/workspace', '.ape');
    assert.strictEqual(isApeWorkspace('/workspace', stub), true);
  });

  it('returns false when .ape/ missing', () => {
    assert.strictEqual(isApeWorkspace('/workspace', () => false), false);
  });
});

describe('getPlatform', () => {
  it('returns process.platform', () => {
    assert.strictEqual(getPlatform(), process.platform);
  });
});
