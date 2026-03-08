param(
    [string]$Actor = "default-agent",
    [Parameter(Mandatory = $true)]
    [string]$Intent,
    [Parameter(Mandatory = $true)]
    [string[]]$Paths,
    [Parameter(Mandatory = $true)]
    [string]$Summary,
    [string]$RollbackHint = "manual",
    [string]$ChangesFile = "content/memory/changes.md"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$selfwareRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if (-not [System.IO.Path]::IsPathRooted($ChangesFile)) {
    $ChangesFile = Join-Path $selfwareRoot $ChangesFile
}

if (-not (Test-Path $ChangesFile)) {
    New-Item -ItemType Directory -Path (Split-Path -Parent $ChangesFile) -Force | Out-Null
    Set-Content -Path $ChangesFile -Encoding UTF8 -Value "# Change Records`n"
}

$timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$changeId = "CHG-{0}-{1}" -f (Get-Date -Format "yyyyMMdd-HHmmss"), (Get-Random -Minimum 1000 -Maximum 9999)

$lines = @()
$lines += ""
$lines += "## $changeId"
$lines += "- timestamp: $timestamp"
$lines += "- actor: $Actor"
$lines += "- intent: $Intent"
$lines += "- paths:"
foreach ($p in $Paths) {
    $lines += "  - $p"
}
$lines += "- summary: $Summary"
$lines += "- rollback_hint: $RollbackHint"
$lines += ""

Add-Content -Path $ChangesFile -Value ($lines -join "`n") -Encoding UTF8
Write-Output "Appended change record: $changeId"
Write-Output "Change file: $ChangesFile"
