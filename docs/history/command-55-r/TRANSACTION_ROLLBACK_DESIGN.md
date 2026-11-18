# Transaction and Rollback Design

## Preconditions
1. Acquire a process-wide and database-level migration lock.
2. Open the target file and verify it is not an in-memory executor.
3. Run read-only `PRAGMA quick_check`, `foreign_key_check`, schema inventory and migration-ledger checks.
4. Create and verify a restorable backup before any write.
5. Ensure `PRAGMA foreign_keys=ON` before opening the transaction; SQLite ignores attempts to toggle it inside an active transaction.
6. Begin with `BEGIN IMMEDIATE` to reserve the write transaction and avoid a late writer race.

## Atomic unit
One transaction contains:
- additive schema changes;
- occurrence presence columns and opaque JSON columns;
- data transfer and reconciliation;
- post-write readback and row/hash parity;
- final integrity and foreign-key checks;
- migration receipt and schema ledger insertion.

No external side effect, source deletion, notification scheduling, or TaskStore exposure occurs inside the copy loop.

## Failure points
| Failure point | Required result |
|---|---|
| Before transaction | No DB change; backup remains verified |
| DDL failure | ROLLBACK all DDL/data |
| JSON parse/type/duplicate-key failure | ROLLBACK all writes; source untouched |
| ID/natural-key conflict | ROLLBACK all writes |
| Failure after some Occurrence rows | ROLLBACK all rows and checklist rows |
| Readback mismatch | ROLLBACK |
| FK/integrity check failure | ROLLBACK |
| Receipt insert failure | ROLLBACK data and DDL |
| Process termination before COMMIT | SQLite recovery must leave transaction uncommitted; verify on reopen |
| Process termination after COMMIT | Receipt and data both present; recompute receipt on reopen |
| Reopen with neither data nor receipt | retry only if source intact and preflight passes |
| Reopen with partial data but no receipt | classify external/corrupt state; stop |

## Rollback policy
Rollback means transaction rollback for in-flight failures. It does not mean decrement schema version or delete a committed receipt. After a committed migration, recovery is restore-from-verified-backup or a separately designed forward correction. Do not implement destructive downgrade.

## Reopen verification
Close the connection, reopen the same disposable file, recompute schema and data fingerprints, rerun quick_check and foreign_key_check, load Tasks through TaskStore, and compare every protected identity and payload against the pre-migration snapshot.
