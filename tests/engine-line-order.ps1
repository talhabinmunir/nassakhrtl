# Engine line-order guarantees. Hard line breaks must come out in the same
# top-to-bottom order they went in; only characters WITHIN a line are
# reordered. ToVisual maps lines by index and never reverses the list.
. (Join-Path $PSScriptRoot 'lib.ps1')
Import-NassakhEngine

$o = New-Object RTLFixer.FixOptions
$o.WrapWidth = 0
$L1 = [string][char]0x628 + [char]0x633 + [char]0x645                                   # bsm
$L2 = [string][char]0x627 + [char]0x644 + [char]0x62D + [char]0x645 + [char]0x62F        # alhmd
$L3 = [string][char]0x631 + [char]0x628                                                  # rb
$L4 = [string][char]0x645 + [char]0x627 + [char]0x644 + [char]0x643                      # malk

function OrderPreserved([string[]]$inLines, [RTLFixer.FixOptions]$opt) {
    $r = [RTLFixer.Engine]::Convert(($inLines -join "`n"), $opt)
    $outLines = Lines $r.Text
    if ($outLines.Count -ne $inLines.Count) { return $false }
    for ($i = 0; $i -lt $inLines.Count; $i++) {
        if ([RTLFixer.Engine]::Restore($outLines[$i]).Trim() -ne $inLines[$i].Trim()) { return $false }
    }
    return $true
}

Section "Hard line breaks"
Check "single line stays one line" ((Lines ([RTLFixer.Engine]::Convert($L1, $o).Text)).Count -eq 1)
Check "4 lines keep their order" (OrderPreserved @($L1, $L2, $L3, $L4) $o)
$ten = @(); for ($i = 1; $i -le 10; $i++) { $ten += ($L1 + [string]$i) }
Check "10 distinct lines keep their order" (OrderPreserved $ten $o)
$fifty = @(); for ($i = 1; $i -le 50; $i++) { $fifty += ($L2 + [string]$i) }
Check "50 distinct lines keep their order" (OrderPreserved $fifty $o)
$mixed = @(($L1 + ' Hello'), ($L2 + ' World 2024'), $L3)
Check "mixed Arabic + English lines keep their order" (OrderPreserved $mixed $o)

Section "Paragraph wrapping (WrapWidth)"
$words = @(); for ($i = 1; $i -le 20; $i++) { $words += ($L2 + [string]$i) }
$para = ($words -join ' ')
$w = New-Object RTLFixer.FixOptions
$w.WrapWidth = 30
$rp = [RTLFixer.Engine]::Convert($para, $w)
$pl = Lines $rp.Text
Check "long paragraph is broken into several lines" ($pl.Count -gt 1)
Check "first output line holds the START of the text" ([RTLFixer.Engine]::Restore($pl[0]).Trim().StartsWith($words[0]))
Check "last output line holds the END of the text" ([RTLFixer.Engine]::Restore($pl[$pl.Count - 1]).Trim().EndsWith($words[19]))
$rejoined = (($pl | ForEach-Object { [RTLFixer.Engine]::Restore($_).Trim() }) -join ' ')
Check "restore + rejoin is lossless" ($rejoined -eq $para)
$rOff = [RTLFixer.Engine]::Convert($para, $o)
Check "with WrapWidth 0 the same paragraph stays one physical line" ((Lines $rOff.Text).Count -eq 1)

Finish
