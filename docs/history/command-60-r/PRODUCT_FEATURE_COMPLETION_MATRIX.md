# PRODUCT FEATURE COMPLETION MATRIX — INITIAL
**Status:** IN PROGRESS. Statuses below are evidence-based starting classifications, not final acceptance.

| Feature | Starting classification | Main known gap / evidence |
|---|---|---|
| Task | IN PROGRESS | Broad canonical flows and tests exist; complete CRUD/reopen/relations acceptance pending |
| Project | IN PROGRESS | File-backed persistence test passes in COMMAND 20-E phase; M2M repository integration remains incomplete |
| Center | BLOCKED | Approved M2M model not fully integrated into canonical stores/UI |
| Category | IN PROGRESS | Catalog and Home/Notebook taxonomy consistency need end-to-end audit |
| Tag | IN PROGRESS | Task tags exist; Notebook and Project/Category relationship behavior require audit |
| People | IN PROGRESS | Directory persistence/report support partial; management dialog test fails |
| Follow-up | IN PROGRESS | Persistence tests pass on baseline; legacy metadata and migration parity still open |
| Checklist | IN PROGRESS | Existing model test recovered; enable/disable regression reported |
| Calendar | IN PROGRESS | Emulator smoke passes; device provider/settings integration regressions remain |
| Reminder | IN PROGRESS | File persistence coverage exists; migration parity and full CRUD/reopen remain open |
| Recurrence | IN PROGRESS | Canonical recurrence tests exist; migration and independent occurrence state require proof |
| Occurrence | BLOCKED | COMMAND 49 parity mismatch and COMMAND 50 unknown-state failure |
| Search / Filter | IN PROGRESS | Search service tests pass; five-dimension Home filters require completion |
| Notebook | IN PROGRESS | Taxonomy and Tag interaction regressions reported in #1901 |
| Quick Add | BLOCKED | Date/Time selectors reported to navigate to blank screen |
| Reports | IN PROGRESS | Projection tests exist; full filter and device acceptance pending |
| Settings | IN PROGRESS | Appearance/font controls and Calendar settings incomplete per #1901 |
| Backup / Restore | BLOCKED | COMMAND 20-E final acceptance failed; independent physical restore not accepted |

Acceptance requires create/view/edit/delete, close/reopen persistence, cross-entity relations, validation/empty/error states and regression tests per feature.



## Source reconciliation — 2026-11-19
- Home currently renders four filter dimensions, not five; Center is the missing REV10 filter. Five due-date groups are present. Classification: BLOCKED on Center store/model/UI integration.
- Schema 9 migration creates Center and M2M tables, but no canonical CenterStore or Center management page was found at the expected source paths. ProjectStore remains on ProjectPlan/itemIds and project_items; complete M2M integration is not accepted.
- Settings text-size slider is present (12–24); do not report it as absent. Font-family picker remains absent and font authority is unresolved.
- PersonDirectoryPage is present with CRUD flows; its delete-dialog test expected only the second sentence while the actual dialog includes a person-specific introduction. PR #3547 corrects the assertion to the full rendered copy; pending CI.
- Primary navigation shared design tokens are in PR #3548; this does not complete feature behavior or redesign all pages.
