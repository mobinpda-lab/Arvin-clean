# ARVIN — PROJECT STATE

## CURRENT LIVE POINTER — REV10 CONTINUOUS DEVELOPMENT (2026-11-13)

- Repository: `mobinpda-lab/Arvin-clean`; default branch: `main`.
- Main HEAD: `45e4202b03a434459e4c021a04efa7e8396359db`.
- Active master charter: `docs/project-continuity/MASTER_GOVERNANCE.md` — REV10 on development branch, not yet in Main.
- REV9 archive: `docs/project-continuity/MASTER_GOVERNANCE_REV9_ARCHIVE.md`.
- REV10 branch: `docs/rev10-master-charter-2026-11-13`; current HEAD before this root checkpoint update `a13abcef702422750f54533476c94de134fd8db4`; initial base REV9 branch HEAD `5bdb451674e6bbe7832f903b1215cbf39608c730`.
- SQLite execution branch: `feature/command-07-a-sqlite-contract-remediation`; latest verified HEAD at this checkpoint `3f471e6b88764446eabd33752d0aa3d820f52628`.
- PR #3340 (REV9) and PR #3388 (v49.1/Wave 0) remain unmerged competing documentation lines; reconcile before promotion.
- PR #3384 remains the SQLite/product execution stream; no merge is authorized.
- NIRA Main: `7a27ee63b65d343e45c5786f782f2567611722dc`; separate factory/control plane, not Arvin product authority.
- Optional relationship test Run `43431160695`: QUEUED on `3f471e6...`; Build Run `43431160736`: PENDING/no jobs at last poll.
- D01–D05: NOT ACCEPTED as complete gates. Device Smoke: NOT ACCEPTED. Product regression matrix: incomplete.
- Current authorization: continuous development on non-main branches. Main merge, release, deployment and irreversible operations remain prohibited.
- Current next action: poll exact-head SQLite/Build workflows, inspect failure logs, then continue Wave 1 data architecture and update this pointer. Wave 1 source audit: `docs/project-continuity/audit/REV10_WAVE1_DATA_ARCHITECTURE_BASELINE_2026-11-13.md`.
- Release: BLOCKED — RELEASE: NO-GO.

> All sections below are preserved historical checkpoints. Their SHAs, counts and CI results are not current unless reverified against live GitHub.

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


---

## REV9 live checkpoint — 2026-11-10

- Repository: `mobinpda-lab/Arvin-clean`; default branch: `main`.
- Verified Main HEAD at deployment start: `45e4202b03a434459e4c021a04efa7e8396359db`.
- Documentation branch: `docs/rev9-governance-continuity-2026-11-10`.
- First documentation commit: `1a849751b931028581f6ce721952aaa987474053`.
- PR #3052: OPEN / DRAFT / UNMERGED; head `aba68e44be0fcac7d4ad425b58fbe75e5aba264e`; untouched by this mission.
- Related open documentation/proposal PRs: #3022 (canonical product reference v1.4), #2598 (AMPOP governance foundation), #2600 (autonomous memory), #2866 (product concepts). They remain unmerged proposals and are not silently promoted to canonical authority.
- Font decision conflict: Issue #2974 and PRs #2918/#2975/#2932 record an earlier owner-approved Vazirmatn direction; REV9 (newer owner charter) explicitly marks Vazirmatn vs VazirHarf as NEEDS OWNER DECISION. Keep the font unresolved pending a new explicit owner decision.
- Release: BLOCKED — RELEASE: NO-GO.
- CI status is not inferred from an empty combined-status response; no PASS is claimed here.

Older snapshots in this file remain HISTORICAL and must not be deleted.


---

## Documentation PR created — 2026-11-10

- PR: [#3340 — REV9 governance and permanent AI continuity](https://github.com/mobinpda-lab/Arvin-clean/pull/3340).
- State at creation: OPEN / UNMERGED; base `main`; head branch `docs/rev9-governance-continuity-2026-11-10`.
- PR creation head SHA: `b9dc37804a69cd2292a071e008b50bd261bae512`. A subsequent documentation-only follow-up commit updates this state record; always fetch the live PR/branch head before continuing.
- PR #3052 remains OPEN / DRAFT / UNMERGED and untouched.
- Review requested from Mobin; no merge or release is authorized.


---

## WAVE 0 final handoff pointer — 2026-11-10

- Last verified PR #3340 HEAD before this final handoff record: `cd1d52e752ac10c0040738f655d5a288d2523399`.
- Documentation reconciliation commits: `fe85e64199cfdb468228830ecfff3bcf3d8bea5c`, `cd1d52e752ac10c0040738f655d5a288d2523399`.
- The current commit updates the handoff and advances the branch; fetch the live PR head before any further action.
- Main `45e4202b03a434459e4c021a04efa7e8396359db` and PR #3052 `aba68e44be0fcac7d4ad425b58fbe75e5aba264e` remain untouched.
