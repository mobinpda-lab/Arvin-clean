# Arvin Roadmap — Release Completion

## Gate 0 — Exact-head evidence baseline
- Current PR #2585 head at checkpoint: `05c080e706690dd3eb6a96fc5c070971a43d1354`.
- Check [Build #38123874036](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874036) and [Device Smoke #38123874041](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874041). They were not yet green/complete at last inspection.
- Re-check head/main before any merge decision.

## Gate 1 — Restore safety (blocking)
- Validate new failure-injection tests at the real Home and BackupPage restore orchestration boundaries.
- Confirm failure after Category/Tag catalog merge removes only newly introduced entries and preserves prior catalogs.
- Validate late failure after Task, Project, Calendar-link and settings mutations; rollback-failure messaging and emergency-backup reference.
- Verify assigned/unassigned Category and Tag catalog round-trip.
- Verify legacy semantics for missing/null Project fields vs explicit empty list.
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
No merge/release/RC claim until all three gates, remaining ontology acceptance, Golden Flow and exact-head CI are reviewed with evidence. Keep the owner-reported Calendar actions issue in scope until verified.
