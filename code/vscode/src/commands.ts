import * as fs from 'fs';
import * as path from 'path';
import { parseConfig, serializeConfig, formatMutation } from './parsers';

export async function toggleEvolution(apeFolderPath: string): Promise<void> {
  const configPath = path.join(apeFolderPath, 'config.yaml');
  let content = '';
  try {
    content = fs.readFileSync(configPath, 'utf-8');
  } catch {
    // file doesn't exist, use empty string (defaults to false)
  }
  const config = parseConfig(content);
  config.evolutionEnabled = !config.evolutionEnabled;
  const newContent = serializeConfig(config);
  fs.writeFileSync(configPath, newContent, 'utf-8');

  // eslint-disable-next-line @typescript-eslint/no-require-imports
  const vscode = require('vscode');
  vscode.window.showInformationMessage(
    `APE: Evolution ${config.evolutionEnabled ? 'enabled' : 'disabled'}`,
  );
}

export async function addMutation(apeFolderPath: string): Promise<void> {
  // eslint-disable-next-line @typescript-eslint/no-require-imports
  const vscode = require('vscode');
  const text = await vscode.window.showInputBox({
    prompt: 'Mutation note',
    placeHolder: 'What did you observe?',
  });
  if (!text) { return; }

  const mutationsPath = path.join(apeFolderPath, 'mutations.md');
  const entry = formatMutation(text, true);
  fs.appendFileSync(mutationsPath, entry, 'utf-8');
  vscode.window.showInformationMessage('APE: Mutation note added');
}
