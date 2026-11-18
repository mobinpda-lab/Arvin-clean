# COMMAND 55-R — Design Acceptance Ledger

**Disposition:** DESIGN PARTIALLY ACCEPTED  
**Date:** 2026-11-18  
**Repository:** `mobinpda-lab/Arvin-clean`  
**Research branch:** `investigation/command-55-r-safe-forward-migration-design`  
**Research base:** `3d176db1bc54e40ec0055f6931d6216fadd6ca98`  
**Historical V19 source snapshot:** `310c0e20e3447c488c1e1c102c38bea5040708ca`  
**Main:** `45e4202b03a434459e4c021a04efa7e8396359db`  
**Canonical PR #3495 head:** `010cdfa016cd3884b9bea7eaf18b068620d4e980`

## Scope and safety
This branch contains design documentation only. No application source, schema, fixture, migration runner, test fixture, or production database was changed or executed. Main, historical V19 sources, and PR #3495 were not modified. No merge, release, deployment, or V20 execution is authorized.

## Live GitHub audit
- Repository is public; connected permission snapshot: admin/maintain/push/pull all true.
- Default branch: `main`.
- Main ref resolved to `45e4202b03a434459e4c021a04efa7e8396359db`.
- `recovery-02/main-based-integration` resolved to `010cdfa016cd3884b9bea7eaf18b068620d4e980`.
- `investigation/command-54-r-historical-migration-trace` resolved to `3d176db1bc54e40ec0055f6931d6216fadd6ca98`.
- PR #3495 is OPEN / DRAFT / UNMERGED, base `main`, head `recovery-02/main-based-integration`, 317 commits and 239 changed files at the observed snapshot.
- PR metadata was read live; no PR state was changed.

## Historical source pin verification
At commit `310c0e20e3447c488c1e1c102c38bea5040708ca`, Git tree entries and fetched file blobs match all six supplied hashes:

| Path | Expected and observed blob SHA | Result |
|---|---|---|
| `lib/services/g1_drift_schema.dart` | `9f0243dff6d8ffa13649ca7fd2ee33ac4d3a2c21` | MATCH |
| `lib/services/occurrence_sql_codec.dart` | `ae9fb8548fa57a8a3a48e1faa2e98a44e636003e` | MATCH |
| `lib/models/task.dart` | `328c402318878717d9165bccf8303fa6674321bf` | MATCH |
| `lib/services/task_store.dart` | `625f7b24523e621adba7ae7a59e4c3e13c272a09` | MATCH |
| `lib/services/recurrence_sql_codec.dart` | `29ee7c0c778d99135daf376ba19f7773e4760ce4` | MATCH |
| `lib/models/recurrence.dart` | `470418b9d76f66117a9e6b3c9372a0856c01fd17` | MATCH |

Important clarification: commit 310c0e is itself a documentation-only commit, but its tree contains the exact pinned V19 source blobs. The pin is therefore a valid source snapshot, not a claim that 310c0e introduced the V19 code.

COMMAND 54-R source map was fetched from the investigation branch; blob SHA:
`docs/history/command-54-r/V54_OCCURRENCE_CODE_DEPENDENCY_MAP.md` — `0ba469720993f0f3177d0ac9ec479eff3cda4a1e`.

## Design disposition
The documents define a proposed additive forward-repair step, an explicit source/destination state machine, a receipt, presence-aware nullable fields, opaque unknown-field preservation, conflict rules, rollback and backup/restore gates, and a physical test plan.

**DESIGN PARTIALLY ACCEPTED** because:
1. The historical V19 code facts and six blob pins are verified.
2. The proposed design is internally specified for review, but has not been independently reviewed or physically validated.
3. The next schema-version slot must be coordinated with the already documented V20 many-to-many hierarchy work on the canonical delivery route. This design proposes one coordinated V20 migration release train with an occurrence-preservation substep; it must not create a second competing schema-version bump. If the owner reserves V20 exclusively for another migration, the occurrence repair must be explicitly re-sequenced to V21 before implementation.
4. Existing V19 databases that have lost the legacy keys and have no occurrence-specific receipt cannot be proven complete from target rows alone. Those databases require a safe recovery decision, not automatic success.

## Acceptance checklist
- [x] Live Main, canonical branch, investigation branch, and PR #3495 queried.
- [x] Six historical V19 blobs matched exactly.
- [x] COMMAND 54-R source map re-read.
- [x] Forward migration architecture documented.
- [x] Idempotency and receipt contract documented.
- [x] Explicit NULL and unknown-field contracts documented.
- [x] Four source/destination states and partial-database cases documented.
- [x] Identity, relationships, transaction and restore requirements documented.
- [x] Independent test matrix and performance budgets proposed.
- [ ] Independent architecture review completed.
- [ ] V20 slot reservation / sequencing approved by Product Owner.
- [ ] Physical SQLite fixtures built and tested in a separately authorized phase.
- [ ] Backup/restore and failure-injection evidence accepted.
- [ ] Implementation phase separately authorized.

## Required final gates
- V19: NO-GO until physical acceptance is complete.
- V20: PROHIBITED until separately authorized after acceptance.
- Main: PROTECTED.
- Merge / Release / Deploy: PROHIBITED.


## Deployment-lineage qualification
A direct Main source read confirms Main schema v7 (blob `cd065ff25c680ed064e89068b3d063e737091025`). PR #3384 (V19) and PR #3463 (V20 candidate) are both OPEN / DRAFT / UNMERGED; #3463 is stacked on #3384, and #3384 is not based on Main. Consequently this command does not claim V19 is the deployed or universal user-database baseline. Any future migration must identify each database by structural fingerprint and provenance. Main-v7 requires its own approved sequential path.
