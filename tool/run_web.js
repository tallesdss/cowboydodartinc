#!/usr/bin/env node
/**
 * Run the Flutter web dev server WITH the preview-toolbar reload bridge.
 *
 * Uses the kit's local CLI so r/R in the web device preview work out of the box.
 * If a healthy session is already on :5555/:5556, prints the URL and exits 0.
 *
 * Usage (from Firebase/):
 *   node tool/run_web.js
 */

'use strict';

const path = require('node:path');
const { spawn } = require('node:child_process');

const projectDir = path.resolve(__dirname, '..');
const kasyBin = path.resolve(__dirname, '../../cli/bin/kasy.js');
const { probeDevWebSession } = require('../../cli/lib/utils/dev-web-session');

async function main() {
  const session = await probeDevWebSession(5555);
  if (session.healthy) {
    console.log('');
    console.log(`  ✦ Dev web já rodando: http://localhost:${session.webPort}`);
    console.log('  ✦ Toolbar r/R online — abra ou atualize essa URL no navegador.');
    console.log('  ✦ Não precisa de outro terminal. Use q no run original para parar.');
    console.log('');
    process.exit(0);
  }

  const child = spawn(process.execPath, [kasyBin, 'run', '--web'], {
    cwd: projectDir,
    stdio: 'inherit',
    env: process.env,
  });

  child.on('close', (code) => process.exit(code ?? 1));
  child.on('error', (err) => {
    console.error(err);
    process.exit(1);
  });
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
