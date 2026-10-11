# Arvin Feature Evidence Map

**Snapshot date:** 2026-10-11. Refresh exact heads and workflow results before release decisions. “CI success” is scoped to the cited commit/run and is not equivalent to physical-device acceptance.

| Feature | Implementation location (current known path) | Test / validation path | Evidence | Status |
|---|---|---|---|---|
| Canonical Task | `lib/models/task.dart`; `lib/services/task_store.dart` | `test/task_contract_test.dart`; `test/task_store_test.dart` | Existing source/tests; exact release-flow evidence not consolidated | IN PROGRESS |
| Quick Add | `lib/quick_capture_dialog.dart`; `lib/services/quick_capture_service.dart` | `test/quick_capture_dialog_test.dart` | PR #2595 adds compact-surface, priority and stable-draft regression tests; full exact-head CI pending | IN PROGRESS |
| Full Task Editor / Note | `lib/task_editor_dialog.dart`; `lib/models/task.dart` | `test/task_editor_dialog_test.dart`; `test/task_editor_full_entry_test.dart`; `test/task_store_test.dart` | PR #2595 adds additive JSON `Task.note`; round-trip and exact-head validation pending | IN PROGRESS |
| Date / Time picker | `lib/widgets/universal_arvin_time_picker.dart`; migrated existing time-selection paths | PR #2591 tests; full Analyze/test/build run | [Build run 38095687074](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38095687074): Analyze, six test shards, Debug/Release success; Device Smoke skipped | CI PASS; DEVICE PENDING |
| Project | `lib/models/goal_project.dart`; `lib/services/project_store.dart` | project/task store tests (verify current test names before release) | Source references recorded in taxonomy ADR; end-to-end evidence not consolidated | AUDIT REQUIRED |
| Category / Tag | `lib/services/task_store.dart`; `lib/task_taxonomy_management_page.dart` | taxonomy/store tests; cross-surface audit #2580 | Accepted ADR #2582; conformance audit open | IN PROGRESS |
| Checklist | canonical Task checklist fields and existing Task editor/store | `test/task_editor_dialog_test.dart`; task store/backup tests | Existing coverage; occurrence lifecycle and real restore still require acceptance | IN PROGRESS |
| Repeat / Occurrence | `lib/models/recurrence.dart` and canonical Task/occurrence paths (verify current paths before edits) | recurrence and Calendar tests; issue #2254/#2535 | Contract exists; 7-occurrence and past/today/future projection acceptance open | BLOCKED ON VALIDATION |
| Tracking / Follow-up | `lib/follow_up_entry_page.dart`; `lib/task_editor_dialog.dart`; Task fields | follow-up/editor tests | PR #2595 retains current fields; history/count conformance not fully evidenced | IN PROGRESS |
| Calendar external events | existing Calendar Provider bridge and Task event-link metadata (inspect source before edits) | `integration_test/android_home_smoke_test.dart`; Calendar issue #2535 | PR #2587 reports successful build + six-lane smoke; same-event edit, permission, recurrence and physical-device flow pending | DEVICE PENDING |
| Backup / Restore | `lib/backup_manager.dart`; canonical restore path in `lib/main.dart` | `test/canonical_backup_manager_test.dart`; restore rollback tests | PR #2585 reports successful build + six-lane smoke; physical-device/file-provider round-trip pending | DEVICE/DATA PENDING |
| Home / Search / Reports | existing Home, search and Report Center surfaces; inspect current source paths before changing | focused filter/search/report tests (confirm names before release) | No consolidated golden-flow evidence in this snapshot | AUDIT REQUIRED |
| Migration / Integrity | existing Drift schema and canonical stores | migration, persistence, rollback and restore tests | No release-wide migration/rollback evidence asserted here | RELEASE GATE OPEN |

## Evidence rules
- Record exact commit SHA, workflow run URL, relevant job/test names and outcome.
- For UI, include real route screenshots and visual review; widget tests alone do not prove appearance on device.
- For calendar sync, prove an edit updates the same external event and does not create duplicates.
- For Backup/Restore, use a real file/document-provider round-trip and compare task identity, relations, checklist/repeat/history and calendar links; fake/in-memory tests alone are insufficient.
- Mark each row PASS only when its defined acceptance evidence exists. Unknown is not PASS.
