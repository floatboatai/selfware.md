#!/usr/bin/env bash
set -euo pipefail

# Defaults
remote_url=""
local_protocol_path="selfware.md"
manifest_path="manifest.md"
apply=false
force=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --remote-url) remote_url="$2"; shift 2 ;;
        --local-protocol-path) local_protocol_path="$2"; shift 2 ;;
        --manifest-path) manifest_path="$2"; shift 2 ;;
        --apply) apply=true; shift ;;
        --force) force=true; shift ;;
        *) echo "Unknown argument: $1" >&2; exit 1 ;;
    esac
done

selfware_root="$(cd "$(dirname "$0")/../.." && pwd)"

if [[ "$manifest_path" != /* ]]; then
    manifest_path="$selfware_root/$manifest_path"
fi
if [[ "$local_protocol_path" != /* ]]; then
    local_protocol_path="$selfware_root/$local_protocol_path"
fi

if [[ ! -f "$manifest_path" ]]; then
    echo "Manifest not found: $manifest_path" >&2
    exit 1
fi
if [[ ! -f "$local_protocol_path" ]]; then
    echo "Local protocol file not found: $local_protocol_path" >&2
    exit 1
fi

get_manifest_value() {
    local key="$1"
    grep -m1 "^${key}:" "$manifest_path" | sed "s/^${key}:[[:space:]]*//" || true
}

if [[ -z "$remote_url" ]]; then
    remote_url="$(get_manifest_value "Update-Default-Source")"
fi
if [[ -z "$remote_url" ]]; then
    remote_url="$(get_manifest_value "Protocol-Source")"
fi
if [[ -z "$remote_url" ]]; then
    echo "Remote update source is empty. Set Update-Default-Source in manifest.md or pass --remote-url." >&2
    exit 1
fi

echo "Update source: $remote_url"

remote_text="$(curl -fsSL -A "selfware-template-check-update/1.0" "$remote_url")"
local_text="$(cat "$local_protocol_path")"

local_hash="$(printf '%s' "$local_text" | sha256sum | awk '{print $1}')"
remote_hash="$(printf '%s' "$remote_text" | sha256sum | awk '{print $1}')"

echo "Local sha256 : $local_hash"
echo "Remote sha256: $remote_hash"

if [[ "$local_hash" == "$remote_hash" ]]; then
    echo "No update detected."
    exit 0
fi

# Simple diff stats
added="$(diff <(echo "$local_text") <(echo "$remote_text") | grep -c '^>' || true)"
removed="$(diff <(echo "$local_text") <(echo "$remote_text") | grep -c '^<' || true)"

echo "Update detected. Added lines: $added | Removed lines: $removed"
echo "Diff preview (first 30 lines):"
diff <(echo "$local_text") <(echo "$remote_text") | head -30 || true

if [[ "$apply" == false ]]; then
    echo "Apply not requested. Use --apply to proceed with No Silent Apply flow."
    exit 0
fi

if [[ "$force" == false ]]; then
    read -rp "Type APPLY to accept this update: " confirm
    if [[ "$confirm" != "APPLY" ]]; then
        echo "Update apply canceled by user." >&2
        exit 1
    fi
fi

date_folder="$(date +"%Y-%m-%d")"
stamp="$(date +"%Y%m%d-%H%M%S")"
backup_dir="$selfware_root/process/runs/$date_folder"
mkdir -p "$backup_dir"

backup_name="PROTOCOL-BACKUP-${stamp}-$(basename "$local_protocol_path")"
backup_path="$backup_dir/$backup_name"
cp "$local_protocol_path" "$backup_path"

printf '%s' "$remote_text" > "$local_protocol_path"

local_relative="${local_protocol_path#"$selfware_root"/}"
backup_relative="${backup_path#"$selfware_root"/}"

append_script="$(dirname "$0")/append-change-record.sh"
if [[ -x "$append_script" ]]; then
    "$append_script" \
        --actor "default-agent" \
        --intent "apply_protocol_update" \
        --path "$local_relative" \
        --path "$backup_relative" \
        --summary "Applied protocol update from remote source with backup and user confirmation." \
        --rollback-hint "Restore protocol file from backup: $backup_relative"
fi

echo "Applied update. Backup created: $backup_path"
