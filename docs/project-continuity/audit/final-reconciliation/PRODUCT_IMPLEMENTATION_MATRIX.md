# PRODUCT IMPLEMENTATION MATRIX
Decision authority: current owner command + REV10  
Evidence baseline: Main v7; PR #3495 schema9 source; exact-SHA CI on d3a82... failed.

| Product area | Approved contract | Source evidence / current assessment | Acceptance |
|---|---|---|---|
| Brand / theme | Primary Blue #4169A1; Vazirmatn; RTL | Canonical token ArvinColors.primary = 0xFF4169A1; Vazirmatn assets in source/APK. Full 300/400/500/600/700 and every screen not yet audited. | NOT ACCEPTED |
| Home | Time, Center, Project, Category, Tag; OR within, AND across | CenterStore-backed multi-select Center filter, unassigned Center, five horizontal RTL cards, chips/clear and widget coverage committed. Project and Category remain single-select; exact Build/test evidence not available. | PARTIAL — VERIFICATION PENDING |
| Task lifecycle | Create/Edit/Save/Reopen/Complete/Reopen Completed/Delete/Restore | Task model and TaskStore exist; full lifecycle parity and UI acceptance not established by this pass. | NOT ACCEPTED |
| Checklist | Part of Task and same edit form; no parallel storage | Task model has checklist; #1901 regression test recovered. Verify UI placement and persistence/backup on exact SHA. | NOT ACCEPTED |
| Time + Calendar icons | Same row in full edit form | Not yet source-verified in this pass. | UNRESOLVED |
| Center / Project / Category / Tag | M2M hierarchy and optional Task links | Schema9 migration source creates centers, center_projects, categories, project_categories and migration exceptions; store/UI/backup integration still needs proof. | NOT ACCEPTED |
| Reminder | Independent from Due Date; Stop/Follow-up/Snooze/Complete | Notification and scheduling services exist. Issue #3646 says no dedicated four-action window/controller was found in audited tree. | NOT ACCEPTED — P0 |
| Follow-up | Independent history; not auto-projected as Calendar Reminder | Model preserves Follow-up history/legacy metadata; Calendar projection must remain distinct. | PARTIAL |
| Repeat | One Task, independent Occurrences, history, future pattern edits | Schema9 includes occurrence/recurrence data work in historical PRs; full lifecycle not audited. | NOT ACCEPTED |
| Notebook | Existing TaskStore, no parallel storage, backup-safe | Task/Notebook source exists; full disconnect/restore/history acceptance pending. | NOT ACCEPTED |
| People | CRUD, Task/Follow-up links, tombstones, backup | PersonDirectory exclusion migration and people tables exist; full management UI and tombstone/restore parity pending. | NOT ACCEPTED |
| Calendar | Stable Event identity, no duplicates, independent Reminder/Due/Follow-up | Calendar smoke lane failed on d3a82; other Calendar scenarios need direct acceptance. | NOT ACCEPTED |
| Reports / PDF | Canonical data, Persian font, sums, filters, share/print | PDF dependencies/source exist; current artifact/font/print/share acceptance not established. | NOT ACCEPTED |
| Backup / Restore | Independent DB A/B, IDs/relations/NULL/unknown fields, rollback | File-backed A→B test exists in branch; PR #3639 describes a real unknown nested-field failure. Full suite not accepted. | NOT ACCEPTED — P0 |

A class, table, test file or PR description proves implementation presence only; it does not prove end-user behavior or acceptance.

## Home implementation update — 2026-11-27
Reviewed code SHA: a05c74496f390038afb424e4cf7d53b4427ba648. Current PR head after documentation: e372cfe99aef6beb59299ec6912ff8c47691ab86.
- Center is now present in the Home filter enum and visible row, loaded through existing CenterStore.
- Center selection supports multiple IDs (OR) and a no-Center selection; Center dimension is AND-combined with Time/Project/Category/Tags.
- Project and Category remain single-select, so the full owner OR-within-each-dimension contract is still incomplete.
- Widget test was added/updated but has no Arvin Build result on this exact head. Product acceptance remains NOT ACCEPTED.
