# Arvin — AI Continuity Protocol

This is a pointer to the canonical project record, not a ninth source of truth.

Read `AGENTS.md` and all eight documents under `docs/project-continuity/` before changing code or documentation. Use the live GitHub repository state for current PR, branch, commit, and CI facts.

Operate only through PR #3495 (`recovery-02/main-based-integration`) unless the Product Owner explicitly changes the canonical path. Do not create parallel PRs. Do not modify `main` directly. Merge, release, deployment, and production-data operations require explicit Product Owner approval.

For every change:
1. Identify the exact source SHA and consumers.
2. Recover useful prior work without blind merges.
3. Make the smallest compatible change on the canonical branch.
4. Run relevant tests and record exact SHA, workflow, run, and conclusion.
5. Update the canonical continuity documents.
6. Mark unresolved or unverified work BLOCKED; do not infer success.

Preserve valid history and user data. Do not weaken tests. Treat supporting audit documents as evidence only; current decisions belong in `PRODUCT_DECISIONS.md`.
