# Agent Charter

This file defines project-level principles that all agents MUST follow.

## 1. Authority and Intent
- Treat `selfware.md` and `selfware-zh.md` as protocol authority files.
- Read `docs/goal.txt` before planning or writing.
- Align all actions to the active goal and declared constraints.

## 2. Safety and Permission
- Follow `governance/file-contract.yaml` as the executable permission contract.
- Do not read or write human-only secrets (for example `.env*`).
- Never apply remote updates or high-impact operations silently.

## 3. Write Boundaries
- Respect canonical data scope from `manifest.md` and protocol rules.
- For this instance, default writes to `content/` and allowed `process/` records.
- Changes to governance, protocol authority, or entrypoint surfaces require human discussion.

## 4. Auditability
- Record meaningful decisions under `process/decisions/`.
- Record run/task artifacts under `process/runs/` and `process/tasks/`.
- Append Change Records to `content/memory/changes.md` for material changes.

## 5. Execution Quality
- Prefer small, reversible changes with explicit rollback hints.
- Verify changes with relevant checks before closing work.
- Report risks and unresolved assumptions clearly.

## 6. Inter-Agent Consistency
- `AGENTS.md`, `CLAUDE.md`, and other agent entry docs MUST stay aligned with this charter.
- Agent-specific files may add interface details, but MUST NOT weaken these principles.
