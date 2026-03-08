#!/usr/bin/env bash
set -euo pipefail

# Defaults
task_id=""
agent_id="default-agent"
runs_root="process/runs"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --task-id) task_id="$2"; shift 2 ;;
        --agent-id) agent_id="$2"; shift 2 ;;
        --runs-root) runs_root="$2"; shift 2 ;;
        *) echo "Unknown argument: $1" >&2; exit 1 ;;
    esac
done

if [[ -z "$task_id" ]]; then
    echo "Error: --task-id is required." >&2; exit 1
fi

selfware_root="$(cd "$(dirname "$0")/../.." && pwd)"

if [[ "$runs_root" != /* ]]; then
    runs_root="$selfware_root/$runs_root"
fi
repo_root="$(dirname "$selfware_root")"

if [[ ! "$task_id" =~ ^TASK-[0-9]{3,}$ ]]; then
    echo "TaskId must match TASK-### format, for example TASK-001." >&2
    exit 1
fi

date_folder="$(date +"%Y-%m-%d")"
day_path="$runs_root/$date_folder"
mkdir -p "$day_path"

max_run=0
if [[ -d "$day_path" ]]; then
    for d in "$day_path"/RUN-*/; do
        [[ -d "$d" ]] || continue
        name="$(basename "$d")"
        if [[ "$name" =~ ^RUN-([0-9]+)$ ]]; then
            n="${BASH_REMATCH[1]}"
            n=$((10#$n))
            if (( n > max_run )); then
                max_run=$n
            fi
        fi
    done
fi

next_run=$((max_run + 1))
run_id="$(printf "RUN-%03d" "$next_run")"
run_path="$day_path/$run_id"

if [[ -e "$run_path" ]]; then
    echo "Run path already exists: $run_path" >&2
    exit 1
fi

mkdir -p "$run_path/artifacts"

base_commit="unknown"
if git -C "$repo_root" rev-parse HEAD &>/dev/null; then
    base_commit="$(git -C "$repo_root" rev-parse HEAD)"
fi

now_utc="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

cat > "$run_path/manifest.json" <<ENDJSON
{
  "run_id": "$run_id",
  "task_id": "$task_id",
  "agent_id": "$agent_id",
  "started_at": "$now_utc",
  "status": "running",
  "base_commit": "$base_commit",
  "end_commit": "",
  "notes": ""
}
ENDJSON

printf '# Plan\n\n1. ' > "$run_path/plan.md"
printf '# Decisions\n' > "$run_path/decisions.md"
printf '# Result\n' > "$run_path/result.md"
touch "$run_path/log.jsonl"

# Compute relative path from selfware_root to run_path
relative_run_path="${run_path#"$selfware_root"/}"

append_script="$(dirname "$0")/append-change-record.sh"
if [[ -x "$append_script" ]]; then
    "$append_script" \
        --actor "$agent_id" \
        --intent "start_run" \
        --path "$relative_run_path/manifest.json" \
        --path "$relative_run_path/plan.md" \
        --path "$relative_run_path/decisions.md" \
        --path "$relative_run_path/result.md" \
        --path "$relative_run_path/log.jsonl" \
        --summary "Created run workspace $run_id for task $task_id." \
        --rollback-hint "Delete run workspace directory: $relative_run_path"
fi

echo "Created run workspace: $run_path"
