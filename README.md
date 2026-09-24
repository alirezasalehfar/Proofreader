<p align="center">
  <img src="Proofreader/Assets.xcassets/AppIcon.appiconset/icon_512x512@1x.png" width="180" alt="Proofreader icon">
</p>

<h1 align="center">Proofreader</h1>

<p align="center">
  <strong>A sleek macOS menu bar proofreader — powered by Google Gemini.</strong><br>
  Lives quietly in your menu bar. No dock icon, no window clutter. Just type and fix.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS%2014%2B-blue" alt="Platform">
  <img src="https://img.shields.io/badge/Swift-SwiftUI-orange" alt="Swift">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="License">
  <a href="https://github.com/alirezasalehfar/proofreader/releases/latest">
    <img src="https://img.shields.io/badge/⬇%20Download-latest%20release-success" alt="Download latest release">
  </a>
</p>

---

## ✨ Features

|                             |                                                                              |
| --------------------------- | ---------------------------------------------------------------------------- |
| 🧭 **Menu bar app**         | Always a click away — no dock icon, no separate window.                       |
| 🌍 **Auto language**        | Detects **German** or **English** automatically and replies in that language.|
| ✅ **Grammar & spelling**   | Fixes grammar, spelling, and punctuation without changing your style.        |
| 📸 **Screenshot correct**   | Drag a box over any text on screen — it's recognized *and* corrected.        |
| 📋 **One-click copy**       | Send the result straight to your clipboard.                                  |
| ⚙️ **Settings window**      | Set app language & Gemini API key in one place — stored permanently.         |

**Supported languages:** German · English

---

## 📦 Requirements

- 🖥️ **macOS 14** or newer
- 🛠️ **Xcode 16** or newer (to build)
- 🔑 A **free Gemini API key**

---

## 🚀 Installation

### Build from source

```bash
git clone git@github.com:alirezasalehfar/proofreader.git
cd proofreader
```

1. Open `Proofreader.xcodeproj` in Xcode.
2. Under **Signing & Capabilities**, select your **Team** (a free Apple account is enough for local use).
3. Under **App Sandbox → Network**, enable **Outgoing Connections (Client)** so the Gemini request can reach the internet.
4. Set the scheme to **Release** (optional), then **Product → Build** (`⌘B`).
5. In the navigator, expand **Products**, right-click `Proofreader.app` → **Show in Finder**, and drag it into **Applications**.

### 🔁 Launch at login

**System Settings → General → Login Items → "Open at Login"** → add `Proofreader.app` with `+`.

---

## 🔧 Setup

### 🔑 Gemini API key

1. Sign in at [aistudio.google.com/apikey](https://aistudio.google.com/apikey).
2. **Create API key** → new project → copy the key.
3. In the app, click the **gear ⚙️** (top-right) or press `⌘,`.
4. Paste it into **Gemini API key** → **Save & Close**.

> The key is stored locally in the app's settings and is **never** part of the source code — safe to push to a public repo.

> ⚠️ On the free tier, Google may use your input text to improve its models — don't paste sensitive content. Usage stays free as long as no billing is enabled.

### 📸 Screen recording permission (for screenshot correction)

The first time you use screenshot correction, macOS asks for **Screen Recording** access:

**System Settings → Privacy & Security → Screen & System Audio Recording** → enable the app and restart it once.

> Note: the screenshot feature launches `/usr/sbin/screencapture` and therefore does **not** work while App Sandbox is enabled. For text correction alone, the sandbox is fine — you only need the network capability above.

---

## 📖 Usage

1. Click the **check-bubble icon** in the menu bar.
2. Type or paste your text.
3. Hit **Correct** — the corrected text appears below.
4. For text inside an image, click the **scan icon** and drag over the area.
5. **Copy** puts the result on your clipboard.

---

## 🧱 Tech overview

- 🎨 **SwiftUI** with `MenuBarExtra` (window style) for menu bar integration
- 🤖 **Google Gemini API** (`gemini-2.5-flash`) for text & image correction
- 💾 Settings persisted via `@AppStorage` (UserDefaults)
- 🖼️ Screenshots via the system `screencapture -i` tool

---

## 📝 Notes

- The app is locally self-signed. On first launch, right-click → **Open** if Gatekeeper complains.
- Without a key, the app shows a friendly reminder to add one in Settings.

---

## 📄 License

[MIT](LICENSE) © 2026 Alireza Salehfar

---

Made with SwiftUI · Runs on your Mac 🖥️
