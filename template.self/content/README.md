# Canonical Data Scope

All source-of-truth instance data lives under this directory.

## Structure

- `selfware_demo.md`: default editable content served by the runtime.
- `memory/changes.md`: append-only change records.

## Rules

- Runtime and agents write canonical updates here.
- Views, scripts, and generated outputs must not replace this authority.
- Every write should produce a change record entry.
