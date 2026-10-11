# Arvin Roadmap — Release Completion

## Gate 0 — Evidence baseline
- Re-fetch PR #2585 head, main SHA, latest commit and current workflow jobs.
- If any code changes after the last green run, require fresh exact-head Build and all relevant smoke lanes.

## Gate 1 — Restore safety (blocking)
- Review both Home and BackupPage restore orchestration tests.
- Ensure late failure after Task, Project, Calendar-link and settings mutations returns data to its prior state.
- Verify rollback-failure messaging and emergency-backup reference.
- Verify assigned/unassigned Category and Tag catalog round-trip.
- Preserve legacy semantics for missing/null Project fields vs explicit empty list.
- Run focused tests and exact-head full CI.

## Gate 2 — Real Android file-provider/device test
- Export and restore through the actual Android picker/provider on a physical device.
- Verify Task, checklist, repeat/history, follow-up, Project membership, Category/Tag catalogs and assignments, settings and Calendar-link metadata.
- Record device/OS, steps, artifact/logs/screenshots, and before/after data.

## Gate 3 — Calendar identity
- For a restored linked Task, edit and re-sync.
- Verify the same external event ID is updated, event count does not increase, and broken/missing links recover safely.
- Save event IDs/count and logs/screenshots.

## Parallel — Product ontology audit
- Continue Issue #2580 read-only audit and safe documentation-only corrections under ADR #2582.
- No schema or backup semantics changes without coordinating with Gate 1.

## Release gate
No merge/release/RC claim until all three gates, the remaining ontology acceptance, Golden Flow and exact-head CI are reviewed with evidence. Keep user-reported Calendar actions issue in scope until verified.
