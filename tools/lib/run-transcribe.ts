/**
 * Run repo transcribe CLI: Windows prefers transcribe.bat from the tools dir; else `transcribe` on PATH (macOS/Linux).
 */

import { existsSync } from 'fs';
import { execFileSync } from 'child_process';

const WINDOWS_TRANSCRIBE_BAT = 'E:\\dev\\tools\\transcribe.bat';

export function runTranscribeForVideo(videoPath: string): void {
  if (process.platform === 'win32' && existsSync(WINDOWS_TRANSCRIBE_BAT)) {
    execFileSync(WINDOWS_TRANSCRIBE_BAT, [videoPath], { stdio: 'inherit', shell: true });
    return;
  }
  execFileSync('transcribe', [videoPath], { stdio: 'inherit', env: process.env });
}
