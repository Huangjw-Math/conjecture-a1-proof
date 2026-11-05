# push.ps1 — create the GitHub repository (if absent) and push.
#
# Requires a GitHub Personal Access Token (PAT) for the account Huangjw-Math
# with the `repo` scope:  https://github.com/settings/tokens
#
# Why this script: in this environment `git` is configured with
# `http.sslBackend=schannel`, which fails with
#   schannel: AcquireCredentialsHandle failed: SEC_E_NO_CREDENTIALS
# Using `-c http.sslBackend=openssl` works (verified: `git ls-remote` succeeds),
# and PowerShell/curl HTTPS is also blocked, so the repo is created through the
# GitHub REST API using Node.js (whose TLS stack works).
#
# Usage:
#   .\scripts\push.ps1 -Owner Huangjw-Math -Repo conjecture-a1-proof
#   (you will be prompted for the token; it is never echoed nor written to disk)

param(
  [string]$Owner = "Huangjw-Math",
  [string]$Repo  = "conjecture-a1-proof",
  [string]$Description = "A proof of Conjecture A.1 (Liu-Wu-Zhang-Zhou, CMP 375 (2020)): sharpness analysis, exact verification scripts, partial Lean 4 formalisation.",
  [switch]$Private
)

$ErrorActionPreference = "Stop"
$here = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)   # repo root
Set-Location $here

$CA = "C:/Program Files/Git/mingw64/etc/ssl/certs/ca-bundle.crt"
# - schannel is broken in this environment -> force the openssl backend
# - credential.helper is cleared so that Git Credential Manager is never invoked
#   (it would try to open a GUI / named pipe and can fail with "signal pipe" errors)
$GIT = @("git", "-c", "http.sslBackend=openssl", "-c", "http.sslCAInfo=$CA",
         "-c", "credential.helper=")
$env:GIT_TERMINAL_PROMPT = "0"
$env:GCM_INTERACTIVE = "never"

$node = (Get-Command node -ErrorAction SilentlyContinue).Source
if (-not $node) {
  $cand = "C:\Users\$env:USERNAME\.dsh\dsh-runtimes\dsh-primary-runtime\dependencies\node\bin\node.exe"
  if (Test-Path $cand) { $node = $cand } else { throw "node.exe not found (needed for the GitHub API call)" }
}

$sec = Read-Host -Prompt "GitHub PAT for $Owner (input hidden)" -AsSecureString
$tok = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
         [Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec))
if ([string]::IsNullOrWhiteSpace($tok)) { throw "empty token" }

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
if ($LASTEXITCODE -ne 0) { throw "repository creation failed" }

# ---- 2. make sure we are on `main` and have a commit ----
& $GIT branch -M main 2>$null
& $GIT remote remove origin 2>$null
& $GIT remote add origin "https://github.com/$Owner/$Repo.git"

# ---- 3. push (token only in this one command line, never stored) ----
& $GIT push "https://$tok@github.com/$Owner/$Repo.git" main
if ($LASTEXITCODE -ne 0) { throw "push failed" }

# ---- 4. keep a token-free remote ----
& $GIT remote set-url origin "https://github.com/$Owner/$Repo.git"
& $GIT remote -v

Write-Host ""
Write-Host "done: https://github.com/$Owner/$Repo"
Write-Host "NOTE: the token was used only on the command line; it is not written to .git/config."
