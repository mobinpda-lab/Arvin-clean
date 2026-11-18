# ARVIN — COMMAND 34 FINAL REPORT
## Blocker Resolution & Consolidation Execution

**Audit date:** 2026-11-18  
**Governing charter:** ARVIN-MASTER-CHARTER-REV10  
**Repository:** `mobinpda-lab/Arvin-clean`  
**Canonical PR:** #3495  
**Canonical branch:** `recovery-02/main-based-integration`

# FINAL ACCEPTANCE STATUS: BLOCKED

This report records verified execution, actual fixes, exact-SHA workflow evidence, unresolved product work and protected historical changes. It does not authorize merge, release, deployment, Main modification, production-data migration, or deletion of any unproven PR/branch.

## 1. Final SHA and continuity

- SHA received from COMMAND 33: `2641773b329522d6759724b072be577cd3d4e837`.
- Live HEAD read before changes: `2641773b329522d6759724b072be577cd3d4e837`.
- Main SHA remained: `45e4202b03a434459e4c021a04efa7e8396359db`.
- PR #3495 remained OPEN / DRAFT / UNMERGED, based on Main.
- No parallel development PR was created.
- Product and workflow changes were committed only to `recovery-02/main-based-integration`.
- Last code-and-workflow SHA before this report: `c729fb848dff37f59eadb42348b0affc06f88ef3`.
- This report is a documentation-only commit. Its commit SHA is the final repository HEAD after the report is created; it must not be represented as having test results that ran only on its parent SHA.
- Main was not modified.

**Single-SHA rule:** All full acceptance gates have not yet completed on one final SHA. Workflow runs on earlier SHAs are historical evidence only and are not promoted to final PASS.

## 2. Changes performed on the canonical branch

### W01 workflow corrections
1. Moved Runner-context values out of Job-level `env` and into executed steps.
2. Removed the Pull Request label trigger path, which depended on a workflow definition available on the base branch. The supported execution path is the canonical-branch Push trigger; Main was not changed.
3. Corrected the SDK license pipeline so `yes` receiving SIGPIPE does not cause `pipefail` to abort after the SDK manager has accepted the licenses.
4. Corrected a YAML block-indentation defect introduced during the pipeline fix. This malformed indentation was the direct reason a later workflow run again registered zero Jobs.
5. Removed an empty step-level `env:` mapping and initialized the SDK user directory in the shell step.
6. After the KVM check failed on the hosted runner, changed the environment smoke to use Android Emulator software acceleration (`-accel off`) when KVM is unavailable. This uses the existing GitHub-hosted runner and adds no paid infrastructure.

### H01 diagnostics
1. Removed the hard-coded application ID.
2. The script now extracts `applicationId` from `android/app/build.gradle.kts`.
3. It checks `pm path` before `run-as`.
4. If Package Manager cannot resolve the app, it captures installed third-party packages and process diagnostics before failing.
5. No app data clear or destructive device operation was added.

The configured application ID is `com.example.arvin`. It matches the earlier script constant. The old failure therefore was not caused by a simple spelling mismatch.

### A03 duplicate-name protection
1. Added `TaskPeopleService.hasDuplicateDisplayName`, checking existing Task Person references and the stored People directory.
2. Added a Persian duplicate-name warning in the People UI.
3. A duplicate can only be added after explicit confirmation as a separate Person; the generated Person ID remains distinct.
4. Added a widget test covering duplicate-name warning, cancel-without-write and explicit separate identity.
5. No name-based automatic merge was introduced.

No production data, SQLite schema, migration or backup file was modified by COMMAND 34.

## 3. H01 — Calendar Restart

**Status: BLOCKED_ENVIRONMENT — NOT PASS**

Application identity:
- Gradle source: `android/app/build.gradle.kts`
- Extracted ID: `com.example.arvin`
- Previous `run-as unknown package` error: still not fully explained by application-ID mismatch.

Previous exact-SHA evidence:
- Calendar write phase emitted two Calendar Link records.
- The previous test recorded a process PID.
- The previous attempt failed when `run-as` could not resolve `com.example.arvin`.
- No valid fresh-process read and exact before/after comparison was completed in that attempt.

COMMAND 34 updated the script to derive the ID and capture Package Manager state before accessing private SharedPreferences.

Current exact code SHA run:
- COMMAND 20-E run: `44241754751`
- Target SHA: `c729fb848dff37f59eadb42348b0affc06f88ef3`
- Flutter Analyze: PASS
- File-backed ProjectStore test: PASS
- Real SharedPreferences write/stop/fresh-process read: IN PROGRESS at last observation.

Required evidence still pending:
1. Two Calendar records created.
2. Real SharedPreferences disk write captured.
3. PID before stop captured.
4. Full process stop verified.
5. Fresh app process started.
6. Two records read after restart.
7. All eight identity/fingerprint values compared exactly.

Until the current run completes and the comparison artifact is inspected, H01 remains BLOCKED_ENVIRONMENT.

## 4. W01 — Zero-Dollar Workflow

**Status: BLOCKED_ENVIRONMENT — SOFTWARE FALLBACK RUN IN PROGRESS**

### Root causes found

The original zero-Job failures were not evidence that Main had to be changed.

The workflow contained invalid Runner-context use at Job environment scope. Later edits also introduced malformed YAML block indentation, causing a workflow parse failure before any Job was created. A subsequent executable run exposed another independent failure: the `yes | sdkmanager --licenses` pipeline returned a non-zero status because `yes` received SIGPIPE while `pipefail` was enabled.

These issues were corrected on the canonical branch.

### Actual environment failure

Run `44241408317` created a real Job and successfully:
- verified canonical refs and runner class;
- installed Flutter 3.47.0 / Dart 3.13.0;
- installed Android SDK API 35;
- installed the Android Emulator system image.

It then failed at the explicit KVM check because `/dev/kvm` was not available as a readable/writable character device on that GitHub-hosted runner.

### Current zero-dollar fallback

- Software acceleration selected with `-accel off`.
- KVM is optional rather than a hard requirement.
- No Main change, paid runner, external emulator service, or replacement workflow was introduced.
- Latest software-fallback run: `44241747537`.
- Target SHA: `c729fb848dff37f59eadb42348b0affc06f88ef3`.
- Job was in progress at last observation; no ENVIRONMENT_SMOKE=PASS has been claimed.

W01 is not BLOCKED_MAIN_POLICY. The supported Push path exists without changing Main. W01 remains BLOCKED_ENVIRONMENT until the software emulator boots and the workflow completes successfully.

## 5. A03 — Person Identity

**Status: BLOCKED — PARTIAL IMPLEMENTATION**

### Verified existing protections
- Person references have stable Arvin-owned IDs.
- Task Person identity is not inferred from display name.
- Duplicate IDs within a Task are rejected.
- Removing a Task-level Person association does not itself delete historical Follow-up data.
- The report projection can display unresolved historical Person references rather than silently discarding their identity.
- Backup/Restore code has a People-directory reconciliation path keyed by Person ID.
- Existing tests cover Person JSON identity and Task/backup round-trip behavior.

### COMMAND 34 implementation
- Duplicate-name detection and explicit warning were added.
- Confirming a duplicate creates a separate Person reference with its own ID.
- Cancelling the warning performs no write.
- No automatic merge was introduced.

### Still missing
- A complete central Person entity-management lifecycle across all Tasks and Follow-ups.
- Rename operation updating every reference while retaining the same ID.
- Central deletion semantics with complete historical Follow-up verification.
- End-to-end restore of a Person missing from the active directory but referenced by historical Follow-ups.
- Explicit merge of two distinct IDs with a durable, tested undo/rollback record.
- Full Import test proving no implicit name-based merge.

A transient in-memory undo is not sufficient proof of a reversible product merge. Merge was therefore not implemented without a durable rollback contract.

### Tombstone decision
No Tombstone schema was added. Current stable-ID references and historical unresolved-person projection are the simpler existing mechanism. A Tombstone is not justified until an acceptance test demonstrates that this mechanism cannot satisfy the historical identity contract.

## 6. A01 / A02 — Regression

### A01 — Date, time, All-Day and DST
**Status: BLOCKED**

- Existing Calendar/Jalali time tests are present.
- The complete required matrix for date boundaries, time preservation, All-Day transitions and DST spring-forward/fall-back has not been proven on one final SHA.
- No full exact-SHA final regression run has completed.

### A02 — SQLite v7 → v8, file-backed persistence, Backup/Restore and Rollback
**Status: BLOCKED**

- Canonical Drift schema declares version 8.
- `test/services/g1_drift_schema_test.dart` contains a file-backed v7 database migration/reopen test with historical Task, Project, Follow-up and Tag fixtures.
- COMMAND 20-E on SHA `c729fb8...` reported Flutter Analyze PASS and file-backed ProjectStore PASS before the real Calendar restart step began.
- The complete version-7-to-8 migration, full Backup → Restore, repeated reopen, injected failure rollback and historical metadata parity have not all been accepted on the final SHA.
- A passing file-backed ProjectStore test is not a substitute for the complete A02 contract.

## 7. PR migration matrix

**Rule:** A path existing in the canonical tree is not proof that a PR's unique patch was transferred. Exact blob equality proves identical file content only; a different blob requires semantic review. Historical commits and branch ancestry must be preserved until the unique contribution is accounted for.

| PR | Live state / commits / files | Unique useful contribution | Transfer evidence in canonical branch | Final action |
|---|---|---|---|---|
| #1901 | OPEN / DRAFT; 86 commits; 27 files | Checklist and historical Home grouping/UI regression work | Checklist-related model/test coverage exists in canonical; `test/home_grouping_service_test.dart` is absent. REV10 five-filter Home supersedes the old four-mode proposal. | Keep open; transfer only valid REV10-compatible tests and fixes; do not restore superseded Home UI |
| #3052 | OPEN / DRAFT; 2,192 commits; 395 files | Large product recovery: Task Details, templates, Person history, reminders, reports, Calendar, backup, UI, SQL and evidence | Tree comparison against canonical SHA `c729fb8...`: 152 paths absent, including 72 code/test/Android/assets paths and 80 documentation/other paths. First 100 commits were retrieved; full 2,192-commit pagination was not exhausted. | Keep open; major source branch; no cleanup |
| #3346 | OPEN / DRAFT; 3 commits; 3 files | Lossless Task Editor due-date preservation | `lib/task_editor_dialog.dart` and two due-date tests exist as paths in canonical, but current Blob differs; semantic patch equivalence not proven | Keep open pending focused diff/test parity |
| #3356 | OPEN / DRAFT; 1 commit; 1 file | SQL migration writer envelope parity; avoid synthetic legacy fields | `lib/services/sql_task_migration_writer.dart` exists but exact Blob differs | Keep open; SQL writer behavior must be reconciled |
| #3364 | OPEN / DRAFT; 10 commits; 6 files | Legacy Follow-up envelope, false/null/date presence and reopen parity | Model, Drift schema, migration writer and tests share paths with canonical, but exact Blob parity is not established | Keep open; unique migration semantics require tests |
| #3366 | OPEN / DRAFT; 8 commits; 6 files | Task Editor due-date and independent Reminder preservation | Editor and related tests share paths with canonical; exact semantic transfer not proven | Keep open until focused tests and diff reconciliation |
| #3376 | OPEN / DRAFT; 7 commits; 2 files | Exact persisted Task envelope capture before SQL rollback | Diagnostic workflow and forensic test are not present in canonical | Keep branch and evidence; no deletion |
| #3380 | OPEN / DRAFT; 8 commits; 2 files | Recovery of reopened diagnostic executor and exact SQL envelope | Shares the #3376 forensic history and adds reopened-executor initialization; diagnostic test/workflow not transferred | Keep branch; deduplicate only after evidence transfer |
| #3382 | OPEN / DRAFT; 3 commits; 2 files | Independent raw SQL evidence and SHA-256 archive | `test/diagnostics/command_06_h_raw_sql_evidence_test.dart` and dedicated workflow are absent in canonical | Keep open; unique diagnostic evidence not transferred |
| #3384 | OPEN / DRAFT; 218 commits; 120 files | Broad SQL/SQLite remediation, schema/backup tests, Center/Project work, product UI, typography and governance | Many useful SQL and product paths differ or are absent. Contains historical VazirHarf assets that conflict with REV10's current Vazirmatn-only decision; those assets must not be copied as active fonts. | Keep open; selective commit-level transfer required |
| #3463 | OPEN / DRAFT; 139 commits; 42 files | REV10-approved Center↔Project and Project↔Category M2M migration, historical FK preservation, v19/v20 lifecycle, rollback and physical restore tests | ADR `ADR-2026-11-14-CENTER-PROJECT-CATEGORY-M2M.md` is present. However `lib/services/g1_many_to_many_hierarchy_migration.dart`, `center_store.dart`, M2M acceptance tests and transactional ProjectStore tests are absent in canonical. | Keep open; critical unique implementation is not transferred |
| #3470 | OPEN / DRAFT; 24 commits; 21 files | Vazirmatn weight contract and UI font consistency | REV10 confirms Vazirmatn as sole official UI font; current canonical font packaging includes 400/500/700 but the 300 and 600 assets and dedicated contract test are absent. UI paths overlap but Blob content differs. | Keep open; selectively transfer approved Vazirmatn weights and compatible UI fixes after focused tests |

### Dependency and duplication observations
- #3346 and #3356 descend from the #3052 recovery line; #3364 descends from #3356.
- #3366 is another recovery branch from #3052; #3376 and #3380 descend from #3366.
- #3382 descends from the #3380 diagnostic line.
- #3384 descends from #3366; #3463 and #3470 descend from #3384.
- #3376 and #3380 share most diagnostic commits and file paths; #3380 adds reopened-executor initialization.
- The #3463 ADR is present in canonical, but ADR transfer is not code migration.
- No PR is considered replaced solely because its files have overlapping names.

### Commit-level completeness boundary
PR #3052 contains 2,192 commits; the GitHub API returned only the first 100 in this pass. The complete commit pagination and per-commit patch review for all 12 PRs was not finished. The matrix is evidence-based but not a complete commit-by-commit transfer ledger. This is an explicit consolidation blocker.

## 8. Closed PR inventory

**COMMAND 34 closed PRs: NONE.**

All twelve specifically requested PRs were still OPEN / DRAFT / UNMERGED at the time of review. No PR was closed because unique SQL, migration, diagnostic, UI, test or historical evidence remains untransferred or not semantically verified.

## 9. Deleted branch inventory

**COMMAND 34 deleted branches: NONE.**

A complete fresh inventory of all repository branches and their unique commits was not completed. No branch was deleted. The historical branch relationships listed above are preserved.

## 10. Remaining blockers

1. H01: current exact-SHA Calendar Restart must complete write → disk read → PID → force-stop → fresh launch → read → exact comparison.
2. W01: software-accelerated Android Emulator must boot and complete the zero-dollar environment workflow.
3. A03: complete central Person rename/delete/restore and durable explicit reversible merge.
4. A01: complete DST, All-Day, date and time boundary acceptance.
5. A02: complete v7→v8 migration, physical Backup/Restore, repeated reopen and injected rollback on one exact SHA.
6. M2M: selectively integrate and test the unique #3463 migration, stores, backup/restore and rollback; do not import the entire #3384 ancestor branch blindly.
7. SQL diagnostics: preserve and selectively transfer useful #3376/#3380/#3382 evidence.
8. Task Editor and Follow-up envelope changes from #3346/#3356/#3364/#3366 require focused exact-SHA regression proof.
9. Approved Vazirmatn weights 300/600 and #3470 compatible UI fixes require selective integration.
10. Exhaustive commit pagination and full branch inventory are required before any PR closure or branch deletion.
11. Run Analyze, all Unit/Widget shards, Device Smoke, SQLite migration, Backup/Restore, Person Identity, Calendar Restart, Workflow and Regression on one final SHA after all changes.

## 11. REV10 compliance

| Rule | Result |
|---|---|
| PR #3495 remains sole canonical development path | PASS |
| No parallel development PR created | PASS |
| Main unchanged | PASS |
| No merge | PASS |
| No release or deployment | PASS |
| No production user-data modification | PASS |
| No destructive migration | PASS |
| No unproven PR closed | PASS |
| No unproven branch deleted | PASS |
| No automatic Person merge | PASS |
| Duplicate-name warning and explicit separate-ID path | IMPLEMENTED; test awaiting exact-SHA CI |
| Full Person lifecycle and reversible merge | BLOCKED |
| All acceptance gates on one final SHA | BLOCKED |
| Full PR commit-by-commit consolidation | BLOCKED |

## 12. Final acceptance

**Final status: BLOCKED**

The workflow zero-Job and KVM issues have been investigated and corrected/mitigated in code, but the zero-dollar software-emulator run is still required to pass.

H01 now derives the application ID from Gradle and captures Package Manager diagnostics, but no fresh-process Calendar comparison has yet been accepted.

A03 now warns on duplicate names and preserves separate IDs after explicit confirmation, but the full central Person lifecycle and reversible merge are not complete.

The PR inventory proves that significant historical work remains outside #3495, especially SQL/M2M migration, diagnostics, Task Editor preservation and approved typography assets. Closing those PRs or deleting their branches now would violate the no-loss rule.

**No GO is granted. No cleanup deletion is authorized. Continue only on PR #3495 / `recovery-02/main-based-integration`.**
