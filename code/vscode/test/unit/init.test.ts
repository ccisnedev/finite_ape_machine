import * as assert from 'assert';
import { inquiryInit, InitDeps } from '../../src/init';

describe('inquiryInit', () => {
  it('shows error when no workspace folder', async () => {
    let errorMsg = '';
    const deps: InitDeps = {
      isInquiryInstalled: () => true,
      getInquiryBinaryPath: () => '/usr/bin/inquiry',
      showErrorMessage: (msg) => { errorMsg = msg; return Promise.resolve(undefined); },
      showInformationMessage: () => Promise.resolve(undefined),
      createTerminal: () => ({ show: () => {}, sendText: () => {} }),
    };

    await inquiryInit(undefined, deps);
    assert.strictEqual(errorMsg, 'Inquiry: Open a workspace folder first.');
  });

  it('runs inquiry init in terminal when CLI exists', async () => {
    let terminalName = '';
    let sentText = '';
    const deps: InitDeps = {
      isInquiryInstalled: () => true,
      getInquiryBinaryPath: () => '/home/user/.inquiry/bin/inquiry',
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

    await inquiryInit('/workspace', deps);
    assert.strictEqual(terminalName, 'Inquiry Init');
    assert.strictEqual(sentText, '"/home/user/.inquiry/bin/inquiry" init');
  });

  it('delegates to install flow when CLI missing', async () => {
    let installCalled = false;
    const deps: InitDeps = {
      isInquiryInstalled: () => false,
      getInquiryBinaryPath: () => '/usr/bin/inquiry',
      showErrorMessage: () => Promise.resolve(undefined),
      showInformationMessage: () => Promise.resolve(undefined),
      createTerminal: () => ({ show: () => {}, sendText: () => {} }),
    };

    await inquiryInit('/workspace', deps, async () => { installCalled = true; });
    assert.strictEqual(installCalled, true);
  });

  it('shows info message when CLI missing and no install callback', async () => {
    let infoMsg = '';
    const deps: InitDeps = {
      isInquiryInstalled: () => false,
      getInquiryBinaryPath: () => '/usr/bin/inquiry',
      showErrorMessage: () => Promise.resolve(undefined),
      showInformationMessage: (msg) => { infoMsg = msg; return Promise.resolve(undefined); },
      createTerminal: () => ({ show: () => {}, sendText: () => {} }),
    };

    await inquiryInit('/workspace', deps);
    assert.strictEqual(infoMsg, 'Inquiry CLI not found. Install it manually or wait for a future update.');
  });
});
