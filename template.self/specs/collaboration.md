> Parent: [selfware.md](../selfware.md)

# Collaboration Specification

Version: 0.2.0 (Draft)

---

## 1. Local Versioning (Git)

Selfware local files SHOULD use Git for versioning (local repo is sufficient; remote optional):

- Before applying any update (official source, Discovery, or collaboration backend), runtime SHOULD create a rollback point (prefer Git commit/tag; otherwise backups).
- Any "auto pull/merge remote" behavior MUST follow No Silent Apply (user confirmation required).

## 2. Protocol Source & Updates

### 2.1 Protocol Source

An instance MAY declare an "official protocol source" (for update checks only; does not override local authority):
- `Protocol Source: https://floatboat.ai/selfware.md`
- `Protocol Source (GitHub): https://github.com/floatboatai/selfware`

### 2.2 Update Check

If update checking is enabled, runtime MUST check at one of:
- **On Start** (every run), or
- **On User Request**

Checks SHOULD use ETag/Last-Modified or content hashes.

### 2.3 No Silent Apply

If an update is detected, runtime MUST:
1. Explain the update logic (where it's fetched, how compared, how applied, how to roll back)
2. Provide an update summary (at least title + summary; changelog/diff if available)
3. Ask for user confirmation (Accept/Reject/Defer)
4. Apply only after Accept; Reject MUST keep the current version runnable

## 3. Git Collaboration

Instance data (especially `content/`) MAY collaborate via Git (remote optional, e.g., GitHub):

Configuration:
- `Collaboration: git`
- `Remote: <git remote url>`
- `Ref: <branch|tag|commit>` (optional; default branch is implementation-defined)

If Git collaboration is enabled, runtime MUST:
1. Check remote for updates on **On Start** or **On User Request** (MAY choose one, but MUST support explicit user trigger).
2. If updates exist, follow No Silent Apply before pulling/merging.
3. Create a rollback point before merge (prefer Git commit/tag; otherwise backups).
4. On conflicts, stop automatic apply and ask the user for a resolution strategy (manual/assisted/abort).

## 4. Custom Collaboration

Selfware MAY use a custom collaboration service:
- `Collaboration: custom`
- `Endpoint: <service url>`

Regardless of backend:
- Write boundaries MUST remain (only write to `content/` or an explicitly allowed subset).
- Any sync/merge that changes local `selfware.md` MUST be preceded by user confirmation (per No Silent Apply).

## 5. Discovery

### 5.1 Overview

Goal: with **user permission**, carry "intent + partial context" to discover better solutions.

A Discovery request SHOULD include:
- **Intent**: current task goal (e.g., `update`, `recommend`, `fix_overflow`)
- **Partial Context**: minimal relevant info (goal, state/progress, logs — optional and trimmable)

### 5.2 Permissions (MUST)

- Any Discovery request with context MUST be sent only with explicit user consent.
- Default SHOULD send only minimal necessary context; higher-granularity context MUST require additional authorization.

### 5.3 Discovery Responses

MAY return (non-exhaustive):
- A better Selfware (complete solution file/template)
- Skills (reusable workflows)
- Code snippets / patch suggestions
- Other Agent-consumable artifacts

### 5.4 Trigger Points

Runtime SHOULD support (but MUST support explicit user trigger):
1. On Start
2. On Explicit Update Intent
3. On Missing Capability
4. On Error Recovery
5. On User Request

## 6. Self-Analysis (Optional)

Self-Analysis extracts know-how from instance progress/changes and closes an evolution loop with Discovery/ecosystem publishing.

### Inputs (MAY read)

- Canonical Data
- Memory files (if enabled)
- `manifest.md`
- Runtime files (for consistency/boundary scanning)

Self-Analysis MUST respect write boundaries: MUST NOT bypass protocol to write `selfware.md`.

### Outputs (MUST be file-based)

Outputs MUST be materialized as files, auditable and rollbackable. MAY include:
- Insights and executable recommendations
- Draft artifacts (practices/skills/selfware/patches) for local review
- Discovery request drafts (intent + minimal context)
- Publish queues (artifact list with sha256 and distribution drafts)

Any output writes MUST be recorded as Change Records.

### Consent

- MUST obtain explicit user consent before sending anything to external endpoints.
- MUST default to minimal necessary context.
- MUST apply updates only via No Silent Apply.

### Trigger Freedom

Trigger points are implementation-defined. Protocol requires:
- MUST support explicit user trigger
- MUST record key actions and rollback points via Change Records
