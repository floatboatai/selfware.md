#!/usr/bin/env bash
set -euo pipefail

# Defaults
artifact_path=""
expected_sha256=""
signature_file=""
policy_file="governance/trust-policy.yaml"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --artifact-path) artifact_path="$2"; shift 2 ;;
        --expected-sha256) expected_sha256="$2"; shift 2 ;;
        --signature-file) signature_file="$2"; shift 2 ;;
        --policy-file) policy_file="$2"; shift 2 ;;
        *) echo "Unknown argument: $1" >&2; exit 1 ;;
    esac
done

if [[ -z "$artifact_path" ]]; then
    echo "Error: --artifact-path is required." >&2; exit 1
fi

selfware_root="$(cd "$(dirname "$0")/../.." && pwd)"

resolve_path() {
    local p="$1"
    if [[ -z "$p" ]]; then echo "$p"; return; fi
    if [[ "$p" == /* ]]; then echo "$p"; return; fi
    if [[ -e "$p" ]]; then realpath "$p"; return; fi
    echo "$selfware_root/$p"
}

artifact_path="$(resolve_path "$artifact_path")"
policy_file="$(resolve_path "$policy_file")"
if [[ -n "$signature_file" ]]; then
    signature_file="$(resolve_path "$signature_file")"
fi

if [[ ! -f "$artifact_path" ]]; then
    echo "Artifact not found: $artifact_path" >&2
    exit 1
fi

policy_loaded=false
if [[ -f "$policy_file" ]]; then
    policy_loaded=true
fi

# Try sidecar sha256
if [[ -z "$expected_sha256" ]]; then
    sidecar="${artifact_path}.sha256"
    if [[ -f "$sidecar" ]]; then
        first_line="$(head -1 "$sidecar" | tr -d '[:space:]')"
        if [[ -n "$first_line" ]]; then
            expected_sha256="$(echo "$first_line" | awk '{print tolower($1)}')"
        fi
    fi
fi

actual_hash="$(sha256sum "$artifact_path" | awk '{print $1}')"
hash_status="unverified"
if [[ -n "$expected_sha256" ]]; then
    expected_lower="$(echo "$expected_sha256" | tr '[:upper:]' '[:lower:]')"
    if [[ "$actual_hash" == "$expected_lower" ]]; then
        hash_status="match"
    else
        hash_status="mismatch"
    fi
fi

signature_status="not_provided"
if [[ -n "$signature_file" ]]; then
    if [[ ! -f "$signature_file" ]]; then
        echo "Signature file not found: $signature_file" >&2
        exit 1
    fi

    if command -v gpg &>/dev/null; then
        if gpg --verify "$signature_file" "$artifact_path" &>/dev/null; then
            signature_status="verified"
        else
            signature_status="invalid"
        fi
    else
        signature_status="cannot_verify_gpg_missing"
    fi
fi

# Output JSON summary
cat <<ENDJSON
{
  "artifact_path": "$artifact_path",
  "sha256": "$actual_hash",
  "expected_sha256": "$expected_sha256",
  "hash_status": "$hash_status",
  "signature_file": "$signature_file",
  "signature_status": "$signature_status",
  "policy_file": "$policy_file",
  "policy_loaded": $policy_loaded
}
ENDJSON

if [[ "$hash_status" == "mismatch" ]]; then
    echo "Artifact hash mismatch." >&2
    exit 1
fi
if [[ "$signature_status" == "invalid" ]]; then
    echo "Artifact signature verification failed." >&2
    exit 1
fi
