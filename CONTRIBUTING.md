# Contributing to NassakhRTL

Thank you for your interest. NassakhRTL is a small focused tool — contributions that keep it that way are most welcome.

---

## What to contribute

**Most useful:**
- Bug reports with a minimal reproduction (paste the text that broke, screenshot of result)
- Missing Arabic/Persian/Urdu letter forms — if a letter shapes incorrectly, open an issue with the Unicode codepoint(s)
- Hebrew-specific improvements
- SVG parsing edge cases — if a particular Affinity SVG export is not parsed correctly, attach the SVG
- Windows version compatibility reports (older Windows 10 builds, non-English Windows)

**Also welcome:**
- Corrected Unicode name table entries
- Documentation improvements
- Translations of the README or INSTRUCTIONS into Arabic, Hebrew, Urdu, or Persian

**Not in scope for v2:**
- Fully automatic "fix while typing" mode (see the v2 design notes in README — this is architecturally incompatible with visual-order converted text)
- Native .afdesign file writing (no public format spec; writing blind risks corrupting files)
- Server modes, telemetry, or network features

---

## Reporting a bug

Open an issue at [github.com/talhabinmunir/nassakhrtl/issues](https://github.com/talhabinmunir/nassakhrtl/issues) and include:

1. Windows version (Win + R → `winver`)
2. PowerShell version (`$PSVersionTable.PSVersion`)
3. Which feature failed: clipboard hotkey, Ctrl+Alt+F, Files tab, or Folder Watcher
4. The text that caused the problem (or describe it if sensitive)
5. What you expected vs what happened
6. A screenshot if relevant

---

## Source structure

The entire application is in these files:

| File | Contents |
|---|---|
| `NassakhRTL.ps1` | PowerShell launcher with all C# source embedded between `@' '@` |
| `NassakhRTL.bat` | One-line launcher |
| `assets/` | SVG logos (embedded at build time) |

The C# source inside `NassakhRTL.ps1` is structured as:

```
uninames.cs content    <- Unicode name table (578 entries)
assets.cs content      <- Base64 logo/icon assets
n2_common.cs content   <- Engine, RtlFile, WatcherCore, shared UI components
n2_main.cs content     <- MainForm (tabs, tray, hotkeys)
```

---

## Making and testing a change

1. Edit the relevant section inside the `@' '@` block in `NassakhRTL.ps1`.
2. Test by running:
   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -STA -File NassakhRTL.ps1
   ```
3. Test with Arabic text, Persian text with ZWNJ (می‌خواهم), Hebrew, and mixed Arabic+Latin.
4. Test the Ctrl+Alt+F hotkey inside Affinity with a real text frame.
5. Test the Files tab with an SVG exported from Affinity using "Text as text."
6. Test the Folder Watcher by dropping a new .txt file into the watched folder.

---

## Style rules

- Conservative C# 5 only — no LINQ, no `var`, no generic lambdas that capture loop variables, no `string.IsNullOrWhiteSpace`
- All non-ASCII characters as `\uXXXX` escapes in C# strings — the file must remain pure ASCII
- No external libraries, NuGet packages, or network calls
- File operations: always offer Save As or keep a `.bak` — never silently overwrite user files
- Hotkey actions: always check preconditions, always restore the clipboard, never paste if input is invalid

---

## Questions

Email Talha bin Munir at tlhmunir@gmail.com or open a GitHub Discussion.
