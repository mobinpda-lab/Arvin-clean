# PR Migration Ownership Report

**Audit date:** 2026-11-18

## Live PR inventory
| PR | State | Base ref / SHA | Head ref / SHA | Migration ownership |
|---|---|---|---|---|
| #3384 | OPEN / DRAFT / UNMERGED | `fix/wave3-cycle3-calendar-product-repair` / `8c4c23f0c2a4f9b2374a2092c931782c4455fd41` | `feature/command-07-a-sqlite-contract-remediation` / `310c0e20e3447c488c1e1c102c38bea5040708ca` | V19 G1 schema + legacy migration candidate |
| #3463 | OPEN / DRAFT / UNMERGED | #3384 head / `310c0e20e3447c488c1e1c102c38bea5040708ca` | `rev10-m2m-v19-test-expansion` / `812082964c649be7660c41213209ec34aea7167b` | V20 many-to-many hierarchy migration |
| #3495 | OPEN / DRAFT / UNMERGED | `main` / `45e4202b03a434459e4c021a04efa7e8396359db` | `recovery-02/main-based-integration` / `010cdfa016cd3884b9bea7eaf18b068620d4e980` | Separate recovery/integration line; not V19/V20 base |

PR #3384 metadata at audit: 218 commits, 120 changed files. PR #3463: 139 commits, 42 changed files. PR #3495: 317 commits, 239 changed files.

## Version ownership evidence
PR #3384's `lib/services/g1_drift_schema.dart` blob is `9f0243dff6d8ffa13649ca7fd2ee33ac4d3a2c21`, declaring version 19.

PR #3463 changes that schema to version 20 (blob `b03b90efac9f3c5cbef3b1b649385cdf6369ca62`) and imports `g1_many_to_many_hierarchy_migration.dart` (blob `a2c768da3c90d2610ea2285ddd248e8fbbc27489`). That migration creates `center_projects` and `project_categories`, adds Task hierarchy links and writes the marker `rev10_hierarchy_schema_version`.

The PR #3463 architecture addendum in `docs/architecture/COMMAND_07_A2_45_CANONICAL_SCHEMA_MIGRATION_DESIGN.md` blob `a30e9cf69215c0d0eae4f9bdcc44e72be3519ffb` identifies #3463 as the REV10 Project persistence implementation and states that its v20 SQLite evidence is bound to the exact candidate SHA, not accepted for release.

## Exact-head workflow evidence
- PR #3384 head #310c0e: Build run `43575749904` FAILURE; SQLite Snapshot Evidence run `43575749897` SUCCESS; Device Smoke run `43575749907` CANCELLED.
- PR #3463 head #812082: Build run `43629839831` FAILURE; V20 Lifecycle and M2M Acceptance run `43629840018` SUCCESS; SQLite Snapshot Evidence run `43629839832` SUCCESS; Device Smoke run `43629839877` CANCELLED.
- These are exact-head workflow results. A passing specialized migration workflow does not override a failed Build or cancelled device lane.

## Ownership conclusion
V20 is already owned by the M2M hierarchy migration candidate in PR #3463. Do not independently allocate another schema version 20 migration. PR #3495 is not a parent of #3384/#3463 and must not be treated as the release lineage without a reviewed integration decision.
