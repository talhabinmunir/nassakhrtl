# Settings / preset migration for the "Break long paragraphs" option.
#
# 2.1.0 regression: SetOptions read a pre-2.1 "opts=" string (no ":N"
# suffix, WrapWidth 0) as "wrap off", so anyone upgrading from a 2.0.0/2.0.1
# settings file - or applying a preset saved before 2.1 - silently lost the
# line-order safety net, and it was then persisted as wrapon=0 on exit.
#
# Constructs the real MainForm against fixture files via
# NASSAKHRTL_SETTINGS_DIR, so the user's %APPDATA% copy is never touched.
. (Join-Path $PSScriptRoot 'lib.ps1')
Import-NassakhEngine

$dir = Join-Path ([IO.Path]::GetTempPath()) ("nassakh-settings-test-" + [Guid]::NewGuid().ToString('N').Substring(0, 8))
New-Item -ItemType Directory -Force -Path $dir | Out-Null
$env:NASSAKHRTL_SETTINGS_DIR = $dir
$ini = Join-Path $dir 'settings.ini'
$flags = [Reflection.BindingFlags]'NonPublic,Instance'
$T = [RTLFixer.MainForm]

function Load($content) {
    # $null = fresh install (no file at all). A [string] parameter would turn
    # $null into "" and write an EMPTY file, which the app rightly treats as an
    # existing user's settings - a different scenario.
    if ($content -eq $null) { if (Test-Path $ini) { Remove-Item $ini -Force } }
    else { [IO.File]::WriteAllText($ini, [string]$content, (New-Object Text.UTF8Encoding($false))) }
    return New-Object RTLFixer.MainForm
}
function Field($f, [string]$name) { return $T.GetField($name, $flags).GetValue($f) }
function Close($f) {
    try { (Field $f 'tray').Dispose() } catch { }
    $f.Dispose()
}
function WrapOn($f) { return (Field $f 'cWrap').Checked }
function WrapN($f)  { return [int](Field $f 'numWrap').Value }

try {
    Section "Hardcoded default"
    $f = Load $null
    Check "fresh install (no settings.ini): wrap ON, N=70" ((WrapOn $f) -and (WrapN $f) -eq 70)
    Close $f

    Section "Upgrade paths - the checkbox must not be clobbered"
    $f = Load "theme=light`nopts=1100000`ntop=1`n"
    Check "2.0.0/2.0.1 file (opts= only, no wrapon): wrap stays ON" (WrapOn $f)
    Close $f
    $f = Load "theme=light`nopts=1100000`ntop=1`nwrapon=1`nwrapw=90`n"
    Check "2.0.2 file, wrapon=1 wrapw=90: ON at 90" ((WrapOn $f) -and (WrapN $f) -eq 90)
    Close $f
    $f = Load "theme=light`nopts=1100000`ntop=1`nwrapon=0`nwrapw=70`n"
    Check "2.0.2 file, deliberate wrapon=0: stays OFF (user choice honoured)" (-not (WrapOn $f))
    Close $f
    $f = Load "theme=light`nopts=1100000:70`ntop=1`nwrapon=1`nwrapw=70`n"
    Check "2.1.0 file, opts=...:70 + wrapon=1: ON" (WrapOn $f)
    Close $f
    $f = Load "theme=light`nopts=1100000:0`ntop=1`nwrapon=0`nwrapw=70`n"
    Check "2.1.1 file, opts=...:0 + wrapon=0: OFF" (-not (WrapOn $f))
    Close $f
    $f = Load "theme=light`nwrapon=1`nopts=1100000:0`n"
    Check "key order does not matter: later opts=:0 wins over earlier wrapon=1" (-not (WrapOn $f))
    Close $f

    Section "Presets"
    $f = Load $null
    $set = $T.GetMethod('SetOptions', $flags)
    $set.Invoke($f, @([RTLFixer.FixOptions]::FromBits('1100000')))
    Check "applying a pre-2.1 preset (no :N) leaves wrap ON" (WrapOn $f)
    $set.Invoke($f, @([RTLFixer.FixOptions]::FromBits('1100000:0')))
    Check "applying a 2.1.1 preset saved with wrap off turns it OFF" (-not (WrapOn $f))
    $set.Invoke($f, @([RTLFixer.FixOptions]::FromBits('1100000:120')))
    Check "applying a preset with :120 turns it ON at 120" ((WrapOn $f) -and (WrapN $f) -eq 120)
    Close $f

    Section "What gets written"
    $f = Load $null
    $T.GetMethod('SaveSettings', $flags).Invoke($f, $null) | Out-Null
    $written = [IO.File]::ReadAllText($ini)
    Check "default state saves opts= with an explicit :70 suffix" ($written.Contains("opts=1100000:70"))
    Check "and wrapon=1" ($written.Contains("wrapon=1"))
    (Field $f 'cWrap').Checked = $false
    $T.GetMethod('SaveSettings', $flags).Invoke($f, $null) | Out-Null
    $written = [IO.File]::ReadAllText($ini)
    Check "wrap off saves opts= with :0, so 'off' is distinguishable from 'unknown'" ($written.Contains("opts=1100000:0"))
    Close $f
    $f = Load $written
    Check "and that file reloads as OFF" (-not (WrapOn $f))
    Close $f

    Section "Text-box hotkeys: off for fresh installs, kept on for existing files"
    function BoxOn($f) { return [bool](Field $f 'boxHotkey') }
    $f = Load $null
    Check "fresh install: text-box hotkeys OFF" (-not (BoxOn $f))
    Check "fresh install: default specs Ctrl+Alt+R / F / Z" (((Field $f 'hkClipSpec') -eq 'Ctrl+Alt+R') -and ((Field $f 'hkFixSpec') -eq 'Ctrl+Alt+F') -and ((Field $f 'hkRestoreSpec') -eq 'Ctrl+Alt+Z'))
    Close $f
    $f = Load "theme=light`nopts=1100000:70`nwrapon=1`n"
    Check "2.0.x-2.1.1 file (no boxhk key): text-box hotkeys stay ON" (BoxOn $f)
    Close $f
    $f = Load "theme=light`nboxhk=0`n"
    Check "explicit boxhk=0: OFF" (-not (BoxOn $f))
    Close $f
    $f = Load "theme=light`nboxhk=1`nhk.clip=Ctrl+Shift+F9`nhk.fix=Alt+F`nhk.restore=Ctrl+Alt+U`n"
    Check "explicit boxhk=1 and custom specs load" ((BoxOn $f) -and ((Field $f 'hkClipSpec') -eq 'Ctrl+Shift+F9') -and ((Field $f 'hkFixSpec') -eq 'Alt+F') -and ((Field $f 'hkRestoreSpec') -eq 'Ctrl+Alt+U'))
    Close $f
    $f = Load "theme=light`nboxhk=1`nhk.fix=F`nhk.clip=garbage`n"
    Check "invalid specs fall back to the defaults" (((Field $f 'hkFixSpec') -eq 'Ctrl+Alt+F') -and ((Field $f 'hkClipSpec') -eq 'Ctrl+Alt+R'))
    Close $f
    $f = Load $null
    $T.GetMethod('SaveSettings', $flags).Invoke($f, $null) | Out-Null
    $w = [IO.File]::ReadAllText($ini)
    Check "SaveSettings writes boxhk=0 and the three specs" ($w.Contains("boxhk=0") -and $w.Contains("hk.clip=Ctrl+Alt+R") -and $w.Contains("hk.fix=Ctrl+Alt+F") -and $w.Contains("hk.restore=Ctrl+Alt+Z"))
    Close $f
    $f = Load $w
    Check "a file saved by this version reloads OFF (explicit key, not the legacy rule)" (-not (BoxOn $f))
    Close $f
} finally {
    Remove-Item -Recurse -Force $dir -ErrorAction SilentlyContinue
    Remove-Item Env:\NASSAKHRTL_SETTINGS_DIR -ErrorAction SilentlyContinue
}

Finish
