param(
    [Parameter(Position = 0)][string]$HostName,
    [Parameter(Position = 1)][string]$Name,
    [Parameter(Position = 2)][string]$User,
    [Alias('help')][switch]$h
)

$scriptname = Split-Path -Leaf $PSCommandPath

if ($h -or -not $HostName -or $HostName -in '--help', '/?') {
    Write-Host @"
How to use: $scriptname <domain> [key_name] [username]
<...> - required
[...] - optional

  ʕっ•ᴥ•ʔっ

"@
    exit 0
}

if (-not $Name) { $Name = $HostName }
if (-not $User) { $User = 'git' }

$sshDir = Join-Path $HOME '.ssh'
$config = Join-Path $sshDir 'config'
$key    = Join-Path $sshDir $Name

$pattern = "^\s*Host\s.*\b$([regex]::Escape($HostName))\b"
if ((Test-Path $config) -and (Select-String -Path $config -Pattern $pattern -Quiet)) {
    Write-Host "~/.ssh/config already contains section for $host — remove it or edit manually." -ForegroundColor Red
    exit 1
}

New-Item -ItemType Directory -Force -Path $sshDir | Out-Null

ssh-keygen -t ed25519 -f $key -C "$env:USERNAME@$Name"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$block = "`nHost $HostName`n    User $User`n    IdentityFile ~/.ssh/$Name`n    IdentitiesOnly yes`n    AddKeysToAgent yes`n"
[IO.File]::AppendAllText($config, $block, (New-Object Text.UTF8Encoding $false))

Get-Content "$key.pub" | Set-Clipboard
Write-Host "Public key is in the clipboard. If not, copy the fingerprint above"