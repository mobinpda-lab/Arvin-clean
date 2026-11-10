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
