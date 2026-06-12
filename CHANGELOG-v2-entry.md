## [2.0.0] — 2026-06-12

### In-Affinity text-box hotkeys (the headline)
- **Ctrl + Alt + F** — fix the text box you are typing in, inside Affinity, with one keypress:
  NassakhRTL selects the box content, converts it, and pastes it back automatically.
  Your previous clipboard text is preserved.
- **Ctrl + Alt + Z** — restore a converted text box back to normal editable text the same way.
- Safety built in: if no text is captured, if the box has no RTL text, or if it is already
  converted, **nothing is pasted and nothing changes** — you get a notification instead.
- Why not fully automatic "fix while typing": converted text cannot be edited incrementally;
  any auto-fix that fires while you keep typing corrupts the text box. The hotkey gives the
  same speed with you in control. (Full assessment in the repo discussion.)

### Files tab — SVG / TXT editor
- Open or drop an exported `.svg` or `.txt` file; all RTL text items are listed with
  layer/element names and per-item change counts
- Side-by-side review: original (Windows rendering) vs fixed (Affinity-accurate preview)
- Approve items individually or all at once
- **Apply → Save As** (source never touched) or **Apply → Overwrite** (a `.bak` of the
  original is always kept)
- Exportable fix report for client sign-off
- Note: native `.afdesign` editing is not offered — the format has no public specification
  and writing it blind risks corrupting client files. The supported round trip is
  Affinity → Export SVG ("Text as text") → fix → open fixed SVG in Affinity.

### Folder Watcher tab
- Watch a project folder; new or changed `.txt` / `.svg` exports are fixed automatically
- Keeps a `.bak` of every original (on by default)
- Skips non-RTL files and already-converted files; never double-converts; ignores its own writes
- Activity log + tray notifications; resumes automatically on next launch if it was on

### System tray
- Minimize to tray; tray menu: open window, fix clipboard, toggle watcher, exit
- Balloon notifications for hotkey results and watcher activity

### Zero regression
- The entire v1 Quick Fix tab — engine, options, presets, history, import/export,
  Ctrl+Alt+R, Ctrl+Enter, Ctrl+Shift+V — is unchanged and re-verified against the
  v1 test expectations (28/28 tests pass, including live watcher file-event tests).
