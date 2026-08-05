# NassakhRTL — Instructions

Full usage guide for **NassakhRTL 2.0**

---

## Contents

1. [Setup](#1-setup)
2. [Fix text inside Affinity — Ctrl+Alt+F](#2-fix-text-inside-affinity--ctrlaltf)
3. [Classic clipboard workflow](#3-classic-clipboard-workflow)
4. [The Affinity Preview panel](#4-the-affinity-preview-panel)
5. [Files page — SVG and TXT editor](#5-files-page--svg-and-txt-editor)
6. [Folder Watcher](#6-folder-watcher)
7. [System tray](#7-system-tray)
8. [Options explained](#8-options-explained)
9. [Hotkeys and keyboard shortcuts](#9-hotkeys-and-keyboard-shortcuts)
10. [Presets](#10-presets)
11. [History](#11-history)
12. [Import and export](#12-import-and-export)
13. [Restoring converted text](#13-restoring-converted-text)
14. [Settings and themes](#14-settings-and-themes)
15. [Running on startup](#15-running-on-startup)
16. [Troubleshooting](#16-troubleshooting)

---

## 1. Setup

1. Download `NassakhRTL.exe` (or `NassakhRTL.bat` + `NassakhRTL.ps1` if you prefer source).
2. Put the file(s) in any folder, e.g. `C:\Tools\NassakhRTL\`.
3. Double-click `NassakhRTL.exe` to launch.

The app opens and an icon appears in your system tray. Minimize the window — NassakhRTL keeps running in the background.

### SmartScreen warning

Windows may show "Windows protected your PC." Click **More info → Run anyway.** This appears for any new unsigned executable. The full source code is in `NassakhRTL.ps1`.

---

## 2. Fix text inside Affinity — Ctrl+Alt+F

This is the v2 headline feature. No copy-paste needed.

**Workflow:**

1. In Affinity, double-click a text frame to enter text editing mode.
2. Type or paste your Arabic, Urdu, Persian, or Hebrew text normally.
3. Press **Ctrl + Alt + F** (release the keys fully before pressing F).
4. NassakhRTL selects all text in the box, converts it, and pastes it back.
5. You will hear a chime and see a tray notification confirming the fix.

**Safety behaviour:**

- If the text box has no RTL text — nothing is changed, notification says why.
- If the text box is already converted — nothing is changed.
- If the selection fails (e.g. you pressed the hotkey on the canvas, not inside a text box) — nothing is pasted, notification explains.
- Your clipboard before pressing the hotkey is always restored afterward.

**Restoring a converted text box for re-editing:**

Press **Ctrl + Alt + Z** while in the converted text box. NassakhRTL restores it to normal logical text so you can edit it again. When done editing, press Ctrl + Alt + F again.

**Important:** Press the hotkey only after you have finished typing. The conversion changes the letter forms — typing more characters after a conversion will insert them in the wrong position.

**Long paragraphs (multi-line text):**

A paragraph that wraps across several lines needs hard line breaks before conversion — otherwise Affinity re-wraps the converted text and the lines come out in reverse order (last sentence on top). NassakhRTL handles this automatically: the option **"Break long paragraphs into lines of [70] chars"** is on by default.

For best results with paragraphs:
1. Set the Affinity paragraph alignment to **Right** (converted Arabic lines should align right).
2. Make the text frame wide enough for 70-character lines at your font size — or lower the number to match a narrower frame.
3. If one line still wraps inside the frame, reduce the character count and run Ctrl+Alt+Z then Ctrl+Alt+F again.

---

## 3. Classic clipboard workflow

This is the v1 method. Still works exactly the same.

1. Copy RTL text from anywhere (Ctrl + C).
2. Press **Ctrl + Alt + R** — you will hear a chime.
3. Switch to Affinity and paste (Ctrl + V).

Or use the app window:
1. Paste text into the Input box.
2. Check the Affinity Preview panel.
3. Click **Convert + Copy**.
4. Paste into Affinity.

---

## 4. The Affinity Preview panel

The preview panel draws each glyph left-to-right with no bidi engine — exactly how Affinity renders text. What you see in the preview is exactly what you will see after pasting into Affinity.

**Character inspector:** Click any letter in the preview panel to see its Unicode codepoint, official name, and the base letter it came from.

---

## 5. Files page — SVG and TXT editor

Use this when you want to fix a whole exported file — not just one text box.

**Affinity export step (do this first in Affinity):**

Go to **File → Export → SVG**. In the SVG options, make sure **Text** is set to **"As text"** (not "As curves"). This keeps text as editable XML that NassakhRTL can read.

**In NassakhRTL:**

1. Click **Files (SVG / TXT)** in the left sidebar.
2. Click **Open SVG / TXT...** or drag and drop a file onto the window.
3. The list shows every RTL text item found — with element name and change count.
4. Click any item to see the original and fixed versions in the panels below.
5. Tick or untick items to include or exclude them from the fix.
6. Click **Check all** or **Uncheck all** for bulk selection.

**Saving:**

- **Apply → Save As** — saves a new file; your original is never touched.
- **Apply → Overwrite (.bak kept)** — overwrites the source file but saves a `.bak` copy next to it first. A confirmation dialog appears before this runs.

**Fix report:**

Click **Export fix report** to save a plain text record of every item, the change count, original text, and fixed text. Useful for client approval sign-off.

**After saving:**

Open the fixed SVG back in Affinity via **File → Place** or **File → Open**. The text will render correctly.

**Note about fixed SVGs in browsers:** The converted text inside the SVG is in visual order for a left-to-right renderer. If you open the fixed SVG in Chrome or Firefox it will look reversed — this is correct. It is designed for Affinity, not browsers.

---

## 6. Folder Watcher

Automates the fix for whole projects. Once set up, every file you export from Affinity is fixed automatically.

**Setup:**

1. Click **Folder Watcher** in the left sidebar.
2. Click **Browse** and select your project export folder.
3. Leave **Keep a .bak copy** checked (recommended).
4. Click **Start watching**.

**What happens:**

When you export a `.txt` or `.svg` from Affinity into that folder, NassakhRTL detects it within 1 second, fixes it, keeps a `.bak` of the original, logs the action, and shows a tray notification.

**Smart skipping:**

- Files with no RTL text are left untouched (silently).
- Files that are already in Affinity visual-order format are skipped.
- NassakhRTL ignores files it just wrote itself to prevent double-conversion.

**Stopping and resuming:**

Click **Stop watching** to pause. If the watcher was running when you closed the app, it restarts automatically on next launch.

---

## 7. System tray

NassakhRTL runs in the system tray when minimized. Right-click the tray icon for:

- **Open NassakhRTL** — bring the window back
- **Fix clipboard now** — same as Ctrl+Alt+R
- **Folder watcher** — toggle on/off without opening the window
- **Exit** — fully close the app

When the watcher fixes a file or a hotkey runs, a balloon notification appears. These disappear automatically after 2.5 seconds.

---

## 8. Options explained

The two most-used options sit under the Quick Fix input; the rest live on the **Settings** page. They apply to all conversion modes — clipboard, hotkeys, file editor, and watcher.

| Option | Default | What it does |
|---|---|---|
| **Arabic digits → 0-9** | On | Converts ٠١٢٣٤٥٦٧٨٩ and ۰۱۲۳۴۵۶۷۸۹ to Western digits. Also converts ٪ to %. |
| **Remove hidden characters** | On | Strips ZWSP, BOM, LRM, and Unicode direction controls. |
| **Remove diacritics** | Off | Strips Arabic harakat and Hebrew niqqud. |
| **Remove tatweel** | Off | Strips the Arabic elongation mark ـ. |
| **، ؛ ؟ → Latin , ; ?** | Off | Replaces Arabic punctuation with Latin equivalents. |
| **Unify alef أ إ آ → ا** | Off | Normalizes alef variants. **Changes spelling.** |
| **ى → ي and ة → ه** | Off | Normalizes ya and ta marbuta variants. **Changes spelling.** |
| **Stay on top** | On | Window stays above all other windows. |

---

## 9. Hotkeys and keyboard shortcuts

| Shortcut | Where | Action |
|---|---|---|
| **Ctrl + Alt + F** | Anywhere (global) | Fix the Affinity text box you are in |
| **Ctrl + Alt + Z** | Anywhere (global) | Restore the Affinity text box to editable text |
| **Ctrl + Alt + R** | Anywhere (global) | Fix the clipboard |
| **Ctrl + Enter** | NassakhRTL window | Convert + Copy |
| **Ctrl + Shift + V** | NassakhRTL window | Paste clipboard and immediately convert |

**If Ctrl+Alt+F does not work:**

Another app has registered that hotkey combination. The status bar will say the hotkey is not available. Use the window buttons or try Ctrl+Alt+R as a fallback.

**Timing note for Ctrl+Alt+F:**

Release Ctrl, Alt, and F fully before expecting the fix to run. NassakhRTL waits for the modifier keys to be released before sending any simulated keys, to prevent the hotkey chord from interfering with the text selection.

---

## 10. Presets

Save your current option settings under a name.

- Click **+** to save a preset. Give it a name.
- Select a preset from the dropdown to load it.
- Click **−** to delete the selected preset.

Useful when you work across clients who need different configurations — for example one client needs digits converted and diacritics kept, another needs diacritics stripped.

---

## 11. History

The **History** page in the sidebar shows your last 10 conversions, with the original and converted text side by side. Select an entry and click **Send to Quick Fix** to reload the original and re-run conversion with current settings, or **Copy converted** to put the fixed text back on the clipboard.

History is session-only — it clears when you close the app.

---

## 12. Import and export

**Import:** Click the Import button to open a `.txt`, `.csv`, or `.json` file into the Quick Fix input box. You can also drag and drop a `.txt` file onto the window.

**Export options (click Export button):**

- **Copy converted text** — same as Convert + Copy
- **Save as .txt** — saves the converted text as UTF-8 plain text
- **Save as .json** — saves a record with app version, timestamp, options used, original text, and converted text

---

## 13. Restoring converted text

If you need to edit text that is already in Affinity visual-order format:

**From an Affinity text box:** Press **Ctrl + Alt + Z** while in the box.

**From the clipboard:** Click **Restore Clipboard** on the Quick Fix page. The clipboard is restored to normal logical text.

**From the Files page:** Open the fixed SVG — the original text shows in the ORIGINAL panel. You can also keep the `.bak` file as a reference.

---

## 14. Settings and themes

**Theme:** Click the moon/sun icon in the header to toggle dark and light mode.

**Settings file:** `%APPDATA%\NassakhRTL\settings.ini`

Format:
```ini
theme=dark
opts=1100000
top=1
watchdir=C:\Projects\Client\exports
watchon=1
bak=1
win=200,100,640,760
preset.Arabic Standard=1100000
```

Delete the file to reset all settings.

---

## 15. Running on startup

1. Press **Win + R**, type `shell:startup`, press Enter.
2. Right-click in the Startup folder → **New → Shortcut**.
3. Browse to `NassakhRTL.exe` and click Finish.

NassakhRTL opens automatically on login. The window starts minimized to the tray, ready for hotkeys.

---

## 16. Troubleshooting

**App does not open when I double-click the .exe**

Right-click `NassakhRTL.ps1` → Run with PowerShell. Any error will appear in the console. Email the error to tlhmunir@gmail.com.

**PowerShell says "running scripts is disabled"**

Run once in PowerShell as Administrator:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Ctrl+Alt+F fires but the text box still looks broken after pasting**

The font in the Affinity text frame does not contain Arabic glyphs. Set the frame font to **Arial** first, paste, then switch fonts. The glyphs are correct; the font was the issue.

**Ctrl+Alt+F shows "No text captured"**

You pressed the hotkey while the cursor was on the Affinity canvas, not inside a text frame in text-editing mode. Double-click the text frame first, then press the hotkey.

**Fixed SVG looks backwards in my browser**

This is correct. The SVG text is in visual order for a left-to-right renderer (Affinity). Browsers have a proper bidi engine and render it reversed. Open it in Affinity — it will look correct.

**Watcher fixed a file I did not want fixed**

Check the `.bak` file next to the original — it contains the pre-fix version. Rename it to restore. In future, either stop the watcher before exporting files you want to keep as-is, or uncheck items on the Files page instead.

**Persian ZWNJ (نیم‌فاصله)**

NassakhRTL applies ZWNJ during shaping (so joining breaks correctly, e.g. می‌خواهم) and removes it afterward. The result is correct non-joined forms in Affinity.

---

## Contact

**Talha bin Munir**
tlhmunir@gmail.com
[github.com/talhabinmunir/nassakhrtl](https://github.com/talhabinmunir/nassakhrtl)

Bug reports and feature requests: [open an issue](https://github.com/talhabinmunir/nassakhrtl/issues)
