import { parse, stringify } from 'yaml';
import type { ApeState, ApeConfig } from './types';

const DEFAULT_STATE: ApeState = { phase: 'IDLE', task: '' };
const DEFAULT_CONFIG: ApeConfig = { evolutionEnabled: false };

export function parseState(content: string): ApeState {
  if (!content.trim()) {
    return { ...DEFAULT_STATE };
  }
  try {
    const doc = parse(content);
    const cycle = doc?.cycle;
    if (!cycle || typeof cycle !== 'object') {
      return { ...DEFAULT_STATE };
    }
    return {
      phase: String(cycle.phase ?? 'IDLE'),
      task: String(cycle.task ?? ''),
    };
  } catch {
    return { ...DEFAULT_STATE };
  }
}

export function parseConfig(content: string): ApeConfig {
  if (!content.trim()) {
    return { ...DEFAULT_CONFIG };
  }
  try {
    const doc = parse(content);
    const enabled = doc?.evolution?.enabled;
    return { evolutionEnabled: enabled === true };
  } catch {
    return { ...DEFAULT_CONFIG };
  }
}

export function serializeConfig(config: ApeConfig): string {
  return stringify({ evolution: { enabled: config.evolutionEnabled } });
}

export function formatMutation(text: string, withTimestamp: boolean): string {
  const escaped = text.replace(/\|/g, '\\|').replace(/\n/g, ' ');
  if (withTimestamp) {
    const now = new Date();
    const ts = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')} ${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}`;
    return `- [${ts}] ${escaped}\n`;
  }
  return `- ${escaped}\n`;
}
