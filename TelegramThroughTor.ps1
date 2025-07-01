if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

[System.Console]::BackgroundColor = 'Black'
[System.Console]::ForegroundColor = 'White'
[System.Console]::Clear()

Write-Host "[INFO] Preparing Tor for Telegram..." -ForegroundColor Cyan

$url = "https://archive.torproject.org/tor-package-archive/torbrowser/13.5.6/tor-expert-bundle-windows-x86_64-13.5.6.tar.gz"
$destPath = "C:\Tor"
$archivePath = Join-Path $destPath "tor-expert-bundle.tar.gz"
$torExePath = Join-Path $destPath "Tor\tor.exe"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$iconPath = Join-Path $scriptDir "assets\telegramtor.ico"

$telegramPath = Join-Path $env:APPDATA "Telegram Desktop\Telegram.exe"

if (-Not (Test-Path $telegramPath)) {
    Write-Host "[ERROR] Telegram not found at: $telegramPath" -ForegroundColor Red
    Exit
}

if (-Not (Test-Path $torExePath)) {
    New-Item -ItemType Directory -Force -Path $destPath
    Write-Host "[OK] Directory created." -ForegroundColor White

    Invoke-WebRequest -Uri $url -OutFile $archivePath
    Write-Host "[OK] Tor downloaded." -ForegroundColor White

    tar -xzf $archivePath -C $destPath
    Write-Host "[OK] Tor extracted." -ForegroundColor White

    Remove-Item $archivePath
    Write-Host "[OK] Archive removed." -ForegroundColor White
}
else {
    Write-Host "[INFO] Tor already installed." -ForegroundColor White
}

if (-Not (Get-Process -Name "tor" -ErrorAction SilentlyContinue)) {
    Write-Host "[INFO] Starting Tor in background..." -ForegroundColor White
    Start-Process -FilePath $torExePath -WindowStyle Hidden
    Start-Sleep -Seconds 3
    Write-Host "[OK] Tor started as background process." -ForegroundColor Green
}
else {
    Write-Host "[INFO] Tor is already running." -ForegroundColor White
}

$desktopShortcut = [System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), "Telegram.lnk")
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($desktopShortcut)
$Shortcut.TargetPath = $telegramPath
$Shortcut.IconLocation = $iconPath
$Shortcut.Save()
Write-Host "[OK] Telegram shortcut created on Desktop." -ForegroundColor White

Write-Host ""
Write-Host "========== TELEGRAM PROXY SETUP ==========" -ForegroundColor Yellow
Write-Host "Tor is now running as a SOCKS5 proxy at: 127.0.0.1:9050" -ForegroundColor Cyan
Write-Host ""
Write-Host "To enable Tor proxy in Telegram Desktop:" -ForegroundColor White
Write-Host "1. Open Telegram (via the shortcut or manually)" -ForegroundColor White
Write-Host "2. Go to ☰ menu → Settings → Advanced" -ForegroundColor White
Write-Host "3. Scroll to 'Connection type'" -ForegroundColor White
Write-Host "4. Click 'Use custom proxy'" -ForegroundColor White
Write-Host "5. Choose 'SOCKS5'" -ForegroundColor White
Write-Host "6. Server: 127.0.0.1" -ForegroundColor White
Write-Host "7. Port: 9050" -ForegroundColor White
Write-Host "8. Leave username/password blank" -ForegroundColor White
Write-Host ""
Write-Host "[SUCCESS] Telegram can now connect through Tor!" -ForegroundColor Green
Write-Host ""
Write-Host "Press Enter to finish..." -ForegroundColor Yellow
[void][System.Console]::ReadLine()
