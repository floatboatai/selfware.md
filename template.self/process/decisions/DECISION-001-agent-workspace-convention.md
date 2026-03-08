# DECISION-001 - Agent Workspace Convention Baseline

## Summary
- Define `template.self/` as the selfware instance root and formalize an agent collaboration baseline.

## Context
- The project needed more than Git state history: it needed auditable intent, decision, and run-level process data.
- The previous structure mixed capability concepts (`agents`) with identity concepts and caused unclear boundaries.

## Options Considered
1. Keep `agents/` as primary concept and extend ad hoc process logs.
2. Move to `skills/` capability-first model with minimal actor identity layer.
3. Keep only runtime scripts and rely on external docs for governance.

## Decision
- Chosen option: Option 2.
- Why:
  - `skills/` is more reusable and ecosystem-friendly than role-bound `agents/`.
  - Runtime identity is still required, so `runtime/actors.yaml` remains as a minimal identity and permission layer.
  - Governance and interaction become explicit through `entrypoint/`, `governance/file-contract.yaml`, and process records.

## Consequences
- Positive:
  - Clear split between capability (`skills/`) and execution identity (`runtime/actors.yaml`).
  - Better auditability via `process/decisions/` and `content/memory/changes.md`.
  - Client can render `entrypoint/index.yaml` as a stable human-agent interaction surface.
- Negative:
  - Requires strict discipline on file-contract enforcement and change logging.
  - Additional documentation maintenance burden.
- Follow-up actions:
  - Add shared charter files (`AGENTS.md`, `CLAUDE.md`) for cross-agent principles.
  - Add protocol text in `selfware.md` and `selfware-zh.md` for workspace conventions.
  - Keep script paths consolidated in `entrypoint/scripts/`.

## Metadata
- Date: 2026-02-26
- Deciders: human-owner, default-agent
- Related task: TASK-001 (implicit conversation task)
