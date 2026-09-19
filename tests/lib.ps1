# Shared test harness. Dot-source from each test file:
#     . (Join-Path $PSScriptRoot 'lib.ps1')
#
# Run tests with Windows PowerShell 5.1 (powershell.exe), which is what the
# .bat launcher and ps2exe use. PowerShell 7's Add-Type drops the default
# reference set and fails to resolve Dictionary<,>.
#
# Add-Type cannot reload a type in the same session, so run-all.ps1 starts
# a fresh process per test file.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$script:RepoRoot = Split-Path -Parent $PSScriptRoot
$script:Passes = 0
$script:Fails = 0

function Import-NassakhEngine {
    # Slice the C# here-string out of NassakhRTL.ps1 and compile it. Every
    # engine and UI class becomes callable as [RTLFixer.*] without starting
    # the app.
    if ('RTLFixer.Engine' -as [type]) { return }
    $src = Join-Path $script:RepoRoot 'NassakhRTL.ps1'
    $all = [IO.File]::ReadAllText($src, [Text.Encoding]::UTF8)
    $start = $all.IndexOf("`$source = @'")
    $hdr = $all.IndexOf("`n", $start) + 1
    $end = $all.IndexOf("`n'@", $hdr)
    # keep in step with the -ReferencedAssemblies list at the foot of
    # NassakhRTL.ps1, or the suite compiles against a different surface
    Add-Type -TypeDefinition $all.Substring($hdr, $end - $hdr) `
        -ReferencedAssemblies @('System.Windows.Forms', 'System.Drawing', 'System.Core', 'System.Xml', 'System.Security')
}

function Check([string]$name, [bool]$cond) {
    if ($cond) { $script:Passes++; Write-Host ("  PASS  " + $name) -ForegroundColor Green }
    else       { $script:Fails++;  Write-Host ("  FAIL  " + $name) -ForegroundColor Red }
}

function Section([string]$title) {
    Write-Host ""
    Write-Host $title -ForegroundColor Cyan
}

function Finish {
    Write-Host ""
    $total = $script:Passes + $script:Fails
    if ($script:Fails -eq 0) {
        Write-Host ("{0}/{0} passed" -f $total) -ForegroundColor Green
        exit 0
    }
    Write-Host ("{0} of {1} FAILED" -f $script:Fails, $total) -ForegroundColor Red
    exit 1
}

# Split converted text into physical lines regardless of \r\n vs \n.
function Lines([string]$s) {
    return ,(($s -replace "`r`n", "`n").Split("`n"))
}

# Emulates how Affinity lays out visual-order text in a frame W characters
# wide: no bidi, left-to-right fill, greedy break at spaces. Returns the
# display lines top to bottom. This is the step the app's own preview never
# performs, and it is exactly where an unbroken paragraph reverses.
function Emulate-FrameWrap([string]$visual, [int]$width) {
    # (PowerShell variable names are case-insensitive: do not name the loop
    # variable $w with a $W parameter in scope)
    $out = New-Object System.Collections.Generic.List[string]
    foreach ($hard in (Lines $visual)) {
        $cur = ''
        foreach ($word in $hard.Split(' ')) {
            if ($cur.Length -gt 0 -and ($cur.Length + 1 + $word.Length) -gt $width) { $out.Add($cur); $cur = $word }
            elseif ($cur.Length -eq 0) { $cur = $word }
            else { $cur = $cur + ' ' + $word }
        }
        $out.Add($cur)
    }
    return ,$out.ToArray()
}
