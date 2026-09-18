# Regression test for the soft-wrap line-order reversal.
#
# Exact user repro (2026-09-18): one Arabic paragraph, no manual line breaks,
# pasted via Quick Fix into a narrow Affinity frame. With "Break long
# paragraphs" OFF the frame's own wrapping put the END of the paragraph on
# the top line. With it ON at N=70 the app added 2 line breaks and Affinity
# showed 3 lines in the right order.
#
# The engine never reverses lines; Affinity's wrapping of a single long
# visual-order string does. Emulate-FrameWrap (lib.ps1) performs that step
# so the failure is reproducible without Affinity.
. (Join-Path $PSScriptRoot 'lib.ps1')
Import-NassakhEngine

$para = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'fixtures\softwrap-paragraph.txt'), [Text.Encoding]::UTF8).Trim()
$words = $para.Split(' ')
$first = $words[0]; $last = $words[$words.Length - 1]
Write-Host ("fixture: {0} chars, {1} words, no line breaks: {2}" -f $para.Length, $words.Length, ($para.IndexOf("`n") -lt 0))

function Restore([string]$s) { return [RTLFixer.Engine]::Restore($s).Trim() }

Section "1. Wrap OFF - reproduces the reported reversal"
$off = New-Object RTLFixer.FixOptions
$off.WrapWidth = 0
$rOff = [RTLFixer.Engine]::Convert($para, $off)
$offLines = Lines $rOff.Text
Check "converted output is one physical line" ($offLines.Count -eq 1)
$disp = Emulate-FrameWrap $rOff.Text 60
Check "a 60-char frame wraps it into several display lines" ($disp.Count -ge 2)
$top = Restore $disp[0]; $bottom = Restore $disp[$disp.Count - 1]
Check "TOP display line holds the END of the paragraph  (the bug)" ($top.EndsWith($last) -and -not $top.StartsWith($first))
Check "BOTTOM display line holds the START of the paragraph" ($bottom.StartsWith($first))
Check "IsUnbrokenParagraph flags this input at N=70" ([RTLFixer.Engine]::IsUnbrokenParagraph($para, 70))

Section "2. Wrap ON, N=70 - the fix the user confirmed"
$on = New-Object RTLFixer.FixOptions
$on.WrapWidth = 70
$rOn = [RTLFixer.Engine]::Convert($para, $on)
$onLines = Lines $rOn.Text
Check "summary reports '2 line breaks added' (matches the user's status bar)" ($rOn.Summary.Contains("2 line breaks added"))
Check "output has 3 lines" ($onLines.Count -eq 3)
$tooLong = @($onLines | Where-Object { $_.Length -gt 70 })
Check "no line exceeds N=70 chars" ($tooLong.Count -eq 0)
Check "first line restores to the START of the paragraph" ((Restore $onLines[0]).StartsWith($first))
Check "last line restores to the END of the paragraph" ((Restore $onLines[2]).EndsWith($last))
$joined = (($onLines | ForEach-Object { Restore $_ }) -join ' ')
Check "all three lines restore and rejoin to the exact input" ($joined -eq $para)
$disp70 = Emulate-FrameWrap $rOn.Text 70
Check "a 70-char frame does not re-wrap: still 3 display lines" ($disp70.Count -eq 3)
Check "top display line is the START in a 70-char frame" ((Restore $disp70[0]).StartsWith($first))
Check "converted output no longer trips IsUnbrokenParagraph" (-not [RTLFixer.Engine]::IsUnbrokenParagraph($rOn.Text, 70))

Section "3. Characterisation: N must be narrower than the frame"
$disp40 = Emulate-FrameWrap $rOn.Text 40
Check "N=70 in a 40-char frame re-wraps each line and flips it (documented limit)" (-not (Restore $disp40[0]).StartsWith($first))
$on35 = New-Object RTLFixer.FixOptions
$on35.WrapWidth = 35
$r35 = [RTLFixer.Engine]::Convert($para, $on35)
$d35 = Emulate-FrameWrap $r35.Text 40
Check "N=35 in the same 40-char frame reads top-to-bottom" ((Restore $d35[0]).StartsWith($first) -and (Restore $d35[$d35.Count - 1]).EndsWith($last))

Section "4. Detector edge cases"
Check "short single line is NOT flagged" (-not [RTLFixer.Engine]::IsUnbrokenParagraph($words[0] + ' ' + $words[1], 70))
Check "text with a hard break is NOT flagged" (-not [RTLFixer.Engine]::IsUnbrokenParagraph($words[0] + "`n" + $para, 70))
Check "long Latin-only line is NOT flagged" (-not [RTLFixer.Engine]::IsUnbrokenParagraph(('lorem ipsum ' * 20), 70))
Check "length exactly N is NOT flagged; N+1 is" ((-not [RTLFixer.Engine]::IsUnbrokenParagraph($para, $para.Length)) -and [RTLFixer.Engine]::IsUnbrokenParagraph($para, $para.Length - 1))

Finish
