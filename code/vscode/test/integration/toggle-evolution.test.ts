import { strict as assert } from 'node:assert';
import * as fs from 'node:fs';
import * as path from 'node:path';
import { afterEach, beforeEach, describe, it } from 'mocha';

import { toggleEvolution } from '../../src/commands';
import { createTempWorkspace, removeTempWorkspace, stubWindowMethod } from './helpers';

describe('toggleEvolution integration', function () {
  let root = '';
  let inquiryPath = '';
  let restoreInfo: (() => void) | undefined;
  let infoMessages: string[] = [];

  beforeEach(() => {
    const temp = createTempWorkspace('inquiry-vscode-toggle-evolution-');
    root = temp.root;
    inquiryPath = temp.inquiryPath;
    infoMessages = [];
  });

  afterEach(() => {
    restoreInfo?.();
    restoreInfo = undefined;
    removeTempWorkspace(root);
  });

  it('toggleEvolution lee config.yaml, invierte enabled, escribe el nuevo valor', async () => {
    const configPath = path.join(inquiryPath, 'config.yaml');
    fs.writeFileSync(configPath, 'evolution:\n  enabled: false\n', 'utf-8');
    restoreInfo = stubWindowMethod('showInformationMessage', async (message: string) => {
      infoMessages.push(message);
      return undefined;
    });

    await toggleEvolution(inquiryPath);

    const content = fs.readFileSync(configPath, 'utf-8');
    assert.match(content, /enabled: true/);
    assert.deepStrictEqual(infoMessages, ['Inquiry: Evolution enabled']);
  });

  it('toggleEvolution crea config.yaml con enabled=true si no existe', async () => {
    const configPath = path.join(inquiryPath, 'config.yaml');
    restoreInfo = stubWindowMethod('showInformationMessage', async (message: string) => {
      infoMessages.push(message);
      return undefined;
    });

    await toggleEvolution(inquiryPath);

    assert.ok(fs.existsSync(configPath));
    const content = fs.readFileSync(configPath, 'utf-8');
    assert.match(content, /enabled: true/);
    assert.deepStrictEqual(infoMessages, ['Inquiry: Evolution enabled']);
  });

  it('toggleEvolution muestra notification con el nuevo estado', async () => {
    const configPath = path.join(inquiryPath, 'config.yaml');
    fs.writeFileSync(configPath, 'evolution:\n  enabled: true\n', 'utf-8');
    restoreInfo = stubWindowMethod('showInformationMessage', async (message: string) => {
      infoMessages.push(message);
      return undefined;
    });

    await toggleEvolution(inquiryPath);

    const content = fs.readFileSync(configPath, 'utf-8');
    assert.match(content, /enabled: false/);
    assert.deepStrictEqual(infoMessages, ['Inquiry: Evolution disabled']);
  });
});
