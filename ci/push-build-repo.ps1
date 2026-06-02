# DISPATCH-512 Gate 1 — push the iOS-APP-ONLY build repo + set signing secrets (run AFTER `gh auth login`).
# ★ IRON-WALL: this egresses ONLY kolbo-ios/ (a public client, no secret). The kolbo-mdm / policy-server / MDM is
# NEVER touched — a fresh git repo is built from a COPY of kolbo-ios alone. Signing assets go in as encrypted GitHub
# SECRETS, never the repo.
param(
  [string]$RepoName = 'kolbo-ios-build',
  [switch]$Public,
  [switch]$SetSecrets,
  [string]$P12, [string]$P12Password = '', [string]$Profile
)
$ErrorActionPreference = 'Stop'
$gh = (Get-Command gh -ErrorAction SilentlyContinue).Source
if (-not $gh) { Write-Error 'gh not installed'; exit 1 }
$owner = (& gh api user --jq .login) 2>$null
if (-not $owner) { Write-Error 'not logged in — run: gh auth login'; exit 1 }
$repo = "$owner/$RepoName"

if ($SetSecrets) {
  if (-not (Test-Path $P12) -or -not (Test-Path $Profile)) { Write-Error 'set -P12 <file> and -Profile <file>'; exit 1 }
  # base64 in-memory; the plaintext value reaches ONLY gh's encrypted secret store, never disk/repo/log.
  [Convert]::ToBase64String([IO.File]::ReadAllBytes($P12))     | & gh secret set IOS_SIGNING_CERT_P12      --repo $repo
  $P12Password                                                 | & gh secret set IOS_SIGNING_CERT_PASSWORD --repo $repo
  [Convert]::ToBase64String([IO.File]::ReadAllBytes($Profile)) | & gh secret set IOS_PROVISIONING_PROFILE  --repo $repo
  "secrets set on $repo : IOS_SIGNING_CERT_P12, IOS_SIGNING_CERT_PASSWORD, IOS_PROVISIONING_PROFILE"
  "re-run the build:  gh workflow run 'Build iOS .ipa' --repo $repo"
  return
}

# --- push mode: build a fresh iOS-app-only repo from a COPY (iron-wall) ---
$src = 'D:\kolbo-mdm\kolbo-ios'
$stage = Join-Path $env:TEMP ("kolbo-ios-build-" + [Guid]::NewGuid().ToString('N').Substring(0,8))
Copy-Item $src $stage -Recurse
Push-Location $stage
try {
  & git init -b main | Out-Null
  & git add -A
  & git commit -q -m 'KolBo iOS app (public client) — free macOS-CI build' | Out-Null
  $vis = if ($Public) { '--public' } else { '--private' }
  & gh repo create $RepoName $vis --source=. --remote=origin --push
  "pushed $repo — the workflow runs now (unsigned compile-check until the signing secrets are set)."
  "watch:  gh run watch --repo $repo"
} finally { Pop-Location }
