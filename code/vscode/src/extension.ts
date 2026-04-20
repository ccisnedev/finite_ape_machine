import * as vscode from 'vscode';
import * as path from 'path';
import { createStatusBar } from './status-bar';
import { toggleEvolution, addMutation } from './commands';
import { withGuard } from './command-guard';
import { apeInit } from './init';

export function activate(context: vscode.ExtensionContext): void {
  context.subscriptions.push(
    vscode.commands.registerCommand('ape.init', () => {
      const folder = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
      return apeInit(folder);
    }),
  );

  const workspaceFolder = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
  if (!workspaceFolder) { return; }

  const apeFolderPath = path.join(workspaceFolder, '.ape');

  createStatusBar(context, workspaceFolder);

  context.subscriptions.push(
    vscode.commands.registerCommand('ape.toggleEvolution', () =>
      withGuard(workspaceFolder, {}, () => toggleEvolution(apeFolderPath)),
    ),
    vscode.commands.registerCommand('ape.addMutation', () =>
      withGuard(workspaceFolder, {}, () => addMutation(apeFolderPath)),
    ),
  );
}

export function deactivate(): void {
}
