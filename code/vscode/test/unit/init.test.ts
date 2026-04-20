import * as assert from 'assert';
import { apeInit, InitDeps } from '../../src/init';

describe('apeInit', () => {
  it('shows error when no workspace folder', async () => {
    let errorMsg = '';
    const deps: InitDeps = {
      isApeInstalled: () => true,
      getApeBinaryPath: () => '/usr/bin/ape',
      showErrorMessage: (msg) => { errorMsg = msg; return Promise.resolve(undefined); },
      showInformationMessage: () => Promise.resolve(undefined),
      createTerminal: () => ({ show: () => {}, sendText: () => {} }),
    };

    await apeInit(undefined, deps);
    assert.strictEqual(errorMsg, 'APE: Open a workspace folder first.');
  });

  it('runs ape init in terminal when CLI exists', async () => {
    let terminalName = '';
    let sentText = '';
    const deps: InitDeps = {
      isApeInstalled: () => true,
      getApeBinaryPath: () => '/home/user/.ape/bin/ape',
      showErrorMessage: () => Promise.resolve(undefined),
      showInformationMessage: () => Promise.resolve(undefined),
      createTerminal: (name) => {
        terminalName = name;
        return {
          show: () => {},
          sendText: (text) => { sentText = text; },
        };
      },
    };

    await apeInit('/workspace', deps);
    assert.strictEqual(terminalName, 'APE Init');
    assert.strictEqual(sentText, '"/home/user/.ape/bin/ape" init');
  });

  it('delegates to install flow when CLI missing', async () => {
    let installCalled = false;
    const deps: InitDeps = {
      isApeInstalled: () => false,
      getApeBinaryPath: () => '/usr/bin/ape',
      showErrorMessage: () => Promise.resolve(undefined),
      showInformationMessage: () => Promise.resolve(undefined),
      createTerminal: () => ({ show: () => {}, sendText: () => {} }),
    };

    await apeInit('/workspace', deps, async () => { installCalled = true; });
    assert.strictEqual(installCalled, true);
  });

  it('shows info message when CLI missing and no install callback', async () => {
    let infoMsg = '';
    const deps: InitDeps = {
      isApeInstalled: () => false,
      getApeBinaryPath: () => '/usr/bin/ape',
      showErrorMessage: () => Promise.resolve(undefined),
      showInformationMessage: (msg) => { infoMsg = msg; return Promise.resolve(undefined); },
      createTerminal: () => ({ show: () => {}, sendText: () => {} }),
    };

    await apeInit('/workspace', deps);
    assert.strictEqual(infoMsg, 'APE CLI not found. Install it manually or wait for a future update.');
  });
});
