import { strict as assert } from 'node:assert';
import * as fs from 'node:fs';
import * as path from 'node:path';
import type * as vscode from 'vscode';
import { afterEach, beforeEach, describe, it } from 'mocha';

import { createStatusBar } from '../../src/status-bar';
import { createTempWorkspace, delay, removeTempWorkspace, waitFor } from './helpers';

describe('StatusBar integration', function () {
  this.timeout(5000);

  let root = '';
  let inquiryPath = '';

  beforeEach(() => {
    const temp = createTempWorkspace('inquiry-vscode-status-bar-');
    root = temp.root;
    inquiryPath = temp.inquiryPath;
  });

  afterEach(() => {
    removeTempWorkspace(root);
  });

  it('createStatusBar crea un StatusBarItem visible', async () => {
    const context = { subscriptions: [] as vscode.Disposable[] } as unknown as vscode.ExtensionContext;
    const [item, watcher] = createStatusBar(context, root) as [vscode.StatusBarItem, vscode.FileSystemWatcher];

    await waitFor(() => item.text.includes('Inquiry: IDLE'));

    assert.match(item.text, /Inquiry: IDLE/);
    assert.strictEqual(String(item.tooltip), 'Inquiry: IDLE');
    assert.strictEqual(context.subscriptions.length, 2);

    watcher.dispose();
    item.dispose();
  });

  it('updateStatusBar con ApeState actualiza text y tooltip del item', async () => {
    const statePath = path.join(inquiryPath, 'state.yaml');
    fs.writeFileSync(statePath, 'cycle:\n  phase: PLAN\n  task: "042"\n', 'utf-8');
    const context = { subscriptions: [] as vscode.Disposable[] } as unknown as vscode.ExtensionContext;
    const [item, watcher] = createStatusBar(context, root) as [vscode.StatusBarItem, vscode.FileSystemWatcher];

    await waitFor(() => item.text.includes('PLAN #042'));

    assert.match(item.text, /Inquiry: PLAN #042/);
    assert.strictEqual(String(item.tooltip), 'Inquiry: PLAN — Task #042');

    watcher.dispose();
    item.dispose();
  });

  it('dispose limpia el item y el watcher', async () => {
    const statePath = path.join(inquiryPath, 'state.yaml');
    fs.writeFileSync(statePath, 'cycle:\n  phase: ANALYZE\n  task: "042"\n', 'utf-8');
    const context = { subscriptions: [] as vscode.Disposable[] } as unknown as vscode.ExtensionContext;
    const [item, watcher] = createStatusBar(context, root) as [vscode.StatusBarItem, vscode.FileSystemWatcher];

    await waitFor(() => item.text.includes('ANALYZE #042'));
    const beforeDispose = item.text;

    watcher.dispose();
    item.dispose();

    fs.writeFileSync(statePath, 'cycle:\n  phase: EXECUTE\n  task: "042"\n', 'utf-8');
    await delay(250);

    assert.strictEqual(item.text, beforeDispose);
  });
});
