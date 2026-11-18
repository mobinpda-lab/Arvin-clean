# Forward Migration Architecture — COMMAND 55-R

## 1. Purpose
Repair and preserve V19 Occurrence state without modifying the historical V19 installer. The migration is additive, versioned, auditable, retry-safe, and must run only on a disposable, file-backed fixture during the future physical-test phase.

## 2. Versioning decision
The historical source snapshot declares `G1DriftSchema.version = 19`. The canonical PR #3495 description already records a V20 many-to-many hierarchy migration proposal. Therefore the design does **not** authorize a separate competing schema bump.

Proposed release train:
- One sequential schema target: **V20**.
- One migration ledger entry for the coordinated V20 upgrade.
- Ordered substeps: (a) preflight and source inventory, (b) Occurrence preservation repair, (c) any approved V20 hierarchy/M2M work, (d) cross-domain integrity validation, (e) receipt/ledger commit.
- The Occurrence substep must complete before any operation that retires or transforms its source.
- If V20 is reserved for a different incompatible migration, stop and explicitly re-sequence the Occurrence repair to V21. Never run two independent migrations both claiming V20.

V20 remains prohibited now. This is a design reservation only.

## 3. Invocation boundary
The future runner belongs in a dedicated service, e.g. `lib/services/migrations/occurrence_forward_migration_v20.dart`, not in the historical V19 installer or either SQL codec.

The single database-open coordinator must:
1. Open the file-backed database and acquire the migration/open lock.
2. Verify the observed schema and migration ledger.
3. Run the already-approved predecessor steps in order.
4. Ensure the required destination tables exist.
5. Run the Occurrence preservation step before TaskStore exposes data to readers or accepts writes.
6. Validate readback, integrity and foreign keys.
7. Commit the receipt and schema ledger in the same transaction.
8. Only then permit TaskStore decoding and normal writes.

The current V19 path is `TaskStore.load → _loadUnlocked → _ensureReady → G1DriftSchema.install`; V19 invokes `OccurrenceSqlCodec.migrateLegacyEnvelopes` inside the install transaction. The new step must not be inserted by editing that historical installer. A new coordinator/forward migration owns it.

## 4. Dependencies
Required:
- SQLite file database with transactional DDL support.
- V19 destination tables `task_occurrences` and `occurrence_checklist_items`.
- `tasks` identity and `legacy_payload_json` source, when present.
- A durable migration ledger and occurrence receipt table.
- Strict JSON decoder capable of rejecting duplicate object keys before normal Map materialization.
- Stable canonical semantic hashing.
- FK enforcement enabled and verified outside the transaction boundary.

Not acceptable:
- schema-version integer alone as proof of migration;
- `INSERT OR IGNORE` or blind UPSERT;
- implicit model defaults for missing data;
- memory-only test database as physical acceptance;
- an untracked one-off TaskStore repair.

## 5. Version and ledger invariants
Use a monotonic schema version plus a named migration ledger. Suggested ledger fields: migration_id (PK), from_version, to_version, definition_sha256, applied_at_utc, source_fingerprint, destination_fingerprint, row_counts_json, app_build, and result='applied'. Unique migration_id and unique to_version enforce one canonical owner per step.

The ledger and the detailed receipt are written last, in the same SQLite transaction as data changes. A committed schema version without the required receipt is invalid. A receipt without the corresponding ledger row is invalid. Any mismatch is a blocked database, not a successful migration.

## 6. Repeated execution
- Existing valid receipt + matching destination fingerprint + matching schema contract: return ALREADY_APPLIED without changing rows.
- No receipt + legacy source present: perform preflight and full source/destination reconciliation.
- No receipt + source absent + target present: unproven historical state; stop.
- No receipt + source absent + target empty: ambiguous; stop.
- Receipt exists but digest, counts, migration definition SHA, or schema fingerprint differs: stop and preserve all evidence.
- Partial receipt or partial destination state: transaction should have rolled back; if observed, classify as external/manual partial state and stop.

## 7. Failure behavior
All validation happens before destructive retirement. Any parse, identity, FK, parity, hash, duplicate, or constraint failure aborts the entire transaction. No best-effort row skipping, partial success, or silent fallback is permitted.

## 8. Backward compatibility
The adapter is read-only with respect to legacy source. It translates V19 JSON shape into the canonical occurrence DTO. It does not mutate Task identity, Task JSON, recurrence definitions, or unrelated entity stores. After V20 acceptance, legacy source retirement is a separate, explicitly approved operation with its own backup and receipt; this design does not require deleting V19 source keys.

## 9. Compatibility with old app versions
A new app may migrate a V19 database forward. An older app may not understand the new schema or normalized columns. Downgrade to an older binary is not considered safe merely because SQLite can open the file. Until a tested downgrade contract exists, restore a pre-migration backup to use the old app. Never downgrade by editing `user_version`.
