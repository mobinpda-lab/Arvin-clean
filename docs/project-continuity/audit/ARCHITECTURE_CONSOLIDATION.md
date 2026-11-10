## Post-audit source-tree note — 2026-11-10

Current HEAD `a934cabebc814aea13c1800ab151821d12714226` is a documentation-only commit whose parent is `9846f10850031c63964fdc81ae0ab1cdb3028517`. Source, tests, workflows, schema and migration trees were not changed by a934; code observations below, inspected at 9846, remain the same source-tree snapshot. Current verification is updated in CI_HISTORY_AUDIT.md and TEST_INVENTORY.md. No technical remediation is claimed.

---

# Arvin Codebase & Architecture Consolidation — REV8

**Inspected SHA:** `9846f10850031c63964fdc81ae0ab1cdb3028517`

## Canonical data path

- Product Task model: `lib/models/task.dart` — `Task`, `TaskReminder`, and `FollowUp`.
- Canonical persistence service: `lib/services/task_store.dart`.
- Drift schema and migrations: `lib/services/g1_drift_schema.dart`, schema version **16**.
- Follow-up write boundary: `lib/follow_up_repository.dart`.
- Recurrence boundary: `lib/services/task_recurrence_repository.dart`.
- Notebook boundary: `lib/services/canonical_notebook_repository.dart`.
- Template model/store: `lib/models/task_template.dart`, `lib/services/task_template_store.dart`.

## Findings by domain

| Domain | Product approval | Implementation | Verification | Evidence / gap |
|---|---|---|---|---|
| Task + TaskStore | APPROVED | IMPLEMENTED | PARTIAL | TaskStore uses Drift; complete lifecycle acceptance not established. |
| Due Date | APPROVED | IMPLEMENTED | PARTIAL | Task dueDate is distinct from TaskReminder and FollowUp timestamps; current tests include due-date failures. |
| Reminder | APPROVED | PARTIAL | NOT VERIFIED | TaskReminder has `isEnabled` and `isAllDay`; no explicit four-state enum/state machine was found. Do not invent the four states. |
| Follow-up history | APPROVED | IMPLEMENTED | PARTIAL | FollowUp is persisted through follow_up_records; current Follow-up persistence workflow passed, but full UI/People acceptance has failures. |
| Recurrence | APPROVED | PARTIAL | PARTIAL | TaskRecurrenceRepository stores occurrenceHistory/checklistOccurrences maps; end-to-end recurrence acceptance not complete. |
| Checklist history | APPROVED | PARTIAL | PARTIAL | Per-occurrence checklist state exists; current checklist tests fail. |
| Center / Project / Category / Tags | APPROVED | PARTIAL | PARTIAL | Drift has centers/projects/taxonomy_categories/tags/task_tags; selection semantics and all screens not fully verified. |
| Universal filters | APPROVED | PARTIAL | PARTIAL | ReusableMultiSelectFilterBottomSheet supports single/multi selection; Home OR/AND tests fail. |
| Home / Sorting / Eisenhower | APPROVED | PARTIAL | PARTIAL | Five dimensions and grouping services exist; sorting parity and Focus Today tests fail. |
| Quick Capture / Inbox | APPROVED | PARTIAL | PARTIAL | Uses canonical TaskStore; inline creation tests fail; explicit Inbox UX not fully verified. |
| Task Details Auto-Save | APPROVED | PARTIAL | PARTIAL | TaskDetailPage has immediate title save and queued mutations; every permitted field and exit persistence are not fully proven. |
| Notebook | APPROVED | PARTIAL | NOT VERIFIED | CanonicalNotebookRepository uses TaskStore and soft trash/restore; hard-delete/unlink preservation needs explicit tests. |
| Templates / Deep Clone | APPROVED | PARTIAL | NOT VERIFIED | TaskTemplate/TaskTemplateStore exist. TaskTemplate has no dueDate field; full center/project/people and new-base-date semantics need verification. |
| Calendar | APPROVED | IMPLEMENTED | PARTIAL | Internal Calendar and Android provider bridge/executor exist; Calendar Provider Acceptance passed on current SHA, Device Smoke is pending. |
| Reports / PDF | APPROVED | PARTIAL | PARTIAL | Report Center and renderers exist; report/PDF tests fail in current Build. |
| Backup / Restore / Integrity | APPROVED | PARTIAL | NOT VERIFIED | Backup/restore services and Drift migrations exist; full real-database restore and integrity proof is absent. |
| Local P2P / Cloud Sync | APPROVED | PARTIAL | NOT VERIFIED | Local P2P specification exists; no full end-to-end evidence established. |
| NIRA factory integration | APPROVED | PARTIAL | NOT VERIFIED | Adapter/workflows/tests exist; NIRA L10 remains UNVERIFIED. |

## Specific architecture observations

### Reminder and Follow-up

- `TaskReminder` exposes boolean fields `isEnabled` and `isAllDay`; the requested four-state model is not represented as a clear enum/state machine.
- `FollowUp` retains `dateTime`, `nextFollowUp`, and `reminderDate` fields for compatibility. Legacy Task fields `followUpEnabled` and `followUpDate` also remain in model/migration payloads.
- `AutomaticFollowUpService` returns empty candidate lists and documents that automatic Follow-up scheduling is retired. `AutomaticFollowUpAlarmPlanner` is a compatibility shell.
- `FollowUpReminderAlarmPlanner` projects `Task.taskReminders` only. Its historical name must not be mistaken for Follow-up-history scheduling.
- The model/table terminology differs: Dart model is `FollowUp`; Drift table is `follow_up_records`. No separate `FollowUpRecord` domain class was found in the inspected model.

### Person tables

- `persons` stores canonical person records.
- `person_directory` is a membership/visibility marker referencing `persons`, seeded once; it is not proven to be a duplicate person store.
- `task_persons` and `follow_up_record_people` are relationship tables.

### Candidate dead code / compatibility

- `lib/core/storage/task_store.dart` declares a generic TaskStore interface; code search found test-only references, while production uses `lib/services/task_store.dart`. Mark DEAD_CODE_CANDIDATE; do not remove without a separate code review.
- `TaskDetailPage.onEdit` remains declared and is passed by `main.dart`, but no invocation of `widget.onEdit` was found in TaskDetailPage. Mark unused callback candidate.
- Legacy AutomaticFollowUp scheduler files remain as compatibility/no-op surfaces. Do not remove until Android entrypoint and all imports are checked.
- `TaskDialog` is a compatibility wrapper around `ArvinTaskEditorDialog`; it is not a second Task data model.

### Migration and storage safety

- G1 Drift schema version: 16.
- Migration code moves legacy Follow-up/person/reminder data into canonical tables and retains compatibility metadata in payloads.
- Some migration paths drop legacy tables after conversion (including legacy relationship tables). This audit did not open a real production database or prove backup/restore rollback across every historical schema.
- No table, column, migration, or stored data was removed in REV8.

No duplicate canonical Task model was proven. The only clear same-name storage abstraction candidate is the generic test-only TaskStore interface versus the concrete service.
