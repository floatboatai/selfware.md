#!/usr/bin/env bash
set -euo pipefail

# Defaults
task_id=""
title=""
owner="human"
output_dir="process/tasks"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --task-id) task_id="$2"; shift 2 ;;
        --title) title="$2"; shift 2 ;;
        --owner) owner="$2"; shift 2 ;;
        --output-dir) output_dir="$2"; shift 2 ;;
        *) echo "Unknown argument: $1" >&2; exit 1 ;;
    esac
done

if [[ -z "$task_id" ]]; then
    echo "Error: --task-id is required." >&2; exit 1
fi
if [[ -z "$title" ]]; then
    echo "Error: --title is required." >&2; exit 1
fi

selfware_root="$(cd "$(dirname "$0")/../.." && pwd)"

if [[ "$output_dir" != /* ]]; then
    output_dir="$selfware_root/$output_dir"
fi

if [[ ! "$task_id" =~ ^TASK-[0-9]{3,}$ ]]; then
    echo "TaskId must match TASK-### format, for example TASK-001." >&2
    exit 1
fi

mkdir -p "$output_dir"
path="$output_dir/${task_id}.md"

if [[ -e "$path" ]]; then
    echo "Task already exists: $path" >&2
    exit 1
fi

today="$(date +"%Y-%m-%d")"

cat > "$path" <<EOF
# $task_id - $title

## Goal
- Define what user value this task delivers.

## Scope
- In scope:
- Out of scope:

## Plan
1. Analyze current state.
2. Implement changes.
3. Verify with checks/tests.
4. Summarize outcomes and risks.

## Acceptance
- [ ] Behavior implemented
- [ ] Tests or checks updated
- [ ] Docs updated if needed
- [ ] Human review completed

## Metadata
- Owner: $owner
- Created: $today
- Status: draft
EOF

relative_task_path="${path#"$selfware_root"/}"

append_script="$(dirname "$0")/append-change-record.sh"
if [[ -x "$append_script" ]]; then
    "$append_script" \
        --actor "$owner" \
        --intent "create_task" \
        --path "$relative_task_path" \
        --summary "Created task file $task_id." \
        --rollback-hint "Delete task file: $relative_task_path"
fi

echo "Created task file: $path"
