import { isApeInstalled, isApeWorkspace } from './guard';

export interface GuardOptions {
  skipWorkspaceCheck?: boolean;
}

export interface GuardDeps {
  isApeInstalled: () => boolean;
  isApeWorkspace: (folder: string) => boolean;
  showMessage: (msg: string, ...items: string[]) => Thenable<string | undefined>;
  executeCommand: (cmd: string) => Thenable<unknown>;
}

export async function withGuard(
  workspaceFolder: string,
  options: GuardOptions,
  fn: () => Promise<void>,
  deps?: Partial<GuardDeps>,
): Promise<void> {
  const installed = deps?.isApeInstalled ?? (() => isApeInstalled());
  const workspace = deps?.isApeWorkspace ?? ((f: string) => isApeWorkspace(f));

  let showMessage = deps?.showMessage;
  let executeCommand = deps?.executeCommand;
  if (!showMessage || !executeCommand) {
    // eslint-disable-next-line @typescript-eslint/no-require-imports
    const vscode = require('vscode');
    showMessage = showMessage ?? vscode.window.showInformationMessage.bind(vscode.window);
    executeCommand = executeCommand ?? vscode.commands.executeCommand.bind(vscode.commands);
  }

  if (!installed()) {
    const action = await showMessage!('APE CLI not found. Install it?', 'Install');
    if (action === 'Install') {
      await executeCommand!('ape.init');
    }
    return;
  }

  if (!options.skipWorkspaceCheck && !workspace(workspaceFolder)) {
    const action = await showMessage!('No APE workspace detected. Run ape init?', 'Init');
    if (action === 'Init') {
      await executeCommand!('ape.init');
    }
    return;
  }

  await fn();
}
