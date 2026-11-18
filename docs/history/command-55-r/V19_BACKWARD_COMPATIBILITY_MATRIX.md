# V19 Backward Compatibility Matrix

## Source/destination state machine

| Case | Legacy keys | SQL destination | Receipt | Decision |
|---|---|---|---|---|
| 1 | present and valid | empty | absent | PREPARE; full preflight then insert and verify |
| 2 | present and valid | rows present | absent | RECONCILE every row and field; exact match may be adopted only with verified source fingerprint; any mismatch blocks |
| 3 | absent | rows present | valid matching receipt | ALREADY_APPLIED after recomputing destination fingerprint |
| 4 | absent | rows present | absent | AMBIGUOUS_V19_HISTORY; stop; no automatic success |
| 5 | absent | empty | absent | AMBIGUOUS_EMPTY; stop; cannot infer there was no history |
| 6 | present | partial destination | absent | classify partial/manual state; compare all rows; do not overwrite; stop unless exact completeness can be proven |
| 7 | malformed | any | any | reject; retain backup/source; rollback |
| 8 | present | conflicting rows | any | conflict; no merge or overwrite |
| 9 | any | any | receipt mismatch | corrupted/drifted state; stop and recover from verified backup |

## Required database classes
- Pre-V19 database: not a supported direct input to this Occurrence step. It must pass the approved sequential predecessor chain first; never jump schema versions.
- V19 database with intact legacy source: eligible for preflight.
- V19 database with non-empty Occurrence SQL and intact source: eligible only for full record-by-record reconciliation.
- V19 database with SQL rows but deleted source and no receipt: ambiguous and blocked.
- V19 database with no source and no destination: ambiguous and blocked.
- Database with partial/failed V19 installation: schema fingerprint and table inventory will not match; quarantine and restore/recovery path.
- Database with a receipt but missing rows: corruption after migration; restore from backup or manual forensic recovery.
- Database with unknown columns, triggers, custom indexes or noncanonical constraints: do not rebuild/drop tables; preserve and stop for a reviewed adapter.

## Operation policy
Allowed: read-only inventory, snapshot, strict decode, deterministic comparison, insert into a verified-empty destination inside a transaction, and receipt creation after validation.
Forbidden: delete source keys, overwrite conflicting rows, regenerate IDs, infer missing rows, insert-ignore, blanket replace, schema-version-only acceptance, or auto-repair ambiguous states.

## Existing V19 limitations relevant to compatibility
V19 `OccurrenceSqlCodec` has no occurrence-specific receipt. It reads only `tasks.legacy_payload_json`, projects known fields, compares existing Occurrence fields and then removes `occurrenceHistory` and `checklistOccurrences` from that envelope. Its readback emits `completionDate` and `result` only when non-NULL. Consequently a later migration cannot reconstruct absent-vs-explicit-null or unknown nested fields from normalized V19 rows alone.

## Compatibility adapter
Adapter is read-only and versioned. It must recognize the exact V19 envelope shape and exact SQL shape. Unknown schema shape is not coerced into the V19 adapter. Newer and older formats require their own adapter version and explicit fixture coverage.
