# Changelog

All notable changes to NassakhRTL are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [2.1] — 2026-08-04

### Changed

- **Full UI redesign.** The three-tab window is replaced by a three-column
  dashboard: left sidebar navigation, main content area, and a right statistics
  panel. Card-based visual language built on the logo's teal `#1E9B8C` — rounded
  cards with soft shadows, pill-shaped buttons, custom-drawn checkboxes, toggles
  and donut stat rings, all painted with GDI+ so the app stays a single
  dependency-free script.
- Window is now 1120x736 by default (minimum 1000x680). Saved window bounds from
  2.0.x are clamped to the new minimum on first run.
- Layout rows now reflow: option and action rows wrap to a second line instead of
  running off the edge when the window is at its minimum width.

### Added

- **History page** — the last 10 conversions with original/converted previews,
  "Send to Quick Fix", and "Copy converted". Replaces the old dropdown.
- **Settings page** — cleanup and normalisation options, presets, and the theme
  toggle, collected out of the cramped inline Options box.
- **Statistics panel** — characters fixed, files processed, and text items fixed
  this session, drawn as donut rings, plus a Live Mode toggle and rotating tips.
- Status bar showing the last action, character count, and watcher mode.
- Tooltips on every icon-only control; all custom controls are tab-navigable
  with visible focus rings and Space/Enter activation.

### Fixed

- **Presets did not round-trip the paragraph break width.** `ToBits` only
  serialised the 7 boolean flags, so loading a preset silently left the wrap
  setting at whatever was currently on screen. The width is now appended as
  `:N`; 2.0.x settings files with a bare 7-character string still load.
- **"Stay on top" could disagree with the window.** Settings load before the
  handler is attached, so a restored value of off left `TopMost` on.

### Accessibility

- The accent is split into three roles so contrast holds without abandoning the
  brand colour. `#1E9B8C` on white is 3.43:1 — enough for non-text marks (WCAG
  1.4.11 needs 3:1) but short of the 4.5:1 AA floor for text sitting on it. So
  the brand teal is used for graphics (donut rings, toggle and checkbox fills,
  focus rings, outlines), a deepened `#17786C` backs primary buttons so a white
  label reads at 5.33:1, and `#136B62` is used for accent-coloured text.
- Dark mode lifts the accent to `#2BBBA9` and puts dark ink on it rather than
  white, which would have been 2.4:1.
- All 60 foreground/background pairs across both themes were measured against
  the shipped `Theme` values: text ≥ 4.5:1, non-text UI ≥ 3:1.

### Notes

- The "never wrap inside SVG text nodes" rule is now asserted explicitly in
  `RtlFile.Recompute` rather than relying on `ToBits` dropping the width.
- Verified: 4/10/50-line blocks keep their input line order; SVG round-trip
  preserves attributes, structure, XML declaration and leaves the source
  untouched; legacy settings files still parse. Startup ~3s from the .exe.
- Known: list and log selection still use the Windows system highlight blue
  rather than the brand teal. Recolouring it needs owner-draw on a checkbox
  `ListView`, which is a behaviour change rather than a colour change.

---

## [2.0.2] — 2026-06-12

### Fixed

- **Long paragraphs appeared with inverted line order in Affinity after Ctrl+Alt+F
  (and after Ctrl+Alt+R with manual paste — same root cause).** A wrapping paragraph
  is one logical line; converting it produces one long visual-order string, and when
  Affinity re-wraps that string the first chunk on line 1 is the reversed END of the
  text — so the paragraph reads bottom-to-top. This is inherent to visual-order text:
  line breaks must be fixed BEFORE conversion.

### Added

- New option, on by default: **"Break long paragraphs into lines of [N] chars"**
  (default 70, range 20–200). Long lines are hard-broken at word boundaries before
  conversion, so every line is independently correct and reading order is preserved.
  Applies to Quick Fix, Ctrl+Alt+R, and Ctrl+Alt+F. Never applied inside SVG text
  nodes (their positioning is absolute).
- Usage notes: set paragraph alignment to RIGHT in Affinity for multi-line text;
  if a line still re-wraps in a narrow frame, reduce N.

### Verified

- 45/45 tests pass, including: first output line holds the START of the text, last
  line holds the END, restore+rejoin is lossless, oversized single words hard-cut
  without loss, wrapping excluded from SVG file editing.
- The exact demo paragraph from the bug report (561 letters) rendered in a
  bidi-disabled Affinity emulation reads top-to-bottom identically to the reference.

---

## [2.0.1] — 2026-06-12

### Fixed

- **Quick Fix tab controls invisible on Windows.** All v1 controls (options checkboxes,
  Convert + Copy, Fix clipboard, Restore, presets, history, status) were positioned using
  bottom-anchoring against an estimated tab size; on Windows, tab pages start at a tiny
  default size before first layout, so every bottom-anchored control landed below the
  visible window. Layout is now computed explicitly from the live page size on every
  resize — deterministic on all Windows versions.
- **Raw SVG markup could be converted as plain text and pasted into Affinity as literal
  XML.** The Files tab always wrote correct XML, but the plain-text paths (Import button,
  pasting a whole file into the input box, clipboard hotkeys) accepted markup. Now:
  - Importing or pasting SVG/XML content into Quick Fix automatically routes it to the
    Files tab, where only text content inside `<text>` elements is fixed
  - Convert + Copy, Ctrl+Alt+R, and Ctrl+Alt+F refuse markup with a clear message —
    nothing is converted, nothing is pasted

### Added

- **Copy fixed text** button on the Files tab — copies ONLY the selected item's corrected
  plain text to the clipboard for pasting into an Affinity text box. Never copies markup.
- Files tab footer now states exactly what each save action does (Save As = new file,
  Overwrite = .bak kept, Copy fixed text = text only).
- SVG saves now preserve the source file's exact `<?xml ...?>` declaration so fixed files
  diff cleanly against originals.

### Verified

- 36/36 tests pass, including two new guarantees requested in the bug report:
  a no-change save is **byte-identical** to the input file, and a fixed file differs
  from the input **only at the text node values** — all attributes, transforms, and
  styles untouched.

---

## [2.0.0] — 2026-06-12

### In-Affinity text-box hotkeys (headline feature)

- **Ctrl + Alt + F** — fix the Affinity text box you are typing in, with one keypress.
  NassakhRTL selects the box content, converts it, and pastes it back automatically.
  Your previous clipboard is preserved.
- **Ctrl + Alt + Z** — restore a converted text box back to normal editable text.
- Safety: if no text is captured, if the box has no RTL text, or if it is already
  converted — nothing is pasted and nothing changes. A tray notification explains why.
- Why not fully automatic "fix while typing": converted text cannot be edited incrementally.
  Any auto-fix firing while the user keeps typing corrupts the text box. The hotkey gives
  the same speed with the user in control. Full assessment in the repo discussion thread.

### Files tab — SVG / TXT editor

- Open or drop an exported `.svg` or `.txt` file
- Lists every RTL text item with element/layer name and change count
- Side-by-side review: original (Windows rendering) vs fixed (Affinity-accurate preview)
- Approve items individually or all at once via checkboxes
- **Apply → Save As** — source file is never touched
- **Apply → Overwrite** — overwrites source with a `.bak` copy always kept first
- Exportable fix report (.txt) for client sign-off
- Note: native `.afdesign` editing is not offered — the format has no public specification
  and writing it without a spec risks corrupting client files. Supported round-trip:
  Affinity → Export SVG (Text as text) → fix in NassakhRTL → open fixed SVG in Affinity.

### Folder Watcher tab

- Watch a project folder for new or changed `.txt` / `.svg` exports
- Fixes RTL text automatically in the background
- Always keeps a `.bak` of the original (configurable)
- Skips non-RTL files and already-converted files silently
- Never double-converts; ignores its own writes
- Activity log + tray balloon notifications
- Watcher state and folder are persisted — resumes on next launch if it was running

### System tray

- App minimizes to tray (window close still exits; use tray → Exit to fully quit)
- Tray menu: open window, fix clipboard, toggle watcher on/off, exit
- Balloon notifications for all hotkey results and watcher activity

### Other improvements

- Third global hotkey added: Ctrl + Alt + Z (restore active text box)
- Settings persistence extended: watcher folder, watcher state, bak preference
- Fix report export added to Files tab
- About dialog updated to v2.0

### Zero regression

All v1 Quick Fix tab functionality — engine, options, presets, history, import/export,
Ctrl+Alt+R, Ctrl+Enter, Ctrl+Shift+V — is unchanged and re-verified.
28/28 tests pass including live watcher file-event tests.

---

## [1.0.0] — 2026-06-11

### First public release

**Core engine**
- Arabic text shaping: all 36 base Arabic letters with isolated, initial, medial, and final contextual forms
- Lam-alef ligatures: لا لأ لإ لآ
- Persian / Farsi extended letters: پ چ ژ گ and others
- Urdu extended letters: ٹ ڈ ڑ ں ھ ہ ی ے
- Hebrew: correct visual reversal (no shaping needed)
- Visual reorder: each line reversed into LTR visual order; Latin runs stay in place; bracket mirroring
- ZWNJ-aware shaping: Zero-Width Non-Joiner applied during shaping then removed
- Round-trip restore: every conversion is reversible back to original logical text

**Text normalisation options**
- Arabic-Indic and Persian-Indic digits → Western 0-9
- Arabic percent sign ٪ → %
- Hidden / zero-width character removal (ZWSP, BOM, LRM, RLM, direction controls)
- Diacritic removal: Arabic harakat + Hebrew niqqud (optional)
- Tatweel ـ removal (optional)
- Arabic punctuation → Latin ، ; ؟ → , ; ? (optional)
- Alef unification أ إ آ → ا (optional, labeled changes spelling)
- Ya / ta marbuta normalisation ى ة (optional, labeled changes spelling)

**UI**
- Affinity Preview panel: bidi-disabled LTR glyph rendering matching Affinity exactly
- Character inspector: click any glyph to see Unicode codepoint, official name, and source letter
- Real-time preview with 160 ms debounce
- Dark and light theme, persistent
- NassakhRTL logo and icon embedded
- Drag-and-drop .txt files
- File import (.txt, .csv, .json) and export (.txt, .json with metadata)
- Named presets, session history
- Settings persistence

**Shortcuts**
- Global hotkey Ctrl + Alt + R: fix clipboard from any application
- Ctrl + Enter: Convert + Copy
- Ctrl + Shift + V: paste-and-fix

---

## Roadmap

- v2.1: font compatibility checker (warn if Affinity text frame font lacks Arabic glyphs)
- v2.1: batch processing queue for multiple text blocks
- v2.2: self-contained .exe built with .NET SDK (eliminates ps2exe dependency)
- Future: native .afdesign support if Serif publishes the file format specification
