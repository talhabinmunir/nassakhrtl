# SVG round-trip: only the text inside <text>/<tspan> changes; structure,
# attributes and the XML declaration survive; the source is never touched.
. (Join-Path $PSScriptRoot 'lib.ps1')
Import-NassakhEngine

$A = [string][char]0x628 + [char]0x633 + [char]0x645 + ' ' + [char]0x627 + [char]0x644 + [char]0x644 + [char]0x647
$B = [string][char]0x627 + [char]0x644 + [char]0x62D + [char]0x645 + [char]0x62F
$svg = @"
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg xmlns="http://www.w3.org/2000/svg" width="400" height="200" viewBox="0 0 400 200">
  <rect x="0" y="0" width="400" height="200" fill="#eee"/>
  <g transform="translate(10,20)">
    <text id="title" x="200" y="50" font-family="Arial" font-size="24" fill="#123456" text-anchor="middle">$A</text>
    <text x="200" y="90" font-size="16"><tspan x="200" dy="0">$B</tspan><tspan x="200" dy="20">Latin only</tspan></text>
  </g>
</svg>
"@
$dir = Join-Path ([IO.Path]::GetTempPath()) ("nassakh-svg-" + [Guid]::NewGuid().ToString('N').Substring(0, 8))
New-Item -ItemType Directory -Force -Path $dir | Out-Null
try {
    $src = Join-Path $dir 'in.svg'
    [IO.File]::WriteAllText($src, $svg, (New-Object Text.UTF8Encoding($false)))
    $f = [RTLFixer.RtlFile]::Load($src, (New-Object RTLFixer.FixOptions))

    Section "Load"
    Check "detected as SVG" $f.IsSvg
    Check "finds exactly the 2 RTL text items" ($f.Items.Count -eq 2)
    Check "labels: element id, then numbered" ($f.Items[0].Label -eq 'title' -and $f.Items[1].Label -eq 'text #2')

    Section "Save"
    $out = Join-Path $dir 'out.svg'
    $f.SaveTo($out, $false)
    $written = [IO.File]::ReadAllText($out)
    $xd = New-Object Xml.XmlDocument
    $xd.PreserveWhitespace = $true
    $xd.LoadXml($written)
    $ns = New-Object Xml.XmlNamespaceManager($xd.NameTable)
    $ns.AddNamespace('s', 'http://www.w3.org/2000/svg')
    $t1 = $xd.SelectSingleNode("//s:text[@id='title']", $ns)
    Check "output is well-formed XML" ($t1 -ne $null)
    Check "attributes preserved (x, y, font-family, fill, text-anchor)" (($t1.GetAttribute('x') -eq '200') -and `
        ($t1.GetAttribute('y') -eq '50') -and ($t1.GetAttribute('font-family') -eq 'Arial') -and `
        ($t1.GetAttribute('fill') -eq '#123456') -and ($t1.GetAttribute('text-anchor') -eq 'middle'))
    Check "structure preserved (rect + g + transform)" (($xd.SelectSingleNode("//s:rect", $ns) -ne $null) -and `
        ($xd.SelectSingleNode("//s:g[@transform='translate(10,20)']", $ns) -ne $null))
    Check "title text converted to Affinity form" ([RTLFixer.Engine]::LooksConverted($t1.InnerText))
    Check "Latin-only tspan untouched" ($written.Contains('Latin only'))
    Check "no markup leaked into the text node" (-not $t1.InnerText.Contains('<'))
    Check "XML declaration preserved byte-for-byte" ($written.StartsWith('<?xml version="1.0" encoding="UTF-8" standalone="no"?>'))
    Check "source file untouched" ([IO.File]::ReadAllText($src) -eq $svg)

    Section "Guards"
    Check "LooksLikeMarkup(raw svg) is true" ([RTLFixer.Engine]::LooksLikeMarkup($svg))
    Check "LooksLikeMarkup(plain Arabic) is false" (-not [RTLFixer.Engine]::LooksLikeMarkup($A))
} finally { Remove-Item -Recurse -Force $dir -ErrorAction SilentlyContinue }

Finish
