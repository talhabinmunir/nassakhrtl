# Contributing to NassakhRTL

Thank you for your interest in contributing. NassakhRTL is a small focused tool — contributions that keep it that way are most welcome.

---

## What to contribute

**Most useful:**
- Bug reports with a minimal reproduction (paste the text that broke, screenshot of result)
- Missing Arabic/Persian/Urdu letter forms — if a letter shapes incorrectly, open an issue with the Unicode codepoint(s)
- Hebrew-specific improvements
- Windows version compatibility reports (older Windows 10 builds, non-English Windows)

**Also welcome:**
- Corrected Unicode name table entries
- Documentation improvements
- Translations of the README or INSTRUCTIONS into Arabic, Hebrew, Urdu, or Persian

**Not in scope for v1:**
- Plugin systems, server modes, or network features
- Changing the delivery format from .ps1/.bat
- Auto-updating mechanisms

---

## Reporting a bug

Open an issue at [github.com/talhabinmunir/nassakhrtl/issues](https://github.com/talhabinmunir/nassakhrtl/issues) and include:

1. Windows version (Win + R → `winver`)
2. PowerShell version (`$PSVersionTable.PSVersion` in a PowerShell window)
3. The text that caused the problem (or a description if it is sensitive)
4. What you expected to see vs what you got
5. A screenshot if relevant

---

## Making a code change

The entire application is in three files:

| File | Contents |
|---|---|
| `NassakhRTL.ps1` | Everything: PowerShell launcher + embedded C# source |
| `NassakhRTL.bat` | One-line launcher |
| `assets/` | SVG logos (not compiled — embedded at build time) |

The C# source inside `NassakhRTL.ps1` is between the lines:

```
$source = @'
...
'@
```

### Making and testing a change

1. Edit the C# inside the `@' '@ ` block.
2. Run from a PowerShell window to see errors immediately:
   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -STA -File NassakhRTL.ps1
   ```
3. Test with Arabic text, mixed Arabic + Latin, Hebrew, and Persian (especially ZWNJ usage).

### Style

- Conservative C# 5 only — no LINQ, no `var`, no generics beyond `Dictionary<>` and `List<>`, no lambda closures that capture loop variables, no `string.IsNullOrWhiteSpace` (use `.Trim().Length == 0`). This keeps the code compilable by the PowerShell 5.1 `Add-Type` compiler.
- All non-ASCII characters as `\uXXXX` escapes in C# strings — the file must remain pure ASCII.
- No external libraries, NuGet packages, or network calls.

---

## Questions

Email Talha bin Munir at tlhmunir@gmail.com or open a GitHub Discussion.
