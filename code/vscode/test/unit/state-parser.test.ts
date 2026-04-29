import * as assert from 'assert';
import * as fs from 'fs';
import * as path from 'path';
import { parseState } from '../../src/parsers';
import type { ApeState } from '../../src/types';

const fixtures = path.join(__dirname, '..', '..', '..', 'test', 'fixtures');

describe('parseState', () => {
  it('state END con issue 152', () => {
    const content = fs.readFileSync(path.join(fixtures, 'state-end-152.yaml'), 'utf-8');
    const result: ApeState = parseState(content);
    assert.strictEqual(result.phase, 'END');
    assert.strictEqual(result.task, '152');
  });

  it('state ANALYZE con issue 042', () => {
    const content = fs.readFileSync(path.join(fixtures, 'state-analyze-flat.yaml'), 'utf-8');
    const result: ApeState = parseState(content);
    assert.strictEqual(result.phase, 'ANALYZE');
    assert.strictEqual(result.task, '042');
  });

  it('state IDLE sin issue', () => {
    const content = fs.readFileSync(path.join(fixtures, 'state-idle-flat.yaml'), 'utf-8');
    const result: ApeState = parseState(content);
    assert.strictEqual(result.phase, 'IDLE');
    assert.strictEqual(result.task, '');
  });

  it('state PLAN con issue inline', () => {
    const result: ApeState = parseState('state: PLAN\nissue: "77"\n');
    assert.strictEqual(result.phase, 'PLAN');
    assert.strictEqual(result.task, '77');
  });

  it('string vacío retorna defaults', () => {
    const result: ApeState = parseState('');
    assert.strictEqual(result.phase, 'IDLE');
    assert.strictEqual(result.task, '');
  });

  it('YAML inválido retorna defaults', () => {
    const result: ApeState = parseState(': : [invalid');
    assert.strictEqual(result.phase, 'IDLE');
    assert.strictEqual(result.task, '');
  });

  it('YAML sin campo state retorna defaults', () => {
    const result: ApeState = parseState('foo: bar\n');
    assert.strictEqual(result.phase, 'IDLE');
    assert.strictEqual(result.task, '');
  });
});
