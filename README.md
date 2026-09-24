# Proofreader

**A sleek macOS menu bar proofreader — powered by Google Gemini.**

Type any text in German or English and get it back grammar-, spelling-, and
punctuation-corrected. The language is detected automatically. Lives quietly in
your menu bar — no dock icon, no window clutter.

## Features

- Menu bar app — always a click away, no dock icon
- Auto language detection (German / English)
- Auto-correct ~0.6 s after you stop typing (debounced to save quota)
- Screenshot correction — grab text on screen and correct it
- One-click copy to clipboard
- Settings window for app language & Gemini API key (stored locally)

## Requirements

- macOS 14 or newer
- Xcode 16 or newer (to build)
- A free Gemini API key — https://aistudio.google.com/apikey

## Setup

1. Open `Proofreader.xcodeproj` in Xcode.
2. Under **Signing & Capabilities**, select your **Team**.
3. Build & run (`⌘R`).
4. Click the gear icon (or press `⌘,`) and paste your Gemini API key.

> The API key is stored locally via `@AppStorage` (UserDefaults) and is **never**
> part of the source code — safe to push to a public repo.

## Notes

- If the app is sandboxed, enable **Outgoing Network Connections (Client)** under
  App Sandbox, or the Gemini request will fail.
- The screenshot feature launches `/usr/sbin/screencapture`; it needs
  **Screen Recording** permission and does not work inside the App Sandbox.

---

Made with SwiftUI · Runs on your Mac
