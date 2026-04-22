import { isInquiryInstalled, getInquiryBinaryPath, getPlatform } from './guard';

export interface InitDeps {
  isInquiryInstalled: () => boolean;
  getInquiryBinaryPath: () => string;
  showErrorMessage: (msg: string) => Thenable<string | undefined>;
  showInformationMessage: (msg: string, ...items: string[]) => Thenable<string | undefined>;
  createTerminal: (name: string) => { show: () => void; sendText: (text: string) => void };
}

export async function inquiryInit(
  workspaceFolder: string | undefined,
  deps?: Partial<InitDeps>,
  onInstallNeeded?: () => Promise<void>,
): Promise<void> {
  const vscode = deps ? undefined : require('vscode');

  const showErrorMessage = deps?.showErrorMessage
    ?? vscode.window.showErrorMessage.bind(vscode.window);
  const showInformationMessage = deps?.showInformationMessage
    ?? vscode.window.showInformationMessage.bind(vscode.window);
  const installed = deps?.isInquiryInstalled ?? (() => isInquiryInstalled());
  const binaryPath = deps?.getInquiryBinaryPath ?? (() => getInquiryBinaryPath(getPlatform()));
  const createTerminal = deps?.createTerminal ?? vscode.window.createTerminal.bind(vscode.window);

  if (!workspaceFolder) {
    showErrorMessage('Inquiry: Open a workspace folder first.');
    return;
  }

  if (!installed()) {
    if (onInstallNeeded) {
      await onInstallNeeded();
    } else {
      showInformationMessage('Inquiry CLI not found. Install it manually or wait for a future update.');
    }
    return;
  }

  const terminal = createTerminal('Inquiry Init');
  terminal.show();
  terminal.sendText(`"${binaryPath()}" init`);
}
