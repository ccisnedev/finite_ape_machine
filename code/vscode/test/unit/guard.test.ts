import * as assert from 'assert';
import * as path from 'path';
import { getInquiryBinaryPath, isInquiryInstalled, isInquiryWorkspace, getPlatform } from '../../src/guard';

describe('getInquiryBinaryPath', () => {
  it('returns LOCALAPPDATA path on win32', () => {
    const result = getInquiryBinaryPath('win32');
    const expected = path.join(process.env.LOCALAPPDATA!, 'inquiry', 'bin', 'inquiry.exe');
    assert.strictEqual(result, expected);
  });

  it('returns HOME path on linux', () => {
    const result = getInquiryBinaryPath('linux');
    const expected = path.join(process.env.HOME!, '.inquiry', 'bin', 'inquiry');
    assert.strictEqual(result, expected);
  });

  it('throws on unsupported platform', () => {
    assert.throws(() => getInquiryBinaryPath('darwin'), /Unsupported platform: darwin/);
  });
});

describe('isInquiryInstalled', () => {
  it('returns true when binary exists', () => {
    assert.strictEqual(isInquiryInstalled('win32', () => true), true);
  });

  it('returns false when binary missing', () => {
    assert.strictEqual(isInquiryInstalled('linux', () => false), false);
  });
});

describe('isInquiryWorkspace', () => {
  it('returns true when .inquiry/ exists', () => {
    const stub = (p: any) => p === path.join('/workspace', '.inquiry');
    assert.strictEqual(isInquiryWorkspace('/workspace', stub), true);
  });

  it('returns false when .inquiry/ missing', () => {
    assert.strictEqual(isInquiryWorkspace('/workspace', () => false), false);
  });
});

describe('getPlatform', () => {
  it('returns process.platform', () => {
    assert.strictEqual(getPlatform(), process.platform);
  });
});
