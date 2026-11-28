# Arvin Master Execution Registry — Anti-Forgetting / One-Path Index

**Registry ID:** `ARVIN-REGISTRY-001`  
**Mission:** `ARVIN-TOTAL-RECOVERY-UNIFICATION-DELIVERY-2026-11-27-V2`  
**Product baseline:** `ARVIN-MASTER-CHARTER-REV10`  
**Registry status:** ACTIVE — append-only operational index  
**Created against source SHA:** `d599150571541407aa46a05b792c3b1f21bd104d`  
**Canonical route:** PR #3495 / `recovery-02/main-based-integration`  
**Product acceptance:** NOT ACCEPTED · **Release:** NO-GO

## 1. Purpose and authority boundary

This file is the single anti-forgetting index for active execution IDs, ownership, dependencies, deduplication checks and next actions. It does **not** create a second copy of product requirements, decisions, defects, implementation logs or CI evidence.

The detailed record remains in its existing canonical home:

| Information | Single canonical home |
|---|---|
| Owner-approved product/architecture decisions | [PRODUCT_DECISIONS.md](PRODUCT_DECISIONS.md) |
| Permanent requirement definitions and requirement status | [REV10-MASTER-REQUIREMENT-LEDGER.md](REV10-MASTER-REQUIREMENT-LEDGER.md) |
| Verified blockers, defects and their current resolution state | [OPEN_ISSUES.md](OPEN_ISSUES.md) |
| Dated code changes, commits and test evidence | [IMPLEMENTATION_LOG.md](IMPLEMENTATION_LOG.md) |
| Current branch/PR/workflow facts | Live GitHub state, summarized in [CURRENT_STATE.md](CURRENT_STATE.md) |
| Execution sequence and dependencies | [ROADMAP.md](ROADMAP.md) |
| Next safe operator actions | [HANDOFF.md](HANDOFF.md) |
| Governance and protected-operation rules | [MASTER_GOVERNANCE.md](MASTER_GOVERNANCE.md) |

If this index conflicts with a canonical source above, the canonical source wins. Update this index's pointer/status after reconciling the source; never silently fork or copy the underlying record here. Historical entries are append-only: correct them with a dated superseding entry, not deletion.

## 2. Non-negotiable anti-forgetting rules

1. **One identity per fact.** Assign one stable ID to each requirement, decision, defect, architecture item, recovery item, acceptance criterion and action. Reuse it in every reference.
2. **Search before creating.** Search this registry and its canonical source before opening an issue, adding a requirement, creating a test, implementing a capability or proposing a migration.
3. **One owner and one path.** Every entity, relationship, persistence operation and product capability must name one canonical owner, write path and read/query path. Compatibility adapters are not alternate owners.
4. **No duplicate fixes.** Before changing code, inspect current implementation, callers, tests, history and any prior fix. If already fixed, verify it; do not reimplement it.
5. **Preserve user data by default.** Never discard unknown fields, IDs, relationships, history, ambiguous records or backups. Do not guess missing links. Use disposable synthetic databases for destructive migration experiments.
6. **Separate decision, implementation, verification and acceptance.** An approved decision is not implementation; implementation is not proof; a green test is not product acceptance.
7. **Exact-SHA evidence only.** Every PASS records SHA, workflow run, job, test/scenario and artifact where applicable. Evidence never transfers to another SHA. A docs-only commit does not re-verify product code.
8. **Close only with proof.** A defect/action is closed only when its canonical record contains the correction commit and relevant regression evidence. Superseded items remain visible.
9. **No shadow systems.** Do not add another store, repository, service, schema, backlog, test inventory or parallel PR to track the same capability.
10. **Continue independent safe work.** A blocked/protected operation does not stop unrelated reversible work. Main, merge, release, deployment, production data and history remain owner-protected.

## 3. ID namespace and record lifecycle

Use stable prefixes already established by the project:

- `REQ-` requirement; `DEC-` owner/product decision; `BUG-` defect.
- `ARC-` architecture/ownership; `DB-` data/schema/migration.
- `TEST-` test or acceptance scenario; `UX-` UX contract.
- `REC-` recovery/reconciliation; `ACC-` acceptance gate; `ACT-` execution action.

Never recycle an ID. A subtask gets a child ID only when it is independently actionable; otherwise keep it under the parent record.

Allowed state labels: `APPROVED`, `PROPOSAL`, `NEEDS OWNER DECISION`, `NEEDS SOURCE VERIFICATION`, `IMPLEMENTED`, `PARTIAL`, `VERIFIED`, `UNVERIFIED`, `BLOCKED`, `SUPERSEDED`, `HISTORICAL`.

Each record must have: ID; concise statement; canonical source link; owner; status; priority; dependencies; affected files/entities; evidence SHA; exact next action; closure evidence. For defects also record observed behavior, reproduction, root cause, classification and regression test.

## 4. Active execution index

This is a pointer/status index, not a duplicate requirements ledger. Update it whenever the canonical source changes.

| ID | Active item | Canonical owner / source | Status at registry creation | Priority | Dependency / next action |
|---|---|---|---|---|---|
| ARC-DATA-001 | Single write owner for Project↔Task membership (project_items) | ProjectStore / TaskStore | IMPLEMENTED / EXACT-SHA REGRESSION PENDING | P0 | ProjectStore writes membership; TaskStore no longer deletes/inserts it. Verify trigger-guarded TaskStore rewrite, deferred FK rollback and full regression on current candidate SHA |
| DB-RESTORE-001 | FK-safe Project snapshot/restore across all canonical relationships | Project/Center/Category stores and backup pipeline | IMPLEMENTED / EXACT-SHA REGRESSION PENDING | P0 | replaceAll now upserts matching IDs in place, preserves omitted membership and graph edges, and blocks deletion with any project_items/center_projects/project_categories reference; verify file-backed rollback/reopen and full restore flow |
| ARC-M2M-001 | Canonical Center↔Project and Project↔Category relationship ownership | CenterStore, hierarchy migration, Project/Category management | PARTIAL — Center↔Project CRUD exists; Project↔Category canonical CRUD/read path not found in inspected branch services | P0 | Complete caller inventory; add one canonical ProjectCategory owner only if no existing implementation is found; preserve legacy taxonomy and do not infer edges |
| DB-MIG-001 | Sequential migration, parity, exception preservation, rollback/retry | `G1DriftSchema` and versioned migration chain | BLOCKED / NOT ACCEPTED | P0 | Prove every real source→target edge on disposable file-backed fixtures; IDs, null/missing/false/true, metadata, FK and retry checks |
| DB-DATA-001 | Preserve unknown Task/Project/Follow-up/Reminder metadata and relationships | SQL codecs, stores, migration and backup | UNVERIFIED end-to-end | P0 | Exercise edit→close→reopen→backup→restore→recovery; compare full identity/relationship/history parity |
| ACC-CI-001 | Required CI and product acceptance on one candidate SHA | PR #3495 and GitHub workflow runs | IN PROGRESS — candidate a420c89f06c598ed17b9def38efebd9108618c90 | P0 | Poll Build 46116776194, COMMAND 20-E 46116776165, Device Smoke 46116776170, Follow-up 46116776176, Governance 46116776167; all evidence must match final docs-inclusive SHA |
| ACC-DEVICE-001 | Full Device Smoke acceptance | Device Smoke workflow, all required scenarios | PARTIAL — parent fff59f6 passed 7/7; current candidate a420c89 still running | P0 | Re-run/confirm all seven scenarios on final docs-inclusive SHA; parent evidence does not transfer |
| ACC-PRODUCT-001 | Full product acceptance and owner release gate | REV10 acceptance charter / Product Owner | NOT ACCEPTED | P0 | Complete product matrix and 100-pass evidence; owner approval remains separate |

### Source pointers for active architecture findings

- `lib/services/project_store.dart`: `upsert`, `replaceAll`, `_upsertProject`.
- `lib/services/task_store.dart`: `_saveUnlocked` now replaces Task rows with deferred FK validation and does not mutate `project_items` (commit fff59f6...).
- `lib/services/center_store.dart`: Center↔Project link operations and Center deletion.
- `lib/services/g1_drift_schema.dart`: canonical SQL table declarations and FK definitions.
- `lib/services/g1_rev10_hierarchy_v9_migration.dart`: M2M schema and historical relationship transfer.
- `docs/project-continuity/OPEN_ISSUES.md`: existing M2M, migration and backup blockers.
- `docs/project-continuity/REV10-MASTER-REQUIREMENT-LEDGER.md`: requirement IDs and their detailed implementation/test/acceptance state.

**Important:** source pointers above are branch-current only where a dated checkpoint says so. They do not constitute full product acceptance or prove all consumer parity.

## 5. Deduplication gate — mandatory before each change

For every proposed change, record the result of these checks in the canonical Implementation Log:

1. Search registry by ID, entity, behavior and file path.
2. Search canonical requirements/issues and historical implementation log.
3. Inspect current source and every caller/consumer.
4. Inspect existing tests and exact prior CI evidence.
5. Check whether an existing implementation or prior fix already covers it.
6. If duplicate: link to the existing ID and verify it; do not create another record/fix.
7. If genuinely new: assign one ID, state why existing records do not cover it, and link dependencies.
8. After change: record files, entities/relations, tests, invalidated evidence, commit SHA and result.

No test is added merely to make a count. Each new test must cover a distinct requirement or previously untested failure mode.

## 6. Change and evidence ledger

Append one row per meaningful change or verification event. Do not rewrite prior rows.

| Date | Record ID | Event / scope | Files or entities | SHA | Evidence (run/job/test) | Result / remaining uncertainty |
|---|---|---|---|---|---|---|
| 2026-11-28 | ARC-DATA-001, DB-RESTORE-001 | Source audit identified duplicate mutation responsibility for `project_items` and a potential FK conflict in Project snapshot replacement; no code changed | `project_store.dart`, `task_store.dart`, hierarchy schema/migration | `d599150571541407aa46a05b792c3b1f21bd104d` | Source inspection only; no runtime reproduction claimed | NEEDS CALLER AUDIT + TARGETED REGRESSION |
| 2026-11-28 | ACC-CI-001, ACC-DEVICE-001 | Existing workflow evidence was reviewed; several checks passed while other shards/scenarios were pending at the last captured poll | CI / Device Smoke | `d599150571541407aa46a05b792c3b1f21bd104d` | See live runs and exact job records in GitHub; refresh before relying on status | IN PROGRESS; do not treat this row as current live status |

## 7. Required checkpoint format

At every handoff, update the registry and canonical documents with:

- Current live branch, PR state and exact HEAD SHA.
- Current wave, round and pass IDs; mark unrun items explicitly `NOT RUN`.
- Completed work with changed files and commit SHA.
- Defects opened/updated/closed and their evidence.
- Tests and workflows: exact run/job/SHA/status/artifact.
- Data risks, unresolved decisions and blocked dependencies.
- One precise next action that does not repeat completed work.
- Protected operations still awaiting explicit Product Owner authorization.

Never use “done”, “fixed”, “green” or “accepted” without the corresponding evidence and status dimension.

## 8. Initial next action

**ACT-REG-001 — Integrate the registry into the continuity navigation and verify the resulting branch/PR head.**

Then continue with `ARC-DATA-001`: complete caller and test inventory before changing the Project↔Task write path. Do not create a second Project repository or parallel migration. Keep PR #3495 OPEN / DRAFT / UNMERGED and Main read-only.


## Live continuation checkpoint — 2026-11-28 — exact SHA 88dfc7a10b2713c8f5b43c471acb74e82027acd8

- Main remains `45e4202b03a434459e4c021a04efa7e8396359db` (read-only).
- Canonical PR #3495 remains OPEN / DRAFT / UNMERGED; canonical branch remains `recovery-02/main-based-integration`. No merge, release or deployment.
- Current candidate: `88dfc7a10b2713c8f5b43c471acb74e82027acd8`. The preceding exact-SHA Build run `46108844083` on parent `4c3ee249eb9eb2ddbc2e985077bd894b17a80e5b` produced Analyze SUCCESS, Debug/Release APK SUCCESS, but all six quality shards FAILED. Device Smoke `46108844089` passed its seven executed scenarios; Governance `46108844036` and Follow-up Persistence `46108844061` succeeded. COMMAND 20-E `46108844066` had storage-persistence SUCCESS while complete-evidence remained in progress at last poll. These results are parent-SHA evidence only.
- The commit `88dfc7a10b2713c8f5b43c471acb74e82027acd8` changes only `test/support/flutter_async_cleanup.dart`: adds CI-visible phase markers around repeated `WidgetTester.runAsync`/cleanup ownership. It is diagnostic instrumentation, not a product fix. The commit-run query returned no PR-triggered runs at the time of this checkpoint; current-SHA CI is therefore NOT VERIFIED / NOT RUN (do not transfer parent evidence).
- Live failing shard logs on the parent SHA reproduce the already recorded async-runner problem: TaskStorageLock's sequential follow-up operation times out; Center/Home/Backup tests show `project_store.schema_install` or `task_store.load` START events without terminal events. This matches prior forensic note in PR #3495 comment `7227315489`; no duplicate defect is opened. The exact first blocked phase is still unproven; the new CI-visible markers are intended to distinguish callback entry, native work, runAsync return, cleanup barrier and FakeAsync pump.
- Source audit at parent SHA confirms ARC-DATA-001: ProjectStore writes `project_items` in `_upsertProject` / `_insertProject`; TaskStore also snapshots, deletes and reinserts the same table during full Task rewrite. TaskStore's current preservation test proves retained rows in its scenario, not single-writer ownership. Do not remove either path until TaskStore's full-rewrite contract is replaced safely and deletion/ID/history semantics are proven.
- Source audit confirms DB-RESTORE-001 risk: `ProjectBackupBridge.restoreProjects` calls `ProjectStore.replaceAll`; that method deletes `project_items` then all `projects`, but does not snapshot/reconcile `center_projects` or `project_categories`. Both M2M tables use `ON DELETE RESTRICT`; current restore candidate carries ProjectPlan values, not the full canonical relationship graph. This is a source-level blocker; no runtime destructive reproduction was performed.
- CenterStore owns CRUD for `center_projects`, while ProjectStore still omits reads/writes for `center_projects` and `project_categories`. Preserve all legacy columns, IDs, payloads and edges. Do not invent links or clear join tables to make restore pass.
- Product acceptance remains NOT ACCEPTED; release remains NO-GO.


## Live execution checkpoint — 2026-11-28 — candidate a420c89f06c598ed17b9def38efebd9108618c90

- Main: 45e4202b03a434459e4c021a04efa7e8396359db — unchanged/read-only.
- Branch: recovery-02/main-based-integration, HEAD a420c89f06c598ed17b9def38efebd9108618c90.
- PR #3495: OPEN / DRAFT / UNMERGED; no merge, release or deployment.
- Code commits since the prior diagnostic checkpoint:
  - fff59f6b3c5bad6746e271ef42d2c505cce1b368: TaskStore stopped writing/deleting project_items; ProjectStore is the sole membership writer; deferred FK validation preserves rollback when a still-linked Task is omitted; trigger-guarded file-backed test added.
  - a48488ff89ec01d880548d267b66389c28c13d00: ProjectStore.replaceAll now updates matching Project IDs in place, preserves Center/Category graph edges, and blocks deletion of linked Projects; file-backed graph-preservation test added.
  - a420c89f06c598ed17b9def38efebd9108618c90: reuse the canonical insert helper for new Projects and generalize the shared ProjectDeleteBlocked contract.
- Current exact-SHA workflows: Build 46116776194 (all six test shards, Analyze, Debug/Release APK and trace evidence still in progress at checkpoint); COMMAND 20-E 46116776165 storage-persistence in progress; Device Smoke 46116776170 running; Follow-up File Persistence 46116776176 SUCCESS; Governance 46116776167 owner-locked REV10 contract SUCCESS. Re-poll before relying on any pending result.
- Previous candidate Device Smoke 46115088811 on fff59f6... completed SUCCESS 7/7. It is historical evidence and does not transfer to a420c89f06c598ed17b9def38efebd9108618c90.
- Project restore now preserves existing IDs and M2M edges by updating in place. The new file-backed test checks Task membership, Center↔Project and Project↔Category edges, unknown metadata, blocked deletion and FK integrity. It is IMPLEMENTED / NOT VERIFIED until its exact-SHA test job passes.
- Project↔Category still lacks a verified canonical CRUD/read owner in the inspected branch services. Do not add a duplicate store until all consumers and historical implementations are checked.
- Async runner diagnostic remains unresolved: earlier parent-SHA logs show callback entry and eventual work completion after the test harness timeout. Do not increase timeouts or weaken tests; inspect exact current-SHA job logs after completion to identify the first blocked phase.
- Product acceptance: NOT ACCEPTED. Release: NO-GO.


## Live checkpoint — 2026-11-28 — HEAD c51411fcb2019ad733c6fdcf700d94bfdee17a13

- Canonical PR #3495: OPEN / DRAFT / UNMERGED. Main `45e4202b03a434459e4c021a04efa7e8396359db` remains read-only.
- Test-only batch committed on the authorized branch: `f0100e4`, `39ac413`, `d3ef28f`, `bd53ec2`, `d4b4cdf`, `c51411f`. It introduces a real-wall-clock wait helper for native async tests, replaces FakeAsync frame-spin loops in Home/Center/Backup/TaskStorageLock tests, ensures NativeDatabase executors are opened before SQL, and installs the test runner in Home Restore.
- Root-cause evidence is from Build run `46117138055` on parent SHA `9a37b282...`: six quality shards failed; logs show old wait loops expiring before native work completion, one missing `ensureOpen()`, and a Home Restore test without the native async runner. A distinct RTL swipe `pumpAndSettle` failure remains unresolved.
- Prior SHA device evidence: Device Smoke `46117138005` SUCCESS 7/7; Governance `46117137988` SUCCESS; Follow-up Persistence `46117138064` SUCCESS; COMMAND 20-E `46117137975` storage-persistence SUCCESS but complete-evidence still IN_PROGRESS at last poll. These results do not transfer to current HEAD.
- Current HEAD `c51411f...`: no associated workflow runs returned. ACC-CI-001 is BLOCKED / NOT VERIFIED for this SHA. ACC-DEVICE-001 is NOT VERIFIED for this SHA.
- ARC-DATA-001 and DB-RESTORE-001 remain IMPLEMENTED / exact-SHA regression pending. ARC-M2M-001 remains PARTIAL pending full Project↔Category caller/owner audit.
- Next: obtain exact-SHA Build and targeted tests for `c51411f...`; inspect the remaining RTL swipe failure; complete COMMAND 20-E evidence; continue disposable-file D01–D05 acceptance. Do not duplicate a Store or alter Main.


## Superseding evidence poll — 2026-11-28 — prior code SHA 9a37b282bf2b2ef8218357c357b4927606efd349

- COMMAND 20-E run `46117137975` is now COMPLETED / FAILURE. Evidence collection itself is COMPLETED; overall verdict is NO-GO because the exact-SHA Build gate is not successful.
- COMMAND 20-E storage-persistence job `140893371704` SUCCESS. Its ProjectStore file-persistence, Calendar process-restart parity, and cleanup verification gates all report PASS.
- Device Smoke run `46117138005` SUCCESS across all seven scenarios. Follow-up File Persistence `46117138064` SUCCESS. Governance Validation `46117137988` SUCCESS.
- Build run `46117138055` has Analyze SUCCESS and Debug/Release APK jobs SUCCESS, but all six quality shards FAILED; its trace JSONL evidence job was CANCELLED and the workflow conclusion is CANCELLED. These are all evidence for SHA `9a37b282...` only.
- This poll supersedes the earlier note that COMMAND 20-E complete-evidence was still in progress. It does not alter the status of the later test-only candidate `c51411f...` or the current docs-inclusive branch tip; neither has current-SHA workflow evidence.
