# COMMAND 54-R — Backward Compatibility Report

**Status:** Analysis only. No database was migrated.

## Source versions and user states
The V19 schema installer reports schema version 19. The forensic V7 fixture is pinned separately by the prior investigation to source commit `f211326e7615f1c907494232dd3aec8d4732c83c` and SHA-256 `68752dcafcbe84abe399d71ac3411ec9832084fb888e84158d8a3b4a819913f0`.

The inspected V19 code does not show an explicit sequence of migration classes for each integer version from 7 through 19. It applies a consolidated, introspection-driven installer to the existing SQLite shape. The SharedPreferences-to-SQL import is a separate TaskStore path gated by `G1DriftSchema.isLegacyMigrationComplete`.

## Compatibility cases
1. **Pre-normalized legacy envelope:** source Occurrence keys exist in `legacy_payload_json`; a forward migration can decode and transfer them.
2. **Already-normalized V19:** source keys may have been removed after a prior successful transfer; deterministic destination rows remain. A forward migration must validate these rows as prior success, not as an empty source.
3. **Failed historical parity:** the forensic negative cases report that transaction rollback retained source JSON for explicit NULL and unknown nested fields. Such rows are candidates for a lossless forward repair because source evidence remains.
4. **Previously successful but ordinary transfer:** the old keys have been retired. Destination rows preserve the normalized fields that V19 represented. A new receipt can be backfilled only after full destination validation.
5. **Previously retired information:** if a value existed only in a source key that was removed and no opaque copy exists, a forward migration cannot infer or restore it. The repair must report this limitation rather than invent values.

## Compatibility safeguards
- Do not rely only on schema version number; inspect actual tables, columns, source keys and destination relations.
- Use stable Task ID + scheduled timestamp and verify deterministic Occurrence ID.
- Validate all statuses against the historical enum.
- Validate checklist rows and ordinal order.
- Preserve explicit key presence separately from SQL NULL.
- Preserve nested unknown JSON fields in an opaque occurrence payload.
- Use a migration-specific receipt version and checksum/source identity. Receipt and migrated data must commit atomically.
- On conflict, stop and retain source evidence; never suppress with `INSERT OR IGNORE`.
- Do not retire source keys in the first forward-repair phase.
- Keep TaskStore's normalized SQL read path authoritative; do not introduce a parallel occurrence repository.

## Rollback and recovery
The V19 installer wraps its DDL and Occurrence transfer in a transaction and rolls back on thrown errors. The future repair should preserve that atomicity and include the receipt, key-presence metadata and unknown payload in the same transaction. Backup/restore and process-restart tests must compare full logical snapshots. This report does not claim those tests have run.

## V7-to-V19 statement boundary
The immutable V7 fixture proves the origin of the forensic test input, not that all user databases have identical provenance. The exact production upgrade route depends on the database's actual legacy tables and the TaskStore SharedPreferences marker. The verified runtime path is: TaskStore entry → G1DriftSchema.install (schemaVersion 19, structural compatibility) → OccurrenceSqlCodec migration → remaining schema transaction → optional SharedPreferences import if its marker is incomplete.
