@echo off
REM Double-click this file to preview the site. It starts the server and opens Firefox.
REM If the server is already running, it just opens the browser instead of failing.
setlocal
set "HUGO=%LOCALAPPDATA%\Programs\Hugo\hugo.exe"
set "SITE=http://localhost:1313/"

REM Find Firefox. Change this if you keep it somewhere else.
set "FF=%ProgramFiles%\Mozilla Firefox\firefox.exe"
if not exist "%FF%" set "FF=%ProgramFiles(x86)%\Mozilla Firefox\firefox.exe"
if not exist "%FF%" set "FF=%LOCALAPPDATA%\Mozilla Firefox\firefox.exe"

cd /d "%~dp0"

REM Is the site already up? Port 1313 can only be held by one server, so starting a
REM second one would fail. If it answers, just open the browser and stop here.
powershell -NoProfile -ExecutionPolicy Bypass -Command "try{if((Invoke-WebRequest '%SITE%' -UseBasicParsing -TimeoutSec 2).StatusCode -eq 200){exit 0}}catch{};exit 1"
if not errorlevel 1 (
  echo.
  echo The site is already running.
  echo.
  if exist "%FF%" (
    echo Opening Firefox at %SITE%
    start "" "%FF%" "%SITE%"
  ) else (
    echo Open %SITE% in your browser.
  )
  echo.
  timeout /t 3 >nul
  exit /b 0
)

if not exist "%HUGO%" (
  echo.
  echo Hugo was not found at:
  echo   %HUGO%
  echo.
  echo Install Hugo extended, or edit the HUGO path at the top of this file.
  echo.
  pause
  exit /b 1
)

cd /d "%~dp0"

echo.
echo Starting the BITESQUID site preview...
echo.
echo   Firefox opens at %SITE% as soon as the server is ready.
echo   The page reloads by itself every time you save a file.
echo   Press Ctrl+C in this window to stop the server.
echo.

REM Wait for the server in a separate window, then open the browser. This runs in
REM parallel so the server below is not delayed.
if exist "%FF%" (
  start "BITESQUID browser" /min powershell -NoProfile -ExecutionPolicy Bypass -Command "for($i=0;$i -lt 60;$i++){try{if((Invoke-WebRequest '%SITE%' -UseBasicParsing -TimeoutSec 2).StatusCode -eq 200){Start-Process '%FF%' '%SITE%';break}}catch{};Start-Sleep -Milliseconds 500}"
) else (
  echo Firefox was not found. Open %SITE% yourself once the server starts.
  echo.
)

"%HUGO%" server --bind 127.0.0.1 --port 1313

echo.
echo Server stopped.
pause
