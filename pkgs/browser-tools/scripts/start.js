#!/usr/bin/env node

import { spawn, execSync } from "node:child_process";
import { existsSync } from "node:fs";

const useProfile = process.argv[2] === "--profile";

if (process.argv[2] && process.argv[2] !== "--profile") {
  console.log("Usage: start.js [--profile]");
  console.log("\nOptions:");
  console.log(
    "  --profile  Copy your default Chrome/Chromium profile (cookies, logins)",
  );
  console.log("\nExamples:");
  console.log("  start.js            # Start with fresh profile");
  console.log("  start.js --profile  # Start with your browser profile");
  process.exit(1);
}

// Find Chrome/Chromium binary
function findChromeBinary() {
  const candidates = [
    // Linux
    "chromium",
    "chromium-browser",
    "google-chrome",
    "google-chrome-stable",
    // macOS
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    "/Applications/Chromium.app/Contents/MacOS/Chromium",
  ];
  
  for (const bin of candidates) {
    try {
      execSync(`which "${bin}"`, { stdio: "ignore" });
      return bin;
    } catch {
      if (existsSync(bin)) return bin;
    }
  }
  throw new Error("Could not find Chrome or Chromium");
}

// Find profile directory
function findProfileDir() {
  const home = process.env["HOME"];
  const candidates = [
    // Linux
    `${home}/.config/chromium`,
    `${home}/.config/google-chrome`,
    // macOS
    `${home}/Library/Application Support/Google/Chrome`,
    `${home}/Library/Application Support/Chromium`,
  ];
  
  for (const dir of candidates) {
    if (existsSync(dir)) return dir;
  }
  return null;
}

const chromeBin = findChromeBinary();

// Kill existing Chrome with remote debugging
try {
  execSync("pkill -f 'remote-debugging-port=9222'", { stdio: "ignore" });
} catch {}

// Wait a bit for processes to fully die
await new Promise((r) => setTimeout(r, 1000));

// Setup profile directory
const cacheDir = `${process.env["HOME"]}/.cache/web-browser-cdp`;
execSync(`mkdir -p "${cacheDir}"`, { stdio: "ignore" });

if (useProfile) {
  const profileDir = findProfileDir();
  if (profileDir) {
    execSync(
      `rsync -a --delete "${profileDir}/" "${cacheDir}/"`,
      { stdio: "pipe" },
    );
  } else {
    console.error("Warning: Could not find browser profile to copy");
  }
}

// Start Chrome in background (detached so Node can exit)
spawn(
  chromeBin,
  [
    "--remote-debugging-port=9222",
    `--user-data-dir=${cacheDir}`,
    "--profile-directory=Default",
    "--disable-search-engine-choice-screen",
    "--no-first-run",
    "--disable-features=ProfilePicker",
  ],
  { detached: true, stdio: "ignore" },
).unref();

// Wait for Chrome to be ready by checking the debugging endpoint
let connected = false;
for (let i = 0; i < 30; i++) {
  try {
    const response = await fetch("http://localhost:9222/json/version");
    if (response.ok) {
      connected = true;
      break;
    }
  } catch {
    await new Promise((r) => setTimeout(r, 500));
  }
}

if (!connected) {
  console.error("✗ Failed to connect to Chrome");
  process.exit(1);
}

console.log(
  `✓ Chrome started on :9222${useProfile ? " with your profile" : ""}`,
);
