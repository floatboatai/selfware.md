> Parent: [selfware.md](../selfware.md)

# Process Specification

Version: 0.2.0 (Draft)

---

## 1. Overview

A Selfware instance SHOULD record its own development process internally,
so that its full iteration context — tasks, decisions, and changes — is
self-contained and does not depend on external project-management tools.

This directly embodies the Self-Containment principle: the instance carries
not only its data and logic, but also the history of *how* it evolved.

## 2. Directory Structure

| Path | Purpose | Update policy |
|------|---------|---------------|
| `process/tasks/` | Task records — goals, plans, acceptance criteria, status | One file per task |
| `process/decisions/` | Decision records — context, options, rationale, consequences | One file per decision |
| `process/runs/` | Run traces — execution logs and diagnostics | One file per run |
| `content/memory/changes.md` | Append-only change audit log for all writes in this instance | Append only |

## 3. File Formats

Tasks SHOULD follow the template at `process/tasks/TASK-000-template.md`.
Decisions SHOULD follow the template at `process/decisions/DECISION-000-template.md`.

Each process file SHOULD be human-readable Markdown so that any agent or
user can understand the history without special tooling.

## 4. Change Audit

Every significant write — whether to canonical data, runtime, governance,
or process files themselves — MUST be recorded in `content/memory/changes.md`
per the [Memory Specification](memory.md).

This creates a single, append-only timeline that ties tasks and decisions
back to concrete file changes, enabling full traceability.

## 5. Relationship to Self-Containment

By keeping process records inside the instance:

- **Portability**: copying the instance copies its entire project history.
- **Auditability**: anyone inspecting the instance can trace *why* each
  change was made, without access to an external issue tracker.
- **Reproducibility**: an agent can resume work by reading internal context
  alone — no external state is required.

External tools (GitHub Issues, Jira, etc.) MAY be used as mirrors or
interfaces, but the instance's internal records remain the source of truth.
