param(
    [Parameter(Mandatory = $true)]
    [string]$TaskId,
    [string]$AgentId = "default-agent",
    [string]$RunsRoot = "process/runs"
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

$selfwareRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if (-not [System.IO.Path]::IsPathRooted($RunsRoot)) {
    $RunsRoot = Join-Path $selfwareRoot $RunsRoot
}
$repoRoot = Split-Path -Parent $selfwareRoot

if ($TaskId -notmatch "^TASK-[0-9]{3,}$") {
    throw "TaskId must match TASK-### format, for example TASK-001."
}

$dateFolder = Get-Date -Format "yyyy-MM-dd"
$dayPath = Join-Path $RunsRoot $dateFolder
New-Item -ItemType Directory -Path $dayPath -Force | Out-Null

$existingRuns = Get-ChildItem -Path $dayPath -Directory -Filter "RUN-*" -ErrorAction SilentlyContinue
$maxRunNumber = 0

foreach ($run in $existingRuns) {
    if ($run.Name -match "^RUN-([0-9]+)$") {
        $n = [int]$Matches[1]
        if ($n -gt $maxRunNumber) {
            $maxRunNumber = $n
        }
    }
}

$nextRunNumber = $maxRunNumber + 1
$runId = "RUN-{0:d3}" -f $nextRunNumber
$runPath = Join-Path $dayPath $runId

if (Test-Path $runPath) {
    throw "Run path already exists: $runPath"
}

New-Item -ItemType Directory -Path $runPath -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $runPath "artifacts") -Force | Out-Null

$baseCommit = "unknown"
try {
    $baseCommit = (git -C $repoRoot rev-parse HEAD).Trim()
} catch {
    $baseCommit = "unknown"
}

$nowUtc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
$manifest = [ordered]@{
    run_id = $runId
    task_id = $TaskId
    agent_id = $AgentId
    started_at = $nowUtc
    status = "running"
    base_commit = $baseCommit
    end_commit = ""
    notes = ""
}

$manifest | ConvertTo-Json | Set-Content -Path (Join-Path $runPath "manifest.json") -Encoding UTF8
Set-Content -Path (Join-Path $runPath "plan.md") -Encoding UTF8 -Value "# Plan`n`n1. "
Set-Content -Path (Join-Path $runPath "decisions.md") -Encoding UTF8 -Value "# Decisions`n"
Set-Content -Path (Join-Path $runPath "result.md") -Encoding UTF8 -Value "# Result`n"
New-Item -ItemType File -Path (Join-Path $runPath "log.jsonl") -Force | Out-Null

$appendScript = Join-Path $PSScriptRoot "append-change-record.ps1"
if (Test-Path $appendScript) {
    $relativeRunPath = Get-RelativePath -BasePath $selfwareRoot -TargetPath $runPath
    $createdPaths = @(
        "$relativeRunPath/manifest.json",
        "$relativeRunPath/plan.md",
        "$relativeRunPath/decisions.md",
        "$relativeRunPath/result.md",
        "$relativeRunPath/log.jsonl"
    )

    & $appendScript `
        -Actor $AgentId `
        -Intent "start_run" `
        -Paths $createdPaths `
        -Summary "Created run workspace $runId for task $TaskId." `
        -RollbackHint "Delete run workspace directory: $relativeRunPath"
}

Write-Output "Created run workspace: $runPath"
