---
name: browser-tools
description: "Interact with web pages by performing actions such as clicking buttons, filling out forms, and navigating links. Works by remote controlling Chrome/Chromium browsers using CDP (Chrome DevTools Protocol). Use when Claude needs to browse the web interactively."
---

# Browser Tools Skill

Minimal CDP tools for collaborative site exploration.

## Start Chrome

```bash
browser-tools start              # Fresh profile
browser-tools start --profile    # Copy your profile (cookies, logins)
```

Start Chrome on `:9222` with remote debugging.

## Navigate

```bash
browser-tools nav https://example.com
browser-tools nav https://example.com --new
```

Navigate current tab or open new tab.

## Evaluate JavaScript

```bash
browser-tools eval 'document.title'
browser-tools eval 'document.querySelectorAll("a").length'
browser-tools eval 'JSON.stringify(Array.from(document.querySelectorAll("a")).map(a => ({ text: a.textContent.trim(), href: a.href })))'
```

Execute JavaScript in active tab (async context). Be careful with string escaping, best to use single quotes.

## Screenshot

```bash
browser-tools screenshot
```

Screenshot current viewport, returns temp file path.

## Pick Elements

```bash
browser-tools pick "Click the submit button"
```

Interactive element picker. Click to select, Cmd/Ctrl+Click for multi-select, Enter to finish.

## Dismiss Cookie Dialogs

```bash
browser-tools dismiss-cookies          # Accept cookies
browser-tools dismiss-cookies --reject # Reject cookies (where possible)
```

Automatically dismisses EU cookie consent dialogs. Supports:
- **OneTrust** (booking.com, ikea.com, many others)
- **Google** consent dialogs
- **Cookiebot**
- **Didomi**
- **Quantcast Choice**
- **Usercentrics** (shadow DOM)
- **Sourcepoint** (BBC, etc. - works with iframes)
- **Amazon**
- **TrustArc**
- **Klaro**
- Generic cookie banners with common button text patterns

Run after navigating to a page (with a short delay for dialogs to load):
```bash
browser-tools nav https://example.com && sleep 2 && browser-tools dismiss-cookies
```

## Debug Mode

Set `DEBUG=1` to enable verbose logging to stderr:
```bash
DEBUG=1 browser-tools nav https://example.com
```
