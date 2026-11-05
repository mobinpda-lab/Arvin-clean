# Arvin Gap Analysis
**Audit date:** 2026-10-11  
**Audited source:** `main@72a2f4cc24df7a38eff9856ce403461615db5280`  
**Mode:** Observe / Analyze / Report only. No application code, schema, migration, workflows or user data changed.

## Completed — evidence supports the architecture direction
- One canonical `Task` model exists in `lib/models/task.dart`.
- `TaskStore` uses SQLite/Drift, preserves Task identity, uses a transaction for bulk replacement, and keeps an original JSON envelope for fields not represented directly.
- Project membership stores canonical Task IDs instead of copying Task payloads.
- Category and Tag are separate fields and SQL relations. The accepted ADR establishes Category and Group as one concept; the inspected Home `HomeGroup<T>` is a presentation projection, not the taxonomy entity.
- Recurrence uses one Task and per-occurrence state rather than creating a new Task per occurrence in the inspected canonical repository.
- External Calendar sync has a separate link store, stable provider IDs, revision fingerprints, and explicit update logic that verifies event identity before writing.
- Focused tests exist for Task serialization, SQL migration, recurrence/checklist occurrence state, Project backup portability, calendar sync, and backup document validation.

## Partial — implementation exists but evidence/closure is incomplete
1. **Canonical storage cutover:** SQL is active, but legacy `arvin.tasks` migration/read-merge-write code remains. Confirm all production call sites and document the supported transitional boundary.
2. **Relational completeness:** recurrence checklist state and occurrence history are preserved in `legacy_payload_json`, not modeled in dedicated SQL tables. This may be acceptable temporarily, but must be intentional, versioned and tested across every rewrite/backup/restore.
3. **Taxonomy catalogs:** SQL catalogs for Category and Tag coexist with a legacy `TagStore` backed by SharedPreferences. Repository code search did not find a confirmed active call site for `TagStore`; verify all call sites and unused catalog behavior before retiring it.
4. **Backup/restore:** canonical `ArvinBackupManager` and tests exist, including Task/Project round-trip contracts. The separate simple `BackupService` also exists. Confirm it is legacy/unreferenced and test real-device restore, relation preservation, Calendar link conflict handling, corrupt input, and interruption/rollback.
5. **Calendar ownership and sync:** source architecture treats Task/FollowUp as canonical and provider events as projections. Duplicate prevention/update paths exist, but external provider deletion, stale links, changed target calendars, permissions, recurring events and restore relinking require exact-head integration evidence.
6. **Project / Category relation:** Project→Task membership exists, and Category is a Task field/catalog. No physical Category→Project foreign key was found in inspected schema. Product semantics must be explicitly resolved; no schema change is authorized by this audit.
7. **UI and UX acceptance:** widget/integration tests and smoke workflows exist, but no screenshot comparison or physical-device acceptance was executed in this audit.
8. **Repository status documentation:** `docs/ARVIN_STATUS.md` references a historical PR #135 and operating package v49.0 without tying status to the current main SHA. Update the status source and maintain evidence links.
9. **CI/release evidence:** `build.yml` defines Analyze, six test shards and APK builds; device smoke and Calendar Provider acceptance workflows exist. At audit time, current-main Final Head Release Validation run #8799 was still in progress. Workflow configuration is not a passed result.

## Conflict — concrete inconsistencies or competing boundaries
- **Legacy parallel backup API:** `lib/services/backup_service.dart` exports/imports SharedPreferences wholesale, while `lib/backup_service.dart` plus `lib/backup_manager.dart` implement the canonical versioned Task/Project/settings/calendar-link document. The active main wiring uses the canonical manager, but the legacy class still exists; confirm it is unreachable or clearly deprecated. Do not remove it during this audit.
- **Legacy TagStore vs SQL Tag catalog:** `lib/services/tag_store.dart` stores `arvin.tags` in SharedPreferences, while `TaskStore` owns `tags` and `task_tags` in SQL. This is a competing storage boundary if the legacy store is used; active caller status is not proven by the available code search.
- **Historical documentation drift:** `docs/ARVIN_STATUS.md` names PR #135 and an old package revision as current gate, despite main being at SHA `72a2f4c` and recent work covering the PCTADP decision. Treat the status file as stale, not as current implementation evidence.
- **No confirmed Group domain entity in inspected schema:** `HomeGroup<T>` and `HomeGroupMode` are view/grouping abstractions. They are not a conflict by themselves; the open taxonomy audit #2580 must still finish repository-wide UI/help/documentation wording review.

## Risk — release blockers or high-severity uncertainty
- **P0 Data safety:** legacy-to-SQL migration, backup/restore, preserved JSON envelope and project membership must be tested together on upgraded real data, including interrupted migration and rollback.
- **P1 Calendar integrity:** prove linked event update does not create duplicates and never updates/deletes the wrong provider event; test restored/stale provider IDs and external event deletion.
- **P1 Task editor consistency:** verify Quick Add → Full Editor → Save/Cancel preserves the same Task ID, draft values, checklist/repeat/follow-up and creates no duplicate.
- **P1 Checklist recurrence:** verify template changes do not silently rewrite historical occurrence completion state; test backup/restore of per-occurrence state.
- **P1 Taxonomy integrity:** decide whether Category is globally scoped or Project-scoped before schema/query work; preserve Category/Tag distinction and filter AND semantics.
- **P1 Release evidence:** no claim of release readiness until exact final main has successful Analyze, all test shards, Debug/Release APKs, relevant Android smoke, evidence artifact/hash checks and physical-device acceptance.

## Recommended next actions
1. **P0 — finish existing Issue #2580** with file-by-file Project/Category/Tag/Group term classification across app UI, help, tests and docs; do not create another taxonomy issue.
2. **P0 — storage path proof:** audit all call sites of `TaskMigrationWriter`, `TagStore`, and legacy `BackupService`; document whether each is active, compatibility-only, or safely removable in a later approved PR.
3. **P0 — data safety Golden Flow:** legacy data → SQL upgrade → edit Task/checklist/repeat/follow-up → backup → restore candidate → confirm → verify Task IDs, Project membership, Category/Tags, history and Calendar links.
4. **P1 — Calendar Provider acceptance:** run `integration_test/android_calendar_provider_acceptance_test.dart` and record exact SHA/provider/emulator limitation; follow with physical-device verification.
5. **P1 — Task editor acceptance:** exact-head tests and screenshots for Quick Add, Full Editor, cancel/save, 24-hour picker, checklist visible without Follow-up, RTL and constrained viewport.
6. **P1 — release evidence:** inspect run #8799 to completion and verify final-head evidence/artifact checks; do not infer success from a running workflow.
7. **P2 — documentation:** reconcile stale status records and preserve historical documents as historical rather than deleting them.

## Audit exclusions
- No code edits, refactors, schema/migration changes, file deletion or workflow edits.
- No tests/builds were executed by this audit authoring pass.
- Source inspection is not equivalent to a complete runtime, visual or physical-device audit.
- This report does not authorize merge or release.
