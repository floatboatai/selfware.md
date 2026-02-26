param(
    [Parameter(Mandatory = $true)]
    [string]$TaskId,
    [string]$AgentId = "default-agent",
    [string]$RunsRoot = "process/runs"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

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

Write-Output "Created run workspace: $runPath"
