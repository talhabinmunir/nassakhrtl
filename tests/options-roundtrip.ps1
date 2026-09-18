# FixOptions serialisation, legacy compatibility, and the rule that wrapping
# never reaches SVG text nodes.
. (Join-Path $PSScriptRoot 'lib.ps1')
Import-NassakhEngine

Section "ToBits / FromBits"
$o = New-Object RTLFixer.FixOptions
$o.WesternDigits = $true; $o.RemoveZeroWidth = $false; $o.RemoveDiacritics = $true
$o.RemoveTatweel = $false; $o.PunctToLatin = $true; $o.NormalizeAlef = $false
$o.NormalizeYaTa = $true; $o.WrapWidth = 85
$bits = $o.ToBits()
Check "ToBits writes flags + ':85'  (got '$bits')" ($bits -eq '1010101:85')
$b = [RTLFixer.FixOptions]::FromBits($bits)
Check "all seven flags round-trip" (($b.WesternDigits -eq $true) -and ($b.RemoveZeroWidth -eq $false) -and `
    ($b.RemoveDiacritics -eq $true) -and ($b.RemoveTatweel -eq $false) -and ($b.PunctToLatin -eq $true) -and `
    ($b.NormalizeAlef -eq $false) -and ($b.NormalizeYaTa -eq $true))
Check "WrapWidth round-trips (85) and HasWrap is true" ($b.WrapWidth -eq 85 -and $b.HasWrap)

$off = New-Object RTLFixer.FixOptions
$off.WrapWidth = 0
Check "wrap off serialises as ':0', never a bare 7-char string" ($off.ToBits() -eq '1100000:0')
$b0 = [RTLFixer.FixOptions]::FromBits('1100000:0')
Check "':0' parses as HasWrap=true, WrapWidth=0 (explicit off)" ($b0.HasWrap -and $b0.WrapWidth -eq 0)

Section "Legacy strings (2.0.x settings and presets)"
$legacy = [RTLFixer.FixOptions]::FromBits('1100101')
Check "bare 7-char string still parses its flags" (($legacy.WesternDigits -eq $true) -and ($legacy.NormalizeYaTa -eq $true))
Check "bare 7-char string leaves WrapWidth 0" ($legacy.WrapWidth -eq 0)
Check "bare 7-char string has HasWrap=false  (unknown, NOT off)" (-not $legacy.HasWrap)
$bad = [RTLFixer.FixOptions]::FromBits('1100000:7')
Check "out-of-range suffix (7) is ignored: HasWrap=false" (-not $bad.HasWrap -and $bad.WrapWidth -eq 0)
$short = [RTLFixer.FixOptions]::FromBits('11')
Check "too-short string yields defaults" ($short.WesternDigits -and -not $short.HasWrap)

Section "Wrap must never reach SVG text nodes"
$W = [string][char]0x627 + [char]0x644 + [char]0x62D + [char]0x645 + [char]0x62F
$words = @(); for ($i = 1; $i -le 30; $i++) { $words += ($W + [string]$i) }
$long = ($words -join ' ')
$svg = '<?xml version="1.0" encoding="UTF-8"?>' + "`n" + `
  '<svg xmlns="http://www.w3.org/2000/svg" width="500" height="120">' + "`n" + `
  '  <text id="para" x="10" y="40" font-size="14">' + $long + '</text>' + "`n" + '</svg>'
$dir = Join-Path ([IO.Path]::GetTempPath()) ("nassakh-opts-" + [Guid]::NewGuid().ToString('N').Substring(0, 8))
New-Item -ItemType Directory -Force -Path $dir | Out-Null
try {
    $src = Join-Path $dir 'wrap.svg'
    [IO.File]::WriteAllText($src, $svg, (New-Object Text.UTF8Encoding($false)))
    $ow = New-Object RTLFixer.FixOptions
    $ow.WrapWidth = 30
    $f = [RTLFixer.RtlFile]::Load($src, $ow)
    $out = Join-Path $dir 'wrap-out.svg'
    $f.SaveTo($out, $false)
    $xd = New-Object Xml.XmlDocument
    $xd.PreserveWhitespace = $true
    $xd.LoadXml([IO.File]::ReadAllText($out))
    $ns = New-Object Xml.XmlNamespaceManager($xd.NameTable)
    $ns.AddNamespace('s', 'http://www.w3.org/2000/svg')
    $node = $xd.SelectSingleNode("//s:text[@id='para']", $ns)
    Check "SVG output is well-formed" ($node -ne $null)
    Check "no newline injected into the SVG text node" (-not $node.InnerText.Contains("`n"))
    Check "SVG text node was still converted" ([RTLFixer.Engine]::LooksConverted($node.InnerText))
    Check "x / y / font-size preserved" (($node.GetAttribute('x') -eq '10') -and ($node.GetAttribute('y') -eq '40') -and ($node.GetAttribute('font-size') -eq '14'))
    $rt = [RTLFixer.Engine]::Convert($long, $ow)
    Check "the plain-text path with the same options DOES wrap" ((Lines $rt.Text).Count -gt 1)
} finally { Remove-Item -Recurse -Force $dir -ErrorAction SilentlyContinue }

Finish
