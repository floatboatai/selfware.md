param(
    [string]$OutputPath = "",
    [string]$ManifestPath = "manifest.md",
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

function Get-ManifestSectionValues {
    param(
        [string[]]$Lines,
        [string]$SectionTitle
    )

    $values = @()
    $inSection = $false
    $header = "## $SectionTitle"

    foreach ($line in $Lines) {
        $trimmed = $line.Trim()

        if ($trimmed -match '^##\s+') {
            if ($inSection) {
                break
            }
            if ($trimmed -eq $header) {
                $inSection = $true
            }
            continue
        }

        if ($inSection -and $trimmed.StartsWith("- ")) {
            $values += $trimmed.Substring(2).Trim()
        }
    }

    return $values
}

function Test-GlobMatch {
    param(
        [string]$RelativePath,
        [string]$Pattern
    )

    $path = $RelativePath.Replace('\\', '/').Trim()
    $glob = $Pattern.Replace('\\', '/').Trim()
    $wild = [System.Management.Automation.WildcardPattern]::new($glob, [System.Management.Automation.WildcardOptions]::IgnoreCase)
    return $wild.IsMatch($path)
}

$selfwareRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$repoRoot = Split-Path -Parent $selfwareRoot

if (-not [System.IO.Path]::IsPathRooted($ManifestPath)) {
    $ManifestPath = Join-Path $selfwareRoot $ManifestPath
}
if (-not (Test-Path $ManifestPath)) {
    throw "Manifest not found: $ManifestPath"
}

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $distDir = Join-Path $repoRoot "dist"
    $OutputPath = Join-Path $distDir ((Split-Path $selfwareRoot -Leaf) + ".self")
} elseif (-not [System.IO.Path]::IsPathRooted($OutputPath)) {
    $OutputPath = Join-Path $repoRoot $OutputPath
}

$manifestLines = Get-Content -Path $ManifestPath
$include = Get-ManifestSectionValues -Lines $manifestLines -SectionTitle "Pack Include"
$exclude = Get-ManifestSectionValues -Lines $manifestLines -SectionTitle "Pack Exclude"
$required = Get-ManifestSectionValues -Lines $manifestLines -SectionTitle "Pack Required"

if ($include.Count -eq 0) {
    $include = @("**")
}

$defaultExclude = @(
    ".git/**",
    ".DS_Store",
    "__pycache__/**",
    "*.pyc",
    "node_modules/**",
    ".venv/**",
    "dist/**",
    "build/**",
    "output/**",
    "*.log",
    "*.tmp"
)

$allExclude = @($exclude + $defaultExclude | Select-Object -Unique)

$allFiles = Get-ChildItem -Path $selfwareRoot -Recurse -File
$includedFiles = @()

foreach ($file in $allFiles) {
    $relativePath = Get-RelativePath -BasePath $selfwareRoot -TargetPath $file.FullName

    $isIncluded = $false
    foreach ($pattern in $include) {
        if (Test-GlobMatch -RelativePath $relativePath -Pattern $pattern) {
            $isIncluded = $true
            break
        }
    }

    if (-not $isIncluded) {
        continue
    }

    $isExcluded = $false
    foreach ($pattern in $allExclude) {
        if (Test-GlobMatch -RelativePath $relativePath -Pattern $pattern) {
            $isExcluded = $true
            break
        }
    }

    if (-not $isExcluded) {
        $includedFiles += $relativePath
    }
}

$includedFiles = $includedFiles | Sort-Object -Unique

if ($required.Count -gt 0) {
    foreach ($requiredItem in $required) {
        $matched = $false
        foreach ($candidate in $includedFiles) {
            if (Test-GlobMatch -RelativePath $candidate -Pattern $requiredItem) {
                $matched = $true
                break
            }
        }
        if (-not $matched) {
            throw "Missing required pack item: $requiredItem"
        }
    }
}

if ($includedFiles.Count -eq 0) {
    throw "Pack include resolved to zero files."
}

$totalBytes = 0
foreach ($item in $includedFiles) {
    $filePath = Join-Path $selfwareRoot ($item.Replace('/', '\\'))
    $totalBytes += (Get-Item $filePath).Length
}

Write-Output "Pack include files: $($includedFiles.Count)"
$includedFiles | ForEach-Object { Write-Output "  - $_" }
Write-Output ""
Write-Output "Pack exclude rules:"
$allExclude | ForEach-Object { Write-Output "  - $_" }
Write-Output ""
Write-Output "Estimated payload size: $totalBytes bytes"
Write-Output "Output container: $OutputPath"

if (-not $Force) {
    $confirm = Read-Host "Type YES to confirm packaging"
    if ($confirm -ne "YES") {
        throw "Pack canceled by user."
    }
}

$outputDir = Split-Path -Parent $OutputPath
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("selfware-pack-" + [Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

try {
    foreach ($relativePath in $includedFiles) {
        $source = Join-Path $selfwareRoot ($relativePath.Replace('/', '\\'))
        $target = Join-Path $tempRoot ($relativePath.Replace('/', '\\'))
        New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force | Out-Null
        Copy-Item -Path $source -Destination $target -Force
    }

    $containerManifestDir = Join-Path $tempRoot "self"
    New-Item -ItemType Directory -Path $containerManifestDir -Force | Out-Null

    $generatedAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    $containerManifest = @"
Selfware-Container: zip
Selfware-Container-Version: 1
Protocol-Source: https://floatboat.ai/selfware.md
Local-Protocol-Path: selfware.md
Canonical-Data-Scope: content/
Generated-At: $generatedAt
Generated-By: entrypoint/scripts/pack-self.ps1
"@
    Set-Content -Path (Join-Path $containerManifestDir "manifest.md") -Value $containerManifest -Encoding UTF8

    if (Test-Path $OutputPath) {
        Remove-Item -Path $OutputPath -Force
    }

    $archiveOutputPath = $OutputPath
    $useRename = $false
    if ([System.IO.Path]::GetExtension($OutputPath).ToLowerInvariant() -ne ".zip") {
        $archiveOutputPath = $OutputPath + ".zip"
        $useRename = $true
    }

    if (Test-Path $archiveOutputPath) {
        Remove-Item -Path $archiveOutputPath -Force
    }

    Push-Location $tempRoot
    try {
        Compress-Archive -Path * -DestinationPath $archiveOutputPath -Force
    } finally {
        Pop-Location
    }

    if ($useRename) {
        if (Test-Path $OutputPath) {
            Remove-Item -Path $OutputPath -Force
        }
        Move-Item -Path $archiveOutputPath -Destination $OutputPath -Force
    }
} finally {
    if (Test-Path $tempRoot) {
        Remove-Item -Path $tempRoot -Recurse -Force
    }
}

$appendScript = Join-Path $PSScriptRoot "append-change-record.ps1"
if (Test-Path $appendScript) {
    $outputRelative = Get-RelativePath -BasePath $selfwareRoot -TargetPath $OutputPath
    & $appendScript `
        -Actor "default-agent" `
        -Intent "pack_self" `
        -Paths @("manifest.md", $outputRelative) `
        -Summary "Packed template.self into a distributable .self container." `
        -RollbackHint "Delete generated container: $outputRelative"
}

Write-Output "Pack completed: $OutputPath"
