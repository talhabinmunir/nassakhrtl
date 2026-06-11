@echo off
rem Starts NassakhRTL (no installation needed)
start "" powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -WindowStyle Hidden -File "%~dp0NassakhRTL.ps1"
