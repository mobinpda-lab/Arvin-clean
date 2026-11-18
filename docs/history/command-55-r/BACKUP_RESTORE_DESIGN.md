# Backup and Restore Design

## Backup requirements
A file copy is not automatically a valid backup. The future implementation must use SQLite's online backup API or a controlled quiesce/close plus WAL checkpoint and copy procedure that includes all database state. Record:
- source database path identifier (non-sensitive test fixture ID only);
- database byte length and SHA-256;
- SQLite version and compile/runtime details;
- schema inventory and migration ledger;
- row counts and deterministic data fingerprints;
- WAL/journal handling and checkpoint result;
- backup timestamp and test run ID.

Never copy a live main database file while omitting a non-empty WAL file.

## Restore acceptance
Restore into a new independent disposable database file, never over the source fixture. Then:
1. open restored file;
2. run `PRAGMA quick_check` and require exactly `ok`;
3. run `PRAGMA foreign_key_check` and require zero rows;
4. compare schema objects and migration ledger;
5. compare all primary keys, natural keys, nullable presence bits, unknown JSON payloads, checklist order and relationship edges;
6. load through TaskStore and compare model readback;
7. close/reopen and repeat checks.

A backup is accepted only if restore and semantic comparison succeed. File existence, non-zero length, or matching filename is insufficient.

## Pre/post snapshots
Capture deterministic, ordered snapshots for Tasks, Occurrences, checklist items, Recurrence Rules, Follow-ups, People, Projects, Tags, and all relationship tables. Store both raw-source hashes and semantic hashes. Snapshot differences must be explained by an explicit migration mapping; no unexplained deletion, identity change, relationship loss or unknown-field loss is permitted.

## Recovery
If migration fails before commit, rollback and retain the original database. If the database is corrupt or the receipt mismatches after commit, restore the verified pre-migration backup to a separate file and verify it before any replacement decision. Preserve the failed database as forensic evidence; never overwrite it automatically.
