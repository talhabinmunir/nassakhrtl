# The in-Affinity text-box hotkey, minus the keystrokes. Everything the
# hotkey decides is in BoxFix / ClipboardKeeper and is exercised here:
# the guard chain (paste NOTHING unless the capture is plausible RTL text),
# the foreground-process allow-list, hotkey spec parsing, and the
# clipboard save/restore that protects the user's own clipboard.
. (Join-Path $PSScriptRoot 'lib.ps1')
Import-NassakhEngine

$o = New-Object RTLFixer.FixOptions
$o.WrapWidth = 0
$AR = [string][char]0x628 + [char]0x633 + [char]0x645 + ' ' + [char]0x627 + [char]0x644 + [char]0x644 + [char]0x647
$conv = [RTLFixer.Engine]::Convert($AR, $o)

Section "Decide: fix mode - refuses everything that is not plain RTL text"
$p = [RTLFixer.BoxFix]::Decide($null, $false, $o)
Check "null capture -> no paste, 'No text captured'" ((-not $p.Proceed) -and $p.Reason.StartsWith('No text captured'))
$p = [RTLFixer.BoxFix]::Decide("   `r`n ", $false, $o)
Check "whitespace capture -> no paste" (-not $p.Proceed)
$p = [RTLFixer.BoxFix]::Decide('<svg xmlns="x"><text>' + $AR + '</text></svg>', $false, $o)
Check "SVG markup -> no paste, names markup" ((-not $p.Proceed) -and $p.Reason.Contains('markup'))
$p = [RTLFixer.BoxFix]::Decide($conv.Text, $false, $o)
Check "already-converted text -> no paste, points at restore" ((-not $p.Proceed) -and $p.Reason.Contains('already converted'))
$p = [RTLFixer.BoxFix]::Decide('Hello world 2024', $false, $o)
Check "Latin-only -> no paste, 'No RTL text'" ((-not $p.Proceed) -and $p.Reason.Contains('No RTL'))

Section "Decide: fix mode - proceeds on real RTL text"
$p = [RTLFixer.BoxFix]::Decide($AR, $false, $o)
Check "Arabic -> proceeds" $p.Proceed
Check "output equals Engine.Convert with the same options" ($p.Output -eq $conv.Text)
Check "Changed equals FixResult.Total ($($conv.Total))" ($p.Changed -eq $conv.Total -and $p.Changed -gt 0)
Check "short text carries no wrap risk" (-not $p.WrapRisk)
$para = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'fixtures\softwrap-paragraph.txt'), [Text.Encoding]::UTF8).Trim()
$p = [RTLFixer.BoxFix]::Decide($para, $false, $o)
Check "long unbroken paragraph with wrap off -> proceeds but flags WrapRisk" ($p.Proceed -and $p.WrapRisk)
$ow = New-Object RTLFixer.FixOptions; $ow.WrapWidth = 70
$p = [RTLFixer.BoxFix]::Decide($para, $false, $ow)
Check "same paragraph with wrap on -> no WrapRisk, output has line breaks" ($p.Proceed -and -not $p.WrapRisk -and $p.Output.Contains("`n"))
$od = New-Object RTLFixer.FixOptions; $od.WesternDigits = $false
$digits = $AR + ' ' + [char]0x0661 + [char]0x0662
Check "respects the caller's options (digits kept when WesternDigits off)" (([RTLFixer.BoxFix]::Decide($digits, $false, $od)).Output.Contains([string][char]0x0661))
Check "respects the caller's options (digits converted when on)" (([RTLFixer.BoxFix]::Decide($digits, $false, $o)).Output.Contains('1'))

Section "Decide: restore mode"
$p = [RTLFixer.BoxFix]::Decide($AR, $true, $o)
Check "plain text in restore mode -> no paste" ((-not $p.Proceed) -and $p.Reason.Contains('does not contain converted'))
$p = [RTLFixer.BoxFix]::Decide($conv.Text, $true, $o)
Check "converted text in restore mode -> proceeds with the original" ($p.Proceed -and $p.Output.Trim() -eq $AR)

Section "Foreground allow-list"
foreach ($n in @('Designer', 'Photo', 'Publisher', 'Designer.exe', 'designer', 'Affinity Designer 2', 'Affinity Photo 2.exe', 'Publisher 2')) {
    Check "'$n' is Affinity" ([RTLFixer.BoxFix]::IsAffinityProcessName($n))
}
foreach ($n in @('', $null, 'explorer', 'chrome', 'powershell', 'NassakhRTL', 'Code', 'photoshop', 'designerx')) {
    Check "'$n' is NOT Affinity" (-not [RTLFixer.BoxFix]::IsAffinityProcessName($n))
}

Section "Hotkey specs"
$m = 0; $k = 0
Check "'Ctrl+Alt+F' parses to Ctrl|Alt, F" ([RTLFixer.BoxFix]::TryParse('Ctrl+Alt+F', [ref]$m, [ref]$k) -and $m -eq 3 -and $k -eq 0x46)
Check "formats back to 'Ctrl+Alt+F'" ([RTLFixer.BoxFix]::Format(3, 0x46) -eq 'Ctrl+Alt+F')
Check "'ctrl + shift + f7' normalises to 'Ctrl+Shift+F7'" ([RTLFixer.BoxFix]::Normalize('ctrl + shift + f7', 'x') -eq 'Ctrl+Shift+F7')
Check "'Alt+3' is accepted" ([RTLFixer.BoxFix]::TryParse('Alt+3', [ref]$m, [ref]$k))
Check "bare 'F' is refused (would hijack typing)" (-not [RTLFixer.BoxFix]::TryParse('F', [ref]$m, [ref]$k))
Check "'Shift+F' alone is refused" (-not [RTLFixer.BoxFix]::TryParse('Shift+F', [ref]$m, [ref]$k))
Check "garbage is refused and Normalize keeps the fallback" ((-not [RTLFixer.BoxFix]::TryParse('Ctrl+Banana', [ref]$m, [ref]$k)) -and [RTLFixer.BoxFix]::Normalize('nope', 'Ctrl+Alt+Z') -eq 'Ctrl+Alt+Z')
Check "the three defaults all parse" (([RTLFixer.BoxFix]::TryParse('Ctrl+Alt+R', [ref]$m, [ref]$k)) -and ([RTLFixer.BoxFix]::TryParse('Ctrl+Alt+F', [ref]$m, [ref]$k)) -and ([RTLFixer.BoxFix]::TryParse('Ctrl+Alt+Z', [ref]$m, [ref]$k)))

Section "ClipboardKeeper - the user's clipboard survives the hotkey's copy/paste"
$before = $null
try { if ([Windows.Forms.Clipboard]::ContainsText()) { $before = [Windows.Forms.Clipboard]::GetText() } } catch { }
try {
    [Windows.Forms.Clipboard]::SetText('USER CLIPBOARD 12345')
    $saved = [RTLFixer.ClipboardKeeper]::Save()
    Check "Save captures the user's text" ($saved -eq 'USER CLIPBOARD 12345')
    [Windows.Forms.Clipboard]::SetText($conv.Text)          # what the hotkey does internally
    Check "internal paste replaced the clipboard" ([Windows.Forms.Clipboard]::GetText() -eq $conv.Text)
    [RTLFixer.ClipboardKeeper]::Restore($saved)
    Check "Restore puts the user's text back" ([Windows.Forms.Clipboard]::GetText() -eq 'USER CLIPBOARD 12345')
    [Windows.Forms.Clipboard]::Clear()
    $none = [RTLFixer.ClipboardKeeper]::Save()
    Check "empty clipboard saves as null" ($none -eq $null)
    [Windows.Forms.Clipboard]::SetText('X')
    [RTLFixer.ClipboardKeeper]::Restore($null)
    Check "Restore(null) leaves the clipboard alone" ([Windows.Forms.Clipboard]::GetText() -eq 'X')
} finally {
    try { if ($before -ne $null) { [Windows.Forms.Clipboard]::SetText($before) } else { [Windows.Forms.Clipboard]::Clear() } } catch { }
}

Finish
