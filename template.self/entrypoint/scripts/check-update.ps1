param(
    [string]$RemoteUrl = "",
    [string]$LocalProtocolPath = "selfware.md",
    [string]$ManifestPath = "manifest.md",
    [switch]$Apply,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-RelativePath {
    param(
        [string]$BasePath,
        [string]$TargetPath
    )

    $base = [System.IO.Path]::GetFullPath($BasePath)
    if (-not $base.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $base += [System.IO.Path]::DirectorySeparatorChar
    }

    $target = [System.IO.Path]::GetFullPath($TargetPath)
    $baseUri = New-Object System.Uri($base)
    $targetUri = New-Object System.Uri($target)
    $relativeUri = $baseUri.MakeRelativeUri($targetUri)
    return [System.Uri]::UnescapeDataString($relativeUri.ToString()).Replace('\', '/')
}

function Get-ManifestValue {
    param(
        [string[]]$Lines,
        [string]$Key
    )

    $pattern = '^' + [regex]::Escape($Key) + ':\s*(.+)$'
    foreach ($line in $Lines) {
        if ($line -match $pattern) {
            return $Matches[1].Trim()
        }
    }
    return ""
}

function Get-Sha256Text {
    param([string]$Text)

    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $hash = $sha.ComputeHash($bytes)
    } finally {
        $sha.Dispose()
    }
    return ([System.BitConverter]::ToString($hash)).Replace("-", "").ToLowerInvariant()
}

function Get-RemoteText {
    param([string]$Url)

    $client = New-Object System.Net.WebClient
    $client.Encoding = [System.Text.Encoding]::UTF8
    $client.Headers["User-Agent"] = "selfware-template-check-update/1.0"
    try {
        return $client.DownloadString($Url)
    } finally {
        $client.Dispose()
    }
}

$selfwareRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

if (-not [System.IO.Path]::IsPathRooted($ManifestPath)) {
    $ManifestPath = Join-Path $selfwareRoot $ManifestPath
}
if (-not [System.IO.Path]::IsPathRooted($LocalProtocolPath)) {
    $LocalProtocolPath = Join-Path $selfwareRoot $LocalProtocolPath
}
if (-not (Test-Path $ManifestPath)) {
    throw "Manifest not found: $ManifestPath"
}
if (-not (Test-Path $LocalProtocolPath)) {
    throw "Local protocol file not found: $LocalProtocolPath"
}

$manifestLines = Get-Content -Path $ManifestPath
if ([string]::IsNullOrWhiteSpace($RemoteUrl)) {
    $RemoteUrl = Get-ManifestValue -Lines $manifestLines -Key "Update-Default-Source"
}
if ([string]::IsNullOrWhiteSpace($RemoteUrl)) {
    $RemoteUrl = Get-ManifestValue -Lines $manifestLines -Key "Protocol-Source"
}
if ([string]::IsNullOrWhiteSpace($RemoteUrl)) {
    throw "Remote update source is empty. Set Update-Default-Source in manifest.md or pass -RemoteUrl."
}

Write-Output "Update source: $RemoteUrl"

$remoteText = Get-RemoteText -Url $RemoteUrl
$localText = Get-Content -Path $LocalProtocolPath -Raw -Encoding UTF8

$localHash = Get-Sha256Text -Text $localText
$remoteHash = Get-Sha256Text -Text $remoteText

Write-Output "Local sha256 : $localHash"
Write-Output "Remote sha256: $remoteHash"

if ($localHash -eq $remoteHash) {
    Write-Output "No update detected."
    return
}

$localLines = $localText -split "`r?`n"
$remoteLines = $remoteText -split "`r?`n"
$diff = Compare-Object -ReferenceObject $localLines -DifferenceObject $remoteLines
$added = ($diff | Where-Object { $_.SideIndicator -eq '=>' }).Count
$removed = ($diff | Where-Object { $_.SideIndicator -eq '<=' }).Count

Write-Output "Update detected. Added lines: $added | Removed lines: $removed"
Write-Output "Diff preview (first 30 lines):"
$diff | Select-Object -First 30 | ForEach-Object {
    if ($_.SideIndicator -eq '=>') {
        Write-Output ("+ " + $_.InputObject)
    } else {
        Write-Output ("- " + $_.InputObject)
    }
}

if (-not $Apply) {
    Write-Output "Apply not requested. Use -Apply to proceed with No Silent Apply flow."
    return
}

if (-not $Force) {
    $confirm = Read-Host "Type APPLY to accept this update"
    if ($confirm -ne "APPLY") {
        throw "Update apply canceled by user."
    }
}

$dateFolder = Get-Date -Format "yyyy-MM-dd"
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupDir = Join-Path $selfwareRoot (Join-Path "process/runs" $dateFolder)
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

$backupName = "PROTOCOL-BACKUP-$stamp-" + (Split-Path -Path $LocalProtocolPath -Leaf)
$backupPath = Join-Path $backupDir $backupName
Copy-Item -Path $LocalProtocolPath -Destination $backupPath -Force

Set-Content -Path $LocalProtocolPath -Value $remoteText -Encoding UTF8

$appendScript = Join-Path $PSScriptRoot "append-change-record.ps1"
if (Test-Path $appendScript) {
    $localRelative = Get-RelativePath -BasePath $selfwareRoot -TargetPath $LocalProtocolPath
    $backupRelative = Get-RelativePath -BasePath $selfwareRoot -TargetPath $backupPath
    & $appendScript `
        -Actor "default-agent" `
        -Intent "apply_protocol_update" `
        -Paths @($localRelative, $backupRelative) `
        -Summary "Applied protocol update from remote source with backup and user confirmation." `
        -RollbackHint "Restore protocol file from backup: $backupRelative"
}

Write-Output "Applied update. Backup created: $backupPath"
