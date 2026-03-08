#!/usr/bin/env bash
set -euo pipefail

# Defaults
output_path=""
manifest_path="manifest.md"
force=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --output-path) output_path="$2"; shift 2 ;;
        --manifest-path) manifest_path="$2"; shift 2 ;;
        --force) force=true; shift ;;
        *) echo "Unknown argument: $1" >&2; exit 1 ;;
    esac
done

selfware_root="$(cd "$(dirname "$0")/../.." && pwd)"
repo_root="$(dirname "$selfware_root")"

if [[ "$manifest_path" != /* ]]; then
    manifest_path="$selfware_root/$manifest_path"
fi
if [[ ! -f "$manifest_path" ]]; then
    echo "Manifest not found: $manifest_path" >&2
    exit 1
fi

if [[ -z "$output_path" ]]; then
    dist_dir="$repo_root/dist"
    output_path="$dist_dir/$(basename "$selfware_root").self"
elif [[ "$output_path" != /* ]]; then
    output_path="$repo_root/$output_path"
fi

# Parse manifest sections
get_section_values() {
    local file="$1"
    local section="$2"
    local in_section=false
    while IFS= read -r line; do
        trimmed="${line#"${line%%[![:space:]]*}"}"
        if [[ "$trimmed" =~ ^##[[:space:]]+ ]]; then
            if [[ "$trimmed" == "## $section" ]]; then
                in_section=true
            elif [[ "$in_section" == true ]]; then
                break
            fi
            continue
        fi
        if [[ "$in_section" == true ]] && [[ "$trimmed" == "- "* ]]; then
            echo "${trimmed:2}"
        fi
    done < "$file"
}

mapfile -t include < <(get_section_values "$manifest_path" "Pack Include")
mapfile -t exclude < <(get_section_values "$manifest_path" "Pack Exclude")
mapfile -t required < <(get_section_values "$manifest_path" "Pack Required")

if [[ ${#include[@]} -eq 0 ]]; then
    include=("**")
fi

default_exclude=(
    ".git/**"
    ".DS_Store"
    "__pycache__/**"
    "*.pyc"
    "node_modules/**"
    ".venv/**"
    "dist/**"
    "build/**"
    "output/**"
    "*.log"
    "*.tmp"
)

# Combine exclude lists (unique)
declare -A exclude_map
all_exclude=()
for pat in "${exclude[@]}" "${default_exclude[@]}"; do
    if [[ -z "${exclude_map[$pat]+x}" ]]; then
        exclude_map[$pat]=1
        all_exclude+=("$pat")
    fi
done

# Simple glob matching using bash patterns
# Convert glob to bash extended pattern
glob_match() {
    local path="$1"
    local pattern="$2"
    # Convert ** to match-all placeholder, then * to [^/]*, then restore **
    # For simplicity, use a find-based approach or direct pattern matching
    # We use bash's extglob for simple cases
    local regex="$pattern"
    # Escape regex special chars except * and ?
    regex="${regex//./\\.}"
    regex="${regex//\*\*/__DOUBLESTAR__}"
    regex="${regex//\*/[^/]*}"
    regex="${regex//__DOUBLESTAR__/.*}"
    regex="^${regex}$"
    [[ "$path" =~ $regex ]]
}

# Collect all files
included_files=()
while IFS= read -r -d '' file; do
    relative="${file#"$selfware_root"/}"

    is_included=false
    for pattern in "${include[@]}"; do
        if glob_match "$relative" "$pattern"; then
            is_included=true
            break
        fi
    done
    [[ "$is_included" == false ]] && continue

    is_excluded=false
    for pattern in "${all_exclude[@]}"; do
        if glob_match "$relative" "$pattern"; then
            is_excluded=true
            break
        fi
    done
    [[ "$is_excluded" == true ]] && continue

    included_files+=("$relative")
done < <(find "$selfware_root" -type f -print0 | sort -z)

# Sort unique
mapfile -t included_files < <(printf '%s\n' "${included_files[@]}" | sort -u)

# Check required items
for req in "${required[@]}"; do
    matched=false
    for candidate in "${included_files[@]}"; do
        if glob_match "$candidate" "$req"; then
            matched=true
            break
        fi
    done
    if [[ "$matched" == false ]]; then
        echo "Missing required pack item: $req" >&2
        exit 1
    fi
done

if [[ ${#included_files[@]} -eq 0 ]]; then
    echo "Pack include resolved to zero files." >&2
    exit 1
fi

# Calculate total size
total_bytes=0
for item in "${included_files[@]}"; do
    size="$(stat -c%s "$selfware_root/$item" 2>/dev/null || stat -f%z "$selfware_root/$item" 2>/dev/null || echo 0)"
    total_bytes=$((total_bytes + size))
done

echo "Pack include files: ${#included_files[@]}"
for item in "${included_files[@]}"; do
    echo "  - $item"
done
echo ""
echo "Pack exclude rules:"
for pat in "${all_exclude[@]}"; do
    echo "  - $pat"
done
echo ""
echo "Estimated payload size: $total_bytes bytes"
echo "Output container: $output_path"

if [[ "$force" == false ]]; then
    read -rp "Type YES to confirm packaging: " confirm
    if [[ "$confirm" != "YES" ]]; then
        echo "Pack canceled by user." >&2
        exit 1
    fi
fi

output_dir="$(dirname "$output_path")"
mkdir -p "$output_dir"

temp_root="$(mktemp -d)"
trap 'rm -rf "$temp_root"' EXIT

for relative in "${included_files[@]}"; do
    source_file="$selfware_root/$relative"
    target_file="$temp_root/$relative"
    mkdir -p "$(dirname "$target_file")"
    cp "$source_file" "$target_file"
done

# Create container manifest
mkdir -p "$temp_root/self"
generated_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
cat > "$temp_root/self/manifest.md" <<EOF
Selfware-Container: zip
Selfware-Container-Version: 1
Protocol-Source: https://floatboat.ai/selfware.md
Local-Protocol-Path: selfware.md
Canonical-Data-Scope: content/
Generated-At: $generated_at
Generated-By: entrypoint/scripts/pack-self.sh
EOF

# Remove existing output
[[ -f "$output_path" ]] && rm -f "$output_path"

# Create zip archive
archive_path="$output_path"
use_rename=false
if [[ "${output_path##*.}" != "zip" ]]; then
    archive_path="${output_path}.zip"
    use_rename=true
fi
[[ -f "$archive_path" ]] && rm -f "$archive_path"

(cd "$temp_root" && zip -r "$archive_path" . -q)

if [[ "$use_rename" == true ]]; then
    [[ -f "$output_path" ]] && rm -f "$output_path"
    mv "$archive_path" "$output_path"
fi

# Append change record
append_script="$(dirname "$0")/append-change-record.sh"
if [[ -x "$append_script" ]]; then
    output_relative="${output_path#"$selfware_root"/}"
    "$append_script" \
        --actor "default-agent" \
        --intent "pack_self" \
        --path "manifest.md" \
        --path "$output_relative" \
        --summary "Packed template.self into a distributable .self container." \
        --rollback-hint "Delete generated container: $output_relative"
fi

echo "Pack completed: $output_path"
