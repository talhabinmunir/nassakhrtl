# Changelog

All notable changes to NassakhRTL are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [1.0.0] — 2026-06-11

### First public release

**Core engine**
- Arabic text shaping: all 36 base Arabic letters with isolated, initial, medial, and final contextual forms
- Lam-alef ligatures: لا لأ لإ لآ
- Persian / Farsi extended letters: پ چ ژ گ and others
- Urdu extended letters: ٹ ڈ ڑ ں ھ ہ ی ے
- Hebrew: correct visual reversal (no shaping needed)
- Visual reorder: each line reversed into LTR visual order; Latin runs and numbers kept in original order; bracket mirroring
- ZWNJ-aware shaping: Zero-Width Non-Joiner is applied during shaping (to break joining in Persian correctly) then removed
- Round-trip restore: every conversion is reversible back to original logical text

**Text normalisation options**
- Arabic-Indic and Persian-Indic digits → Western 0-9
- Arabic percent sign ٪ → %
- Hidden / zero-width character removal (ZWSP, BOM, LRM, RLM, direction controls)
- Diacritic removal: Arabic harakat + Hebrew niqqud (optional, off by default)
- Tatweel ـ removal (optional, off by default)
- Arabic punctuation → Latin ، ; ؟ → , ; ? (optional)
- Alef unification أ إ آ → ا (optional, labeled "changes spelling")
- Ya / ta marbuta normalisation ى ة (optional, labeled "changes spelling")

**UI**
- Affinity Preview panel: bidi-disabled LTR glyph rendering matching Affinity exactly
- Character inspector: click any glyph to see Unicode codepoint, official name, and source letter
- Real-time preview with 160 ms debounce
- Dark and light theme, persistent
- NassakhRTL logo and icon embedded (no external assets needed)
- Drag-and-drop: .txt files onto app window or input box
- File import (.txt, .csv, .json)
- File export (.txt, .json with original + converted + metadata)
- Named presets: save, load, delete option configurations
- Session history: last 10 conversions
- Settings persistence: theme, options, presets, window position saved to `%APPDATA%\NassakhRTL\settings.ini`

**Shortcuts**
- Global hotkey Ctrl + Alt + R: fix clipboard from any application
- Ctrl + Enter: Convert + Copy
- Ctrl + Shift + V: paste-and-fix

**Technical**
- Zero dependencies: runs on any Windows 10/11 machine with PowerShell 5.1
- No installation required
- No network calls, no telemetry, fully offline
- Engine verified byte-identical to reference JavaScript implementation across 8 test cases
- 10 unit tests covering all option paths, ZWNJ shaping, round-trips, and the Unicode name inspector

---

## Roadmap

Planned for future versions:

- v1.1: system-tray mode (minimize to tray instead of taskbar)
- v1.1: font compatibility checker (detect if current Affinity font supports Arabic glyphs)
- v1.2: batch processing (convert a folder of .txt files)
- v1.2: fix statistics report exportable as PDF for client handoff
- v2.0: self-contained .exe (no PowerShell dependency)
