@echo off
set PATH=C:\msys64\ucrt64\bin;%PATH%
cd /d C:\Users\mohamed\Desktop\Casio\fx991esplus-research\vendor\CasioEmuX\emulator

rem Generate a response file with every .cpp under src (forward slashes, no globs needed)
powershell -NoProfile -Command "New-Item -ItemType Directory -Force obj | Out-Null; Get-ChildItem src -Recurse -Filter *.cpp | ForEach-Object { $_.FullName.Substring((Get-Location).Path.Length + 1).Replace('\','/') } | Set-Content -Encoding ASCII obj\sources.txt"
if errorlevel 1 goto :fail

g++ -I"C:\msys64\ucrt64\include\SDL2" -I"C:\msys64\ucrt64\include\lua5.3" -I"C:\msys64\ucrt64\include" -Wall -std=c++2a -O1 @obj\sources.txt -o casioemu_x.exe -lmingw32 -lSDL2main -lSDL2 -lSDL2_image -llua5.3 -lreadline
if errorlevel 1 goto :fail
if exist casioemu_x.exe (echo BUILD_OK) else goto :fail
exit /b 0

:fail
echo BUILD_FAILED
exit /b 1
