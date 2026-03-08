> Parent: [selfware.md](../selfware.md)

# Packaging Specification

Version: 0.2.0 (Draft)

---

## 1. Container Format

A `.self` file MUST be a **ZIP container** (compatibility first; unpackable by standard unzip tools).

Inside, it MUST include a manifest at the fixed path:
- `self/manifest.md`

### Required Manifest Fields (MUST)

- `Selfware-Container: zip`
- `Selfware-Container-Version: 1`
- `Protocol-Source: <url>` (e.g., `https://floatboat.ai/selfware.md`)
- `Local-Protocol-Path: selfware.md`
- `Canonical-Data-Scope: content/`

The protocol MAY evolve to new container types/versions; implementations MUST handle compatibility via `Selfware-Container-Version` or fail explicitly.

## 2. Pack Policy

Packing writes a Selfware project directory into a `.self` container. Implementations MUST:

1. **Declare pack scope**: provide include/exclude rules (glob or path list) and define the minimal required set.
2. **User confirmation**: before writing the `.self`, MUST show:
   - Final included file list (or tree) and total size
   - Exclude rules summary and key excluded items
   - Output target path (`*.self`)
   - Allow Accept/Reject.
3. **Write boundary**: pack MUST NOT modify `selfware.md`. If `self/manifest.md` is generated, generate it inside the container without writing back to the repo (unless user explicitly requests).

### Default Excludes (SHOULD)

- `.DS_Store`
- `__pycache__/`, `*.pyc`
- `node_modules/`, `.venv/`
- `dist/`, `build/`
- `output/`, `*.log`, `*.tmp`
- `.git/` (unless user explicitly includes)

## 3. Pack Plan Placement

An instance's "pack plan" SHOULD live in its self-description file (e.g., `manifest.md` or a dedicated section inside Canonical Data) to avoid locking into a repo structure and allow different instances to declare different include/exclude/required sets.

## 4. Sharing / Distribution

To share a Selfware project, SHOULD pack the whole directory into a ZIP with a `.self` suffix (e.g., `my_project.self`).

The receiver gets a "living document / living app". If they have collaboration backend access within the permission boundary, they can check for updates and pull/merge after user confirmation per the No Silent Apply rule.
