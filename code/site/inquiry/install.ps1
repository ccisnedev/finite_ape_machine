# install.ps1 — Downloads and installs the latest Inquiry CLI release.
#
# Usage:
#   irm https://inquiry.si14bm.com/install.ps1 | iex
#
# What it does:
#   1. Detects Windows x64
#   2. Downloads the latest .zip from GitHub Releases
#   3. Extracts to $env:LOCALAPPDATA\inquiry\
#   4. Adds inquiry\bin\ to the user PATH
#   5. Creates `iq.cmd` batch shim
#   6. Runs `inquiry target get`
#   7. Verifies with `inquiry version`

$ErrorActionPreference = 'Stop'

$repo = 'siliconbrainedmachines/inquiry'
$installDir = Join-Path $env:LOCALAPPDATA 'inquiry'
$binDir = Join-Path $installDir 'bin'

# ─── Platform check ──────────────────────────────────────────────────────────

if ($env:OS -ne 'Windows_NT') {
    Write-Error 'Inquiry CLI currently supports Windows only.'
    exit 1
}

if ([System.Environment]::Is64BitOperatingSystem -eq $false) {
    Write-Error 'Inquiry CLI requires a 64-bit operating system.'
    exit 1
}

# ─── Fetch latest release ────────────────────────────────────────────────────

Write-Host '>>> Fetching latest release...'
$releaseUrl = "https://api.github.com/repos/$repo/releases/latest"
$headers = @{ Accept = 'application/vnd.github+json' }

$release = Invoke-RestMethod -Uri $releaseUrl -Headers $headers
$asset = $release.assets | Where-Object { $_.name -like 'inquiry-windows-x64*.zip' } | Select-Object -First 1

if (-not $asset) {
    Write-Error "No inquiry-windows-x64 asset found in release $($release.tag_name)."
    exit 1
}

Write-Host "    Release: $($release.tag_name)"
Write-Host "    Asset:   $($asset.name)"

# ─── Download and extract ────────────────────────────────────────────────────

$tempZip = Join-Path $env:TEMP "inquiry-$($release.tag_name).zip"

Write-Host '>>> Downloading...'
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $tempZip

# Clean previous installation
if (Test-Path $installDir) {
    Write-Host '>>> Removing previous installation...'
    Remove-Item -Recurse -Force $installDir
}

Write-Host '>>> Extracting...'
Expand-Archive -Path $tempZip -DestinationPath $installDir -Force
Remove-Item $tempZip

# ─── Create iq alias ─────────────────────────────────────────────────────────

Write-Host '>>> Creating iq alias...'
Set-Content -Path (Join-Path $binDir 'iq.cmd') -Value '@"%~dp0inquiry.exe" %*' -Encoding ASCII

# ─── Update PATH ─────────────────────────────────────────────────────────────

$userPath = [System.Environment]::GetEnvironmentVariable('PATH', 'User')

if ($userPath -notlike "*$binDir*") {
    Write-Host '>>> Adding inquiry\bin\ to PATH...'
    [System.Environment]::SetEnvironmentVariable(
        'PATH',
        "$userPath;$binDir",
        'User'
    )
    $env:PATH = "$env:PATH;$binDir"
}

# ─── Deploy and verify ───────────────────────────────────────────────────────

Write-Host '>>> Deploying Inquiry to all targets...'
& (Join-Path $binDir 'inquiry.exe') target get

Write-Host '>>> Verifying installation...'
$versionOutput = & (Join-Path $binDir 'inquiry.exe') version
Write-Host "    $versionOutput"

Write-Host ''
Write-Host '>>> Inquiry CLI installed successfully!'
Write-Host "    Location: $installDir"
Write-Host '    Restart your terminal to use `inquiry` or `iq` from any directory.'
