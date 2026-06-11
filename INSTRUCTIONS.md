# NassakhRTL — Instructions

Full usage guide for **NassakhRTL 1.0**

---

## Contents

1. [Setup](#1-setup)
2. [Basic workflow](#2-basic-workflow)
3. [The Affinity Preview panel](#3-the-affinity-preview-panel)
4. [Options explained](#4-options-explained)
5. [Hotkey and keyboard shortcuts](#5-hotkey-and-keyboard-shortcuts)
6. [Presets](#6-presets)
7. [History](#7-history)
8. [Import and export](#8-import-and-export)
9. [Restoring Affinity text](#9-restoring-affinity-text)
10. [Settings and themes](#10-settings-and-themes)
11. [Running on startup](#11-running-on-startup)
12. [Troubleshooting](#12-troubleshooting)

---

## 1. Setup

1. Download `NassakhRTL.bat` and `NassakhRTL.ps1`.
2. Put both files in the same folder — for example `C:\Tools\NassakhRTL\`.
3. Double-click `NassakhRTL.bat`.

The app opens as a small always-on-top window. It compiles itself on first launch using PowerShell's built-in C# compiler, which takes 3–5 seconds. Subsequent launches are the same speed.

### SmartScreen warning

Windows may show a blue "Windows protected your PC" dialog. This appears for any new, unsigned executable. Click **More info**, then **Run anyway**. You can inspect the full source code in `NassakhRTL.ps1` before running.

---

## 2. Basic workflow

### Option A — Global hotkey (recommended)

This is the fastest method. No window switching required.

1. Keep NassakhRTL open (minimized is fine).
2. In any application, select and copy RTL text (Ctrl + C).
3. Press **Ctrl + Alt + R** — you will hear a chime.
4. Switch to Affinity and paste (Ctrl + V).

The clipboard is converted in place. You never need to touch the NassakhRTL window.

### Option B — App window

1. Paste your text into the **Input** box (it supports Arabic right-to-left display).
2. Watch the **Affinity Preview** panel update in real time.
3. Click **⚡ Convert + Copy**.
4. Paste into Affinity.

### Option C — Paste and fix shortcut

1. Copy RTL text from anywhere.
2. Press **Ctrl + Shift + V** while NassakhRTL is focused — this pastes the text into the input box and immediately converts it.
3. Paste into Affinity.

---

## 3. The Affinity Preview panel

The preview panel below the input box does not use a bidi rendering engine. It draws each glyph individually from left to right — exactly how Affinity renders text. What you see in the preview is exactly what you will see after pasting into Affinity.

### Character inspector

Click any letter in the preview panel to inspect it. The inspector bar shows:

- **Unicode codepoint** — e.g. `U+FE91`
- **Unicode name** — e.g. `ARABIC LETTER BEH INITIAL FORM`
- **Source letter** — e.g. `[from ب]`

This is useful when debugging why a specific character looks wrong, or for client documentation.

---

## 4. Options explained

| Option | Default | What it does |
|---|---|---|
| **Arabic digits → 0-9** | On | Converts ٠١٢٣٤٥٦٧٨٩ (Arabic-Indic) and ۰۱۲۳۴۵۶۷۸۹ (Persian) to Western digits. Also converts ٪ to %. |
| **Remove hidden characters** | On | Strips zero-width space (ZWSP), byte-order mark (BOM), left-to-right mark (LRM), and Unicode direction controls (RLO, LRE, etc.) that are invisible but corrupt visual order. |
| **Remove diacritics** | Off | Strips Arabic harakat (fatha, kasra, damma, shadda, tanwin, sukun) and Hebrew niqqud. Turn on when the receiving font does not support diacritics or when you want plain text. |
| **Remove tatweel** | Off | Strips the Arabic elongation mark ـ (U+0640). Some typefaces render it incorrectly in visual-order mode. |
| **، ؛ ؟ → Latin , ; ?** | Off | Replaces Arabic punctuation with Latin equivalents. Useful when the Affinity text frame uses a Latin font. |
| **Unify alef أ إ آ → ا** | Off | Normalizes all alef variants to bare alef. **Changes spelling** — only use for specific typography use cases, not for published text. |
| **ى → ي and ة → ه** | Off | Normalizes ya and ta marbuta variants. **Changes spelling** — same caveat as above. |
| **Stay on top** | On | Keeps the NassakhRTL window above all other windows. Uncheck if it gets in the way of other apps. |

Options are saved automatically when you close the app.

---

## 5. Hotkey and keyboard shortcuts

| Shortcut | Where | Action |
|---|---|---|
| **Ctrl + Alt + R** | Anywhere (global) | Fix clipboard — converts whatever text is copied, with a chime confirmation |
| **Ctrl + Enter** | NassakhRTL window | Convert + Copy |
| **Ctrl + Shift + V** | NassakhRTL window | Paste clipboard text and immediately convert |

### If Ctrl + Alt + R is not working

Another app on your system has registered the same hotkey. The NassakhRTL status bar will say "Hotkey Ctrl+Alt+R not available". The buttons and in-window shortcuts still work.

---

## 6. Presets

Presets save your current option settings under a name. Useful when you work with multiple clients or languages that need different configurations.

**Saving a preset:**

1. Set the options the way you want them.
2. Click the **+** button next to the Preset dropdown.
3. Type a name and click OK.

**Loading a preset:**

Select it from the Preset dropdown — options update immediately.

**Deleting a preset:**

Select it from the dropdown, then click **−**.

**Examples of useful presets:**

- `Arabic Standard` — digits on, diacritics off, all else off
- `Arabic With Harakat` — digits on, diacritics off (keep them), all else off
- `Hebrew` — all Arabic options off
- `Urdu Print` — digits on, tatweel removed

---

## 7. History

The History dropdown shows your last 10 conversions. Each entry shows the time and a preview of the original text.

Select any entry to reload the original text into the input box and re-run the conversion with current settings.

History is session-only — it resets when you close the app.

---

## 8. Import and export

### Import

Click **Import** to open a .txt, .csv, or .json file. The file content loads into the input box. You can also drag and drop a .txt file directly onto the app window or the input box.

### Export

Click **Export** for three options:

**Copy converted text** — same as Convert + Copy.

**Save as .txt** — saves the converted text as a UTF-8 plain text file.

**Save as .json** — saves a record with:
- App name and version
- Timestamp
- Options used (as a compact bit string)
- Original text
- Converted text

The JSON export is useful for client documentation — it records exactly what was changed and when.

---

## 9. Restoring Affinity text

If you have text that was already converted (visual-order, presentation-form glyphs) and need the normal editable version back:

1. Copy the converted text.
2. Click **↩ Restore**.
3. The clipboard is restored to normal logical text and loaded into the input box.

This works because the conversion is reversible: every presentation-form glyph maps back to its base letter, and line reversal is its own inverse.

---

## 10. Settings and themes

### Theme

Click the **☽ / ☀** button in the header to toggle dark and light mode. The choice is saved and restored on next launch.

### Settings file

All settings are stored in:

```
%APPDATA%\NassakhRTL\settings.ini
```

You can open this file in Notepad. Format:

```ini
theme=dark
opts=1100000
top=1
win=200,100,580,720
preset.Arabic Standard=1100000
preset.Urdu Print=1101000
```

The `opts` field is a 7-character bit string corresponding to the 7 checkboxes in order: digits, remove hidden, remove diacritics, remove tatweel, punctuation to Latin, unify alef, normalize ya/ta.

To reset all settings, delete the file or the folder.

---

## 11. Running on startup

To have NassakhRTL open automatically with Windows:

1. Press **Win + R**, type `shell:startup`, press Enter.
2. In the Startup folder that opens, right-click → **New → Shortcut**.
3. Browse to `NassakhRTL.bat` and click Finish.

NassakhRTL will now open every time you log in, sitting quietly in the background ready for the hotkey.

---

## 12. Troubleshooting

**The app does not open when I double-click the .bat**

Right-click `NassakhRTL.ps1` → **Run with PowerShell**. Any error message will appear in the console window. Copy the error and email it to tlhmunir@gmail.com.

**PowerShell says "running scripts is disabled"**

Your system's execution policy blocks PowerShell scripts. Run this once in PowerShell as Administrator:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Then try again.

**Text pastes into Affinity but still looks broken**

Make sure the text frame in Affinity uses a font that contains Arabic glyphs. Arial works reliably. If you are using a decorative or Latin-only font, the glyphs will show as boxes. Switch the frame font to Arial, paste, then change the font if needed — the glyphs will re-render.

**The hotkey Ctrl + Alt + R does not work**

Another application has claimed that hotkey combination. Use the **Fix clipboard** button or the **Ctrl + Shift + V** shortcut instead.

**Converted text shows boxes in the preview panel but not in Affinity**

The preview panel in NassakhRTL uses Arial. If your system's Arial font is missing or corrupted, glyphs may show as boxes in the preview but still paste correctly. Reinstalling Arial from Microsoft's website fixes this.

**Persian ZWNJ (نیم‌فاصله) — does NassakhRTL handle it?**

Yes. ZWNJ (Zero-Width Non-Joiner) is used in Persian to break letter joining intentionally, as in می‌خواهم. NassakhRTL applies ZWNJ during shaping (so joining breaks correctly) and removes it afterward (so it does not interfere with visual order in Affinity). The result is correct non-joined forms.

---

## Contact

**Talha bin Munir**
tlhmunir@gmail.com
[github.com/talhabinmunir/nassakhrtl](https://github.com/talhabinmunir/nassakhrtl)

Bug reports and feature requests: [open an issue](https://github.com/talhabinmunir/nassakhrtl/issues)
