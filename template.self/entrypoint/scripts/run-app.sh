#!/usr/bin/env bash
set -euo pipefail

# Defaults
port=5273
host="127.0.0.1"
allow_non_loopback=false
server_path="runtime/server.py"
skip_deps=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --port) port="$2"; shift 2 ;;
        --host) host="$2"; shift 2 ;;
        --allow-non-loopback) allow_non_loopback=true; shift ;;
        --server-path) server_path="$2"; shift 2 ;;
        --skip-deps) skip_deps=true; shift ;;
        *) echo "Unknown argument: $1" >&2; exit 1 ;;
    esac
done

selfware_root="$(cd "$(dirname "$0")/../.." && pwd)"

if [[ "$server_path" != /* ]]; then
    server_path="$selfware_root/$server_path"
fi

if [[ ! -f "$server_path" ]]; then
    echo "Server file not found: $server_path" >&2
    exit 1
fi

# --- 1. Detect Python runtime ---
use_uv=false
python_cmd=""

if command -v uv &>/dev/null; then
    use_uv=true
fi

if command -v python3 &>/dev/null; then
    python_cmd="python3"
elif command -v python &>/dev/null; then
    python_cmd="python"
elif [[ "$use_uv" == false ]]; then
    echo "Python runtime not found. Install python3, python, or uv." >&2
    exit 1
fi

# --- 2. Create isolated environment ---
venv_dir="$selfware_root/.venv"
req_file="$selfware_root/runtime/requirements.txt"

if [[ "$skip_deps" == false ]] && [[ -f "$req_file" ]]; then
    has_content=false
    while IFS= read -r line; do
        trimmed="${line#"${line%%[![:space:]]*}"}"
        if [[ -n "$trimmed" ]] && [[ "$trimmed" != \#* ]]; then
            has_content=true
            break
        fi
    done < "$req_file"

    if [[ "$has_content" == true ]]; then
        if [[ "$use_uv" == true ]]; then
            echo "[init] Installing dependencies with uv..."
            cd "$selfware_root"
            if ! uv sync 2>/dev/null; then
                uv venv "$venv_dir"
                uv pip install -r "$req_file"
            fi
        else
            if [[ ! -d "$venv_dir" ]]; then
                echo "[init] Creating virtual environment..."
                $python_cmd -m venv "$venv_dir"
            fi

            echo "[init] Installing dependencies..."
            pip_path="$venv_dir/bin/pip"
            if [[ ! -f "$pip_path" ]]; then
                pip_path="$venv_dir/Scripts/pip"
            fi
            "$pip_path" install -r "$req_file" --quiet
        fi
        echo "[init] Dependencies ready."
    fi
fi

# --- 3. Resolve python executable (prefer venv) ---
venv_python="$venv_dir/bin/python"
if [[ ! -f "$venv_python" ]]; then
    venv_python="$venv_dir/Scripts/python.exe"
fi
if [[ -f "$venv_python" ]]; then
    python_cmd="$venv_python"
fi

# --- 4. Launch server ---
run_args=("$server_path" "--host" "$host" "--port" "$port")
if [[ "$allow_non_loopback" == true ]]; then
    run_args+=("--allow-non-loopback")
fi

cd "$selfware_root"
if [[ "$use_uv" == true ]] && [[ ! -f "$venv_dir/bin/python" ]]; then
    uv run python "${run_args[@]}"
else
    $python_cmd "${run_args[@]}"
fi
