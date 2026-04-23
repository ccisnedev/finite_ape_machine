import { strict as assert } from 'assert';

// extension.ts imports 'vscode' at module level — these tests
// can only run inside the VS Code test runner (@vscode/test-electron).
describe('extension exports', () => {
  it('activate is a function', () => {
    // eslint-disable-next-line @typescript-eslint/no-require-imports
    const { activate } = require('../../src/extension');
    assert.strictEqual(typeof activate, 'function');
  });

  it('deactivate is a function', () => {
    // eslint-disable-next-line @typescript-eslint/no-require-imports
    const { deactivate } = require('../../src/extension');
    assert.strictEqual(typeof deactivate, 'function');
  });
});
