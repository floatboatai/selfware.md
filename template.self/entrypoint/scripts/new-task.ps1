param(
    [Parameter(Mandatory = $true)]
    [string]$TaskId,
    [Parameter(Mandatory = $true)]
    [string]$Title,
    [string]$Owner = "human",
    [string]$OutputDir = "process/tasks"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$selfwareRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if (-not [System.IO.Path]::IsPathRooted($OutputDir)) {
    $OutputDir = Join-Path $selfwareRoot $OutputDir
}

if ($TaskId -notmatch "^TASK-[0-9]{3,}$") {
    throw "TaskId must match TASK-### format, for example TASK-001."
}

New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
$path = Join-Path $OutputDir ($TaskId + ".md")

if (Test-Path $path) {
    throw "Task already exists: $path"
}

$today = Get-Date -Format "yyyy-MM-dd"
$content = @"
# $TaskId - $Title

## Goal
- Define what user value this task delivers.

## Scope
- In scope:
- Out of scope:

## Plan
1. Analyze current state.
2. Implement changes.
3. Verify with checks/tests.
4. Summarize outcomes and risks.

## Acceptance
- [ ] Behavior implemented
- [ ] Tests or checks updated
- [ ] Docs updated if needed
- [ ] Human review completed

## Metadata
- Owner: $Owner
- Created: $today
- Status: draft
"@

Set-Content -Path $path -Value $content -Encoding UTF8
Write-Output "Created task file: $path"
