$ErrorActionPreference = 'Stop'
$repo = 'https://github.com/<user>/dotfiles'
$dest = "$env:USERPROFILE\dotfiles"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    winget install --id Git.Git -e --silent --accept-source-agreements --accept-package-agreements
    # 現セッションに PATH を反映
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [Environment]::GetEnvironmentVariable('Path', 'User')
}

git config --global http.sslBackend schannel   # 社内 CA を Windows 証明書ストアで解決

if (Test-Path "$dest\.git") { git -C $dest pull --ff-only }
else                        { git clone $repo $dest }

$bash = Join-Path (Split-Path (Split-Path (Get-Command git).Source)) 'bin\bash.exe'
Push-Location $dest
try { & $bash -l ./setup.sh } finally { Pop-Location }
