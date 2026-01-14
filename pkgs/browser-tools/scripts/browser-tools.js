#!/usr/bin/env node

import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import { spawn } from "node:child_process";

const __dirname = dirname(fileURLToPath(import.meta.url));

const commands = {
  start: "start.js",
  nav: "nav.js",
  eval: "eval.js",
  screenshot: "screenshot.js",
  pick: "pick.js",
  "dismiss-cookies": "dismiss-cookies.js",
};

function usage() {
  console.log(`Usage: browser-tools <command> [args...]

Commands:
  start [--profile]           Start Chrome with remote debugging
  nav <url> [--new]           Navigate to URL (--new opens new tab)
  eval '<code>'               Evaluate JavaScript in active tab
  screenshot                  Capture screenshot, returns temp file path
  pick '<message>'            Interactive element picker
  dismiss-cookies [--reject]  Dismiss cookie consent dialogs

Examples:
  browser-tools start
  browser-tools nav https://example.com
  browser-tools eval 'document.title'
  browser-tools screenshot
  browser-tools pick "Click the login button"
  browser-tools dismiss-cookies

Set DEBUG=1 for verbose logging.`);
  process.exit(1);
}

const command = process.argv[2];

if (!command || command === "-h" || command === "--help") {
  usage();
}

const script = commands[command];
if (!script) {
  console.error(`Unknown command: ${command}`);
  console.error(`Run 'browser-tools --help' for usage.`);
  process.exit(1);
}

const scriptPath = join(__dirname, script);
const args = process.argv.slice(3);

const child = spawn(process.execPath, [scriptPath, ...args], {
  stdio: "inherit",
  env: process.env,
});

child.on("close", (code) => {
  process.exit(code ?? 0);
});
