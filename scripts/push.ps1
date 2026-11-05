# push.ps1  create the GitHub repository (if absent) and push.
#
# Requires a GitHub Personal Access Token (PAT) for the account Huangjw-Math
# with the `repo` scope:  https://github.com/settings/tokens
#
# Why this script: in this environment `git` is configured with
# `http.sslBackend=schannel`, which fails with
#   schannel: AcquireCredentialsHandle failed: SEC_E_NO_CREDENTIALS
# Using `-c http.sslBackend=openssl` works (verified), and PowerShell/curl HTTPS
# is also blocked, so the repository is created through the GitHub REST API by
# Node.js (whose TLS stack works).
#
# Usage:
#   powershell -NoProfile -ExecutionPolicy Bypass -File "<repo>/scripts/push.ps1"
#   ./scripts/push.ps1 -Owner Huangjw-Math -Repo conjecture-a1-proof
#   ./scripts/push.ps1 -Token ghp_xxx          # non-interactive
#
# The token is used only on the single `git push` command line; it is never
# written to .git/config.

param(
  [string]$Owner = "Huangjw-Math",
  [string]$Repo  = "conjecture-a1-proof",
  [string]$Description = "A proof of Conjecture A.1 (Liu-Wu-Zhang-Zhou, CMP 375 (2020)): sharpness analysis, exact verification scripts, partial Lean 4 formalisation.",
  [string]$Token = "",          # optional: pass the PAT directly instead of being prompted
  [switch]$Private
)

$ErrorActionPreference = "Stop"
$here = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)   # repo root
if (-not (Test-Path (Join-Path $here "README.md"))) { $here = (Get-Location).Path }
Set-Location $here
Write-Host "repository root: $here"

# ---- git invocation -------------------------------------------------------------
# IMPORTANT: build the `-c` options as an ARRAY and apply them with splatting.
# `& $array ...` would treat the whole array as one command name and fail with
#   " "git -c http.sslBackend=openssl ..."  cmdlet ..."
$CA = "C:/Program Files/Git/mingw64/etc/ssl/certs/ca-bundle.crt"
$gitOpts = @()
if (Test-Path $CA) {
  $gitOpts += @("-c", "http.sslBackend=openssl", "-c", "http.sslCAInfo=$CA")
} else {
  $alt = "C:/Program Files/Git/mingw64/ssl/certs/ca-bundle.crt"
  if (Test-Path $alt) { $gitOpts += @("-c", "http.sslBackend=openssl", "-c", "http.sslCAInfo=$alt") }
}
$gitOpts += @("-c", "credential.helper=")        # never invoke Git Credential Manager
$env:GIT_TERMINAL_PROMPT = "0"
$env:GCM_INTERACTIVE = "never"

function Invoke-Git {
  & git @gitOpts @args
  return $LASTEXITCODE
}

if ((Invoke-Git --version) -ne 0) { throw "git not found in PATH" }

# ---- locate node (for the GitHub REST API call) ----
$node = (Get-Command node -ErrorAction SilentlyContinue).Source
if (-not $node) {
  $cand = "C:\Users\$env:USERNAME\.dsh\dsh-runtimes\dsh-primary-runtime\dependencies\node\bin\node.exe"
  if (Test-Path $cand) { $node = $cand } else { throw "node.exe not found (needed for the GitHub API call)" }
}

# ---- token ----
$tok = $Token
if ([string]::IsNullOrWhiteSpace($tok)) { $tok = $env:GITHUB_TOKEN }
if ([string]::IsNullOrWhiteSpace($tok)) { $tok = $env:GH_TOKEN }

if ([string]::IsNullOrWhiteSpace($tok)) {
  Write-Host ""
  Write-Host "A GitHub Personal Access Token (classic, scope 'repo') is required." -ForegroundColor Cyan
  Write-Host "  Create one: https://github.com/settings/tokens -> Generate new token (classic)" -ForegroundColor Cyan
  Write-Host "  Tick [repo], generate, copy the ghp_... string (shown only once)." -ForegroundColor Cyan
  Write-Host "  At the prompt: Ctrl+V to paste, then Enter. Nothing is echoed - that is normal." -ForegroundColor Cyan
  Write-Host ""
  $sec = Read-Host -Prompt "  Paste PAT for $Owner here and press Enter" -AsSecureString
  $tok = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
           [Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec))
}

# tolerate trailing newlines / spaces / accidental quotes from copy-paste
$tok = $tok.Trim().Trim('"').Trim("'")
if ([string]::IsNullOrWhiteSpace($tok)) { throw "empty token" }
if ($tok -notmatch '^(ghp_|github_pat_|gho_)') {
  Write-Warning "token does not start with ghp_ / github_pat_ ; continuing anyway."
}
Write-Host ("token accepted: {0}...{1} (length {2})" -f $tok.Substring(0,[Math]::Min(4,$tok.Length)),
            $tok.Substring($tok.Length-4), $tok.Length)

# ---- 1. create the repository if it does not exist (Node, JSON POST) ----
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

# ---- 2. branch name / remote ----
Invoke-Git branch -M main | Out-Null
Invoke-Git remote remove origin | Out-Null      # may fail if absent; ignore
Invoke-Git remote add origin "https://github.com/$Owner/$Repo.git" | Out-Null

# ---- 3. push (token only on this one command line, never stored) ----
Write-Host "pushing to https://github.com/$Owner/$Repo ..."
$rc = Invoke-Git push "https://$tok@github.com/$Owner/$Repo.git" main
if ($rc -ne 0) {
  Write-Host ""
  Write-Host "push failed (exit $rc)." -ForegroundColor Red
  Write-Host "  401/403 -> token wrong/expired or missing 'repo' scope" -ForegroundColor Yellow
  Write-Host "  'Repository not found' -> run:  git remote -v   and check Owner/Repo" -ForegroundColor Yellow
  throw "push failed"
}

# ---- 4. keep a token-free remote ----
Invoke-Git remote set-url origin "https://github.com/$Owner/$Repo.git" | Out-Null
Write-Host ""
Invoke-Git remote -v
Write-Host ""
Write-Host "done: https://github.com/$Owner/$Repo"
Write-Host "NOTE: the token was used only on the command line; it is not written to .git/config."
