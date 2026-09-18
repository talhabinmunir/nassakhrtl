# Releasing NassakhRTL

`NassakhRTL.exe` is gitignored on purpose, so nothing in git guarantees the
binary matches the source. This process does. **Run `release.ps1`; do not
hand-build.** It refuses to continue at the first thing that is wrong.

## The one command

```powershell
# from the repo root, on main, after the release PR is merged
powershell.exe -ExecutionPolicy Bypass -File .\release.ps1            # gate: tests, build, verify, smoke
powershell.exe -ExecutionPolicy Bypass -File .\release.ps1 -Publish   # + git tag + GitHub Release
```

The first form leaves nothing outside your machine. Run it as often as you
like. The second form is the release.

## What the script checks, in order

| # | Step | Fails when |
|---|------|------------|
| 1 | Repo state | not on `main`, working tree dirty, or `HEAD != origin/main` |
| 2 | Version | `App.Version` missing from `NassakhRTL.ps1`; a version hard-coded anywhere else in the source; tag `vX.Y.Z` already exists at a different commit |
| 3 | Docs | `CHANGELOG.md` has no `## [X.Y.Z]` entry; `README.md` badge is not `X.Y.Z` |
| 4 | Tests | `tests\run-all.ps1` is not green (currently 72 checks across 5 files) |
| 5 | Build | `ps2exe` missing or produces no exe |
| 6 | Verify | exe file-version resource is not `X.Y.Z.0`, or the script embedded in the exe does not carry `Version = "X.Y.Z"` — i.e. the binary was not built from this source |
| 7 | Smoke | another instance is running; no window within 60 s; the app did **not** register `Ctrl+Alt+R`; non-zero exit on close |
| 8 | Tag (`-Tag` / `-Publish`) | push fails |
| 9 | Publish (`-Publish`) | `gh` is not authenticated as `talhabinmunir`; release already exists |

Step 6 is the one that closes the gap this file exists for: an exe that says
2.0.2 cannot pass a gate whose source says 2.1.1.

## Where the version number lives

**One place:** `NassakhRTL.ps1`, the line

```csharp
public const string Version = "2.1.1";
```

Every UI string (title bar, version pill, sidebar, tray tooltip), the fix
report, the JSON export and the About dialog read `App.Version`. `release.ps1`
parses that line, passes it to `ps2exe -version`, and verifies the result.
`README.md` and `CHANGELOG.md` still contain the number, but the script
refuses to build if they disagree with the source.

## Cutting a release, start to finish

1. **Bump the version** in `NassakhRTL.ps1` (`App.Version`), the `README.md`
   badge, and add the `## [X.Y.Z] — YYYY-MM-DD` section to `CHANGELOG.md`.
   Do this in the PR that ships the change, not afterwards.
2. **Merge to `main`** and pull it locally.
3. **Run the gate:** `.\release.ps1`. Fix whatever it reports; re-run until
   `RELEASE GATE PASSED`.
4. **Publish:** `.\release.ps1 -Publish`. This tags `vX.Y.Z`, pushes the tag,
   and creates the GitHub Release with `NassakhRTL.exe` attached and the
   CHANGELOG section as the notes.
5. **Gumroad:** upload the same `NassakhRTL.exe` and update the version shown
   on the product page. (No API here; the script prints this reminder.)
6. **Check** `gh release view vX.Y.Z` shows the asset, and that downloading it
   and running it shows `vX.Y.Z` in the title bar.

## If you must build by hand

The script runs exactly this. Substitute the version from `App.Version`;
the four-part form is required by ps2exe.

```powershell
Install-Module -Name ps2exe -Scope CurrentUser -Force   # once
Invoke-ps2exe -InputFile .\NassakhRTL.ps1 -OutputFile .\NassakhRTL.exe `
  -IconFile .\NassakhRTL.ico -NoConsole -STA `
  -title "NassakhRTL" -product "NassakhRTL" `
  -description "RTL Text Fixer for Affinity" `
  -company "Talha bin Munir" -version "X.Y.Z.0"
```

Then confirm `(Get-Item .\NassakhRTL.exe).VersionInfo.FileVersion` prints
`X.Y.Z.0`. A hand build is what let a stale exe nearly ship twice; prefer the
script.

## Requirements

- Windows PowerShell 5.1 (`powershell.exe`). The script re-launches itself
  under 5.1 if started from PowerShell 7 — ps2exe and the test harness need it.
- `ps2exe` module, `git`, and for `-Publish` the `gh` CLI logged in as
  `talhabinmunir` (`gh auth status`).
- No NassakhRTL instance running: the smoke test proves the hotkeys register,
  and a running copy would hold them.
