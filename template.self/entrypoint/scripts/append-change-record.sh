#!/usr/bin/env bash
set -euo pipefail

# Defaults
actor="default-agent"
intent=""
paths=()
summary=""
rollback_hint="manual"
changes_file="content/memory/changes.md"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --actor) actor="$2"; shift 2 ;;
        --intent) intent="$2"; shift 2 ;;
        --path) paths+=("$2"); shift 2 ;;
        --summary) summary="$2"; shift 2 ;;
        --rollback-hint) rollback_hint="$2"; shift 2 ;;
        --changes-file) changes_file="$2"; shift 2 ;;
        *) echo "Unknown argument: $1" >&2; exit 1 ;;
    esac
done

if [[ -z "$intent" ]]; then
    echo "Error: --intent is required." >&2; exit 1
fi
if [[ ${#paths[@]} -eq 0 ]]; then
    echo "Error: at least one --path is required." >&2; exit 1
fi
if [[ -z "$summary" ]]; then
    echo "Error: --summary is required." >&2; exit 1
fi

selfware_root="$(cd "$(dirname "$0")/../.." && pwd)"

if [[ "$changes_file" != /* ]]; then
    changes_file="$selfware_root/$changes_file"
fi

if [[ ! -f "$changes_file" ]]; then
    mkdir -p "$(dirname "$changes_file")"
    printf '# Change Records\n' > "$changes_file"
fi

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
change_id="CHG-$(date +"%Y%m%d-%H%M%S")-$((RANDOM % 9000 + 1000))"

{
    echo ""
    echo "## $change_id"
    echo "- timestamp: $timestamp"
    echo "- actor: $actor"
    echo "- intent: $intent"
    echo "- paths:"
    for p in "${paths[@]}"; do
        echo "  - $p"
    done
    echo "- summary: $summary"
    echo "- rollback_hint: $rollback_hint"
    echo ""
} >> "$changes_file"

echo "Appended change record: $change_id"
echo "Change file: $changes_file"
