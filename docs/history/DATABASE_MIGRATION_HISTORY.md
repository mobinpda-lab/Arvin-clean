# Database Migration History — Evidence Ledger (Preliminary)
- Recorded: 2026-11-18 | Scope: Schema versions 7–20
- Status: PRELIMINARY FORENSIC INVENTORY — NOT A PROVEN UPGRADE PATH
- Main observed: `45e4202b03a434459e4c021a04efa7e8396359db`
- Canonical audited SHA: `9d455fae7ae6fd3ba207709aa0348b3b48c66e97`

## Provenance
Historical commits and blobs for `lib/services/g1_drift_schema.dart` were inspected, including version snapshots from PR lineage #3384/#3463 and the canonical branch. This SHA index is not proof that every adjacent upgrade edge is executable. Full fixture-based validation remains outstanding.

| Version | Historical source commit SHA | Observed change (preliminary) | Risk |
|---|---|---|---|
| 7 | `5e974519087c14f07387e45a903cee3409cc68bf` | completed_at-era baseline | baseline fixture required |
| 8 | `ed93d6ad30bfe4e75199f297efda0a2b8099ce49` | follow_ups.extension_json addition | additive |
| 9 | `708c112a82c753f1dcdb77f1cf9712a6336a725d` | legacy Task Template schema lineage | branch ambiguity |
| 10 | `00e3d8007798c5e29222faaa9c4738075c9d5a93` | template context fields | additive |
| 11 | `96651f7690a1cd40f7fa087e12293bcf288bb667` | checklist template setting | additive |
| 12 | `01238b00dd9e58cdc3987bf24b093a9d6c23f6ac` | relational Follow-up/Reminder/Person structures | data transfer |
| 13 | `7bcd218254c7931a766bdd091bb3d39483c1888e` | old Follow-up and People structures retired after transfer | destructive |
| 14 | `102e7d4fc00674524c50f577ce9f5b929d67349d` | Tasks table rebuild; legacy scheduling columns retired | destructive |
| 15 | `1313c3e59a726126db06d22d5e63e4ff952b1e15` | subsequent Tasks rebuild/version transition | rebuild |
| 16 | `633a0ac413a27a00be948947fa9047c316c10878` | reminder-source consolidation; legacy marker retired | rebuild/data transfer |
| 17 | `e12d86c77aecebde94f2f386a3b6c5732d539ccd` | recurrence_json addition | additive |
| 18 | `bceadc8f9bba6a9d7f0ba6756b7477f0cdb264b2` | task_reminders rebuild; legacy marker retired | destructive |
| 19 | `cd2cec72fb4bad77d1ae116913f811abfd94ea07` | Tasks rebuild and legacy column retirement | destructive |
| 20 | `9bd415ea7450d9863a1a72941e8f56701954d3a0` | Center/Project/Category many-to-many hierarchy work | architectural |

## Critical lineage ambiguity
Version 9 appears in two contexts: legacy v9 Task Template structure and current REV10 v8→v9 Center/Project/Category hierarchy migration. They are not automatically the same schema state or one linear history. Migration registry must establish actual source state by proven lineage/schema fingerprint; do not infer compatibility from integer version alone.

## Destructive/rebuild operations requiring proof
v13: old Follow-up/People structures retired after transfer; v14: Tasks rebuilt and scheduling columns retired; v15: Tasks rebuilt again; v16: reminder source consolidated; v18: task_reminders rebuilt; v19: Tasks rebuilt and legacy columns retired.
For each: before/after row counts, stable IDs, field mapping, relation checks, rollback/failure injection and exact-source SQLite fixture are required.

## PR lineage
- #3384: historical source for v19 implementation lineage.
- #3463: historical v20 / many-to-many hierarchy lineage.
- #3495: canonical integration PR audited at the SHA above.
Re-fetch these when continuing; this record is a historical snapshot, not a claim about their current state.

## Completion work
Fetch full diffs and changed files for #3384/#3463; extract all DDL and data-copy/delete sequences; verify exact schema state at each transition and merge boundary; build exact historical SQLite fixtures; test every supported path including failure injection/retry; document unsupported paths; only then authorize destructive cleanup.