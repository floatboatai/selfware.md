# Selfware

> A file is an app. Everything is a file.

Selfware is a file philosophy for the Agent era: returning files to users so they never become obsolete and can evolve indefinitely.

Version: 0.2.0 (Draft)

License: MIT — you MAY modify, redistribute, and create derivatives.

This document uses RFC-style terms: **MUST / MUST NOT / SHOULD / SHOULD NOT / MAY**.

---

## 1. Data Sovereignty

**"Files belong to users, not applications."**

Traditional software locks data in proprietary formats and cloud black boxes. Users nominally own their data but are effectively held hostage by vendors. Selfware rejects this: user data stays in user hands, always.

### Inviolable Principles

- User data (Canonical Data) MUST always reside in a location the user can access, read, and migrate.
- Any change to user data MUST take effect only after user confirmation (No Silent Apply).
- Any change MUST be rollbackable — users have the right to undo everything.
- Runtime, views, and logic are replaceable implementations; they MUST NOT become the sole holder of or access bottleneck to data.
- Remote sync MUST NOT silently modify local data without user permission.

---

## 2. Self-Containment

**"A single file is a complete piece of software."**

A Selfware distributable unit (a single file or a `.self` package) can contain data, logic, and views together. This is not a technical curiosity but a shift in power structure: when all constituents live in a single user-holdable unit, no centralized platform can become a bottleneck.

### Inviolable Principles

- A Selfware instance MUST be copyable, transferable, and runnable as a standalone unit, independent of any specific platform or service.
- Views are functions of data (`View = f(Data, Intent, Rules)`); views MUST NOT become the source of truth for data.
- Runtime components (Kernel, Views, Skills, etc.) are replaceable; any Agent SHOULD be able to regenerate logic and views from the protocol.
- Packaging (`.self`) MUST use a universal format (ZIP) so anyone can unpack and inspect the contents.
- An instance's development process (tasks, decisions, change records) SHOULD be recorded inside the instance itself, keeping its iteration history auditable and traceable without relying on external tools.

---

## 3. Decentralized Evolution

**"Files evolve on their own, without depending on a center."**

Selfware instances are not static snapshots but living entities. They can discover better solutions, distill their own experience, and exchange know-how with other instances — all under user permission, with no centralized platform as intermediary.

### Inviolable Principles

- Instances MAY use Discovery to find better solutions (Skills, Practices, templates, etc.), but sending any context MUST require explicit user permission.
- Instances MAY use Self-Analysis to distill know-how from their own changes, but publishing externally MUST require user confirmation.
- Ecosystem artifacts MUST be self-describing (carrying metadata) to support decentralized discovery and verification.
- The protocol itself is MIT-licensed: anyone MAY modify, distribute, and evolve it. No single entity can monopolize the right to define software.
- Collaboration (multi-person sync, versioning) SHOULD be based on open protocols (e.g., Git), not proprietary services.

---

## Specifications

This document defines only philosophy and inviolable principles. For all implementation details, API formats, field definitions, and directory conventions, see the `specs/` directory:

| Spec | Content |
|------|---------|
| [specs/runtime-api.md](specs/runtime-api.md) | Runtime API and capability declaration |
| [specs/packaging.md](specs/packaging.md) | `.self` container format and pack policy |
| [specs/memory.md](specs/memory.md) | Memory module format and change records |
| [specs/ecosystem.md](specs/ecosystem.md) | Ecosystem artifact metadata, publish & consume |
| [specs/collaboration.md](specs/collaboration.md) | Versioning and collaboration spec |
| [specs/process.md](specs/process.md) | Development process records (tasks, decisions, changes) |

## Guides

| Guide | Content |
|-------|---------|
| [guides/adoption.md](guides/adoption.md) | Adoption guide: making existing projects Selfware-compliant |
| [guides/import-history.md](guides/import-history.md) | History import guide: importing change records from Git |
