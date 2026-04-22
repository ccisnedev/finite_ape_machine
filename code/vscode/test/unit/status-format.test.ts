import { strict as assert } from 'node:assert';
import { describe, it } from 'mocha';
import { formatStatus } from '../../src/status-bar';

describe('formatStatus', () => {
  it('IDLE with no task', () => {
    const result = formatStatus('IDLE', '');
    assert.deepStrictEqual(result, {
      text: '$(circle-outline) Inquiry: IDLE',
      tooltip: 'Inquiry: IDLE',
    });
  });

  it('ANALYZE with task', () => {
    const result = formatStatus('ANALYZE', '042');
    assert.deepStrictEqual(result, {
      text: '$(search) Inquiry: ANALYZE #042',
      tooltip: 'Inquiry: ANALYZE — Task #042',
    });
  });

  it('PLAN with task', () => {
    const result = formatStatus('PLAN', '042');
    assert.deepStrictEqual(result, {
      text: '$(list-ordered) Inquiry: PLAN #042',
      tooltip: 'Inquiry: PLAN — Task #042',
    });
  });

  it('EXECUTE with task', () => {
    const result = formatStatus('EXECUTE', '042');
    assert.deepStrictEqual(result, {
      text: '$(rocket) Inquiry: EXECUTE #042',
      tooltip: 'Inquiry: EXECUTE — Task #042',
    });
  });

  it('EVOLUTION with no task', () => {
    const result = formatStatus('EVOLUTION', '');
    assert.deepStrictEqual(result, {
      text: '$(sparkle) Inquiry: EVOLUTION',
      tooltip: 'Inquiry: EVOLUTION',
    });
  });

  it('unknown phase uses default icon', () => {
    const result = formatStatus('UNKNOWN_PHASE', '');
    assert.deepStrictEqual(result, {
      text: '$(question) Inquiry: UNKNOWN_PHASE',
      tooltip: 'Inquiry: UNKNOWN_PHASE',
    });
  });

  it('END phase with task', () => {
    const result = formatStatus('END', '099');
    assert.deepStrictEqual(result, {
      text: '$(git-pull-request) Inquiry: END #099',
      tooltip: 'Inquiry: END — Task #099',
    });
  });
});
