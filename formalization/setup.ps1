# setup.ps1  download a Lean 4 toolchain (and optionally Mathlib sources) using Node.js.
#
# Why Node?  In this environment Windows schannel is blocked for PowerShell/curl:
#   Invoke-WebRequest -> ""
#   curl.exe          -> schannel: AcquireCredentialsHandle failed: SEC_E_NO_CREDENTIALS
# while Node's own TLS stack works (verified: https://github.com -> 200).
#
# Usage:
#   .\setup.ps1 -LeanVersion 4.35.0
#   .\setup.ps1 -LeanVersion 4.35.0 -WithMathlib -MathlibTag v4.35.0
#
# Everything is installed *inside this directory* (sandbox-friendly).

param(
  [Parameter(Mandatory=$true)][string]$LeanVersion,
  [switch]$WithMathlib,
  [string]$MathlibTag = ""
)

$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = Join-Path $here ".lean"
New-Item -ItemType Directory -Force -Path $root | Out-Null

# ---- locate node ----
$node = (Get-Command node -ErrorAction SilentlyContinue).Source
if (-not $node) {
  $cand = "C:\Users\$env:USERNAME\.dsh\dsh-runtimes\dsh-primary-runtime\dependencies\node\bin\node.exe"
  if (Test-Path $cand) { $node = $cand } else { throw "node.exe not found; pass it via -NodePath" }
}
Write-Host "using node: $node"

$downloader = Join-Path $root "download.js"
@'
const https = require('https'), fs = require('fs'), path = require('path');
const [,, url, out] = process.argv;
function get(u, depth) {
  if (depth > 8) { console.error('too many redirects'); process.exit(1); }
  https.get(u, { headers: { 'User-Agent': 'curl/8' } }, res => {
    if (res.statusCode >= 300 && res.statusCode < 400) return get(res.headers.location, depth + 1);
    if (res.statusCode !== 200) { console.error('HTTP ' + res.statusCode + ' for ' + u); process.exit(1); }
    fs.mkdirSync(path.dirname(out), { recursive: true });
    const f = fs.createWriteStream(out);
    let n = 0;
    res.on('data', c => { n += c.length; process.stdout.write('\r' + Math.round(n / 1048576) + ' MB'); });
    res.pipe(f);
    f.on('finish', () => { f.close(); console.log('\ndone: ' + out + ' (' + n + ' bytes)'); });
  }).on('error', e => { console.error('ERR ' + e.message); process.exit(1); });
}
get(url, 0);
'@ | Set-Content -Encoding UTF8 $downloader

function Fetch($url, $out) {
  Write-Host "downloading $url"
  & $node $downloader $url $out
  if ($LASTEXITCODE -ne 0) { throw "download failed: $url" }
}

# ---- 1. Lean toolchain ----
$zipName = "lean-$LeanVersion-windows.zip"
$zipUrl  = "https://github.com/leanprover/lean4/releases/download/v$LeanVersion/$zipName"
$zipPath = Join-Path $root $zipName
if (-not (Test-Path $zipPath)) { Fetch $zipUrl $zipPath }
Write-Host "extracting..."
Expand-Archive -Path $zipPath -DestinationPath $root -Force
$leanBin = Get-ChildItem $root -Directory | Where-Object { $_.Name -like "lean-*windows*" } |
           Select-Object -First 1
if (-not $leanBin) { throw "unexpected archive layout under $root" }
$binDir = Join-Path $leanBin.FullName "bin"
Write-Host ""
Write-Host "Lean installed at: $binDir"
Write-Host "add it to PATH for this session with:"
Write-Host "  `$env:PATH = `"$binDir;`$env:PATH`""
Write-Host "  lean --version"

# ---- 2. (optional) Mathlib sources + deps ----
if ($WithMathlib) {
  if (-not $MathlibTag) { throw "-WithMathlib requires -MathlibTag (a mathlib4 tag, e.g. v4.35.0)" }
  $tb = Join-Path $root "mathlib4-$MathlibTag.tar.gz"
  Fetch "https://github.com/leanprover-community/mathlib4/archive/refs/tags/$MathlibTag.tar.gz" $tb
  $pkgDir = Join-Path $here ".lake\packages"
  New-Item -ItemType Directory -Force -Path $pkgDir | Out-Null
  tar -xzf $tb -C $pkgDir
  Rename-Item (Join-Path $pkgDir "mathlib4-$($MathlibTag.TrimStart('v'))") (Join-Path $pkgDir "mathlib") -Force
  Write-Host ""
  Write-Host "Mathlib sources unpacked to $pkgDir\mathlib"
  Write-Host "NOTE: its transitive deps (batteries, Qq, aesop, proofwidgets, importGraph, Cli)"
  Write-Host "      must be fetched the same way; and precompiled .olean caches are NOT included."
  Write-Host "      Building Mathlib from source takes hours."
}
