# ARVIN — PROJECT STATE
**Owner:** Mobin — Product Owner & Product Director  
**Repository:** `mobinpda-lab/Arvin-clean`  
**Checkpoint created:** 2026-11-10  
**Checkpoint type:** Live GitHub reconciliation + continuity protocol establishment  
**Authority:** `AI_CONTINUITY_PROTOCOL.md`

> This checkpoint records the live state observed immediately before the continuity documentation commit. The commit itself advances the branch. Every subsequent agent MUST fetch the live HEAD and must not assume this recorded SHA is still current.

## 1. Live repository baseline (pre-continuity commit)

| Item | Verified value |
|---|---|
| Default branch | `main` |
| Main HEAD | `45e4202b03a434459e4c021a04efa7e8396359db` |
| Active delivery branch | `fix/recovery-calendar-device-smoke-2026-10-31` |
| Related PR | [#3052](https://github.com/mobinpda-lab/Arvin-clean/pull/3052) |
| PR state | OPEN / DRAFT / UNMERGED |
| PR base | `main` |
| PR head / inspected SHA | `c6750a92243a3a2046ab36823f280505b5335dfe` |
| Last commit message | `docs(governance): register unresolved typography authority conflict` |
| Last commit parent | `1eb960819331d1998eeaf74ecd33a8ba56dd7aa4` |
| Main policy | READ-ONLY |
| Release | BLOCKED — RELEASE: NO-GO |

Recent branch history:
1. `c6750a92243a3a2046ab36823f280505b5335dfe` — docs(governance): register unresolved typography authority conflict
2. `1eb960819331d1998eeaf74ecd33a8ba56dd7aa4` — docs(audit): refresh REV8 evidence on current exact head
3. `a934cabebc814aea13c1800ab151821d12714226` — docs(audit): reconcile repository history and project governance REV8

## 2. Exact-SHA CI checkpoint

All rows below refer only to `c6750a92243a3a2046ab36823f280505b5335dfe`.

| Workflow | Run ID | Result |
|---|---:|---|
| Arvin Build | `42805111874` | FAILURE — six test shards failed; Analyze and APK build stages succeeded |
| Arvin Device Smoke | `42805112200` | PENDING |
| Calendar Provider Acceptance | `42805111910` | SUCCESS |
| Follow-up File Persistence | `42805112251` | SUCCESS |
| Draft Review APK | `42805111849` | SUCCESS |
| Parallel Wave | `42805112166` | SUCCESS |
| Orchestrator | `42805112164` | SUCCESS |
| Orchestrator PR Wakeup | `42805111973` | SUCCESS |
| Production Loop | `42805111854` | SUCCESS |
| G1 lock sync | `42805111844` | SUCCESS |

Green orchestration workflows do not override Build failure or pending Device Smoke. None of these results transfers to the continuity commit or any later SHA. Fresh exact-HEAD validation is required.

## 3. Current approved architecture and governance

- **SQL-ONLY is FINAL / CANONICAL:** one product, one canonical database, one SQL source of truth for persistent business and operational data.
- JSON is permitted only for explicit Backup, Import/Export, Data Transfer, and truly temporary/rebuildable payloads. Durable duplicate JSON ownership is not approved.
- Preserve IDs, relationships, history, and user data. No destructive migration or legacy retirement before non-destructive migration, validation, backup/restore, rollback proof, and owner acceptance.
- Task due date, independent Reminder, recurrence, Occurrence, Follow-up history, and per-Occurrence Checklist remain distinct concepts.
- Do not invent the four Reminder states. They remain unresolved until the actual contract is established.
- Main remains read-only. PR #3052 remains OPEN / DRAFT / UNMERGED. Release remains NO-GO.

## 4. Active workstream and last approved action

**Active workstream:** WAVE 4 — SQL-ONLY CANONICAL DATABASE AUDIT, read-only data ownership and migration discovery.

**Latest owner instruction:** complete a comprehensive evidence-based inventory of SQL and JSON persistence, map read/write/update/delete paths, prepare a non-destructive migration blueprint, and identify test/integrity gaps. This is an audit, not implementation authorization.

**Last verified repository commit before this continuity operation:** `c6750a92243a3a2046ab36823f280505b5335dfe`, which registered an unresolved typography authority conflict.

**Wave 4 progress:** an interim source review has identified SQL tables, legacy payload columns, SharedPreferences persistence, recurrence/occurrence JSON, template JSON fields, calendar-link metadata, and test candidates. The previous report explicitly did NOT complete content review of all 868 files. No full migration proof exists. Do not label Wave 4 COMPLETE or MIGRATION VERIFIED.

**Documentation authorization boundary:** this task authorizes the continuity files and their navigation links. It does not automatically authorize the separate Wave 4 audit deliverables or any code/schema/test changes.

## 5. Known blockers and unresolved risks

1. Build failure on the inspected SHA; six test shards failed.
2. Device Smoke remains pending on the inspected SHA.
3. Four Reminder states are not established by the inspected model/table contract.
4. SQL still contains `tasks.legacy_payload_json`, `projects.legacy_payload_json`, `tasks.recurrence_json`, and template JSON fields.
5. Occurrence history and occurrence-specific checklist state do not yet have proven independent relational SQL ownership in the reviewed DDL.
6. Legacy SharedPreferences owners remain in Task, Project, Tag, Calendar links, Prayer Completion, settings, and notification-delivery state.
7. Backup/Restore completeness across all persistent entities is not proven.
8. No actual user database contents, complete historical-schema fixture matrix, or end-to-end SQL round-trip has been verified.
9. Existing canonical continuity snapshots include older SHAs; re-fetch live GitHub and treat this root checkpoint as a navigation aid, not a substitute for source evidence.

## 6. Last action in this session

Establish the mandatory AI continuity protocol by adding:
- `AI_CONTINUITY_PROTOCOL.md`
- `AGENTS.md`
- `PROJECT_STATE.md`
- links from root `README.md`, `ARVIN_AI_CONTEXT.md`, and `docs/project-continuity/README.md`

This is a documentation-only action. No executable code, tests, schema, migrations, workflows, data, PR metadata, Main, merge, or release are in scope. CI for the resulting documentation commit is NOT RUN at the moment this checkpoint is authored; check exact-HEAD Actions after the commit.

## 7. Deterministic next action

Continue WAVE 4 as a **READ-ONLY** audit from the newly committed live HEAD:
1. Re-fetch PR #3052 and its exact head SHA.
2. Complete caller-level tracing for every persistent Store/Repository and every JSON/SharedPreferences read/write/update/delete path.
3. Finish the SQL entity and persistent JSON inventory, including Sync, Backup/Restore, settings, notification state, and historical migrations.
4. Audit test contents and exact-SHA results; distinguish test existence from PASS.
5. Record gaps and a proposed non-destructive migration/rollback sequence.
6. Do not edit Wave 4 deliverable documents unless a separate documentation authorization is explicitly granted.
7. Do not change code, schema, migrations, tests, workflows, Main, PR metadata, merge, or release.

**Release gate:** BLOCKED — RELEASE: NO-GO.


## WAVE 4 REV8 — implementation checkpoint (2026-11-10)

**Owner authorization:** Mobin explicitly superseded the former read-only Wave 4 task and authorized audit, implementation and testing on the working branch.

### Live checkpoint at the time of this entry
- Implementation checkpoint SHA: `dbfcdb02879ed3939cb6a69d3a150e2237283a51`.
- Documentation/report checkpoint before this addendum: `8f43c5273920bba738479484a53e5e9d1eff8fd4`.
- Branch: `fix/recovery-calendar-device-smoke-2026-10-31`.
- PR #3052: OPEN / DRAFT / UNMERGED; base Main SHA `45e4202b03a434459e4c021a04efa7e8396359db`.
- Main remains READ-ONLY; Release remains BLOCKED — NO-GO.

### Work implemented in source
- Task migration validates row count, ordered IDs, storage ordinals, scalar fields, unknown-field envelope, TaskReminder, Follow-up, checklist, Person/Tag relations, Occurrence and Recurrence parity, plus foreign keys before COMMIT.
- Existing same-ID rows are compared; content conflicts fail instead of being skipped.
- The post-COMMIT ID-only Task validator was removed.
- Unproven legacy table drops and Task/Reminder table rebuilds were disabled; legacy source tables/columns remain.
- Project migration is unified through SqlProjectMigrationWriter with field, membership, ordering, unknown-field and FK checks; ProjectStore preserves unknown Project fields and persists order.
- Recurrence rules and Occurrence/per-occurrence checklist state now have relational SQL tables and TaskStore read/write paths.
- Added migration conflict, ordering, unknown-field, Recurrence and Occurrence round-trip tests.

### Verification
Exact-SHA workflows on implementation SHA `dbfcdb02879ed3939cb6a69d3a150e2237283a51` were PENDING/QUEUED at the last lookup: Build run `42864431438`, Device Smoke run `42864430851`, Calendar Provider `42864431259`, Follow-up Persistence `42864430953`, Draft APK `42864431042`. No local Flutter command was run; local workspace state is NOT VERIFIED. Do not claim test PASS.

### Remaining blockers
- Full field/relation parity for G1 legacy Follow-up/Person migrations.
- One atomic transaction across all legacy sources and stores.
- Complete SQL normalization of Task/Project envelopes and template JSON fields.
- Settings, Calendar, Prayer Completion, Notification State and Sync ownership.
- Complete Backup/Restore coverage and round-trip proof.
- Exact-SHA CI, integration and Android Device Smoke acceptance.
- Four Reminder state names/transitions remain a Mobin decision.

**Next action:** inspect exact-SHA Build and Device Smoke outcomes, repair failures without weakening tests, then continue G1 parity and full Backup/Restore coverage. Preserve all legacy sources until every retirement gate and Mobin acceptance is proven.

## WAVE 4 final report checkpoint — 2026-11-10

- Implementation candidate SHA: `271633dcf1793773738097ad6021ceca98ad1784`.
- WAVE 4 final report: `docs/project-continuity/audit/WAVE4_FINAL_REPORT.md`.
- Report creation commit: `b0a8db484d6fea8c68d13b41e059f8b24ee97a9d`.
- Latest implementation candidate remains PARTIAL / BLOCKED; exact-SHA Build `42866834521` and Device Smoke `42866834509` were PENDING at the time of the report.
- Subsequent commits in this documentation checkpoint are documentation-only; no source change was made after implementation candidate SHA `271633dcf1793773738097ad6021ceca98ad1784`.
- PR #3052 remains OPEN / DRAFT / UNMERGED. Main remains READ-ONLY. Release remains NO-GO.


## COMMAND 63-R live checkpoint — 2026-11-19

**Audit baseline before this state update:** Main `45e4202b03a434459e4c021a04efa7e8396359db`; PR #3052 branch HEAD `80c24c61f090aa24d2e808995ad0220f9a389a21`. PR #3052 remains OPEN / DRAFT / UNMERGED. Main remains READ-ONLY. No merge, release or deployment was performed.

### Actions completed
- Re-read AGENTS.md, AI_CONTINUITY_PROTOCOL.md, PROJECT_STATE.md, MASTER_GOVERNANCE.md, CURRENT_STATE.md, HANDOFF.md, OPEN_ISSUES.md and PRODUCT_DECISIONS.md at the authorized branch.
- Confirmed the root file COMMAND-63-R-MASTER-TRACKER.md was absent from Main and the operational branch.
- Created COMMAND-63-R-MASTER-TRACKER.md on the authorized PR #3052 branch. Tracker commit: `80c24c61f090aa24d2e808995ad0220f9a389a21`. It records live baseline, PR inventory, 72 failed test labels, font metadata, dependency conflicts and release gates.
- No executable source, test, schema, migration, workflow, product data or Main file was changed.
- The tracker commit advanced PR #3052 from 2,214 to 2,215 commits and from 401 to 402 changed files.

### Exact-SHA evidence
Build run `44490319550` on pre-tracker SHA `a2825e003bb9e6b5c2413b0dc74b085273b6148b`: Analyze PASS; six shards FAILED with 72 failures / 1,310 passes; Debug, Release build, Staging and Visual PASS. Calendar Provider `44490319483` and Follow-up File Persistence `44490319367` PASS. Device Smoke `44490319359` PENDING with no jobs returned. These results do not transfer to later commits.

Fresh workflows triggered for tracker SHA `80c24c61f090aa24d2e808995ad0220f9a389a21`: Build `44502574294`, Device Smoke `44502574314`, Calendar Provider `44502574390`, Follow-up Persistence `44502574257`, Draft Review APK `44502574254`, Parallel Wave `44502574347`, Orchestrator `44502574205`, Production Loop `44502574225`, PR Wakeup `44502574458`, G1 lock sync `44502574219`. All were QUEUED or PENDING at the last lookup; no PASS is claimed.

### Additional findings
- PRs #3567, #3570, #3573, #3574 and #3575 are OPEN / DRAFT. #3570 and #3574 both edit g1_drift_schema.dart; #3574 and #3575 both edit task_store.dart; #3567 edits main.dart. Reconcile shared-file diffs before integration.
- PR #3575 reports base SHA `90a8100c0e58fe0b6cedc9e1df3b234adf951b5d`, different from PR #3574 head `8aca2bd36ea28ae8c291e7418541453d12847de2`; verify the live dependency ref before accepting the chain.
- The nine Vazirmatn TTF binaries on PR #3573 were inspected. OS/2 weight classes match 100–900 and pubspec maps all nine. Repository README identifies upstream v33.003 archive SHA-256 `0a9afd41967e6f57096a56a181a23f81a2b999b62f1f2a4e4b26736580854fdb`; the ZIP itself was not retrievable in this session, so archive checksum/content verification remains NOT VERIFIED.
- The existing Task Details specification and historical REV8/REV9 records contain directions that may conflict with current COMMAND 63-R. Current owner instruction and REV10 govern; preserve historical records and reconcile before changing product behavior.
- Local P2P specification is a Phase 1 design draft only; implementation and two-device acceptance remain NOT VERIFIED.
- Real user database inspection, full backup/restore, destructive migration safety, complete Device Smoke and owner acceptance remain open.

### Next deterministic action
Poll all fresh workflows for the exact live PR #3052 HEAD after this state update. Then inspect and fix the 72 failure roots individually on the authorized branch, beginning with the most shared Home/Quick Capture/Task Details/Date-Time behavior. Before every write, re-fetch PR #3052 and branch HEAD. Do not weaken tests, edit Main, merge, release or deploy.

**Release:** BLOCKED — RELEASE: NO-GO.


## COMMAND 63-R execution checkpoint — 2026-11-19 (continued)

**Operational PR #3052 pre-state-update HEAD:** c607f3c817301f529e04ffb2780c84de9676e87b. Main remains 45e4202b03a434459e4c021a04efa7e8396359db. PR #3052 remains OPEN / DRAFT / UNMERGED. No Main change, PR merge, release or deployment.

### Additional verified work
- Read current product operating package v49.1, Development Rules, UI Governance, Home Style Lock, Design Authority Index, project continuity docs and the non-authoritative COMMAND 28 REV10 migration draft from Library.
- Personal continuity search recovered the owner-approved REV10 constraints: teal palette #078B91 / #066F75 / #DDF7F5 / #F0FAF9 / #D9ECEA; five visible Home filters including Center; four grouping modes; single-column Task Details with Action Rows, Quick Presets and Universal Bottom Sheet.
- Audited PR #3569 and #3572 in addition to #3567/#3570/#3573/#3574/#3575. #3569's grouping service currently has no user-facing mode selector; main.dart still uses Time only. #3572 lacks Universal Bottom Sheet, reminders, attachments and Notebook integration. #3567's actual palette matches the approved values, but its shared component set is incomplete.
- PR #3567, #3569 and #3572 are diverged from the current operational branch and 13 commits behind at the comparison checkpoint. Reconcile before integration.
- Fixed stale Home filter test labels and strengthened the test to verify all five filters, including Center.
- Updated Task Details calendar-launcher test to verify inline auto-save and stable Task identity.
- Corrected stale Home wiring count by asserting the additional Task Details Project callback.
- Corrected two TaskReminder fixtures to use canonical reminder rows instead of deprecated reminderDate constructor input.
- Replaced obsolete static source-boundary anchors in two tests with method-body extraction.
- Added a transactional, fail-closed SQL migration for obsolete task_reminders.is_legacy_task_reminder, with stable-ID checks and complete before/after row parity including unknown columns and explicit NULL; expanded its test to verify TaskStore readback.
- Updated the Task Editor test to match immediate tag-rollbox selection rather than a nonexistent Apply button.

### Important unresolved items
- These corrections are not yet accepted: the latest complete Build/CI result has not returned. The earlier exact-SHA run on a2825e0 still has 72 failures and remains the only completed six-shard evidence at this checkpoint.
- PR #3570 has a competing implementation of the same reminder-flag migration in g1_drift_schema.dart. The operational implementation is more defensive; reconcile one implementation before integration.
- Full authoritative REV10 governance package is not present in the repository or Library search. The Library has a clearly marked non-authoritative migration engineering draft only. Current owner instructions and recovered constraints govern this work; full page-by-page visual acceptance remains incomplete.
- The Vazirmatn ZIP itself remains unavailable for direct inspection. Nine actual TTF files on PR #3573 were inspected and their OpenType weight classes matched 100–900.
- The operational Task Details page still lacks the Universal Bottom Sheet, attachments and Notebook integration. Home still lacks user-facing selection among all four grouping modes.
- Local P2P is design-only; physical backup/restore, migration parity and device acceptance remain open.

### CI for the latest code/test candidate before documentation updates
Candidate SHA: 0535e78ff6f271086c259fadcfd088d52efcf79b.
- Build 44504242136: PENDING, no jobs returned.
- Calendar Provider 44504241833: QUEUED.
- Follow-up File Persistence 44504241878: QUEUED.
- Device Smoke 44504241926: PENDING.
- Draft Review APK 44504241933: QUEUED.
No pass is claimed for this candidate. This state update advances the branch again; fetch the exact live PR #3052 HEAD and run status before interpreting any result.

**Next:** validate the latest SHA, then continue the remaining failing test roots and implement the missing Home grouping selector / Task Details Universal Bottom Sheet in controlled, non-conflicting workstreams. Do not merge, release or deploy. **RELEASE = NO-GO.**


## COMMAND 63-R persistence evidence correction — 2026-11-19

- Correction: PR #3570's inspected G1DriftSchema is version 17, not v19/v20. Its Occurrence/Checklist test is genuinely file-backed: temporary SQLite file, three installs, close/reopen, unknown nested state, explicit NULL, integrity_check and foreign_key_check. The separate Library draft references v19/v20 but that implementation was not found in the current PR set.
- PR #3574 has a file-backed Person Directory exclusion migration test with close/reopen, retained Task/Follow-up history, tombstone behavior and integrity checks.
- PR #3575 has a file-backed source/target SQLite backup/restore orchestration test for Person exclusions and historical relations. Its backup service is faked; real Android SAF file read/write is still not verified.
- TaskReminder unknown JSON keys are not currently preserved by a dedicated opaque payload in the model/SQL relation mapping. The new schema migration preserves unknown SQL columns and explicit NULL values during the column retirement itself, but a later TaskStore load/save cycle is not yet proven to preserve arbitrary unknown TaskReminder payloads.
- PR #3570 and the operational branch both implement legacy reminder flag retirement differently. The operational branch implementation adds stable-ID and full row parity guards. Reconcile before integration; keep one migration path.
- Latest tracker update commit: e925bb38eceee8155c8b29b25c375324e951e7fb. This update advances the operational branch; fetch the exact live HEAD and CI status again before accepting any result.

**No merge, release or deploy. RELEASE = NO-GO.**


## COMMAND 63-R live checkpoint — 2026-11-19 (final audit pass)

**Exact operational HEAD before this state update:** af524c5dca1d67f8c12e286d87decfc5557e1506  
**Main:** 45e4202b03a434459e4c021a04efa7e8396359db  
**PR #3052:** OPEN / DRAFT / UNMERGED; 2,235 commits; 404 changed files.  
**Protection:** Main remains untouched; no merge, release or deployment.

### Latest tracker and validation state
- Master Tracker latest commit: af524c5dca1d67f8c12e286d87decfc5557e1506.
- The tracker now includes the complete 72-failure inventory, root-cause symptom triage, PR #3567–#3575 audit, font metadata, migration/backup evidence, and corrections to the shadow-token and Quick Capture time assertions.
- Latest exact-head workflows for af524c5: Build 44505528910 PENDING with zero jobs returned; Device Smoke 44505528946 PENDING; Calendar Provider 44505528897 QUEUED; Follow-up Persistence 44505529066 QUEUED; Draft Review APK 44505528908 QUEUED; Parallel Wave 44505528912 QUEUED. No PASS is claimed.
- Earlier completed six-shard evidence remains the a2825e0 baseline: 72 failures / 1,310 passes. No test correction on the newer operational branch is accepted until the new exact-head Build completes.
- The latest code/test candidate was 0535e78ff6f271086c259fadcfd088d52efcf79b. Subsequent operational commits in this checkpoint were documentation-only; the Build still must run against the exact current HEAD.

### Confirmed work / remaining blockers
- Source-grounded test corrections and the task_reminders flag migration are present on the operational branch; they remain unverified by completed CI.
- PR #3567's shadow tokens now agree at card blur 10 / offset (0,4); the branch correction is documented in the tracker.
- PR #3571 Quick Capture visible labels and due-time/reminder independence are documented; its Build has six failed shards, so no acceptance.
- PR #3569 still lacks user-facing selection for all four Home grouping modes.
- PR #3572 and the operational Task Details page still lack the complete Universal Bottom Sheet, attachment flow and Notebook linkage.
- PR #3570 is schema v17 and includes file-backed Occurrence/Checklist persistence coverage; its reminder-flag migration must be reconciled with the operational implementation. TaskReminder arbitrary unknown JSON keys still lack a proven opaque-payload round trip.
- PR #3574 has file-backed Person history/exclusion coverage. PR #3575 has file-backed source/target database backup/restore orchestration, but its backup service is faked; Android SAF file read/write and physical device acceptance remain open.
- The nine Vazirmatn TTFs are metadata-verified on #3573; the ZIP archive itself was not retrieved. Device glyph/fallback and layout acceptance remain open.
- Full authoritative REV10 package is not present in repository/Library; current owner instructions and recovered approved constraints are being followed. Full page-by-page visual acceptance remains incomplete.
- Local P2P Phase 1 remains design-only; pairing/security/transfer/conflict/recovery and two-device testing are not complete.

**Next deterministic action:** poll all workflows for the exact new HEAD created by this state update; inspect Build logs and verify the narrow fixes before proceeding to shared-file integration. Re-fetch Main and branch HEAD before every write. Preserve all 72 failures until each is individually reproduced and closed. **RELEASE = NO-GO.**
