import { strict as assert } from 'node:assert';
import * as fs from 'node:fs';
import * as path from 'node:path';
import { afterEach, beforeEach, describe, it } from 'mocha';

import { addMutation } from '../../src/commands';
import { createTempWorkspace, removeTempWorkspace, stubWindowMethod } from './helpers';

describe('addMutation integration', function () {
  let root = '';
  let inquiryPath = '';
  let restoreInputBox: (() => void) | undefined;
  let restoreInfo: (() => void) | undefined;
  let infoMessages: string[] = [];

  beforeEach(() => {
    const temp = createTempWorkspace('inquiry-vscode-add-mutation-');
    root = temp.root;
    inquiryPath = temp.inquiryPath;
    infoMessages = [];
  });

  afterEach(() => {
    restoreInputBox?.();
    restoreInfo?.();
    restoreInputBox = undefined;
    restoreInfo = undefined;
    removeTempWorkspace(root);
  });

  it('addMutation muestra InputBox y appends texto a mutations.md', async () => {
    const mutationsPath = path.join(inquiryPath, 'mutations.md');
    fs.writeFileSync(mutationsPath, '# Mutations\n', 'utf-8');

    restoreInputBox = stubWindowMethod('showInputBox', async () => 'Observed drift');
    restoreInfo = stubWindowMethod('showInformationMessage', async (message: string) => {
      infoMessages.push(message);
      return undefined;
    });

    await addMutation(inquiryPath);

    const content = fs.readFileSync(mutationsPath, 'utf-8');
    assert.match(content, /^# Mutations\n- \[\d{4}-\d{2}-\d{2} \d{2}:\d{2}\] Observed drift\n$/);
    assert.deepStrictEqual(infoMessages, ['Inquiry: Mutation note added']);
  });

  it('addMutation crea mutations.md si no existe', async () => {
    const mutationsPath = path.join(inquiryPath, 'mutations.md');

    restoreInputBox = stubWindowMethod('showInputBox', async () => 'Fresh note');
    restoreInfo = stubWindowMethod('showInformationMessage', async (message: string) => {
      infoMessages.push(message);
      return undefined;
    });

    await addMutation(inquiryPath);

    assert.ok(fs.existsSync(mutationsPath));
    const content = fs.readFileSync(mutationsPath, 'utf-8');
    assert.match(content, /^- \[\d{4}-\d{2}-\d{2} \d{2}:\d{2}\] Fresh note\n$/);
    assert.deepStrictEqual(infoMessages, ['Inquiry: Mutation note added']);
  });

  it('addMutation con cancel (undefined) no modifica archivo', async () => {
    const mutationsPath = path.join(inquiryPath, 'mutations.md');

    restoreInputBox = stubWindowMethod('showInputBox', async () => undefined);
    restoreInfo = stubWindowMethod('showInformationMessage', async (message: string) => {
      infoMessages.push(message);
      return undefined;
    });

    await addMutation(inquiryPath);

    assert.ok(!fs.existsSync(mutationsPath));
    assert.deepStrictEqual(infoMessages, []);
  });
});
