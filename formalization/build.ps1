# Build the pinned Lean project, or check one file with an existing environment.
# Cached builds only read the supplied dependency checkouts.
param(
  [string]$File = 'ConjectureA1.lean',
  [string]$LeanBin = $env:LEAN_BIN,
  [switch]$Mathlib,
  [string]$MathlibCache = $env:MATHLIB_CACHE
)
$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$evidence = Join-Path $here 'evidence'
$oldPath = $env:PATH
$oldLeanPath = $env:LEAN_PATH
$oldA1Lean = $env:A1_LEAN
$oldConsoleEncoding = [Console]::OutputEncoding
$oldOutputEncoding = $OutputEncoding
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
$OutputEncoding = [Console]::OutputEncoding
Push-Location $here
try {
  if (-not $LeanBin) {
    $local = Get-ChildItem (Join-Path $here '.lean') -Directory -ErrorAction SilentlyContinue |
      Where-Object { $_.Name -like 'lean-*windows*' } | Select-Object -First 1
    if ($local) { $LeanBin = Join-Path $local.FullName 'bin' }
  }
  if ($LeanBin) {
    $lean = Join-Path $LeanBin 'lean.exe'
    $lake = Join-Path $LeanBin 'lake.exe'
  } else {
    $lean = (Get-Command lean -ErrorAction Stop).Source
    $lake = (Get-Command lake -ErrorAction Stop).Source
  }
  if (-not (Test-Path -LiteralPath $lean) -or -not (Test-Path -LiteralPath $lake)) {
    throw 'Pass -LeanBin <existing toolchain bin directory>, or put pinned Lean/Lake on PATH.'
  }
  $env:PATH = "$(Split-Path -Parent $lean);$env:PATH"
  $version = & $lean --version
  if ($LASTEXITCODE -ne 0 -or $version -notmatch 'version 4\.31\.0,') {
    throw "Expected Lean 4.31.0; observed: $version"
  }
  Write-Host "lean: $version"
  $env:A1_LEAN = $lean
  New-Item -ItemType Directory -Force -Path $evidence | Out-Null

  if ($MathlibCache) {
    $cache = (Resolve-Path -LiteralPath $MathlibCache).Path
    $manifest = Get-Content -LiteralPath (Join-Path $here 'lake-manifest.json') -Raw |
      ConvertFrom-Json
    $mathlibPin = ($manifest.packages | Where-Object name -eq 'mathlib').rev
    $paths = @()
    $pins = @()
    foreach ($package in $manifest.packages) {
      if ($package.name -eq 'mathlib') {
        $directory = $cache
      } else {
        $directory = Join-Path (Split-Path -Parent $cache) $package.name
        if (-not (Test-Path -LiteralPath $directory)) {
          $directory = Join-Path (Join-Path $cache '.lake\packages') $package.name
        }
      }
      if (-not (Test-Path -LiteralPath $directory)) {
        throw "Missing pinned package: $($package.name)"
      }
      $head = & git -C $directory rev-parse HEAD
      if ($LASTEXITCODE -ne 0 -or $head -ne $package.rev) {
        throw "Cached $($package.name) HEAD does not match $($package.rev)"
      }
      $dirty = & git -C $directory status --porcelain --untracked-files=no
      if ($LASTEXITCODE -ne 0 -or $dirty) {
        throw "Cached $($package.name) has tracked changes; supply the pinned clean checkout."
      }
      $library = Join-Path $directory '.lake\build\lib\lean'
      # Some locked packages are Lake-only dependencies and have no imported
      # library here. Lean itself rejects a missing artifact if it is needed.
      if (Test-Path -LiteralPath $library) { $paths += $library }
      $pins += "$($package.name) expected=$($package.rev) actual=$head"
    }
    if ((Get-Content -LiteralPath (Join-Path $cache 'lean-toolchain') -Raw).Trim() -ne
        (Get-Content -LiteralPath (Join-Path $here 'lean-toolchain') -Raw).Trim()) {
      throw 'Cached Mathlib lean-toolchain does not match this project.'
    }
    $env:LEAN_PATH = ($paths | Select-Object -Unique) -join [IO.Path]::PathSeparator
    @("Lean=$lean", "Mathlib=$cache", "HEAD=$mathlibPin", "LEAN_PATH=$env:LEAN_PATH",
      'COMMAND=lake -f lakefile.offline.lean build',
      'External caches are read-only inputs; proof artifacts are rebuilt in this package.') + $pins |
      Set-Content -LiteralPath (Join-Path $evidence 'build-context.log')
    & $lake -f lakefile.offline.lean build 2>&1 |
      Tee-Object -FilePath (Join-Path $evidence 'lake-build.log')
    $code = $LASTEXITCODE
  } elseif ($Mathlib) {
    & $lake build
    if ($LASTEXITCODE -ne 0) { throw "lake build failed: $LASTEXITCODE" }
    # The normal build may reuse valid artifacts. Always recompile the material
    # modules and axiom probes so validation never depends on a cached print log.
    & $lake env $lake -f lakefile.offline.lean build 2>&1 |
      Tee-Object -FilePath (Join-Path $evidence 'lake-build.log')
    $code = $LASTEXITCODE
  } else {
    & $lean (Join-Path $here $File)
    if ($LASTEXITCODE -ne 0) { throw "Lean check failed: $LASTEXITCODE" }
    return
  }
  "EXIT=$code" | Tee-Object -FilePath (Join-Path $evidence 'lake-build.log') -Append
  if ($code -ne 0) { throw "Fresh Lake proof target failed: $code" }
} finally {
  Pop-Location
  $env:PATH = $oldPath
  $env:LEAN_PATH = $oldLeanPath
  $env:A1_LEAN = $oldA1Lean
  [Console]::OutputEncoding = $oldConsoleEncoding
  $OutputEncoding = $oldOutputEncoding
}
