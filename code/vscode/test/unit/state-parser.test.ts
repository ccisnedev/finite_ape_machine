import * as assert from 'assert';
import * as fs from 'fs';
import * as path from 'path';
import { parseState } from '../../src/parsers';
import type { ApeState } from '../../src/types';

const fixtures = path.join(__dirname, '..', '..', '..', 'test', 'fixtures');

describe('parseState', () => {
  it('con ANALYZE y task 042 retorna {phase: "ANALYZE", task: "042"}', () => {
    const content = fs.readFileSync(path.join(fixtures, 'state-analyze.yaml'), 'utf-8');
    const result: ApeState = parseState(content);
    assert.strictEqual(result.phase, 'ANALYZE');
    assert.strictEqual(result.task, '042');
  });

  it('con IDLE retorna {phase: "IDLE", task: ""}', () => {
    const content = fs.readFileSync(path.join(fixtures, 'state-idle.yaml'), 'utf-8');
    const result: ApeState = parseState(content);
    assert.strictEqual(result.phase, 'IDLE');
    assert.strictEqual(result.task, '');
  });

  it('con string vacío retorna defaults {phase: "IDLE", task: ""}', () => {
    const content = fs.readFileSync(path.join(fixtures, 'state-empty.yaml'), 'utf-8');
    const result: ApeState = parseState(content);
    assert.strictEqual(result.phase, 'IDLE');
    assert.strictEqual(result.task, '');
  });

  it('con YAML inválido retorna defaults', () => {
    const result: ApeState = parseState(': : [invalid');
    assert.strictEqual(result.phase, 'IDLE');
    assert.strictEqual(result.task, '');
  });

  it('con phase desconocido retorna el string tal cual', () => {
    const content = 'cycle:\n  phase: CUSTOM_PHASE\n  task: "99"';
    const result: ApeState = parseState(content);
    assert.strictEqual(result.phase, 'CUSTOM_PHASE');
    assert.strictEqual(result.task, '99');
  });
});
