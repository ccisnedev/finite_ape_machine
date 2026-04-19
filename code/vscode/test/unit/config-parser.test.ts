import * as assert from 'assert';
import * as fs from 'fs';
import * as path from 'path';
import { parseConfig, serializeConfig } from '../../src/parsers';
import { parse } from 'yaml';
import type { ApeConfig } from '../../src/types';

const fixtures = path.join(__dirname, '..', '..', '..', 'test', 'fixtures');

describe('parseConfig', () => {
  it('con evolution.enabled=true retorna {evolutionEnabled: true}', () => {
    const content = fs.readFileSync(path.join(fixtures, 'config-enabled.yaml'), 'utf-8');
    const result: ApeConfig = parseConfig(content);
    assert.strictEqual(result.evolutionEnabled, true);
  });

  it('con evolution.enabled=false retorna {evolutionEnabled: false}', () => {
    const content = fs.readFileSync(path.join(fixtures, 'config-disabled.yaml'), 'utf-8');
    const result: ApeConfig = parseConfig(content);
    assert.strictEqual(result.evolutionEnabled, false);
  });

  it('con string vacío retorna {evolutionEnabled: false}', () => {
    const content = fs.readFileSync(path.join(fixtures, 'config-missing.yaml'), 'utf-8');
    const result: ApeConfig = parseConfig(content);
    assert.strictEqual(result.evolutionEnabled, false);
  });

  it('con YAML inválido retorna {evolutionEnabled: false}', () => {
    const result: ApeConfig = parseConfig(': : [invalid');
    assert.strictEqual(result.evolutionEnabled, false);
  });
});

describe('serializeConfig', () => {
  it('({evolutionEnabled: true}) produce YAML válido con evolution.enabled: true', () => {
    const yaml = serializeConfig({ evolutionEnabled: true });
    const parsed = parse(yaml);
    assert.strictEqual(parsed.evolution.enabled, true);
  });

  it('({evolutionEnabled: false}) produce YAML válido con evolution.enabled: false', () => {
    const yaml = serializeConfig({ evolutionEnabled: false });
    const parsed = parse(yaml);
    assert.strictEqual(parsed.evolution.enabled, false);
  });
});
