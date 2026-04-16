# install.ps1 — Downloads and installs the latest APE CLI release.
#
# Usage:
#   irm https://raw.githubusercontent.com/ccisnedev/finite_ape_machine/main/scripts/install.ps1 | iex
#
# What it does:
#   1. Detects Windows x64
#   2. Downloads the latest .zip from GitHub Releases
#   3. Extracts to $env:LOCALAPPDATA\ape\
#   4. Adds ape\bin\ to the user PATH
#   5. Runs `ape target get`
#   6. Verifies with `ape version`

$ErrorActionPreference = 'Stop'

$repo = 'ccisnedev/finite_ape_machine'
$installDir = Join-Path $env:LOCALAPPDATA 'ape'
$binDir = Join-Path $installDir 'bin'

# ─── Platform check ──────────────────────────────────────────────────────────

if ($env:OS -ne 'Windows_NT') {
    Write-Error 'APE CLI currently supports Windows only.'
    exit 1
}

if ([System.Environment]::Is64BitOperatingSystem -eq $false) {
    Write-Error 'APE CLI requires a 64-bit operating system.'
    exit 1
}

# ─── Fetch latest release ────────────────────────────────────────────────────

Write-Host '>>> Fetching latest release...'
$releaseUrl = "https://api.github.com/repos/$repo/releases/latest"
$headers = @{ Accept = 'application/vnd.github+json' }

if ($env:GITHUB_TOKEN) {
    $headers['Authorization'] = "Bearer $env:GITHUB_TOKEN"
}

$release = Invoke-RestMethod -Uri $releaseUrl -Headers $headers
$asset = $release.assets | Where-Object { $_.name -like 'ape-windows-x64*.zip' } | Select-Object -First 1

if (-not $asset) {
    Write-Error "No ape-windows-x64 asset found in release $($release.tag_name)."
    exit 1
}

Write-Host "    Release: $($release.tag_name)"
Write-Host "    Asset:   $($asset.name)"

# ─── Download and extract ────────────────────────────────────────────────────

$tempZip = Join-Path $env:TEMP "ape-$($release.tag_name).zip"

Write-Host '>>> Downloading...'
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $tempZip -Headers $headers

# Clean previous installation
if (Test-Path $installDir) {
    Write-Host '>>> Removing previous installation...'
    Remove-Item -Recurse -Force $installDir
}

Write-Host '>>> Extracting...'
Expand-Archive -Path $tempZip -DestinationPath $installDir -Force
Remove-Item $tempZip

# ─── Update PATH ─────────────────────────────────────────────────────────────

$userPath = [System.Environment]::GetEnvironmentVariable('PATH', 'User')

if ($userPath -notlike "*$binDir*") {
    Write-Host '>>> Adding ape\bin\ to PATH...'
    [System.Environment]::SetEnvironmentVariable(
        'PATH',
        "$userPath;$binDir",
        'User'
    )
    $env:PATH = "$env:PATH;$binDir"
}

# ─── Deploy and verify ───────────────────────────────────────────────────────

Write-Host '>>> Deploying APE to all targets...'
& (Join-Path $binDir 'ape.exe') target get

Write-Host '>>> Verifying installation...'
$versionOutput = & (Join-Path $binDir 'ape.exe') version
Write-Host "    $versionOutput"

Write-Host ''
Write-Host '>>> APE CLI installed successfully!'
Write-Host "    Location: $installDir"
Write-Host '    Restart your terminal to use `ape` from any directory.'
