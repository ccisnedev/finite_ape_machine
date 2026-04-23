import { strict as assert } from 'node:assert';
import * as vscode from 'vscode';
import { describe, it } from 'mocha';

// Smoke test: requires @vscode/test-electron runner.

describe('extension module', function () {
  it('activate registers the init command in the VS Code host', async () => {
    // eslint-disable-next-line @typescript-eslint/no-require-imports
    const extension = require('../../src/extension');
    const context = {
      subscriptions: [] as vscode.Disposable[],
      environmentVariableCollection: {
        prepend: () => {},
        description: '',
      },
    } as unknown as vscode.ExtensionContext;

    extension.activate(context);

    const commands = await vscode.commands.getCommands(true);
    assert.ok(commands.includes('inquiry.init'));

    for (const disposable of context.subscriptions) {
      disposable.dispose();
    }
  });
});
