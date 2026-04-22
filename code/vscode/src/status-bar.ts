import type * as vscode from 'vscode';
import type { ApeState, StatusBarData } from './types';
import { parseState } from './parsers';
import { readFile } from 'node:fs/promises';
import { join } from 'node:path';

const PHASE_ICONS: Record<string, string> = {
  'IDLE': '$(circle-outline)',
  'ANALYZE': '$(search)',
  'PLAN': '$(list-ordered)',
  'EXECUTE': '$(rocket)',
  'END': '$(git-pull-request)',
  'EVOLUTION': '$(sparkle)',
};

const DEFAULT_ICON = '$(question)';

export function formatStatus(phase: string, task: string): StatusBarData {
  const icon = PHASE_ICONS[phase] ?? DEFAULT_ICON;
  const taskSuffix = task ? ` #${task}` : '';
  const text = `${icon} Inquiry: ${phase}${taskSuffix}`;
  const tooltip = task
    ? `Inquiry: ${phase} — Task #${task}`
    : `Inquiry: ${phase}`;
  return { text, tooltip };
}

function getVscode(): typeof import('vscode') {
  // eslint-disable-next-line @typescript-eslint/no-require-imports
  return require('vscode');
}

export function createStatusBar(
  context: vscode.ExtensionContext,
  workspaceFolder: string,
): vscode.Disposable[] {
  const vs = getVscode();
  const item = vs.window.createStatusBarItem(
    vs.StatusBarAlignment.Left,
    100,
  );

  const stateFile = '.inquiry/state.yaml';
  const absPath = join(workspaceFolder, stateFile);

  async function refresh(): Promise<void> {
    try {
      const content = await readFile(absPath, 'utf-8');
      const state = parseState(content);
      applyState(item, state);
    } catch {
      applyState(item, { phase: 'IDLE', task: '' });
    }
  }

  function applyState(
    bar: vscode.StatusBarItem,
    state: ApeState,
  ): void {
    const data = formatStatus(state.phase, state.task);
    bar.text = data.text;
    bar.tooltip = data.tooltip;
    bar.show();
  }

  const pattern = new vs.RelativePattern(workspaceFolder, stateFile);
  const watcher = vs.workspace.createFileSystemWatcher(pattern);

  watcher.onDidChange(() => refresh());
  watcher.onDidCreate(() => refresh());
  watcher.onDidDelete(() => {
    applyState(item, { phase: 'IDLE', task: '' });
  });

  // Initial read
  refresh();

  const disposables = [item, watcher];
  context.subscriptions.push(...disposables);
  return disposables;
}
