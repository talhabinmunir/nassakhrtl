# Runs every test file in a fresh Windows PowerShell 5.1 process (Add-Type
# cannot reload a type in-session) and reports a single pass/fail.
#
#     powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File tests\run-all.ps1
#
# settings-migration.ps1 constructs the real MainForm; it needs an STA
# thread and a desktop session, and briefly shows a tray icon.
$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$ps51 = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$files = @(
    'engine-line-order.ps1',
    'options-roundtrip.ps1',
    'svg-roundtrip.ps1',
    'softwrap-repro.ps1',
    'settings-migration.ps1'
)
$failed = @()
foreach ($f in $files) {
    Write-Host ""
    Write-Host ("=" * 72)
    Write-Host $f -ForegroundColor Yellow
    Write-Host ("=" * 72)
    & $ps51 -NoProfile -ExecutionPolicy Bypass -STA -File (Join-Path $here $f)
    if ($LASTEXITCODE -ne 0) { $failed += $f }
}
Write-Host ""
Write-Host ("=" * 72)
if ($failed.Count -eq 0) {
    Write-Host ("ALL {0} TEST FILES PASSED" -f $files.Count) -ForegroundColor Green
    exit 0
}
Write-Host ("{0} TEST FILE(S) FAILED: {1}" -f $failed.Count, ($failed -join ', ')) -ForegroundColor Red
exit 1
