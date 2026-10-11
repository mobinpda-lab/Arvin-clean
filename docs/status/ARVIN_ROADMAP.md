# Arvin Execution Roadmap
**Created:** 2026-10-11  
**Repository:** `mobinpda-lab/Arvin-clean`  
**Plan basis:** Repository reality audit of `main@72a2f4cc24df7a38eff9856ce403461615db5280`  
**Mode:** Stabilize existing product; no redesign, rebuild, schema change, or new Core feature is authorized by this roadmap.

## Current Project State
**Overall: PARTIAL — Release Ready is not proven.** The Task model, SQLite/Drift persistence, recurrence/checklist, Calendar integration and versioned backup paths exist. The highest-risk work is to prove data integrity across the real legacy-to-SQL and backup/restore paths, then close Core Flow and integration acceptance. Workflow files and existing tests are not, by themselves, release evidence.

## Current Phase
**Phase 1 — Data Integrity and storage-path proof (P0).**

### CURRENT BOTTLENECK
- **Problem:** The canonical SQL Task path coexists with legacy compatibility paths, and end-to-end data preservation through migration, backup, restore and Calendar-link reconciliation has not been proven on representative upgraded data.
- **Impact:** Users could lose or disconnect task details, checklist occurrence state, project/category/tag relations, history or external Calendar links during upgrade or recovery.
- **Why Now:** Data loss is the highest-impact release risk. Stabilizing this before UI polish or new capabilities follows FIX WHAT EXISTS / STABILIZE BEFORE EXPAND.
- **Success Criteria:** Identify all production call sites for legacy `TaskMigrationWriter`, `TagStore` and legacy `BackupService`; classify each as active, compatibility-only or unused with evidence; complete migration → edit → backup → restore → verify with stable Task IDs, Project membership, Category/Tags, checklist/repeat/history and Calendar-link reconciliation; demonstrate interruption/rollback behavior or explicitly keep that path blocked; attach exact commit, test run and device/emulator limitations. No destructive change until recovery is demonstrated.

## Priority Classification

### P0 — Critical: data integrity and release gate
1. **Legacy/SQL write-path inventory and migration safety**
   - Action: Search all app/test call sites for `TaskMigrationWriter`, `TagStore`, legacy `BackupService` and canonical `TaskStore`; record which are reachable and when.
   - Owner: Core / Storage.
   - Affected components: TaskStore, migration reader/adapter/writers, SharedPreferences compatibility, Drift schema and backup.
   - Risk: High — any write-path or migration change can affect user data.
   - Test required: Existing migration tests plus migration with existing data, interrupted cutover/retry, stable-ID equality, rollback/source preservation and old-payload compatibility.
   - Evidence required: Call-site inventory, exact SHA, full relevant test output, before/after record counts and ID comparison, migration/rollback result.
   - Expected result: One documented canonical production path; legacy paths explicitly bounded, not casually deleted.
2. **Backup/Restore Golden Flow**
   - Action: Exercise representative existing data through backup and restore, including related entities and external Calendar link metadata.
   - Owner: Data Safety + QA.
   - Affected components: ArvinBackupManager/Service, TaskStore, Project backup bridge, taxonomy relations, occurrence state, ExternalCalendarLinkStore.
   - Risk: High — recovery failure can cause permanent loss.
   - Test required: Round-trip Task IDs/content, Project membership, Category, Tags, checklist items and per-occurrence completion, repeat history, Follow-up history and Calendar link conflict handling; invalid/corrupt input and interrupted restore.
   - Evidence required: Exact-head automated test results, backup/restore artifact or anonymized verification report, device/emulator details and rollback outcome.
   - Expected result: Restore preserves the same logical Tasks and relationships without silent loss or duplicate links.
3. **Release authorization and exact-head gate**
   - Action: Resolve release workflow gates only after technical acceptance and explicit product-owner approval.
   - Owner: Release/CI + Product owner.
   - Affected components: Final Head Release Validation, Release Closure, build artifacts and release evidence.
   - Risk: High — release must not occur without authorization and verified artifacts.
   - Test required: Analyze, all test shards, Debug/Release APK, applicable Android smoke/integration tests and evidence/artifact/hash checks on exact final main.
   - Evidence required: Successful exact-SHA workflow runs and artifacts; explicit product-owner approval recorded in the approved mechanism.
   - Expected result: Release can be considered only when technical gates pass and authorization exists.
   - Current evidence: Main Release Closure run #9289 failed at “Require explicit product release approval”; release-build and publish steps were skipped. This is an authorization gate, not proof of an app-code failure. Final Head Release Validation runs #8800/#8801 were skipped.

### P1 — Core Experience
4. **Task editor continuity**
   - Action: Verify Quick Add → Full Editor → Save/Cancel keeps the same Task ID and draft, and preserves date/time, checklist, repeat, Follow-up and tags/category.
   - Owner: Task UX + QA.
   - Affected components: Home capture, Task editor/detail, TaskStore, checklist and recurrence.
   - Risk: Medium-high — accidental duplicate/lost edits undermine daily trust.
   - Test required: Existing widget tests plus save/reopen/cancel/reopen flows, ordinary Task with Follow-up disabled, recurrence checklist isolation and constrained RTL layout.
   - Evidence required: Exact-head tests, screenshots/visual review and device/emulator record.
   - Expected result: Quick Add remains quick; advanced options do not create a second Task or separate storage.
5. **Calendar link integrity**
   - Action: Prove create/update/delete/relink behavior with existing external events.
   - Owner: Calendar integration + QA.
   - Affected components: Outbound/inbound sync, provider executor, external link store, recurrence and backup restore.
   - Risk: High when wrong events are changed; otherwise medium.
   - Test required: Update same event without duplicates; stale/deleted event; permissions; recurring events; changed calendar; restore/relink.
   - Evidence required: Calendar Provider integration run at exact SHA, event-ID before/after comparison, then physical-device acceptance.
   - Expected result: Task remains the source of truth; external Calendar is a projection and updates target the correct linked event.
6. **Taxonomy consistency**
   - Action: Finish the existing repository-wide audit in Issue #2580 and resolve Category/Project semantics before any schema or query change.
   - Owner: Product/domain + UI/docs + QA.
   - Affected components: Project, Category, Tag, Home filters, search, reports, Calendar, backup/restore and help/docs.
   - Risk: Medium-high — inconsistent concepts can misclassify or hide Tasks.
   - Test required: Filter AND semantics, assignment, search/report consistency and backup/restore round-trip.
   - Evidence required: File-by-file vocabulary audit, approved decision, affected tests and exact SHA.
   - Expected result: Exactly three concepts: Project, Category (Group is not a separate entity), and Tag; no parallel taxonomy.
7. **Repeat, checklist and Follow-up full-flow**
   - Action: Verify current implementation across create/edit/complete/skip/missed, per-occurrence checklist, history, reminders and backup.
   - Owner: Core + QA.
   - Affected components: Task model/store, recurrence repository, Follow-up services, notifications and backup.
   - Risk: High if occurrence history or checklist state is overwritten.
   - Test required: Occurrence independence, historical state preservation when the repeat definition changes, notification action and backup/restore round-trip.
   - Evidence required: Unit + integration results, exact SHA, and real-device evidence for notification behavior.
   - Expected result: One Task, clear per-occurrence state, preserved history and reliable follow-up.

### P2 — Quality Improvement
8. UI polish, performance and animation only after P0/P1 acceptance.
   - Owner: UI/Performance + QA.
   - Risk: Low to medium; no visual redesign without explicit approval.
   - Test/evidence: Before/after screenshots, RTL and constrained-screen checks, targeted performance/regression tests.
   - Expected result: Better readability/responsiveness without changing the approved Arvin identity or data behavior.

### P3 — Future Ideas (deferred; not Core work before Release Gate)
- New standalone entities or a second checklist/tracking/calendar/backup system.
- Database normalization or a Category-to-Project schema change before the product semantics decision and migration/rollback plan.
- New Core features, broad redesign, animation expansion or speculative optimization.
- Removal of legacy compatibility code before call-site proof and safe migration/rollback evidence.

## Execution Order
1. **Data Integrity:** storage-path inventory → migration safety → backup/restore Golden Flow.
2. **Core Flow:** Quick Add/Full Editor, Checklist, Repeat and Follow-up end-to-end.
3. **Integration:** Calendar Provider, reminders, restore relinking and device smoke.
4. **UX Improvement:** screenshots, visual review, RTL and constrained-device acceptance.
5. **Optimization:** targeted performance work based on measured regressions.

Independent documentation, test inventory and CI evidence inspection may proceed in parallel. Data-changing implementation remains serialized behind the approved storage/migration decision. Do not create a second storage path, entity, workflow or duplicate issue.

## Status
### Completed
- Repository audit documents drafted: repository map, Task core status and gap analysis.
- Current status report rewritten on the audit branch against the stated main SHA.
- Exact-main workflow snapshot checked; release closure currently requires explicit product-owner approval.
- This roadmap is documentation-only.

### In Progress
- Review/CI of documentation PR #2599.
- Phase 1 planning; storage call-site inventory and Golden Flow execution are not yet evidenced complete.

### Next
1. Complete legacy storage/backup call-site inventory and attach references.
2. Inspect the latest exact-main CI results and identify failed release-closure checks without bypassing approval.
3. Run migration and backup/restore Golden Flow on a representative dataset.
4. Close the existing taxonomy issue #2580 and record the Category/Project decision before any related code change.
5. Execute Core Flow and Calendar acceptance, then physical-device checks.
6. Re-evaluate release only after exact-main gates pass and the product owner explicitly approves.

### Blocked
- **Release:** explicit product-owner approval is absent; main Release Closure run #9289 failed at the approval step, and later build/publish steps were skipped.
- **Data-safety closure:** real upgraded-data round-trip and interruption/rollback evidence are not recorded in this audit.
- **Physical-device acceptance:** not performed by this audit; requires device test evidence.
- **Category/Project schema semantics:** needs an explicit product decision before schema/query changes.

## Release Estimate
**Calendar date: not responsibly estimable yet.** The remaining work is evidence-gated and includes data-safety validation, integration/device acceptance and explicit release authorization. Re-estimate after the Phase 1 Golden Flow has a measured result and the current exact-main CI state is known. Do not equate a green CI run, an APK build or this roadmap with release readiness.

## Evidence Links
- Audit PR #2599: https://github.com/mobinpda-lab/Arvin-clean/pull/2599
- Taxonomy audit Issue #2580: https://github.com/mobinpda-lab/Arvin-clean/issues/2580
- Main Release Closure run #9289 (failed at explicit approval gate): https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38115567877
- Final Head Release Validation run #8801 (skipped): https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38115590777
- Canonical operating standard: https://github.com/mobinpda-lab/Arvin-clean/blob/main/docs/ARVIN_PROJECT_OPERATING_PACKAGE.md
- Architecture decision: https://github.com/mobinpda-lab/Arvin-clean/blob/main/docs/ADR/ADR-2026-10-10-PCTADP-project-category-tag.md
