> Parent: [selfware.md](../selfware.md)

# Memory Specification

Version: 0.2.0 (Draft)

---

## 1. Overview

Memory is a set of **auditable context files** maintained under `content/`, used to:
- Record conversations, decisions, changes, and run traces
- Support collaboration and retrospection (humans and Agents)
- Provide minimal necessary context for Discovery/update decisions, with user permission

Memory MUST NOT become the protocol authority; the protocol authority is `selfware.md`.

## 2. Placement

If enabled, instances SHOULD use: `content/memory/`

Implementations MAY use a single file (e.g., `content/memory.md`), but a multi-file structure is better for permission splitting and minimization.

## 3. File Self-Description

Each Memory file MUST include metadata at the top explaining "who I am / what I record / how to update me".

### Allowed Formats (choose one)

**Option A — YAML front matter** (recommended; still Markdown):

```yaml
---
selfware:
  role: memory_chat | memory_changes | memory_decisions | memory_runs | custom
  title: "..."
  purpose: "..."
  scope: "what is included / excluded"
  update_policy: "append_only | editable | generated"
  owner: "user | team | agent"
  created_at: "YYYY-MM-DDThh:mm:ssZ"
  updated_at: "YYYY-MM-DDThh:mm:ssZ"
---
```

**Option B — `## Meta` section** (same fields; key-value lines).

## 4. Change Metadata (Change Record)

For any change to any instance file (`content/`, `views/`, `server.py`, `manifest.md`, etc.), the implementation MUST record a Change Record to `content/memory/changes.md` (or equivalent).

### Required Fields (MUST)

| Field | Description |
|-------|-------------|
| `id` | Unique identifier |
| `timestamp` | When the change occurred |
| `actor` | `user` / `agent` / `service` |
| `intent` | What the change aims to achieve |
| `paths` | Affected file list |
| `summary` | Human-readable description |
| `rollback_hint` | How to roll back (git ref / backup / manual steps) |

If Git is used locally, `rollback_hint` SHOULD point to a concrete Git rollback point (commit/tag/ref).

## 5. Discovery Consent & Minimization

When Discovery carries context, Memory MAY be selectively referenced, but MUST:
- Be sent only with explicit user consent
- Default to minimal fragments (e.g., decision/change summaries, not full runs/logs)
- Support user-level trimming and redaction
