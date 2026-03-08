param(
    [Parameter(Mandatory = $true)]
    [string]$ArtifactPath,
    [string]$ExpectedSha256 = "",
    [string]$SignatureFile = "",
    [string]$PolicyFile = "governance/trust-policy.yaml"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-InputPath {
    param(
        [string]$PathValue,
        [string]$BasePath
    )

    if ([string]::IsNullOrWhiteSpace($PathValue)) {
        return $PathValue
    }

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return $PathValue
    }

    if (Test-Path $PathValue) {
        return (Resolve-Path $PathValue).Path
    }

    return (Join-Path $BasePath $PathValue)
}

$selfwareRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$ArtifactPath = Resolve-InputPath -PathValue $ArtifactPath -BasePath $selfwareRoot
$PolicyFile = Resolve-InputPath -PathValue $PolicyFile -BasePath $selfwareRoot
if (-not [string]::IsNullOrWhiteSpace($SignatureFile)) {
    $SignatureFile = Resolve-InputPath -PathValue $SignatureFile -BasePath $selfwareRoot
}

if (-not (Test-Path $ArtifactPath)) {
    throw "Artifact not found: $ArtifactPath"
}

$policyText = ""
if (Test-Path $PolicyFile) {
    $policyText = Get-Content -Path $PolicyFile -Raw -Encoding UTF8
}

if ([string]::IsNullOrWhiteSpace($ExpectedSha256)) {
    $sidecar = "$ArtifactPath.sha256"
    if (Test-Path $sidecar) {
        $firstLine = (Get-Content -Path $sidecar -TotalCount 1).Trim()
        if ($firstLine.Length -gt 0) {
            $ExpectedSha256 = ($firstLine -split '\s+')[0].Trim().ToLowerInvariant()
        }
    }
}

$actualHash = (Get-FileHash -Path $ArtifactPath -Algorithm SHA256).Hash.ToLowerInvariant()
$hashStatus = "unverified"
if (-not [string]::IsNullOrWhiteSpace($ExpectedSha256)) {
    if ($actualHash -eq $ExpectedSha256.ToLowerInvariant()) {
        $hashStatus = "match"
    } else {
        $hashStatus = "mismatch"
    }
}

$signatureStatus = "not_provided"
if (-not [string]::IsNullOrWhiteSpace($SignatureFile)) {
    if (-not (Test-Path $SignatureFile)) {
        throw "Signature file not found: $SignatureFile"
    }

    if (Get-Command gpg -ErrorAction SilentlyContinue) {
        & gpg --verify $SignatureFile $ArtifactPath *> $null
        if ($LASTEXITCODE -eq 0) {
            $signatureStatus = "verified"
        } else {
            $signatureStatus = "invalid"
        }
    } else {
        $signatureStatus = "cannot_verify_gpg_missing"
    }
}

$summary = [ordered]@{
    artifact_path = $ArtifactPath
    sha256 = $actualHash
    expected_sha256 = $ExpectedSha256
    hash_status = $hashStatus
    signature_file = $SignatureFile
    signature_status = $signatureStatus
    policy_file = $PolicyFile
    policy_loaded = -not [string]::IsNullOrWhiteSpace($policyText)
}

$summary | ConvertTo-Json -Depth 4

if ($hashStatus -eq "mismatch") {
    throw "Artifact hash mismatch."
}
if ($signatureStatus -eq "invalid") {
    throw "Artifact signature verification failed."
}
