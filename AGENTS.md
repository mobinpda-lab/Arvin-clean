# Arvin — Agent Entry Point

This file is a thin adapter, not an independent policy source.

Before any repository work, read these eight authoritative documents in order:
1. `docs/project-continuity/README.md`
2. `docs/project-continuity/MASTER_GOVERNANCE.md`
3. `docs/project-continuity/PRODUCT_DECISIONS.md`
4. `docs/project-continuity/CURRENT_STATE.md`
5. `docs/project-continuity/ROADMAP.md`
6. `docs/project-continuity/OPEN_ISSUES.md`
7. `docs/project-continuity/IMPLEMENTATION_LOG.md`
8. `docs/project-continuity/HANDOFF.md`

Current development path: PR #3495, branch `recovery-02/main-based-integration`.
- Never commit directly to `main`.
- Do not create parallel feature PRs or revive historical branches as active development paths.
- Do not merge, release, deploy, or alter production user databases without explicit Product Owner approval.
- Preserve IDs, relationships, history, backups, and restore compatibility.
- Never delete a legacy field, migration, test, workflow, branch, or PR before checking consumers and recovering valuable contributions.
- Never weaken or remove a valid test to make CI green.
- Report only evidence-backed PASS results, with the exact tested SHA.
- Historical PRs, ADRs, audit files, and supplemental references are evidence, not independent sources of current policy.

If sources conflict, the latest explicit Product Owner instruction and live GitHub state take precedence; the eight canonical documents record the resulting decision.
