@echo off
REM run-s00.cmd — run the S00 boot-observation experiment headlessly-ish.
REM Usage: run from the research repo root:  tools\experiments\run-s00.cmd
REM Output goes to the given log file (default %1 = artifacts/experiments/s00-run.log)

setlocal
cd /d "%~dp0..\..\vendor\CasioEmuX"
set LOG=%~dp0..\..\artifacts\experiments\s00-run.log
if not "%~1"=="" set LOG=%~1

echo dofile("../../tools/experiments/s00.lua") > "%TEMP%\s00in.txt"
echo (end of input — exit_on_console_shutdown fires) >> nul


rem   model= models/fx570esplus/model.lua
rem exit_on_console_shutdown makes it quit after stdin EOF.
casioemu_x.exe model=models/fx570esplus/model.lua exit_on_console_shutdown < "%TEMP%\s00in.txt" > "%LOG%" 2>&1
echo exit code %ERRORLEVEL%, log at %LOG%
endlocal
