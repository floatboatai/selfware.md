---
selfware:
  role: memory_changes
  title: Change Records
  purpose: Auditable change log for all writes in this instance.
  scope: Canonical data, runtime actions, governance updates, and protocol updates.
  update_policy: append_only
  owner: team
  created_at: 2026-02-26T00:00:00Z
  updated_at: 2026-02-26T12:21:58Z
---

# Change Records

Append one block per change. Do not rewrite history.

## CHG-20260226-000001
- timestamp: 2026-02-26T00:00:00Z
- actor: template-bootstrap
- intent: initialize_memory
- paths:
  - content/memory/changes.md
- summary: Initialized append-only change record file.
- rollback_hint: Restore this file from version control if needed.

## CHG-20260226-212433-1396
- timestamp: 2026-02-26T11:24:33Z
- actor: default-agent
- intent: pack_self
- paths:
  - manifest.md
  - ../dist/template-smoke.self
- summary: Packed template.self into a distributable .self container.
- rollback_hint: Delete generated container: ../dist/template-smoke.self

## CHG-20260226-122158-2001
- timestamp: 2026-02-26T12:21:58Z
- actor: default-agent
- intent: consolidate_agent_protocol_decisions
- paths:
  - docs/goal.txt
  - process/tasks/TASK-001-agent-protocol-consolidation.md
  - process/decisions/DECISION-001-agent-workspace-convention.md
  - AGENT_CHARTER.md
  - AGENTS.md
  - CLAUDE.md
  - governance/file-contract.yaml
  - manifest.md
- summary: Integrated conversation intent and decisions into task/decision/charter/governance files.
- rollback_hint: Revert these paths to the previous git commit.

## CHG-20260226-122158-2002
- timestamp: 2026-02-26T12:21:58Z
- actor: default-agent
- intent: update_protocol_for_agent_charter_convention
- paths:
  - selfware.md
  - selfware-zh.md
- summary: Added protocol section defining agent charter files and workspace conventions.
- rollback_hint: Revert protocol files to the previous git commit.

