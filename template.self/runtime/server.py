#!/usr/bin/env python3
"""Minimal Selfware runtime server for template.self.

This server intentionally keeps a narrow write boundary:
- Canonical writes are limited to content/selfware_demo.md
- Any write appends a change record entry under content/memory/changes.md
"""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import pathlib
import random
import urllib.error
import urllib.parse
import urllib.request
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

ROOT = pathlib.Path(__file__).resolve().parents[1]
CONTENT_FILE = ROOT / "content" / "selfware_demo.md"
MANIFEST_FILE = ROOT / "manifest.md"
PROTOCOL_FILE = ROOT / "selfware.md"
CAPABILITIES_FILE = ROOT / "runtime" / "capabilities.yaml"
CHANGES_FILE = ROOT / "content" / "memory" / "changes.md"

LOOPBACK_HOSTS = {"127.0.0.1", "localhost", "::1"}


def utc_now() -> str:
    return dt.datetime.now(dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def sha256_text(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def ensure_parent(path: pathlib.Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)


def append_change_record(actor: str, intent: str, paths: list[str], summary: str, rollback_hint: str) -> str:
    ensure_parent(CHANGES_FILE)
    if not CHANGES_FILE.exists():
        CHANGES_FILE.write_text("# Change Records\n\n", encoding="utf-8")

    change_id = f"CHG-{dt.datetime.now(dt.timezone.utc).strftime('%Y%m%d-%H%M%S')}-{random.randint(1000, 9999)}"
    lines = [
        "",
        f"## {change_id}",
        f"- timestamp: {utc_now()}",
        f"- actor: {actor}",
        f"- intent: {intent}",
        "- paths:",
    ]
    for path in paths:
        lines.append(f"  - {path}")
    lines.extend(
        [
            f"- summary: {summary}",
            f"- rollback_hint: {rollback_hint}",
            "",
        ]
    )

    with CHANGES_FILE.open("a", encoding="utf-8", newline="\n") as fh:
        fh.write("\n".join(lines))

    return change_id


def read_text(path: pathlib.Path) -> str:
    return path.read_text(encoding="utf-8") if path.exists() else ""


def fetch_remote_text(url: str) -> tuple[str, str | None]:
    req = urllib.request.Request(url, headers={"User-Agent": "selfware-template-runtime/1.0"})
    with urllib.request.urlopen(req, timeout=15) as resp:  # nosec: B310, user-triggered URL
        charset = resp.headers.get_content_charset() or "utf-8"
        data = resp.read().decode(charset, errors="replace")
        etag = resp.headers.get("ETag")
        return data, etag


class SelfwareHandler(BaseHTTPRequestHandler):
    server_version = "SelfwareRuntime/0.1"

    def _send_json(self, payload: dict, status: HTTPStatus = HTTPStatus.OK) -> None:
        data = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def _send_text(self, text: str, status: HTTPStatus = HTTPStatus.OK, content_type: str = "text/plain") -> None:
        data = text.encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", f"{content_type}; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def _read_json_body(self) -> dict:
        length = int(self.headers.get("Content-Length", "0"))
        raw = self.rfile.read(length) if length > 0 else b"{}"
        return json.loads(raw.decode("utf-8"))

    def do_GET(self) -> None:  # noqa: N802
        parsed = urllib.parse.urlparse(self.path)

        if parsed.path == "/":
            html = """<!doctype html>
<html>
<head>
  <meta charset=\"utf-8\" />
  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\" />
  <title>Selfware Template Runtime</title>
  <style>
    body { font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; margin: 24px; background: #f7f7f4; color: #1f2a37; }
    h1 { margin-bottom: 12px; }
    textarea { width: 100%; min-height: 55vh; padding: 12px; border: 1px solid #cfd7e2; border-radius: 8px; background: #fff; }
    button { margin-top: 12px; padding: 10px 14px; border: 0; border-radius: 6px; background: #115e59; color: #fff; cursor: pointer; }
    .status { margin-top: 10px; font-size: 0.9rem; }
  </style>
</head>
<body>
  <h1>template.self</h1>
  <p>Canonical file: <code>content/selfware_demo.md</code></p>
  <textarea id=\"editor\"></textarea>
  <br />
  <button id=\"save\">Save</button>
  <div class=\"status\" id=\"status\"></div>
  <script>
    async function loadContent() {
      const res = await fetch('/api/content');
      const data = await res.json();
      document.getElementById('editor').value = data.content || '';
    }
    async function saveContent() {
      const content = document.getElementById('editor').value;
      const res = await fetch('/api/save', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({content})
      });
      const data = await res.json();
      document.getElementById('status').textContent = data.status + ' | change_id=' + (data.change_id || 'n/a');
    }
    document.getElementById('save').addEventListener('click', saveContent);
    loadContent();
  </script>
</body>
</html>
"""
            self._send_text(html, content_type="text/html")
            return

        if parsed.path == "/api/content":
            self._send_json(
                {
                    "path": str(CONTENT_FILE.relative_to(ROOT)).replace("\\", "/"),
                    "content": read_text(CONTENT_FILE),
                }
            )
            return

        if parsed.path == "/api/self":
            text = read_text(PROTOCOL_FILE)
            self._send_json(
                {
                    "path": str(PROTOCOL_FILE.relative_to(ROOT)).replace("\\", "/"),
                    "sha256": sha256_text(text),
                    "content": text,
                }
            )
            return

        if parsed.path == "/api/manifest":
            self._send_json(
                {
                    "path": str(MANIFEST_FILE.relative_to(ROOT)).replace("\\", "/"),
                    "content": read_text(MANIFEST_FILE),
                }
            )
            return

        if parsed.path == "/api/capabilities":
            self._send_json(
                {
                    "path": str(CAPABILITIES_FILE.relative_to(ROOT)).replace("\\", "/"),
                    "content": read_text(CAPABILITIES_FILE),
                    "write_scope": ["content/**"],
                    "confirmation_required": [
                        "pack_self",
                        "check_update_apply",
                        "publish",
                        "send_context",
                        "protocol_change",
                    ],
                }
            )
            return

        if parsed.path == "/api/check_update":
            params = urllib.parse.parse_qs(parsed.query)
            url = params.get("url", [""])[0].strip()
            if not url:
                self._send_json({"error": "Missing query parameter: url"}, HTTPStatus.BAD_REQUEST)
                return

            try:
                remote_text, etag = fetch_remote_text(url)
            except urllib.error.URLError as exc:
                self._send_json({"error": f"Failed to fetch remote content: {exc}"}, HTTPStatus.BAD_GATEWAY)
                return

            local_text = read_text(PROTOCOL_FILE)
            local_hash = sha256_text(local_text)
            remote_hash = sha256_text(remote_text)
            changed = local_hash != remote_hash

            self._send_json(
                {
                    "url": url,
                    "etag": etag,
                    "local_sha256": local_hash,
                    "remote_sha256": remote_hash,
                    "changed": changed,
                }
            )
            return

        self._send_json({"error": "Not found"}, HTTPStatus.NOT_FOUND)

    def do_POST(self) -> None:  # noqa: N802
        parsed = urllib.parse.urlparse(self.path)

        if parsed.path != "/api/save":
            self._send_json({"error": "Not found"}, HTTPStatus.NOT_FOUND)
            return

        try:
            data = self._read_json_body()
        except json.JSONDecodeError:
            self._send_json({"error": "Invalid JSON body"}, HTTPStatus.BAD_REQUEST)
            return

        content = data.get("content")
        if not isinstance(content, str):
            self._send_json({"error": "Field 'content' must be a string"}, HTTPStatus.BAD_REQUEST)
            return

        ensure_parent(CONTENT_FILE)
        CONTENT_FILE.write_text(content, encoding="utf-8", newline="\n")

        change_id = append_change_record(
            actor="runtime-server",
            intent="save_content",
            paths=["content/selfware_demo.md"],
            summary="Saved canonical demo content through /api/save.",
            rollback_hint="Use git checkout on content/selfware_demo.md or restore from backup.",
        )

        self._send_json({"status": "success", "change_id": change_id})

    def log_message(self, format: str, *args) -> None:
        timestamp = dt.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        msg = format % args
        print(f"[{timestamp}] {self.client_address[0]} {msg}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run the template.self local runtime server")
    parser.add_argument("--host", default="127.0.0.1", help="Bind host (default: 127.0.0.1)")
    parser.add_argument("--port", type=int, default=5273, help="Bind port (default: 5273)")
    parser.add_argument(
        "--allow-non-loopback",
        action="store_true",
        help="Allow non-loopback binding. Use only when explicitly approved.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    if args.host not in LOOPBACK_HOSTS and not args.allow_non_loopback:
        raise SystemExit(
            "Refusing non-loopback bind. Use --allow-non-loopback only with explicit user approval."
        )

    server = ThreadingHTTPServer((args.host, args.port), SelfwareHandler)
    print(f"Selfware runtime started: http://{args.host}:{args.port}")
    print("Write scope: content/**")
    print("Change record: content/memory/changes.md")

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down runtime.")
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
