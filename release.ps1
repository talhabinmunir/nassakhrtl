<#
.SYNOPSIS
    One-command release gate for NassakhRTL. Refuses to proceed if anything
    is off, so a stale or mismatched NassakhRTL.exe cannot ship by accident.

.DESCRIPTION
    Runs, in order, and stops at the first failure with a non-zero exit:

      1. Repo state    - on main, working tree clean, HEAD == origin/main
      2. Version       - read App.Version from NassakhRTL.ps1 (the only place
                         it is written); tag vX.Y.Z must not already exist
      3. Consistency   - CHANGELOG has a "## [X.Y.Z]" entry, README badge
                         shows X.Y.Z
      4. Tests         - tests\run-all.ps1 must pass
      5. Build         - ps2exe with -version X.Y.Z.0
      6. Verify exe    - file version resource == X.Y.Z.0 AND the embedded
                         script carries Version = "X.Y.Z"
      7. Smoke test    - launch the exe on a clean process, wait for its
                         window, prove it registered Ctrl+Alt+R, close it,
                         expect exit code 0
      8. -Tag          - git tag -a vX.Y.Z and push it
      9. -Publish      - gh release create with the exe and the CHANGELOG
                         section as notes (implies -Tag)

    Gumroad upload stays manual; the script prints the reminder.

.EXAMPLE
    powershell.exe -ExecutionPolicy Bypass -File .\release.ps1
        Gate only: tests, build, verify, smoke. Nothing leaves the machine.

.EXAMPLE
    powershell.exe -ExecutionPolicy Bypass -File .\release.ps1 -Publish
        Everything, then tag + GitHub Release.
#>
[CmdletBinding()]
param(
    [switch]$Tag,
    [switch]$Publish,
    [switch]$SkipSmoke,
    [switch]$AllowBranch      # let the gate run on a non-main branch (no tag/publish)
)
$ErrorActionPreference = 'Stop'

# Windows PowerShell 5.1 only: ps2exe and the test harness need it.
if ($PSVersionTable.PSVersion.Major -gt 5) {
    $ps51 = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
    & $ps51 -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath @PSBoundParameters
    exit $LASTEXITCODE
}

$root = $PSScriptRoot
$ps1  = Join-Path $root 'NassakhRTL.ps1'
$exe  = Join-Path $root 'NassakhRTL.exe'
$ico  = Join-Path $root 'NassakhRTL.ico'
$step = 0

function Step([string]$title) { $script:step++; Write-Host ""; Write-Host ("[{0}] {1}" -f $script:step, $title) -ForegroundColor Cyan }
function Ok([string]$msg)     { Write-Host ("    ok   " + $msg) -ForegroundColor Green }
function Fail([string]$msg)   { Write-Host ""; Write-Host ("RELEASE BLOCKED: " + $msg) -ForegroundColor Red; exit 1 }

Push-Location $root
try {
    # ---------------------------------------------------------------- 1
    Step "Repository state"
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) { Fail "git not found on PATH" }
    $branch = (git rev-parse --abbrev-ref HEAD).Trim()
    if ($branch -ne 'main') {
        if ($AllowBranch -and -not ($Tag -or $Publish)) { Ok "on branch '$branch' (allowed for a dry gate)" }
        else { Fail "on branch '$branch', not main. Releases are cut from main only. (Use -AllowBranch for a dry gate.)" }
    } else { Ok "on main" }
    $dirty = git status --porcelain
    if ($dirty) { Fail "working tree is not clean:`n$dirty" }
    Ok "working tree clean"
    git fetch -q origin
    $local = (git rev-parse HEAD).Trim()
    # show-ref --quiet writes nothing to stderr; under ErrorActionPreference=Stop
    # a native command's stderr would otherwise become a terminating error
    git show-ref --verify --quiet ("refs/remotes/origin/" + $branch)
    if ($LASTEXITCODE -eq 0) {
        $remote = (git rev-parse ('origin/' + $branch)).Trim()
        if ($local -ne $remote) { Fail "HEAD ($($local.Substring(0,7))) != origin/$branch ($($remote.Substring(0,7))). Push or pull first." }
        Ok "HEAD == origin/$branch ($($local.Substring(0,7)))"
    } elseif ($branch -eq 'main') {
        Fail "origin/main not found after fetch"
    } else {
        Ok "branch '$branch' has no remote yet (dry gate, HEAD $($local.Substring(0,7)))"
    }

    # ---------------------------------------------------------------- 2
    Step "Version (single source of truth: App.Version in NassakhRTL.ps1)"
    $src = [IO.File]::ReadAllText($ps1)
    $m = [regex]::Match($src, 'public const string Version = "(\d+\.\d+\.\d+)";')
    if (-not $m.Success) { Fail "could not find 'public const string Version = ""X.Y.Z"";' in NassakhRTL.ps1" }
    $ver = $m.Groups[1].Value
    $ver4 = "$ver.0"
    $tagName = "v$ver"
    Ok "App.Version = $ver  (file version $ver4, tag $tagName)"
    $stray = [regex]::Matches($src, 'NassakhRTL \d+\.\d+(\.\d+)?"|"v\d+\.\d+|Version \d+\.\d+')
    if ($stray.Count -gt 0) { Fail "NassakhRTL.ps1 still hard-codes a version somewhere other than App.Version: " + (($stray | ForEach-Object { $_.Value }) -join ', ') }
    Ok "no other hard-coded version string in the source"
    # git prints nothing when the tag is absent; never call .Trim() on that
    $existing = [string](@(git tag --list $tagName) | Select-Object -First 1)
    if ($existing) {
        $tagSha = (git rev-list -n 1 $tagName).Trim()
        if ($tagSha -ne $local) { Fail "tag $tagName already exists at $($tagSha.Substring(0,7)), not at HEAD. Bump App.Version before releasing again." }
        Ok "tag $tagName already exists at HEAD (re-run after tagging is fine)"
    } else { Ok "tag $tagName not yet used" }

    # ---------------------------------------------------------------- 3
    Step "Docs agree with the version"
    $chg = [IO.File]::ReadAllText((Join-Path $root 'CHANGELOG.md'), [Text.Encoding]::UTF8)
    if ($chg -notmatch ('(?m)^## \[' + [regex]::Escape($ver) + '\]')) { Fail "CHANGELOG.md has no '## [$ver]' entry. Write the release notes first." }
    Ok "CHANGELOG.md has a [$ver] entry"
    $readme = [IO.File]::ReadAllText((Join-Path $root 'README.md'), [Text.Encoding]::UTF8)
    if ($readme -notmatch ('badge/Version-' + [regex]::Escape($ver) + '-')) { Fail "README.md version badge does not say $ver" }
    Ok "README.md badge says $ver"

    # ---------------------------------------------------------------- 4
    Step "Regression suite (tests\run-all.ps1)"
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File (Join-Path $root 'tests\run-all.ps1') | Out-Host
    if ($LASTEXITCODE -ne 0) { Fail "regression suite failed" }
    Ok "all test files passed"

    # ---------------------------------------------------------------- 5
    Step "Build NassakhRTL.exe with ps2exe"
    if (-not (Get-Module -ListAvailable -Name ps2exe)) { Fail "ps2exe module not installed. Run: Install-Module -Name ps2exe -Scope CurrentUser -Force" }
    Import-Module ps2exe
    if (Test-Path $exe) { Remove-Item $exe -Force }
    Invoke-ps2exe -InputFile $ps1 -OutputFile $exe -IconFile $ico -NoConsole -STA `
        -title 'NassakhRTL' -product 'NassakhRTL' -description 'RTL Text Fixer for Affinity' `
        -company 'Talha bin Munir' -version $ver4 | Out-Null
    if (-not (Test-Path $exe)) { Fail "ps2exe did not produce NassakhRTL.exe" }
    Ok ("built {0} ({1:N0} bytes)" -f (Split-Path $exe -Leaf), (Get-Item $exe).Length)

    # ---------------------------------------------------------------- 6
    Step "Verify the exe is this version"
    $fvi = [Diagnostics.FileVersionInfo]::GetVersionInfo($exe)
    if ($fvi.FileVersion -ne $ver4) { Fail "exe file version is '$($fvi.FileVersion)', expected '$ver4'" }
    Ok "file version resource = $($fvi.FileVersion)"
    $bytes = [IO.File]::ReadAllText($exe, [Text.Encoding]::Default)
    if ($bytes.IndexOf('Version = "' + $ver + '"') -lt 0) { Fail "embedded script inside the exe does not contain Version = ""$ver"" - the binary was not built from this source" }
    Ok "embedded script carries Version = ""$ver"""
    $ps1Time = (Get-Item $ps1).LastWriteTimeUtc; $exeTime = (Get-Item $exe).LastWriteTimeUtc
    if ($exeTime -lt $ps1Time) { Fail "exe is older than NassakhRTL.ps1" }
    Ok "exe is newer than the source"

    # ---------------------------------------------------------------- 7
    if ($SkipSmoke) { Step "Smoke test SKIPPED (-SkipSmoke)" }
    else {
        Step "Smoke test: launch on a clean process"
        $running = Get-Process -Name NassakhRTL -ErrorAction SilentlyContinue
        if ($running) { Fail "NassakhRTL.exe is already running (PID $($running.Id -join ', ')). Close it first; it would hold the hotkeys and mask the check." }
        $stale = Get-Process powershell -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -like 'NassakhRTL*' }
        if ($stale) { Fail "a NassakhRTL.ps1 instance is running (PID $($stale.Id -join ', ')). Close it first." }
        Add-Type -Namespace Rel -Name Hk -MemberDefinition @'
[DllImport("user32.dll", SetLastError=true)] public static extern bool RegisterHotKey(IntPtr h, int id, uint mods, uint vk);
[DllImport("user32.dll")] public static extern bool UnregisterHotKey(IntPtr h, int id);
'@
        $sw = [Diagnostics.Stopwatch]::StartNew()
        $proc = Start-Process $exe -PassThru
        $h = [IntPtr]::Zero
        while ($sw.Elapsed.TotalSeconds -lt 60) {
            Start-Sleep -Milliseconds 250; $proc.Refresh()
            if ($proc.HasExited) { Fail "exe exited during startup with code $($proc.ExitCode)" }
            if ($proc.MainWindowHandle -ne [IntPtr]::Zero) { $h = $proc.MainWindowHandle; break }
        }
        if ($h -eq [IntPtr]::Zero) { try { $proc.Kill() } catch {}; Fail "no main window within 60s" }
        Ok ("window up after {0:N1}s" -f $sw.Elapsed.TotalSeconds)
        Start-Sleep -Milliseconds 1500
        # If the app registered Ctrl+Alt+R globally, our own attempt must fail.
        $mine = [Rel.Hk]::RegisterHotKey([IntPtr]::Zero, 0x5A17, 0x0001 -bor 0x0002, 0x52)
        if ($mine) {
            [void][Rel.Hk]::UnregisterHotKey([IntPtr]::Zero, 0x5A17)
            try { $proc.CloseMainWindow() | Out-Null; $proc.WaitForExit(5000) | Out-Null } catch {}
            Fail "Ctrl+Alt+R was NOT registered by the app (this process could grab it)"
        }
        Ok "Ctrl+Alt+R is held by the app (global hotkeys registered)"
        [void]$proc.CloseMainWindow()
        if (-not $proc.WaitForExit(10000)) { try { $proc.Kill() } catch {}; Fail "exe did not exit within 10s of close" }
        if ($proc.ExitCode -ne 0) { Fail "exe exited with code $($proc.ExitCode)" }
        Ok "closed cleanly, exit code 0"
    }

    # ---------------------------------------------------------------- 8
    if ($Tag -or $Publish) {
        Step "Tag $tagName"
        if (-not $existing) {
            git tag -a $tagName -m "NassakhRTL $ver"
            git push -q origin $tagName
            Ok "tagged HEAD and pushed $tagName"
        } else { Ok "already tagged" }
    }

    # ---------------------------------------------------------------- 9
    if ($Publish) {
        Step "GitHub Release $tagName"
        if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { Fail "gh CLI not found" }
        $who = & { $ErrorActionPreference = 'Continue'; (gh api user -q .login 2>&1) | Select-Object -First 1 }
        if ("$who" -ne 'talhabinmunir') { Fail "gh is authenticated as '$who', not talhabinmunir. Run: gh auth switch --user talhabinmunir" }
        $sec = [regex]::Match($chg, '(?s)## \[' + [regex]::Escape($ver) + '\][^\n]*\n(.*?)(?=\n## \[|\z)').Groups[1].Value.Trim()
        $notes = Join-Path $env:TEMP "nassakh-notes-$ver.md"
        [IO.File]::WriteAllText($notes, $sec, (New-Object Text.UTF8Encoding($false)))
        & { $ErrorActionPreference = 'Continue'; gh release view $tagName 2>&1 | Out-Null }
        if ($LASTEXITCODE -eq 0) { Fail "release $tagName already exists on GitHub" }
        gh release create $tagName $exe --title "NassakhRTL $ver" --notes-file $notes | Out-Host
        Remove-Item $notes -ErrorAction SilentlyContinue
        Ok "release published with NassakhRTL.exe attached"
    }

    Write-Host ""
    Write-Host ("RELEASE GATE PASSED for {0}" -f $ver) -ForegroundColor Green
    if (-not $Publish) {
        Write-Host "  next: .\release.ps1 -Publish   (tags $tagName, creates the GitHub Release with the exe)"
    }
    Write-Host "  then: upload NassakhRTL.exe to Gumroad by hand and bump the version shown there to $ver"
    exit 0
} finally { Pop-Location }
