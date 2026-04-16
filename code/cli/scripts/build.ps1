# build.ps1 — Compiles ape CLI and packages assets for distribution.
#
# Output structure:
#   build/
#     bin/ape.exe
#     assets/
#       agents/ape.agent.md
#       skills/memory-read/SKILL.md
#       skills/memory-write/SKILL.md

$ErrorActionPreference = 'Stop'

$cliRoot = Split-Path -Parent $PSScriptRoot
$buildDir = Join-Path $cliRoot 'build'

# Clean previous build
if (Test-Path $buildDir) {
    Remove-Item -Recurse -Force $buildDir
}

# Create build directories
New-Item -ItemType Directory -Force -Path (Join-Path $buildDir 'bin') | Out-Null

# Compile
Write-Host '>>> Compiling ape.exe...'
$binOutput = Join-Path (Join-Path $buildDir 'bin') 'ape.exe'
Push-Location $cliRoot
dart compile exe bin/main.dart -o $binOutput
Pop-Location

# Copy assets
Write-Host '>>> Copying assets...'
Copy-Item -Recurse (Join-Path $cliRoot 'assets') (Join-Path $buildDir 'assets')

Write-Host '>>> Build complete.'
Write-Host "    Binary: $binOutput"
Write-Host "    Assets: $(Join-Path $buildDir 'assets')"
