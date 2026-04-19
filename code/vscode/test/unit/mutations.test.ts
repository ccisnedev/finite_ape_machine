import * as assert from 'assert';
import { formatMutation } from '../../src/parsers';

describe('formatMutation', () => {
  it('con texto retorna "- <texto>\\n"', () => {
    const result = formatMutation('Phase transition IDLE → ANALYZE', false);
    assert.strictEqual(result, '- Phase transition IDLE → ANALYZE\n');
  });

  it('con texto y timestamp retorna "- [YYYY-MM-DD HH:mm] <texto>\\n"', () => {
    const result = formatMutation('Phase transition', true);
    assert.match(result, /^- \[\d{4}-\d{2}-\d{2} \d{2}:\d{2}\] Phase transition\n$/);
  });

  it('escapa caracteres que romperían el markdown (|, newlines)', () => {
    const result = formatMutation('col1|col2\nline2', false);
    assert.ok(!result.includes('|') || result.includes('\\|'), 'pipe should be escaped');
    assert.ok(!result.includes('\n\n'), 'should not contain double newlines mid-entry');
    assert.ok(result.startsWith('- '));
    assert.ok(result.endsWith('\n'));
  });
});
