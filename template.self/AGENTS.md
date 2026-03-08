# AGENTS

This file is the universal agent entrypoint for this Selfware instance. All agents (regardless of model or platform) MUST follow:
- `AGENT_CHARTER.md` — canonical principles (MUST read first)
- `governance/file-contract.yaml` — file-level permission contract
- `docs/goal.txt` — current goal

---

## Three Pillars (Quick Reference)

1. **Data Sovereignty** — User data lives in `content/` only. All changes require user confirmation and MUST be rollbackable.
2. **Self-Containment** — Data + logic + views in one distributable unit. Runtime is replaceable. Development process is recorded inside the instance.
3. **Decentralized Evolution** — Discovery, Self-Analysis, and Ecosystem operations all require explicit user permission. No central dependency.

Full definition: `selfware.md` (EN) / `selfware-zh.md` (ZH).

---

## File Map

```
selfware.md / selfware-zh.md   ← Protocol authority (philosophy + principles)
manifest.md                     ← Instance manifest (canonical scope, pack plan)
content/                        ← Canonical data scope (agent writable)
  memory/changes.md             ← Change audit log (append-only)
process/
  tasks/                        ← Task records (require discussion)
  decisions/                    ← Decision records (require discussion)
  runs/                         ← Run logs (agent writable)
runtime/                        ← Replaceable runtime code
specs/                          ← Implementation specs
guides/                         ← Operational guides (adoption, import-history)
governance/                     ← Governance files (require discussion)
entrypoint/                     ← Human-agent interaction surfaces (require discussion)
```

---

## Write Boundaries

| Scope | Permission | Notes |
|-------|-----------|-------|
| `content/**` | **writable** | Canonical data scope |
| `content/memory/changes.md` | **appendable** | MUST append a Change Record for every material change |
| `process/runs/**` | **writable** | Agent-generated run logs |
| `process/tasks/**`, `process/decisions/**` | require discussion | Must align with human intent |
| `selfware*.md`, `governance/**`, `entrypoint/**`, `runtime/**` | require discussion | High-impact files |
| `.env*` | **denied** | Human-only secrets |

---

## Core Workflows

### Modifying user data
1. Write to target file under `content/`
2. Append a Change Record to `content/memory/changes.md` (format: `specs/memory.md`)
3. Ensure rollbackability (git commit if available)

### Developing features / fixing bugs
1. Read `docs/goal.txt` — verify alignment with current goal
2. Create task record in `process/tasks/` (requires discussion)
3. Implement changes within write boundaries
4. Append Change Record
5. Record key decisions in `process/decisions/`

### Initializing the environment
1. Check `manifest.md` for `Runtime-Lang` and `Deps-File`
2. Create isolated env (Python: uv venv, Node: pnpm)
3. Install dependencies (prefer lock file for reproducibility)
4. Verify entry point is executable before starting
5. Scripts MUST be provided in both `.ps1` (Windows) and `.sh` (Linux/macOS) with equivalent functionality. See `specs/runtime-api.md` §1.5
6. See `specs/runtime-api.md` §1

### Importing an existing project
→ Follow `guides/adoption.md` (step-by-step adoption) and `guides/import-history.md` (Git history migration)

### Runtime changes
1. Modify code under `runtime/` (requires discussion)
2. Ensure views remain functions of data: `View = f(Data, Intent, Rules)`
3. Views MUST NOT hardcode canonical data
4. Views spec: `specs/runtime-api.md` §4

### Generating / migrating views
- **Existing UI**: Preserve ALL original user-facing functionality. Rewire data flow through Runtime API. Feature set MUST NOT shrink.
- **CLI / No UI**: Map each command to an operable area (button, form, panel). Organize by user intent, not command syntax. Visualize outputs as tables/charts/indicators.
- All data mutation scenarios (save, update, pack, Discovery, publish) MUST present a confirmation UI.

### Packaging as .self
→ Follow `specs/packaging.md`. MUST show file list and get user confirmation before packing.

### Discovery / outbound communication
→ Sending any context MUST have explicit user permission. Default to minimal necessary information.

---

## Change Record Format (Quick Reference)

Every material change MUST be logged. Minimum fields:

```yaml
- id: CHG-NNN
  timestamp: YYYY-MM-DDThh:mm:ssZ
  actor: user | agent | service
  intent: what and why
  paths: [affected files]
  summary: human-readable description
  rollback_hint: git ref or manual steps
```

Full spec: `specs/memory.md`
