@echo off
REM Double-click this file to stop the local preview server.
REM Useful when a server is still holding port 1313 and you cannot find its window.
setlocal

echo.
echo Stopping the BITESQUID site preview...

set "FOUND="
for /f "tokens=5" %%P in ('netstat -ano ^| findstr /r /c:"TCP.*:1313 .*LISTENING"') do (
  echo   Stopping process %%P
  taskkill /PID %%P /F >nul 2>&1
  set "FOUND=1"
)

if not defined FOUND (
  echo   Nothing was listening on port 1313. The site is already stopped.
) else (
  echo.
  echo Site stopped.
)

echo.
timeout /t 3 >nul
