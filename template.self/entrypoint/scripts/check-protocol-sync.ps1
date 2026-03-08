param(
    [string]$EnglishPath = "selfware.md",
    [string]$ChinesePath = "selfware-zh.md"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-VersionLine {
    param([string[]]$Lines)

    foreach ($line in $Lines) {
        if ($line -match '^Version:\s*(.+)$') {
            return $Matches[1].Trim()
        }
    }
    return ""
}

function Get-NumberedSections {
    param([string[]]$Lines)

    $items = @()
    foreach ($line in $Lines) {
        if ($line -match '^##\s+([0-9]+(?:\.[0-9]+)?)') {
            $items += $Matches[1]
        }
    }
    return $items
}

$selfwareRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if (-not [System.IO.Path]::IsPathRooted($EnglishPath)) {
    $EnglishPath = Join-Path $selfwareRoot $EnglishPath
}
if (-not [System.IO.Path]::IsPathRooted($ChinesePath)) {
    $ChinesePath = Join-Path $selfwareRoot $ChinesePath
}

if (-not (Test-Path $EnglishPath)) {
    throw "English protocol file not found: $EnglishPath"
}
if (-not (Test-Path $ChinesePath)) {
    throw "Chinese protocol file not found: $ChinesePath"
}

$enLines = Get-Content -Path $EnglishPath
$zhLines = Get-Content -Path $ChinesePath

$enVersion = Get-VersionLine -Lines $enLines
$zhVersion = Get-VersionLine -Lines $zhLines

$enSections = Get-NumberedSections -Lines $enLines
$zhSections = Get-NumberedSections -Lines $zhLines

$hasError = $false

if ($enVersion -ne $zhVersion) {
    Write-Error "Version mismatch: EN='$enVersion' ZH='$zhVersion'"
    $hasError = $true
}

if ($enSections.Count -ne $zhSections.Count) {
    Write-Error "Section count mismatch: EN=$($enSections.Count) ZH=$($zhSections.Count)"
    $hasError = $true
}

$max = [Math]::Min($enSections.Count, $zhSections.Count)
for ($i = 0; $i -lt $max; $i++) {
    if ($enSections[$i] -ne $zhSections[$i]) {
        Write-Error "Section number mismatch at index ${i}: EN=$($enSections[$i]) ZH=$($zhSections[$i])"
        $hasError = $true
    }
}

if ($hasError) {
    throw "Protocol sync check failed."
}

Write-Output "Protocol sync check passed."
Write-Output "Version: $enVersion"
Write-Output "Numbered sections: $($enSections.Count)"
