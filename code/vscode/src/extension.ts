import * as vscode from 'vscode';
import * as path from 'path';
import { createStatusBar } from './status-bar';
import { toggleEvolution, addMutation } from './commands';
import { withGuard } from './command-guard';
import { inquiryInit } from './init';
import { installInquiryCli } from './installer';
import { getInquiryBinDir, shellExec } from './guard';

export function activate(context: vscode.ExtensionContext): void {
  // Inject inquiry bin dir into terminal PATH so `inquiry` and `iq` work
  // in new terminals without requiring a VS Code restart after install.
  const binDir = getInquiryBinDir();
  if (binDir) {
    const envCollection = context.environmentVariableCollection;
    envCollection.prepend('PATH', binDir + path.delimiter);
    envCollection.description = 'Adds Inquiry CLI to terminal PATH';
  }

  context.subscriptions.push(
    vscode.commands.registerCommand('inquiry.init', () => {
      const folder = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
      return inquiryInit(folder, undefined, async () => {
        await installInquiryCli();
        const { isInquiryInstalled, getInquiryBinaryPath, getPlatform, shellExec: se } = require('./guard');
        if (isInquiryInstalled()) {
          const terminal = vscode.window.createTerminal('Inquiry Init');
          terminal.show();
          terminal.sendText(se(getInquiryBinaryPath(getPlatform()), ['init']));
          terminal.sendText(se(getInquiryBinaryPath(getPlatform()), ['target', 'get']));
          const action = await vscode.window.showInformationMessage(
            'Inquiry initialized. Reload window so Copilot detects the @inquiry agent?',
            'Reload',
          );
          if (action === 'Reload') {
            await vscode.commands.executeCommand('workbench.action.reloadWindow');
          }
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
