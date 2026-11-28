# HANDOFF — 2026-11-28

- Repository: `mobinpda-lab/Arvin-clean`
- Branch: `recovery-02/main-based-integration`
- Current checkpoint SHA: `88dfc7a10b2713c8f5b43c471acb74e82027acd8`
- PR: #3495 OPEN / DRAFT / UNMERGED; Main read-only at `45e4202b03a434459e4c021a04efa7e8396359db`.
- Product acceptance: NOT ACCEPTED. Release: NO-GO.

## Next action (single lane)
1. Poll exact-SHA workflows for `88dfc7a10b2713c8f5b43c471acb74e82027acd8`. If Build is absent, do not infer PASS; inspect Actions events and obtain a legitimate run through the existing workflow path, without creating duplicate workflows.
2. Read the CI-visible `ARVIN_ASYNC_CLEANUP` markers. Identify whether the first missing phase is callback entry, native work completion, runAsync return, cleanup barrier or FakeAsync pump. Fix only the proven test-runner contract; keep all assertions and timeouts.
3. Independently continue ARC-DATA-001 and DB-RESTORE-001 design: incremental Task row persistence or another safe relation-preserving strategy; full Project/Center/Category relationship snapshot contract; file-backed rollback/reopen tests. No schema/restore mutation until the complete caller and dependency audit is done.
4. Re-poll all gates on one exact SHA after every commit. Never reuse prior SHA PASS.

## Protected boundaries
- No writes to Main; no merge/release/deployment.
- No production database mutation, branch deletion, history rewrite or force push.
- No duplicate store/repository/registry or duplicate tests.
- Preserve IDs, unknown metadata, relationships, reminders, follow-up history and backups.
