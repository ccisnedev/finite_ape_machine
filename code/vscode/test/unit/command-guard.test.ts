import * as assert from 'assert';
import { withGuard, GuardDeps } from '../../src/command-guard';

describe('withGuard', () => {
  it('executes fn when CLI installed and .ape/ exists', async () => {
    let called = false;
    const deps: GuardDeps = {
      isApeInstalled: () => true,
      isApeWorkspace: () => true,
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
      isApeInstalled: () => false,
      isApeWorkspace: () => true,
      showMessage: (msg) => { message = msg; return Promise.resolve(undefined); },
      executeCommand: () => Promise.resolve(undefined),
    };

    await withGuard('/workspace', {}, async () => { called = true; }, deps);
    assert.strictEqual(called, false);
    assert.match(message, /APE CLI not found/);
  });

  it('shows workspace notification when .ape/ missing', async () => {
    let called = false;
    let message = '';
    const deps: GuardDeps = {
      isApeInstalled: () => true,
      isApeWorkspace: () => false,
      showMessage: (msg) => { message = msg; return Promise.resolve(undefined); },
      executeCommand: () => Promise.resolve(undefined),
    };

    await withGuard('/workspace', {}, async () => { called = true; }, deps);
    assert.strictEqual(called, false);
    assert.match(message, /No APE workspace/);
  });

  it('skips workspace check when skipWorkspaceCheck is true', async () => {
    let called = false;
    const deps: GuardDeps = {
      isApeInstalled: () => true,
      isApeWorkspace: () => false,
      showMessage: () => Promise.resolve(undefined),
      executeCommand: () => Promise.resolve(undefined),
    };

    await withGuard('/workspace', { skipWorkspaceCheck: true }, async () => { called = true; }, deps);
    assert.strictEqual(called, true);
  });

  it('calls ape.init when user clicks Install', async () => {
    let executedCommand = '';
    const deps: GuardDeps = {
      isApeInstalled: () => false,
      isApeWorkspace: () => true,
      showMessage: () => Promise.resolve('Install'),
      executeCommand: (cmd) => { executedCommand = cmd; return Promise.resolve(undefined); },
    };

    await withGuard('/workspace', {}, async () => {}, deps);
    assert.strictEqual(executedCommand, 'ape.init');
  });

  it('calls ape.init when user clicks Init for workspace', async () => {
    let executedCommand = '';
    const deps: GuardDeps = {
      isApeInstalled: () => true,
      isApeWorkspace: () => false,
      showMessage: () => Promise.resolve('Init'),
      executeCommand: (cmd) => { executedCommand = cmd; return Promise.resolve(undefined); },
    };

    await withGuard('/workspace', {}, async () => {}, deps);
    assert.strictEqual(executedCommand, 'ape.init');
  });
});
