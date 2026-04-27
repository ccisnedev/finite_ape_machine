# dev-install.ps1 — Builds and installs Inquiry CLI from source.
#
# Usage:
#   .\code\cli\scripts\dev-install.ps1
#
# What it does:
#   1. Runs build.ps1 (compile + package assets)
#   2. Copies build\ → $env:LOCALAPPDATA\inquiry\ (same layout as install.ps1)
#   3. Adds inquiry\bin\ to user PATH
#   4. Creates iq.cmd alias
#
# Requires: Dart SDK in PATH.

$ErrorActionPreference = 'Stop'

$scriptDir = $PSScriptRoot
$cliRoot = Split-Path -Parent $scriptDir
$buildDir = Join-Path $cliRoot 'build'
$installDir = Join-Path $env:LOCALAPPDATA 'inquiry'
$binDir = Join-Path $installDir 'bin'

# ─── Build ────────────────────────────────────────────────────────────────────

Write-Host '>>> Building from source...'
& "$scriptDir\build.ps1"

# ─── Install ──────────────────────────────────────────────────────────────────

if (Test-Path $installDir) {
    Write-Host '>>> Removing previous installation...'
    Remove-Item -Recurse -Force $installDir
}

Write-Host ">>> Installing to $installDir..."
New-Item -ItemType Directory -Force -Path $binDir | Out-Null
Copy-Item (Join-Path $buildDir 'bin' 'inquiry.exe') (Join-Path $binDir 'inquiry.exe')
Copy-Item -Recurse (Join-Path $buildDir 'assets') (Join-Path $installDir 'assets')

# ─── iq alias ─────────────────────────────────────────────────────────────────

Write-Host '>>> Creating iq alias...'
Set-Content -Path (Join-Path $binDir 'iq.cmd') -Value '@"%~dp0inquiry.exe" %*' -Encoding ASCII

# ─── PATH ─────────────────────────────────────────────────────────────────────

$userPath = [System.Environment]::GetEnvironmentVariable('PATH', 'User')

if ($userPath -notlike "*$binDir*") {
    Write-Host '>>> Adding inquiry\bin\ to PATH...'
    [System.Environment]::SetEnvironmentVariable('PATH', "$userPath;$binDir", 'User')
    $env:PATH = "$env:PATH;$binDir"
}

# ─── Verify ───────────────────────────────────────────────────────────────────

Write-Host '>>> Verifying...'
& (Join-Path $binDir 'inquiry.exe') version

Write-Host ''
Write-Host '>>> Installed from source successfully!'
Write-Host "    Location: $installDir"
