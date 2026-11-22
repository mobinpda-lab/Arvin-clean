# ENTITY RELATIONSHIP MATRIX — ARVIN REV10 / MASTER EXECUTION 150-R

**Repository:** `mobinpda-lab/Arvin-clean`  
**Canonical PR:** #3495  
**Source audit SHA:** `ac52f706a6b785a2b194a46bc97866d48c54b5e5`  
**Authority:** REV10; approved 2026-11-14 Center–Project / Project–Category M2M ADR

| Source | Target | Cardinality / contract | Database structure | Store / writer | Consumers | Restart / persistence | Backup / restore | Test / evidence | Status |
|---|---|---|---|---|---|---|---|---|---|
| Center | Project | Many-to-Many | `center_projects(center_id, project_id)`; composite PK; reverse index | CenterStore link/unlink/replace and bidirectional lookup; ProjectStore does not own edge reads/writes | CenterStore only; Project UI and Home consumers absent | File-backed close/reopen test exists | CenterProject edges not included in portable backup | `test/center_store_file_persistence_test.dart`; exact-SHA Build pending | **PARTIAL** |
| Project | Category | Many-to-Many | `project_categories(project_id, category_id)`; composite PK; reverse index | No canonical ProjectCategory Store/API found | No verified Project/Category management consumer | Table is created by v9 migration; no relation round-trip test found | Not included in portable backup | Migration test verifies schema/FK safety, not user-managed M2M operations | **PARTIAL** |
| Project | Task | Project membership list; legacy M:N `project_items`; Task also has optional single `project_id` | `project_items(project_id, task_id, ordinal)` plus `tasks.project_id` | ProjectStore owns legacy membership; TaskStore writes direct optional field; TaskProjectAssignmentService bridges assignment | Projects page, selector, Notebook, Quick Capture and Home | ProjectStore file persistence and Task hierarchy test exist | Both Task and Project payloads included; exact membership parity in all restore cases incomplete | `test/project_store_file_persistence_test.dart`, `test/task_center_relation_persistence_test.dart` | **PARTIAL** |
| Center | Task | Optional 0..1 direct Task assignment | `tasks.center_id` FK to `centers.id` | TaskStore persists the direct FK; CenterStore checks direct Task references before delete | Task Editor, Quick Capture and Home Center selection are absent | File-backed Task hierarchy close/reopen test exists | Task JSON can retain the ID; Center catalog and relationship endpoint are not backed up | `test/task_center_relation_persistence_test.dart` | **PARTIAL** |
| Category | Task | Optional 0..1 direct assignment; legacy category text retained | `tasks.category_id` FK plus legacy `tasks.category` and `taxonomy_categories` | TaskStore persists Task field; catalog CRUD remains on legacy string catalog | Legacy Task Category field and Home filter; no canonical Category entity selection | Task hierarchy migration/persistence test exists | Task JSON/legacy category list included; canonical Category rows not proven portable | `test/task_center_relation_persistence_test.dart`, migration tests | **PARTIAL** |
| Task | Tag | Many-to-Many | `tags` + `task_tags(task_id, tag_id, ordinal)` | TaskStore catalog and Task relation persistence | Task Editor, Home Tags filter and Notebook | TaskStore persists join rows; exact standalone Tag acceptance not established | Tags catalog and Task tags are included in portable backup | Task/editor/backup test suite; final exact-SHA acceptance pending | **IMPLEMENTED** |
| Task | People | Many-to-Many | `task_people(task_id, person_id, person_json, ordinal)`; Person directory table | TaskStore + Task People service | Task Editor, Person Directory and Task detail | SQL-backed Task relations survive reopen | People directory and Task references included | Person Directory and Task People tests; Device Smoke People PASS on 149-R SHA | **IMPLEMENTED** |
| Follow-up | People | Many-to-Many | `follow_up_people(follow_up_id, person_id, ordinal)` | TaskStore Follow-up serializer/repository | Follow-up editor and People Directory | SQL relation is read/written with Follow-up | Follow-up payload included through Task backup; full orphan-person edge cases require acceptance | Follow-up repository and Person tests | **IMPLEMENTED** |
| Task | Reminder | One-to-Many embedded Reminder records | `taskReminders` in Task JSON/legacy payload; no dedicated reminders table | TaskStore | Task Editor, Android scheduler, notifications, Calendar projection | File-backed Task Reminder persistence test exists | Reminder records and extension fields are included in Task backup | `test/task_reminders_file_backed_sqlite_test.dart`, `test/task_store_reminder_persistence_test.dart` | **PARTIAL** |
| Task | Follow-up | One-to-Many | `follow_ups.task_id` FK; unique ordinal per Task | TaskStore and Follow-up write coordinator | Task Detail, Follow-up UI/timeline, notification planner | File-backed Follow-up persistence test and Run 44930273121 PASS on 149-R SHA | Follow-ups travel in canonical Task backup | Follow-up repository/lifecycle tests | **IMPLEMENTED** |
| Reminder | Calendar Link | Optional one provider-event link per Reminder identity | ExternalCalendarEventLink serialized in SharedPreferences JSON; not SQLite | ExternalCalendarLinkStore + Calendar sync services | Calendar provider sync and Calendar page | COMMAND 20-E proved 8 links / 32 field assertions across Android process restart on 149-R SHA | Calendar links included in portable backup; provider identity is revalidated | Run 44930273200 Calendar restart evidence PASS; overall gate NO-GO due Build | **PARTIAL** |
| Task | Calendar | Derived 1:N through Task due-date / TaskReminder identities; no direct Task–Calendar FK | Task reminders remain in Task JSON; provider link metadata is keyed by reminderId in SharedPreferences | TaskStore/projections + ExternalCalendarLinkStore; no duplicate calendar store | Calendar page, inbound/outbound provider sync and reschedule flows | Process-restart proof exists for the provider-link records | Task data and Calendar links are included in portable backup; complete Center/M2M parity is absent | COMMAND 20-E Run 44930273200 proved eight links and 32 field assertions across Android process restart on 149-R SHA | **PARTIAL** |
| Project | Template | Historical optional reference only; no verified current runtime contract | Historical v8 `projects.template_id`; not in canonical v9 fresh schema | No current Template/Project template writer found | No verified current Template consumers | Historical fixture only | No current backup path verified | Historical V8 fixture test only | **NOT IMPLEMENTED** |
| Template | Template Tasks | One-to-Many in historical v8 schema | `project_template_tasks.template_id` FK in fixture | No current TemplateTask store | No verified runtime consumers | Historical DDL fixture only | No current backup path verified | Historical V8 fixture test only | **NOT IMPLEMENTED** |
| Template Tasks | Template Applications | Historical join/application relation | `template_task_applications(template_task_id, project_id, task_id)` in fixture | No current application writer/reader | No verified runtime consumers | Historical DDL fixture only | No current backup path verified | Historical V8 fixture test only | **NOT IMPLEMENTED** |
| Task | Notebook | Same Task identity classified by `notebookKind`; not a separate FK relation | `tasks.notebook_kind` and `checklist_items` | CanonicalNotebookRepository delegates to TaskStore | Notebook page, Project assignment and category/tag consumers | Same Task persistence and file-backed store | Included as Task records | Notebook repository/page/membership tests | **IMPLEMENTED** |
| Center / Project | Reports | Derived query/projection; no dedicated stored relation | Report projections read canonical Task/Project data; Center query path absent | Report projections/adapters | Report Center and PDF/text output | Depends on underlying Task/Project persistence | No Center report parity in backup acceptance | Report projection/page/PDF tests | **PARTIAL** |
| Migration Exception | Historical entity | Polymorphic reference via entity_type + entity_id; not FK by design | `arvin_migration_exceptions` unique migration/entity/code key | G1Rev10HierarchyV9Migration writes records transactionally; no management reader | Migration diagnostics only | Exception rows commit with migration marker or roll back together | Exception ledger absent from portable backup | File-backed migration failure-injection/retry tests | **PARTIAL** |

## Canonical relationship decisions

1. Center↔Project and Project↔Category are M2M. Do not restore the superseded single-parent assumption.
2. Task's direct Center, Project and Category assignments are independently optional, zero-or-one fields. A Task may remain standalone.
3. Task↔Tag and Task↔People remain M2M.
4. Follow-up and Reminder remain independent Task-owned data; Task-to-Calendar is a derived projection through due-date/TaskReminder identities, while external provider links are keyed by reminderId. Legacy Follow-up reminder metadata must not be projected as a duplicate independent Calendar Reminder.
5. Notebook is a Task classification, not a parallel Task/Note catalog.
6. Project membership currently has both legacy `project_items` edges and direct `tasks.project_id`. Their semantics and write authority must be reconciled before acceptance.
7. Canonical Project↔Category join storage exists but is not yet exposed through a complete Store/API/UI/backup path.
8. No relationship is COMPLETE. A passing relation test on an earlier SHA is historical evidence only and must be rerun or included in the exact Candidate's verified CI.

## Relationship acceptance blockers

- Center↔Project: wire Project consumers and backup/restore; preserve edges across independent A→B restore.
- Project↔Category: implement canonical relation Store/API, duplicate/idempotent edge behavior, bidirectional lookup, archive/delete safety and backup/restore.
- Project↔Task: reconcile `project_items` and `tasks.project_id` without losing legacy membership.
- Center↔Task and Category↔Task: expose real selection in Task Editor and Quick Capture; validate allowed relation combinations.
- Task↔Reminder: deliver the approved four-action floating window without a second scheduler.
- Calendar: keep provider link metadata identity-safe and prove backup/restore plus real-device behavior.
- Template relations: recover runtime functionality only after source assets and data contracts are verified.
- Reports: add Center/Project-aware projections and independent acceptance.


## MASTER EXECUTION 151-R — LIVE ACCEPTANCE ADDENDUM (2026-11-22)

**Audited Candidate:** `3c72a341fc1aac785a22b6fe151c23507c16793c`
**Main baseline:** `45e4202b03a434459e4c021a04efa7e8396359db`
**PR:** #3495 — OPEN / DRAFT / UNMERGED. **Release: NO-GO.**

### Exact-SHA CI
- Build `44933088338`: SUCCESS; all 9 jobs passed (Analyze, Test Shards 0–5, Debug APK, Release APK).
- Governance `44933088356`: SUCCESS.
- Follow-up File Persistence `44933088362`: SUCCESS.
- Device Smoke `44933088406`: FAILURE; Home, Quick Capture, SQL Persistence, SQL Migration, Backup/Restore and People passed; Calendar failed (6/7).
- COMMAND 20-E `44933088374`: FAILURE / NO-GO at aggregate acceptance.

### COMMAND 20-E artifact inspection
Final artifact `14719705601` and phase artifact `14718404033` were downloaded and inspected. Analyze, all six test shards, Debug/Release APK, ProjectStore file persistence, Calendar Link process restart, cleanup and Follow-up persistence passed. Process restart independently compared eight links × four fields = 32 values across distinct process PIDs 2334 and 2406. Cleanup passed without clearing app data. Aggregate NO-GO is caused by the Device Smoke Calendar failure; ProjectStore, process restart and cleanup are not the cause.

### Calendar failure boundary
The failing test is `integration_test/calendar_card_interaction_test.dart:169`. Logs prove the seeded Task was reloaded from SQLite and independent Reminder records were projected. The expected keyed Calendar card was nevertheless absent from the rendered list. The follow-on screenshot upload failed because its screenshot was not produced. Root cause is narrowed to Calendar UI/test interaction after projection; whether date selection, list construction, widget identity or test interaction is responsible remains unproven. No speculative correction is accepted.

### Entity acceptance addendum
- Center model, v9 SQLite catalog / `center_projects`, CenterStore CRUD/search/archive/restore and bidirectional M2M operations exist. File-backed Center CRUD/M2M close-reopen test exists and Build passed. Dedicated Center management UI, Project UI integration, Task Editor / Quick Capture / Details selection, portable Backup/Restore coverage and Home Center filter are not evidenced. Center remains PARTIAL.
- Center↔Project schema/store and additive idempotent link/unlink/lookups are IMPLEMENTED at storage layer; product UI and portable backup/restore relationship acceptance remain NOT ACCEPTED.
- Project↔Category join schema exists, but canonical Category model/store, relationship API/UI and accepted round-trip were not found. PARTIAL / NOT ACCEPTED.
- Home five-dimension filter contract, including Center and OR-within / AND-between semantics, remains NOT ACCEPTED.
- Reminder's four required operations (Stop Alarm, Follow-up, Snooze, Complete) are not all independently proven against canonical Task data with restart and backup/restore. PARTIAL / NOT ACCEPTED.
- Selected Backup/Restore Device Smoke passed, but independent Database A→B, repeated restore, corruption, interrupted restore, destination preservation and rollback matrix remains NOT ACCEPTED.

### Artifact IDs
Debug APK `14718821042`; Release APK `14718204892`; Smoke People `14718882016`; Smoke Home `14718517988`; Smoke Quick Capture `14718209271`; Persian Time Picker `14718612582`; COMMAND 20-E Phase `14718404033`; COMMAND 20-E Final `14719705601`.

### Disposition
150-R is NOT FINALIZED. No safe minimal Calendar source correction was committed because the root cause is not isolated. No code or tests were changed in this audit pass. No Main change, merge, release, deployment, destructive data operation, test removal or test weakening occurred.

## MASTER EXECUTION 152-R — relationship acceptance refresh (2026-11-22)
- Center↔Project: schema/store CRUD, idempotent link/unlink and bidirectional lookup are IMPLEMENTED at storage level; product relationship UI and portable Backup/Restore acceptance remain NOT ACCEPTED.
- Center↔Task: optional direct FK persistence foundation exists; Task Editor, Details and Quick Capture selection integration remains NOT IMPLEMENTED / NOT ACCEPTED.
- Project↔Category: join-table foundation exists; canonical relationship API, bidirectional product UI and accepted backup/restore round-trip remain PARTIAL / NOT ACCEPTED.
- Task↔Project: both `tasks.project_id` and legacy `project_items` remain present. Canonical consistency contract and all move/remove/reload/restart/restore scenarios are NOT VERIFIED; neither path is deleted.
- Home dimensions: Time, Project, Category, Tags and Center are the required five dimensions. The complete SQLite-backed OR-within / AND-between contract and five-dimension acceptance remain NOT ACCEPTED.
- No relationship migration, destructive edge replacement or legacy membership deletion was performed.


## MASTER EXECUTION 153-R — relationship revalidation (2026-11-22)
**Audited source Candidate:** `6fb78dee3d236385df8045149f8c929df076ae78`.

| Relationship | Current source/API | 153-R product path | Acceptance |
|---|---|---|---|
| Center → Project | Existing `center_projects` M2M; CenterStore exposes idempotent link/unlink, transactional replace and bidirectional lookup | Center Details displays associated Projects; relationship editor now selects multiple Projects and persists via existing Store | IMPLEMENTED in UI; UI tests pending; backup/restore parity NOT ACCEPTED |
| Center → Task | Existing optional `tasks.center_id`; Task model/TaskStore retain `centerId` | No Center selector in Task Editor or Quick Capture; no Center label in Task Details | PERSISTENCE IMPLEMENTED; PRODUCT UI PARTIAL |
| Project → Category | Existing `project_categories` schema table | No canonical ProjectCategory Store/API or multi-select UI verified | SCHEMA PRESENT; PRODUCT RELATIONSHIP NOT IMPLEMENTED / NOT ACCEPTED |
| Project → Task | Legacy `project_items` and optional direct `tasks.project_id` both remain | Existing assignment path still needs canonical authority/consistency proof | PARTIAL / NOT ACCEPTED |
| Task → Tag | Existing `task_tags` and TaskStore APIs | Existing editor/Home paths | IMPLEMENTED foundation; full REV10 acceptance not established |

No join table was recreated, no existing relation was deleted, and no schema/persistence contract was changed in 153-R. Lane A remains the gate for any schema or protected persistence modification.
