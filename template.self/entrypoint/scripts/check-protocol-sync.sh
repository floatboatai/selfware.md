#!/usr/bin/env bash
set -euo pipefail

# Defaults
english_path="selfware.md"
chinese_path="selfware-zh.md"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --english-path) english_path="$2"; shift 2 ;;
        --chinese-path) chinese_path="$2"; shift 2 ;;
        *) echo "Unknown argument: $1" >&2; exit 1 ;;
    esac
done

selfware_root="$(cd "$(dirname "$0")/../.." && pwd)"

if [[ "$english_path" != /* ]]; then
    english_path="$selfware_root/$english_path"
fi
if [[ "$chinese_path" != /* ]]; then
    chinese_path="$selfware_root/$chinese_path"
fi

if [[ ! -f "$english_path" ]]; then
    echo "English protocol file not found: $english_path" >&2
    exit 1
fi
if [[ ! -f "$chinese_path" ]]; then
    echo "Chinese protocol file not found: $chinese_path" >&2
    exit 1
fi

get_version() {
    grep -m1 '^Version:' "$1" | sed 's/^Version:\s*//' | tr -d '[:space:]' || true
}

get_numbered_sections() {
    grep '^## [0-9]' "$1" | sed 's/^## \([0-9][0-9.]*\).*/\1/' || true
}

en_version="$(get_version "$english_path")"
zh_version="$(get_version "$chinese_path")"

en_sections="$(get_numbered_sections "$english_path")"
zh_sections="$(get_numbered_sections "$chinese_path")"

en_count="$(echo "$en_sections" | grep -c . || true)"
zh_count="$(echo "$zh_sections" | grep -c . || true)"

has_error=false

if [[ "$en_version" != "$zh_version" ]]; then
    echo "Version mismatch: EN='$en_version' ZH='$zh_version'" >&2
    has_error=true
fi

if [[ "$en_count" != "$zh_count" ]]; then
    echo "Section count mismatch: EN=$en_count ZH=$zh_count" >&2
    has_error=true
fi

# Compare section numbers line by line
paste <(echo "$en_sections") <(echo "$zh_sections") | {
    idx=0
    while IFS=$'\t' read -r en_sec zh_sec; do
        if [[ "$en_sec" != "$zh_sec" ]]; then
            echo "Section number mismatch at index $idx: EN=$en_sec ZH=$zh_sec" >&2
            has_error=true
        fi
        idx=$((idx + 1))
    done
}

if [[ "$has_error" == true ]]; then
    echo "Protocol sync check failed." >&2
    exit 1
fi

echo "Protocol sync check passed."
echo "Version: $en_version"
echo "Numbered sections: $en_count"
