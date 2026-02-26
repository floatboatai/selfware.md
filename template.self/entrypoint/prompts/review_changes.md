# Review Changes

Use this prompt for pre-merge or pre-release review.

Review contract:
1. Focus on bugs, regressions, security risk, and missing tests.
2. Validate that file changes follow `governance/file-contract.yaml`.
3. Confirm no restricted files were read or modified.
4. Check run artifacts in `process/runs/` for traceability.
5. Provide findings ordered by severity with file references.

Output checklist:
- Critical findings
- Medium findings
- Low findings
- Gaps in tests or observability
- Merge recommendation
