import * as fs from 'fs';
import * as path from 'path';

export function getPlatform(): string {
  return process.platform;
}

export function getApeBinaryPath(platform: string): string {
  if (platform === 'win32') {
    return path.join(process.env.LOCALAPPDATA!, 'ape', 'bin', 'ape.exe');
  }
  if (platform === 'linux') {
    return path.join(process.env.HOME!, '.ape', 'bin', 'ape');
  }
  throw new Error(`Unsupported platform: ${platform}`);
}

export function isApeInstalled(
  platform?: string,
  existsSync: (p: fs.PathLike) => boolean = fs.existsSync
): boolean {
  return existsSync(getApeBinaryPath(platform ?? getPlatform()));
}

export function isApeWorkspace(
  workspaceFolder: string,
  existsSync: (p: fs.PathLike) => boolean = fs.existsSync
): boolean {
  return existsSync(path.join(workspaceFolder, '.ape'));
}
