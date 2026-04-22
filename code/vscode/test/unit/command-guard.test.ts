import * as assert from 'assert';
import { withGuard, GuardDeps } from '../../src/command-guard';

describe('withGuard', () => {
  it('executes fn when CLI installed and .inquiry/ exists', async () => {
    let called = false;
    const deps: GuardDeps = {
      isInquiryInstalled: () => true,
      isInquiryWorkspace: () => true,
      showMessage: () => Promise.resolve(undefined),
      executeCommand: () => Promise.resolve(undefined),
    };

    await withGuard('/workspace', {}, async () => { called = true; }, deps);
    assert.strictEqual(called, true);
  });

  it('shows CLI notification when not installed', async () => {
    let called = false;
    let message = '';
    const deps: GuardDeps = {
      isInquiryInstalled: () => false,
      isInquiryWorkspace: () => true,
      showMessage: (msg) => { message = msg; return Promise.resolve(undefined); },
      executeCommand: () => Promise.resolve(undefined),
    };

    await withGuard('/workspace', {}, async () => { called = true; }, deps);
    assert.strictEqual(called, false);
    assert.match(message, /Inquiry CLI not found/);
  });

  it('shows workspace notification when .inquiry/ missing', async () => {
    let called = false;
    let message = '';
    const deps: GuardDeps = {
      isInquiryInstalled: () => true,
      isInquiryWorkspace: () => false,
      showMessage: (msg) => { message = msg; return Promise.resolve(undefined); },
      executeCommand: () => Promise.resolve(undefined),
    };

    await withGuard('/workspace', {}, async () => { called = true; }, deps);
    assert.strictEqual(called, false);
    assert.match(message, /No Inquiry workspace/);
  });

  it('skips workspace check when skipWorkspaceCheck is true', async () => {
    let called = false;
    const deps: GuardDeps = {
      isInquiryInstalled: () => true,
      isInquiryWorkspace: () => false,
      showMessage: () => Promise.resolve(undefined),
      executeCommand: () => Promise.resolve(undefined),
    };

    await withGuard('/workspace', { skipWorkspaceCheck: true }, async () => { called = true; }, deps);
    assert.strictEqual(called, true);
  });

  it('calls inquiry.init when user clicks Install', async () => {
    let executedCommand = '';
    const deps: GuardDeps = {
      isInquiryInstalled: () => false,
      isInquiryWorkspace: () => true,
      showMessage: () => Promise.resolve('Install'),
      executeCommand: (cmd) => { executedCommand = cmd; return Promise.resolve(undefined); },
    };

    await withGuard('/workspace', {}, async () => {}, deps);
    assert.strictEqual(executedCommand, 'inquiry.init');
  });

  it('calls inquiry.init when user clicks Init for workspace', async () => {
    let executedCommand = '';
    const deps: GuardDeps = {
      isInquiryInstalled: () => true,
      isInquiryWorkspace: () => false,
      showMessage: () => Promise.resolve('Init'),
      executeCommand: (cmd) => { executedCommand = cmd; return Promise.resolve(undefined); },
    };

    await withGuard('/workspace', {}, async () => {}, deps);
    assert.strictEqual(executedCommand, 'inquiry.init');
  });
});
