# build.ps1  type-check / build the Lean sources in this folder.
#
# Usage:
#   .\build.ps1                      # check ConjectureA1.lean with `lean` (no Mathlib)
#   .\build.ps1 -Mathlib             # same, but with Mathlib on the search path (lake)
#   .\build.ps1 -File ConjectureA1.lean
#
# Prerequisite: run .\setup.ps1 first, then prepend the toolchain's bin to PATH
# (or pass -LeanBin explicitly).

param(
  [string]$File = "ConjectureA1.lean",
  [string]$LeanBin = "",
  [switch]$Mathlib
)

$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

if (-not $LeanBin) {
  $d = Get-ChildItem (Join-Path $here ".lean") -Directory -ErrorAction SilentlyContinue |
       Where-Object { $_.Name -like "lean-*windows*" } | Select-Object -First 1
  if ($d) { $LeanBin = Join-Path $d.FullName "bin" }
}
if (-not $LeanBin -or -not (Test-Path (Join-Path $LeanBin "lean.exe"))) {
  throw "Lean not found. Run .\setup.ps1 -LeanVersion <ver> first, or pass -LeanBin <dir>."
}
$env:PATH = "$LeanBin;$env:PATH"

Write-Host "lean: $(& (Join-Path $LeanBin 'lean.exe') --version)"

if ($Mathlib) {
  $lake = Join-Path $LeanBin "lake.exe"
  if (-not (Test-Path $lake)) { throw "lake.exe not found in $LeanBin" }
  Write-Host "building with lake (Mathlib)..."
  Push-Location $here
  try { & $lake build } finally { Pop-Location }
} else {
  Write-Host "type-checking $File with bare lean (Mathlib imports will fail unless available)..."
  & (Join-Path $LeanBin "lean.exe") (Join-Path $here $File)
  if ($LASTEXITCODE -eq 0) { Write-Host "OK: $File checks" } else { Write-Host "FAILED with exit $LASTEXITCODE" }
}
