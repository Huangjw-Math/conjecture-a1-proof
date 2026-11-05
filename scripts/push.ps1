# push.ps1 - create the GitHub repository (if absent) and push.
#
# Requires a GitHub Personal Access Token (PAT) for the account Huangjw-Math
# with the 'repo' scope:  https://github.com/settings/tokens
#
# Why this script:
#   * `git` is configured here with http.sslBackend=schannel, which fails with
#     "SEC_E_NO_CREDENTIALS" -> we force the openssl backend;
#   * credential.helper is cleared, because Git Credential Manager tries to open
#     a GUI / named pipe and fails in restricted terminals;
#   * PowerShell/curl HTTPS is blocked here, so the repository is created through
#     the GitHub REST API by Node.js (whose TLS stack works).
#
# Usage:
#   powershell -NoProfile -ExecutionPolicy Bypass -File "<repo>/scripts/push.ps1"
#   ./scripts/push.ps1 -Owner Huangjw-Math -Repo conjecture-a1-proof
#   ./scripts/push.ps1 -Token ghp_xxx      # non-interactive
#
# The token is used only on the single `git push` command line; it is never
# written to .git/config.

param(
  [string]$Owner = "Huangjw-Math",
  [string]$Repo  = "conjecture-a1-proof",
  [string]$Description = "A proof of Conjecture A.1 (Liu-Wu-Zhang-Zhou, CMP 375 (2020)): sharpness analysis, exact verification scripts, partial Lean 4 formalisation.",
  [string]$Token = "",
  [switch]$Private
)

$ErrorActionPreference = "Stop"

$here = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
if (-not (Test-Path (Join-Path $here "README.md"))) { $here = (Get-Location).Path }
Set-Location $here
Write-Host "repository root: $here"

# ---------------------------------------------------------------------------
# 1. locate git (do not rely on PATH alone)
# ---------------------------------------------------------------------------
$gitExe = $null
$cmd = Get-Command git -ErrorAction SilentlyContinue
if ($cmd) { $gitExe = $cmd.Source }
if (-not $gitExe) {
  $cands = @(
    "C:\Program Files\Git\cmd\git.exe",
    "C:\Program Files (x86)\Git\cmd\git.exe",
    (Join-Path $env:LOCALAPPDATA "Programs\Git\cmd\git.exe")
  )
  foreach ($c in $cands) { if (Test-Path $c) { $gitExe = $c; break } }
}
if (-not $gitExe) { throw "git.exe not found. Install Git for Windows and re-run." }
Write-Host "git: $gitExe"

# ---------------------------------------------------------------------------
# 2. git options (TLS backend + no credential helper), applied by splatting
# ---------------------------------------------------------------------------
$gitOpts = @()
foreach ($ca in @("C:/Program Files/Git/mingw64/etc/ssl/certs/ca-bundle.crt",
                  "C:/Program Files/Git/mingw64/ssl/certs/ca-bundle.crt")) {
  if (Test-Path $ca) { $gitOpts += @("-c", "http.sslBackend=openssl", "-c", "http.sslCAInfo=$ca"); break }
}
$gitOpts += @("-c", "credential.helper=")
$env:GIT_TERMINAL_PROMPT = "0"
$env:GCM_INTERACTIVE = "never"

# Runs git, swallows stdout (so stdout can never be mistaken for the exit code),
# and returns only the exit code as an int.  Diagnostics go to the host.
function Invoke-Git {
  param([Parameter(ValueFromRemainingArguments = $true)] $GitArgs)
  # git writes progress/summary lines ("To https://...", counting objects, ...)
  # to STDERR.  With $ErrorActionPreference = 'Stop' PowerShell would turn those
  # into terminating errors, so relax it for the duration of the native call.
  $eap = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  try {
    $out = & $gitExe @gitOpts @GitArgs 2>&1
    $code = $LASTEXITCODE
  } finally {
    $ErrorActionPreference = $eap
  }
  if ($out) { $out | ForEach-Object { Write-Host ("  " + $_) } }
  return [int]$code
}

if ((Invoke-Git --version) -ne 0) { throw "cannot run git" }
Write-Host ("git version: " + ((& $gitExe @gitOpts --version) -join " "))

# ---------------------------------------------------------------------------
# 3. locate node (for the GitHub API call)
# ---------------------------------------------------------------------------
$node = (Get-Command node -ErrorAction SilentlyContinue).Source
if (-not $node) {
  $cands = @(
    (Join-Path $env:USERPROFILE ".dsh\dsh-runtimes\dsh-primary-runtime\dependencies\node\bin\node.exe"),
    "C:\Program Files\nodejs\node.exe"
  )
  foreach ($c in $cands) { if (Test-Path $c) { $node = $c; break } }
}
if (-not $node) { throw "node.exe not found (needed for the GitHub API call)" }

# ---------------------------------------------------------------------------
# 4. token
# ---------------------------------------------------------------------------
$tok = $Token
if ([string]::IsNullOrWhiteSpace($tok)) { $tok = $env:GITHUB_TOKEN }
if ([string]::IsNullOrWhiteSpace($tok)) { $tok = $env:GH_TOKEN }

if ([string]::IsNullOrWhiteSpace($tok)) {
  Write-Host ""
  Write-Host "A GitHub Personal Access Token (classic, scope 'repo') is required." -ForegroundColor Cyan
  Write-Host "  Create: https://github.com/settings/tokens -> Generate new token (classic)" -ForegroundColor Cyan
  Write-Host "  Tick [repo]; copy the ghp_... string (shown only once)." -ForegroundColor Cyan
  Write-Host "  At the prompt: Ctrl+V then Enter. Nothing is echoed - that is normal." -ForegroundColor Cyan
  Write-Host ""
  $sec = Read-Host -Prompt "  Paste PAT for $Owner here and press Enter" -AsSecureString
  $tok = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
           [Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec))
}
$tok = $tok.Trim().Trim('"').Trim("'")
if ([string]::IsNullOrWhiteSpace($tok)) { throw "empty token" }
if ($tok -notmatch '^(ghp_|github_pat_|gho_)') { Write-Warning "token prefix unusual; continuing." }
Write-Host ("token accepted: {0}...{1} (length {2})" -f $tok.Substring(0, [Math]::Min(4, $tok.Length)),
            $tok.Substring($tok.Length - 4), $tok.Length)

# ---------------------------------------------------------------------------
# 5. create the repository if absent
# ---------------------------------------------------------------------------
$api = Join-Path $env:TEMP "gh_create_repo.js"
@'
const https = require('https');
const [,, token, owner, repo, desc, priv] = process.argv;
const body = JSON.stringify({ name: repo, description: desc, private: priv === 'true', auto_init: false });
const req = https.request({
  hostname: 'api.github.com', path: '/user/repos', method: 'POST',
  headers: {
    'User-Agent': 'push-script', 'Authorization': 'token ' + token,
    'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(body),
    'Accept': 'application/vnd.github+json'
  }
}, res => {
  let d = ''; res.on('data', c => d += c); res.on('end', () => {
    let j = null; try { j = JSON.parse(d); } catch (e) {}
    if (res.statusCode === 201) console.log('CREATED ' + j.full_name + ' -> ' + j.html_url);
    else if (res.statusCode === 422 && /already exists/i.test(d)) console.log('EXISTS ' + owner + '/' + repo);
    else { console.log('ERROR ' + res.statusCode + ': ' + d.slice(0, 400)); process.exit(1); }
  });
});
req.on('error', e => { console.log('ERR ' + e.message); process.exit(1); });
req.write(body); req.end();
'@ | Set-Content -Encoding UTF8 $api

$privArg = if ($Private) { "true" } else { "false" }
& $node $api $tok $Owner $Repo $Description $privArg
if ($LASTEXITCODE -ne 0) { throw "repository creation failed (token needs the 'repo' scope)" }

# ---------------------------------------------------------------------------
# 6. branch + remote
# ---------------------------------------------------------------------------
Invoke-Git branch -M main | Out-Null
Invoke-Git remote remove origin | Out-Null
if ((Invoke-Git remote add origin "https://github.com/$Owner/$Repo.git") -ne 0) {
  Invoke-Git remote set-url origin "https://github.com/$Owner/$Repo.git" | Out-Null
}

# ---------------------------------------------------------------------------
# 7. push (token only on this command line)
# ---------------------------------------------------------------------------
Write-Host "pushing to https://github.com/$Owner/$Repo ..."
$rc = Invoke-Git push "https://$tok@github.com/$Owner/$Repo.git" main
if ($rc -ne 0) {
  Write-Host ""
  Write-Host "push failed (exit $rc)." -ForegroundColor Red
  Write-Host "  401/403 -> token wrong/expired or missing 'repo' scope" -ForegroundColor Yellow
  Write-Host "  'Repository not found' -> check -Owner/-Repo" -ForegroundColor Yellow
  throw "push failed"
}

# ---------------------------------------------------------------------------
# 8. keep a token-free remote
# ---------------------------------------------------------------------------
Invoke-Git remote set-url origin "https://github.com/$Owner/$Repo.git" | Out-Null
Write-Host ""
& $gitExe @gitOpts remote -v
Write-Host ""
Write-Host "done: https://github.com/$Owner/$Repo"
Write-Host "NOTE: the token was used only on the command line; it is not written to .git/config."
