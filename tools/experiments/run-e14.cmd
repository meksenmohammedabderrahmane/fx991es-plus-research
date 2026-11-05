@setlocal
@echo off
REM run-e.cmd — run an e-series CasioEmuX experiment deterministically.
REM Usage: run from repo root:  fx991esplus-research\tools\experiments\run-e.cmd e14 [logfile]
REM %1 = experiment short name (e14, e15, e15c)

cd /d "%~dp0..\..\vendor\CasioEmuX\emulator"
set EXP=%~1
if "%EXP%"=="" set EXP=e14
set LOG=%~dp0..\..\artifacts\experiments\%EXP%-run.log
if not "%~2"=="" set LOG=%~2

set INFILE=%TEMP%\%EXP%-in.txt
echo dofile("../../tools/experiments/%EXP%.lua")> "%INFILE%"

casioemu_x.exe model=../models/fx570esplus/model.lua script=lua-common.lua exit_on_console_shutdown < "%INFILE%" > "%LOG%" 2>&1
echo exit code %ERRORLEVEL%, log at %LOG%
