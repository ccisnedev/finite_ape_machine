import * as fs from 'fs';
import * as path from 'path';

export function getPlatform(): string {
  return process.platform;
}

export function getInquiryBinaryPath(platform: string): string {
  if (platform === 'win32') {
    return path.join(process.env.LOCALAPPDATA ?? '', 'inquiry', 'bin', 'inquiry.exe');
  }
  if (platform === 'linux') {
    return path.join(process.env.HOME ?? '', '.inquiry', 'bin', 'inquiry');
  }
  throw new Error(`Unsupported platform: ${platform}`);
}

export function getInquiryBinDir(): string {
  const platform = getPlatform();
  if (platform === 'win32') {
    return path.join(process.env.LOCALAPPDATA ?? '', 'inquiry', 'bin');
  }
  if (platform === 'linux') {
    return path.join(process.env.HOME ?? '', '.inquiry', 'bin');
  }
  return '';
}

export function isInquiryInstalled(
  platform?: string,
  existsSync: (p: fs.PathLike) => boolean = fs.existsSync
): boolean {
  return existsSync(getInquiryBinaryPath(platform ?? getPlatform()));
}

export function isInquiryWorkspace(
  workspaceFolder: string,
  existsSync: (p: fs.PathLike) => boolean = fs.existsSync
): boolean {
  return existsSync(path.join(workspaceFolder, '.inquiry'));
}

/**
 * Build a shell command string that works in both PowerShell (Windows) and bash (Linux).
 * On Windows, uses the `&` call operator; on Linux, invokes the path directly.
 */
export function shellExec(binaryPath: string, args: string[], platform?: string): string {
  const plat = platform ?? getPlatform();
  if (plat === 'win32') {
    return `& "${binaryPath}" ${args.join(' ')}`;
  }
  return `"${binaryPath}" ${args.join(' ')}`;
}
