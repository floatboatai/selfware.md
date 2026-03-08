param(
    [int]$Port = 5273,
    [string]$Host = "127.0.0.1",
    [switch]$AllowNonLoopback,
    [string]$ServerPath = "runtime/server.py",
    [switch]$SkipDeps
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$selfwareRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if (-not [System.IO.Path]::IsPathRooted($ServerPath)) {
    $ServerPath = Join-Path $selfwareRoot $ServerPath
}

if (-not (Test-Path $ServerPath)) {
    throw "Server file not found: $ServerPath"
}

# --- 1. Detect Python runtime ---
$pythonCmd = $null
if (Get-Command uv -ErrorAction SilentlyContinue) {
    $useUv = $true
} else {
    $useUv = $false
}

if (Get-Command python -ErrorAction SilentlyContinue) {
    $pythonCmd = "python"
} elseif (Get-Command py -ErrorAction SilentlyContinue) {
    $pythonCmd = "py"
} elseif (-not $useUv) {
    throw "Python runtime not found. Install python, py launcher, or uv."
}

# --- 2. Create isolated environment ---
$venvDir = Join-Path $selfwareRoot ".venv"
$reqFile = Join-Path $selfwareRoot "runtime/requirements.txt"

if (-not $SkipDeps -and (Test-Path $reqFile)) {
    $hasContent = (Get-Content $reqFile | Where-Object { $_ -notmatch '^\s*(#|$)' }).Count -gt 0

    if ($hasContent) {
        if ($useUv) {
            # uv handles venv creation + install in one step
            Write-Host "[init] Installing dependencies with uv..."
            Push-Location $selfwareRoot
            try {
                & uv sync 2>$null
                if ($LASTEXITCODE -ne 0) {
                    & uv venv $venvDir
                    & uv pip install -r $reqFile
                }
            } finally {
                Pop-Location
            }
        } else {
            # Fallback: stdlib venv + pip
            if (-not (Test-Path $venvDir)) {
                Write-Host "[init] Creating virtual environment..."
                if ($pythonCmd -eq "py") {
                    & py -3 -m venv $venvDir
                } else {
                    & $pythonCmd -m venv $venvDir
                }
            }

            Write-Host "[init] Installing dependencies..."
            $pipPath = Join-Path $venvDir "Scripts/pip"
            if (-not (Test-Path $pipPath)) {
                $pipPath = Join-Path $venvDir "bin/pip"
            }
            & $pipPath install -r $reqFile --quiet
        }
        Write-Host "[init] Dependencies ready."
    }
}

# --- 3. Resolve python executable (prefer venv) ---
$venvPython = Join-Path $venvDir "Scripts/python.exe"
if (-not (Test-Path $venvPython)) {
    $venvPython = Join-Path $venvDir "bin/python"
}
if (Test-Path $venvPython) {
    $pythonCmd = $venvPython
}

# --- 4. Launch server ---
$runArgs = @()
$runArgs += $ServerPath
$runArgs += "--host"
$runArgs += $Host
$runArgs += "--port"
$runArgs += $Port
if ($AllowNonLoopback) {
    $runArgs += "--allow-non-loopback"
}

Push-Location $selfwareRoot
try {
    if ($useUv -and -not (Test-Path $venvPython)) {
        & uv run python @runArgs
    } else {
        & $pythonCmd @runArgs
    }
} finally {
    Pop-Location
}
