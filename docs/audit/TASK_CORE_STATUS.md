# Task Core Status
**Audit date:** 2026-10-11  
**Base:** `main@72a2f4cc24df7a38eff9856ce403461615db5280`  
**Verdicts:** PASS = direct source/test evidence supports the invariant; PARTIAL = code exists but an integration/data-safety gate remains; FAIL = inspected source contradicts the required invariant. UNKNOWN = evidence was not sufficient.

## Summary
**Overall: PARTIAL.** Arvin has one canonical `Task` domain model and a SQLite/Drift TaskStore. However, the storage transition is not demonstrably complete across all write paths, some canonical state remains in a preserved JSON envelope, and the full relationship/backup/device evidence is not complete.

| Check | Verdict | Evidence and reasoning |
|---|---|---|
| One canonical Task model | PASS | `lib/models/task.dart` contains Task, checklist, occurrence state, recurrence, FollowUp history and tags/category; migration adapter also decodes into Task |
| Task identity is stable through SQL migration | PASS at unit-test level | `TaskMigrationAdapter` rejects missing/duplicate IDs; `TaskStore._verifyLegacySourceBeforeCutover` compares SQL and legacy ID sets; `test/services/sql_task_migration_writer_test.dart` checks migration |
| TaskStore is the only active write path | PARTIAL | `lib/services/task_store.dart` is canonical SQL storage, but `lib/services/task_migration_writer.dart` still writes `arvin.tasks` in SharedPreferences as a legacy Home boundary. Main/Home tests say current wiring uses TaskStore; every caller and historical path needs a call-site audit before declaring the old write path retired |
| Relational schema covers all Task state | PARTIAL | SQL tables cover core fields, FollowUps, tags, checklist rows and people. `legacy_payload_json` preserves unknown/additive fields such as `checklistOccurrences` and `occurrenceHistory`; these are not separate relational tables in schema version 5 |
| Project relation avoids duplicate Task payloads | PASS | `ProjectPlan.itemIds` stores canonical Task IDs; `project_items` links project_id/task_id; TaskStore preserves project_items while rewriting Task rows |
| Category and Tag are distinct | PASS in model/schema | `Task.category` and `Task.tags` are separate; SQL has `taxonomy_categories`, `tags`, `task_tags` |
| Category is physically owned/scoped by Project | UNKNOWN / unresolved decision | Current schema has no category.project_id and Task has no projectId; Project membership is represented Project→Task. Accepted ADR and Issues #2580/#2582 explicitly flag this as an audit question, not a completed relation |
| Checklist belongs to Task | PASS at model level | `Task.checklist`, `checklistEnabled`, `checklistOccurrences`; migration and TaskStore use canonical Task ID |
| Checklist completion is independent per recurrence occurrence | PASS at repository/unit-test level | `TaskRecurrenceRepository` stores per-occurrence checklist state on the same Task; `test/task_recurrence_repository_test.dart` checks two dates independently |
| Repeat creates new cloned Task rows | PASS — no clone path found in inspected recurrence code | `TaskRecurrenceRepository` updates one Task and its occurrenceHistory; `RecurrenceRule.occurrencesBetween` is documented as not persisting occurrences |
| Follow-up is a Task extension, not an independent task system | PASS at model level | `FollowUp` is defined with Task in `lib/models/task.dart`; SQL `follow_ups.task_id` references Task; repository writes through TaskStore |
| Tracking is not a separate CRM Task store | PASS in inspected model boundaries | Follow-up state remains on Task/FollowUp; no independent Tracking model/store was found in inspected canonical paths. Full repository-wide audit still required |
| Backup includes Task identity and extended state | PARTIAL | Canonical backup serializes Task JSON and tests cover recurrence/checklist/Project fields; external link metadata is included through the canonical path. A second legacy SharedPreferences BackupService still exists; actual-device restore/rollback remains a release gate |
| Data migration is safe and rollback is proven | PARTIAL | SQL migration is transactional, preserves the legacy source and original JSON envelope, and verifies ID equality. This is not equivalent to proving all schema upgrade paths, rollback, interrupted migration and real-device upgrade behavior |
| History is immutable | PARTIAL | Recurrence service preserves FollowUp history on resume; code allows state updates to occurrenceHistory. A complete immutability contract for all historical records is not proven by inspected code |
| Test evidence exists for key invariants | PASS for selected focused tests; overall PARTIAL | Relevant model, migration, recurrence, checklist, backup, calendar and SQL integration tests exist. This audit did not run the suite; latest main release-validation workflow was still in progress |

## Data-path snapshot
```
Home / editors / projections
          ↓
Task (canonical domain identity)
          ↓
TaskStore (SQLite/Drift + legacy JSON envelope)
          ├── follow_ups → Task ID
          ├── checklist_items → Task ID
          ├── task_tags → Task ID + Tag ID
          ├── task_people → Task ID
          └── project_items ← Project ID + Task ID

External Calendar provider IDs → ExternalCalendarLinkStore
Backup document → Task JSON + Projects + settings + Calendar-link metadata
```

## Highest-risk unresolved items
1. Prove that every production create/edit/archive/restore path writes through the canonical TaskStore and that legacy `arvin.tasks` writes are migration-only or deliberately retained.
2. Reconcile recurrence checklist/history storage: dedicated tables or the JSON envelope must have explicit versioning, integrity and backup/migration guarantees; do not change schema without a migration/rollback plan.
3. Resolve Category/Project semantics with the product owner before adding any foreign key or changing assignment/filter behavior.
4. Exercise full backup → destructive restore confirmation → relink verification on a real device with representative existing data.
5. Obtain final-head Analyze/full tests/Debug+Release APK/Android integration evidence, then physical-device UX acceptance. No release-ready claim before those gates.
