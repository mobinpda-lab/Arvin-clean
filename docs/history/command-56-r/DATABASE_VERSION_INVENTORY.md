# Database Version Inventory

**Audit date:** 2026-11-18  
**Repository Main:** `45e4202b03a434459e4c021a04efa7e8396359db`

## Version inventory
| Source / state | Schema version | App version | Installer / path | Delivery status |
|---|---:|---|---|---|
| Current Main | 7 | 1.0.1+2 | `G1DriftSchema.install`; TaskStore then checks `legacy_tasks_migrated` and may import SharedPreferences `arvin.tasks` | Main source is proven; actual installed population unknown |
| Historical V19 candidate | 19 | PR branch pubspec must be read at exact candidate SHA before any release claim | `G1DriftSchema` at `310c0e20...`; legacy V7 compatibility path | PR #3384 unmerged; no V19 delivery evidence found in GitHub releases |
| Historical V20 candidate | 20 | Candidate inherits app version lineage from PR #3384; not a shipped version | `G1DriftSchema` at `81208296...`; calls M2M hierarchy migration from V19 | PR #3463 unmerged; not shipped |
| Intermediate / older databases | V0–V6 or unknown | Not inferable | Must classify from actual DDL, metadata, legacy keys and provenance | BLOCKED; no installed DB samples |
| V19 after occurrence migration | 19 | Unknown | V19 SQL destination may exist while Legacy Occurrence keys have been deleted | Ambiguous without source snapshot / receipt |

## Current Main schema and opening path
Main `lib/services/g1_drift_schema.dart` declares `static const int version = 7` (blob `cd065ff25c680ed064e89068b3d063e737091025`). It creates/ensures the V7-era G1 tables and uses `arvin_storage_meta` key `legacy_tasks_migrated` as the SharedPreferences cutover marker. Its source comment explicitly says not to write SQLite `PRAGMA user_version` in this installer.

Main `lib/services/task_store.dart` (blob `e65afaf905310b5ab19bf627c03aa21a2651c856`) performs:
1. `G1DriftSchema.install(executor)`;
2. checks `G1DriftSchema.isLegacyMigrationComplete`;
3. if not complete, reads SharedPreferences through `SqlTaskMigrationWriter.migrateFromPreferences`;
4. migrates Task people, verifies source IDs, seeds categories, then writes the completion marker.

The migration reader is blob `923b560aca647588c0e98e59b61ab224b50c5bb4`; the SQL writer is blob `54409754dcf9a3ad6daba5a4ca86573fbf5ac4d0`. This is the currently visible source path; it does not mean every user's local database has identical metadata or contents.

## V19 / V20 lineage
- V19 source commit: `310c0e20e3447c488c1e1c102c38bea5040708ca`; schema blob `9f0243dff6d8ffa13649ca7fd2ee33ac4d3a2c21`.
- V20 source commit: `812082964c649be7660c41213209ec34aea7167b`; schema blob `b03b90efac9f3c5cbef3b1b649385cdf6369ca62`.
- V20 M2M migration blob: `a2c768da3c90d2610ea2285ddd248e8fbbc27489`; it declares sourceSchemaVersion 19 and targetSchemaVersion 20.

## Version interpretation rules
- Do not treat a PR branch's schema number as the deployed schema.
- Do not treat SQLite `PRAGMA user_version` alone as proof of lineage; V19's source does not use it as the canonical marker.
- Classify with schema fingerprint, table/column shape, `arvin_storage_meta`, migration markers, legacy JSON key presence and backup provenance.
- Any unrecognized or mixed state is BLOCKED pending a read-only inventory; do not normalize or rewrite it.
