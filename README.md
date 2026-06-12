<div align="center">

<img src="assets/NassakhRTL-logo.svg" alt="NassakhRTL" height="70" />

**Fix Arabic, Hebrew, Persian, and Urdu text for Affinity apps — instantly.**

[![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D4?logo=windows&logoColor=white)](https://github.com/talhabinmunir/nassakhrtl/releases)
[![Download](https://img.shields.io/badge/Download-.exe-22c55e)](https://github.com/talhabinmunir/nassakhrtl/releases/latest)
[![Gumroad](https://img.shields.io/badge/Download-Gumroad-FF90E8?logo=gumroad&logoColor=white)](https://1712812868996.gumroad.com/l/nassakhrtl)
[![License](https://img.shields.io/badge/License-MIT-teal)](LICENSE)
[![Made by Talha](https://img.shields.io/badge/Made%20by-Talha%20bin%20Munir-1e9b8c)](mailto:tlhmunir@gmail.com)

</div>

---

## The problem

Affinity Designer, Affinity Publisher, and Affinity Photo have no Arabic shaping engine and no bidi support. When you paste Arabic, Persian, Urdu, or Hebrew text, you get this:

```
لامعأ تيب
```

Instead of this:

```
بيت الأعمال
```

Letters appear disconnected, isolated, and in the wrong order. NassakhRTL fixes that before you paste.

---

## How it works

NassakhRTL converts each letter to its correct contextual glyph form (initial, medial, final, or isolated), applies lam-alef ligatures, then reverses each line into visual order — which is what a left-to-right renderer like Affinity expects. The result pastes in and renders correctly.

---

## Quick start

**Option A — hotkey (fastest)**

1. Keep NassakhRTL running in the background.
2. Copy any RTL text from anywhere.
3. Press **Ctrl + Alt + R**.
4. Paste into Affinity with **Ctrl + V**.

**Option B — via the app window**

1. Paste or type text into the input box.
2. Check the Affinity Preview panel to confirm it looks right.
3. Click **Convert + Copy**.
4. Paste into Affinity.

---

## Download & run

Single `.exe` file — double-click and go. No installation, no Python, no .NET SDK.

### Option 1 — GitHub Releases (recommended)

1. Go to [Releases](https://github.com/talhabinmunir/nassakhrtl/releases/latest)
2. Download `NassakhRTL.exe`
3. Double-click to run

### Option 2 — Gumroad

[https://1712812868996.gumroad.com/l/nassakhrtl](https://1712812868996.gumroad.com/l/nassakhrtl)

Free download. Pay what you want.

---

> **SmartScreen warning:** Windows may show "Windows protected your PC" because the
> file is new and unsigned. Click **More info → Run anyway**. This is normal for all
> new indie software. The full source code is readable in `NassakhRTL.ps1`.

> **Tip:** Put a shortcut to `NassakhRTL.exe` in your Windows Startup folder
> (`Win + R` → `shell:startup`) so it opens automatically with Windows.

---

## Features

| Feature | Details |
|---|---|
| **Arabic shaping** | Contextual letter forms + lam-alef ligatures |
| **Visual reorder** | Lines reversed for LTR renderers; Latin runs stay in place |
| **Affinity preview** | Live preview exactly matching Affinity rendering |
| **Character inspector** | Click any glyph → Unicode codepoint, name, and origin |
| **Arabic digits → 0-9** | ٠١٢٣٤٥٦٧٨٩ converted on the fly |
| **Remove diacritics** | Optional: strips harakat (Arabic) and niqqud (Hebrew) |
| **Remove tatweel** | Optional: removes ـ elongation marks |
| **Arabic → Latin punctuation** | ، ؛ ؟ → , ; ? |
| **Alef unification** | أ إ آ → ا (off by default, changes spelling) |
| **Hidden char removal** | Strips ZWSP, BOM, direction marks |
| **Drag and drop** | Drop a .txt file directly onto the app |
| **Import / Export** | .txt and .json (original + converted, with metadata) |
| **Presets** | Save named option sets per client or language |
| **History** | Last 10 conversions, one click to restore |
| **Dark / Light theme** | Persistent across sessions |
| **Settings persistence** | Window position, options, presets saved automatically |
| **Global hotkey** | Ctrl + Alt + R from any open application |
| **Keyboard shortcuts** | Ctrl + Enter to convert, Ctrl + Shift + V to paste-and-fix |
| **Languages** | Arabic, Persian, Urdu, Hebrew |
| **Privacy** | Fully offline, zero telemetry, no network calls |

---

## Supported languages

| Language | Script | Notes |
|---|---|---|
| Arabic | Arabic | Full shaping + ligatures |
| Persian / Farsi | Perso-Arabic | Additional letters: پ چ ژ گ |
| Urdu | Nastaliq subset | Additional letters: ٹ ڈ ڑ ں ھ ہ ی ے |
| Hebrew | Hebrew | Reversal only (Hebrew is already Unicode-encoded correctly) |

---

## Screenshots

<details>
<summary>Light theme</summary>

![Light theme](assets/screenshot-light.png)

</details>

<details>
<summary>Dark theme</summary>

![Dark theme](assets/screenshot-dark.png)

</details>

---

## Requirements

- Windows 10 or Windows 11
- No installation needed
- Arial font (installed on every Windows machine by default)

---

## Files in this repo

```
NassakhRTL.exe       ← download and run (single file)
NassakhRTL.ps1       ← full source code (C# embedded in PowerShell)
NassakhRTL.bat       ← alternative launcher (runs the .ps1 directly)
NassakhRTL.ico       ← app icon (all sizes)
assets/
  NassakhRTL-icon.svg
  NassakhRTL-logo.svg
  screenshot-light.png
  screenshot-dark.png
README.md
INSTRUCTIONS.md
CHANGELOG.md
CONTRIBUTING.md
LICENSE
```

---

## Build from source

If you want to build the `.exe` yourself from the `.ps1` source:

```powershell
# Install ps2exe (one time)
Install-Module -Name ps2exe -Scope CurrentUser -Force

# Build
Invoke-ps2exe -InputFile .\NassakhRTL.ps1 -OutputFile .\NassakhRTL.exe `
  -IconFile .\NassakhRTL.ico -NoConsole -STA `
  -title "NassakhRTL" -product "NassakhRTL" `
  -description "RTL Text Fixer for Affinity" `
  -company "Talha bin Munir" -version "1.0.0.0"
```

---

## Author

**Talha bin Munir**
tlhmunir@gmail.com
[github.com/talhabinmunir](https://github.com/talhabinmunir)
[youtube.com/@Talhabinmuneer](https://www.youtube.com/@Talhabinmuneer)

---

## License

MIT — free to use, modify, and distribute. See [LICENSE](LICENSE).
