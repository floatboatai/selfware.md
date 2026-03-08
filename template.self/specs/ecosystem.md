> Parent: [selfware.md](../selfware.md)

# Ecosystem Specification

Version: 0.2.0 (Draft)

---

## 1. Overview

The Ecosystem module enables Selfware instances to share know-how (best practices, workflows, templates, patches) through decentralized discovery, without introducing any single-vendor monopoly.

## 2. Artifact Types (non-exhaustive)

- `practice`: rules / best practices (triggers, checks, fix suggestions)
- `skill`: executable workflows (install, trigger, I/O, safety boundary)
- `selfware`: templates / complete instances (copyable, runnable)
- `patch`: patches / migration scripts (targeting specific versions/structures)

## 3. Artifact Metadata (MUST)

Any published or Discovery-returned artifact MUST carry self-describing metadata (YAML front matter recommended).

### Required Fields

| Field | Description |
|-------|-------------|
| `type` | `practice` \| `skill` \| `selfware` \| `patch` |
| `id` | Globally unique (namespace recommended, e.g., `floatboat.practice.pack.confirmation.v1`) |
| `version` | Artifact version |
| `protocol_version_range` | Compatible Selfware protocol versions |
| `applies_to` | Scope/platform/runtime (e.g., `generic`, `python_runtime`, `zip_container`) |
| `license` | License identifier |
| `sha256` | Content verification hash (lowercase hex) |
| `provenance` | Origin (which changes/decisions/issues it was distilled from; may include hashes) |
| `distribution` | One or more distribution entries (see §4) |

### Optional Fields

- `trust`: signing/publisher/verification info (not required, but implementations SHOULD support it for local trust policy)

## 4. Distribution

`distribution` constraints (MUST):
- MUST include at least one resolvable "fetch hint" (e.g., URL or `git:` pointer)
- MUST be human-readable; SHOULD follow machine-extractable prefix conventions

Recommended prefixes (SHOULD):
- `hosted:` — hosted content URL
- `index:` — index entry URL
- `git:` — decentralized pointer (e.g., `repo#ref=...:path=...`)
- `sha256:` — explicit hash (same as metadata field)

### SHA-256 Rules (MUST)

- MUST be the SHA-256 of the fetchable/applicable artifact content (lowercase hex).
- If distributed as hosted text: hash UTF-8 bytes (no implicit rewrites).
- If distributed as zip/binary container: hash the container bytes.

## 5. Publish & Consume Boundaries

### Publish

- Before pushing local know-how to any external destination, the runtime MUST obtain user confirmation.
- Publish MUST write a Change Record (see [memory.md](memory.md) §4), including where/how it was published and rollback strategy.

### Consume

- Discovery MUST return a candidate artifact list + metadata; it MUST NOT silently apply anything.
- Runtime/Agent MUST let the user choose, then follow No Silent Apply (logic + summary/diff + rollback point + user confirmation).

## 6. Ecosystem Repo Convention (SHOULD)

For decentralized ecosystem building and indexing, ecosystem repos SHOULD use top-level directories:
- `selfware/`
- `skills/`
- `practices/`

This convention applies to ecosystem repos (for publishing/sharing), not to normal `.self` instances.
