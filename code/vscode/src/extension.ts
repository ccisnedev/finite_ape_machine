import * as vscode from 'vscode';
import * as path from 'path';
import { createStatusBar } from './status-bar';
import { toggleEvolution, addMutation } from './commands';
import { withGuard } from './command-guard';
import { inquiryInit } from './init';
import { installInquiryCli } from './installer';

export function activate(context: vscode.ExtensionContext): void {
  context.subscriptions.push(
    vscode.commands.registerCommand('inquiry.init', () => {
      const folder = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
      return inquiryInit(folder, undefined, async () => {
        await installInquiryCli();
        const { isInquiryInstalled, getInquiryBinaryPath, getPlatform } = require('./guard');
        if (isInquiryInstalled()) {
          const terminal = vscode.window.createTerminal('Inquiry Init');
          terminal.show();
          terminal.sendText(`"${getInquiryBinaryPath(getPlatform())}" init`);
        } else {
          vscode.window.showErrorMessage('Inquiry CLI installation failed. Please install manually.');
        }
      });
    }),
  );

  const workspaceFolder = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
  if (!workspaceFolder) { return; }

  const inquiryFolderPath = path.join(workspaceFolder, '.inquiry');

  createStatusBar(context, workspaceFolder);

  context.subscriptions.push(
    vscode.commands.registerCommand('inquiry.toggleEvolution', () =>
      withGuard(workspaceFolder, {}, () => toggleEvolution(inquiryFolderPath)),
    ),
    vscode.commands.registerCommand('inquiry.addMutation', () =>
      withGuard(workspaceFolder, {}, () => addMutation(inquiryFolderPath)),
    ),
  );
}

export function deactivate(): void {
}
