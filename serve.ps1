# Start the local preview server for the BITESQUID site and open Firefox.
# Usage:  .\serve.ps1        (or right-click -> Run with PowerShell)

$ErrorActionPreference = 'Stop'

$hugo = Join-Path $env:LOCALAPPDATA 'Programs\Hugo\hugo.exe'
$site = 'http://localhost:1313/'
$firefoxCandidates = @(
    (Join-Path $env:ProgramFiles 'Mozilla Firefox\firefox.exe'),
    (Join-Path ${env:ProgramFiles(x86)} 'Mozilla Firefox\firefox.exe'),
    (Join-Path $env:LOCALAPPDATA 'Mozilla Firefox\firefox.exe')
)
$firefox = $firefoxCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1

# Is the site already up? Port 1313 can only be held by one server, so starting a
# second one would fail with a bind error. If it answers, just open the browser.
$alreadyRunning = $false
try { $alreadyRunning = (Invoke-WebRequest $site -UseBasicParsing -TimeoutSec 2).StatusCode -eq 200 } catch { }

if ($alreadyRunning) {
    Write-Host ''
    Write-Host 'The site is already running.' -ForegroundColor Green
    Write-Host ''
    if ($firefox) {
        Write-Host "Opening Firefox at $site" -ForegroundColor Cyan
        Start-Process $firefox $site
    } else {
        Write-Host "Open $site in your browser."
    }
    Write-Host ''
    exit 0
}

if (-not (Test-Path $hugo)) {
    Write-Host ''
    Write-Host "Hugo was not found at:" -ForegroundColor Red
    Write-Host "  $hugo" -ForegroundColor Red
    Write-Host ''
    Write-Host 'Install Hugo extended, or edit the $hugo path near the top of this script.'
    Write-Host ''
    exit 1
}

Set-Location -LiteralPath $PSScriptRoot

Write-Host ''
Write-Host 'Starting the BITESQUID site preview...' -ForegroundColor Green
Write-Host ''
if ($firefox) {
    Write-Host "  Firefox opens at $site as soon as the server is ready." -ForegroundColor Cyan
} else {
    Write-Host "  Firefox was not found. Open $site yourself once the server starts." -ForegroundColor Yellow
}
Write-Host '  The page reloads by itself every time you save a file.'
Write-Host '  Press Ctrl+C in this window to stop the server.'
Write-Host ''

# Wait for the server in the background, then open the browser, so the server
# below is not delayed.
if ($firefox) {
    Start-Job -ScriptBlock {
        param($url, $ff)
        for ($i = 0; $i -lt 60; $i++) {
            try {
                if ((Invoke-WebRequest $url -UseBasicParsing -TimeoutSec 2).StatusCode -eq 200) {
                    Start-Process $ff $url
                    break
                }
            } catch { }
            Start-Sleep -Milliseconds 500
        }
    } -ArgumentList $site, $firefox | Out-Null

    # Remove the job when this script exits so it does not linger.
    try { & $hugo server --bind 127.0.0.1 --port 1313 } finally { Get-Job | Remove-Job -Force -ErrorAction SilentlyContinue }
} else {
    & $hugo server --bind 127.0.0.1 --port 1313
}
