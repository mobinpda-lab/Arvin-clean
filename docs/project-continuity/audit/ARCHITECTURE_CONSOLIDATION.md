## Typography authority / implementation conflict — 2026-11-10

| Domain | Product approval | Implementation | Verification | Evidence / gap |
|---|---|---|---|---|
| UI typography | NEEDS OWNER-SOURCE RECONCILIATION | IMPLEMENTED (Vazirmatn) | PARTIAL | Direct owner instruction 2026-09-06 selected VazirHarf v34.003 and required replacing Vazirmatn references; current PRODUCT_DECISIONS.md claims later Vazirmatn approvals on 2026-11-05/08 without a Decision ID or linked primary message. Current pubspec, AppFonts, ArvinTheme and PDF tests all use Vazirmatn. The test named vazirharf_settings_convergence_test.dart also asserts Vazirmatn. Do not infer product approval from code/tests. |

No font assets, code or tests were modified. Resolve the source authority before a separate typography remediation wave.

---

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


---

# REV10 — Single Product Architecture Audit (COMMAND 07-A.2.93)

**Audit date:** 2026-11-14  
**Inspected source HEAD before this documentation update:** `ba1c97206939941ab57d16f36a2b7418a32c369e`  
**Branch / PR:** `rev10-m2m-v19-test-expansion` / #3463  
**Schema declaration:** `G1DriftSchema.version = 20`  
**Scope:** read-only source inspection. No installed-user database was opened. No production rows, device behavior, or cross-device restore outcome are inferred.

## Canonical ownership map — observed source, not target architecture

| Domain | Current model / owner | SQL or storage surface | Actual status and unresolved boundary |
|---|---|---|---|
| Task | `Task` / `TaskStore` | `tasks`, `task_reminders`, `follow_up_records`, `task_tags`, checklist/recurrence relations | One main Task model and one concrete production TaskStore are present. P0 gap: the REV10 migration adds nullable `tasks.center_id/project_id/category_id`, but Task has no `projectId/categoryId`; TaskStore's row decoder does not hydrate these columns and its Task INSERT omits them. The existing `centerId` is model/legacy-envelope data, not an end-to-end direct SQL relationship. |
| Project | `ProjectPlan` / `ProjectStore` | `projects`, `project_items`, `center_projects`, `project_categories` | ProjectStore currently reads the two M2M junctions and its Upsert path writes explicitly supplied Center/Category edges. `project_items` remains the Task membership relation. Do not confuse the compatibility `projects.center_id` column with the canonical Center↔Project graph. |
| Center | `ArvinCenter` / `CenterStore` | `centers`, `center_projects`; Task direct FK column added by REV10 migration | CenterStore reads and writes Center↔Project edges. Its current delete guard checks both `center_projects` and the legacy `projects.center_id` projection, plus `tasks.center_id`. TaskStore does not yet maintain the Task direct FK end-to-end. |
| Category | No canonical Category model/store/CRUD boundary found | Legacy Task taxonomy: `taxonomy_categories`; canonical Project catalog: `categories`; edge: `project_categories`; Task direct FK column added by migration | Two distinct concepts currently coexist: legacy Task category text and stable-ID Project Category entities. Task taxonomy UI/CRUD still targets the legacy text catalog. Migration seeds canonical Category rows, but no single production Category repository/CRUD and Project selector were established by this audit. |
| Tag | Task tag values / `TaskStore`; `TagStore` is a facade | `tags`, `task_tags` | TagStore delegates to TaskStore; it is not a second catalog. Preserve the existing many-to-many SQL relation and template references. |
| Follow-up | `FollowUpRecord` (source-compatible alias `FollowUp`); `FollowUpRepository` / `FollowUpWriteCoordinator` | `follow_up_records`, `follow_up_record_people` | Historical Follow-up writes have a repository boundary. Follow-up history is not the future Reminder scheduler; deprecated next-follow-up values are compatibility metadata only. |
| Reminder | `TaskReminder` on Task; TaskStore plus reminder projection/delivery services | `task_reminders` | This is the active Reminder data path. Keep it independent from Due Date and historical Follow-up records. Full product/device scheduling acceptance remains separate from model/schema existence. |
| Notebook | `CanonicalNotebookRepository` | Same canonical TaskStore / `tasks` | Notebook intentionally owns no separate Task database or model. Its Task writes delegate to TaskStore; Project membership delegates to TaskProjectAssignmentService. |
| Calendar | `CalendarPage` plus internal schedule projections and Android provider bridge | Task/Follow-up projections; external calendar link store for provider links | Calendar is a projection/integration surface, not another owner of Task or Follow-up records. End-to-end provider/device parity is not established by this source audit. |
| Reports | Report pages and Task/Follow-up report projections/renderers | Read models over canonical records | Derived/read-only layer; no second Task persistence owner identified. Report UI/PDF acceptance remains unverified here. |
| Backup / Restore | `ArvinBackupManager`, `ProjectBackupBridge`, `BackupPage` | Existing portable JSON backup document plus store-specific restore operations | This is the active UI path found. It includes Tasks, Projects, legacy Category names, Tags, People and calendar links. It does not export/import the canonical stable-ID `categories` entity catalog; therefore Project↔Category cross-device restoration is not proven. `BackupService` is a separate SharedPreferences JSON v1 implementation and must be classified by consumer search before removal or continued product use. |

## Source corrections and stale documentation

The current PR #3463 description contains earlier audit statements that no longer match the inspected source:
- It says CenterStore deletion checks only the legacy `projects.center_id`; current `CenterStore.delete` also counts `center_projects`.
- It says ProjectStore ignores the M2M joins and deletes/recreates Projects; current ProjectStore loads both junction tables and has an additive Upsert path, with explicit collection/snapshot deletion methods kept separate.
- These source-level improvements are real implementation evidence, but they do not establish complete product acceptance. PR body and older status documents should be reconciled rather than used as substitutes for current source.

## P0 consolidation order

1. Complete Task relationship ownership in the existing Task model/TaskStore: preserve Missing vs explicit NULL, hydrate and write the three nullable SQL FK columns, validate the approved graph, and keep `project_items` as a compatibility projection without dual authority. No name-based inference.
2. Establish one canonical Category entity API over the existing `categories` table; keep legacy Task taxonomy separate. Wire Project Category selection and all required consumers to stable Category IDs.
3. Extend the existing backup document/restore flow with a versioned canonical Category catalog. Restore Category entities before Project↔Category edges; retain the legacy `categories` name list for old backup compatibility; fail and roll back on unresolved IDs.
4. Verify Project/Center CRUD, archive/delete, template, Task editor, Home, Notebook, Calendar and Reports against the same canonical relations. Do not remove compatibility fields/tables until all consumers and historical parity gates pass.
5. Reconcile stale PR descriptions and existing continuity documents after source and exact-SHA evidence is updated.

## Acceptance boundary

- **IMPLEMENTED (source only):** schema v20 lifecycle and M2M migration candidate; ProjectPlan/ProjectStore Center and Category edge support; CenterStore M2M-aware deletion guard; TaskStore canonical Task/Reminder/Follow-up/Tag persistence; Notebook delegation to TaskStore; Follow-up repository boundary.
- **NOT IMPLEMENTED / NOT VERIFIED:** Task direct Center/Project/Category model-to-SQL round trip; canonical Category CRUD and Project selector; canonical Category catalog backup/restore; complete product-wide consumer convergence; installed-user data parity; device acceptance.
- **CI at inspected SHA:** Build, SQLite v20 acceptance, SQLite snapshot, Follow-up persistence, Device Smoke and orchestrator-related runs were queued/pending; Draft Review APK was skipped. No PASS is claimed for this SHA.
- **Development environment:** this audit was performed through GitHub source APIs only. Flutter/Dart execution, Dart Analyze, Flutter tests and local APK/device validation were not run in this environment.
- **Safety:** Main remains read-only. PRs #3384, #3463 and #3470 remain open/draft/unmerged. No merge, release, deployment, destructive migration or NIRA change was performed.
