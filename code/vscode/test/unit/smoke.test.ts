import * as assert from 'assert';
import * as extension from '../../src/extension';

describe('extension module', () => {
  it('exports activate and deactivate', () => {
    assert.strictEqual(typeof extension.activate, 'function');
    assert.strictEqual(typeof extension.deactivate, 'function');
  });
});
