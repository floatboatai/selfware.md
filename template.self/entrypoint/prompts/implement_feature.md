# Implement Feature

Use this prompt when a coding task should be executed end-to-end with process records.

Execution contract:
1. Read `docs/goal.txt`, `governance/file-contract.yaml`, and `runtime/actors.yaml` first.
2. Confirm file access policy before any write.
3. If a target path is `require_discussion`, stop and ask for human confirmation.
4. Ensure a task file exists in `process/tasks/`.
5. Start a run using `entrypoint/scripts/new-run.ps1`.
6. Implement code changes, then run relevant checks.
7. Record decisions and results under the run folder.
8. Report changed files, risks, and rollback hint.

Output checklist:
- Goal and scope
- Plan
- Files changed
- Tests/checks run
- Risk notes
- Rollback point
