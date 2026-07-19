#!/usr/bin/env node
'use strict';

const fs = require('node:fs');
const path = require('node:path');

const root = path.resolve(__dirname, '..');
const pubspecPath = path.join(root, 'pubspec.yaml');

function parseArgs() {
  const args = process.argv.slice(2);
  let versionName = null;
  for (let i = 0; i < args.length; i += 1) {
    if (args[i] === '--version-name' && args[i + 1]) {
      versionName = args[i + 1];
      i += 1;
    }
  }
  return { versionName };
}

function bumpPubspecVersion(content, versionNameOverride) {
  const match = content.match(/^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$/m);
  if (!match) {
    throw new Error('Invalid version line in pubspec.yaml (expected format: 1.0.0+1)');
  }
  const name = versionNameOverride || match[1];
  const build = parseInt(match[2], 10) + 1;
  const next = `version: ${name}+${build}`;
  const updated = content.replace(/^version:\s*.*/m, next);
  return { updated, label: `${name}+${build}` };
}

const { versionName } = parseArgs();
const content = fs.readFileSync(pubspecPath, 'utf8');
const { updated, label } = bumpPubspecVersion(content, versionName);
fs.writeFileSync(pubspecPath, updated);
console.log(label);
