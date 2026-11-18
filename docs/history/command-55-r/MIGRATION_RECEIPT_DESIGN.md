# Migration Receipt Design

## Purpose
Provide durable proof that a named migration completed against a specific source and destination state. A schema version or empty legacy source is not proof.

## Tables
Suggested `arvin_migration_receipts`:
- `migration_id TEXT PRIMARY KEY`
- `migration_version INTEGER NOT NULL`
- `definition_sha256 TEXT NOT NULL`
- `source_state TEXT NOT NULL`
- `source_fingerprint TEXT NOT NULL`
- `destination_fingerprint TEXT NOT NULL`
- `task_count INTEGER NOT NULL`
- `occurrence_count INTEGER NOT NULL`
- `checklist_item_count INTEGER NOT NULL`
- `unknown_payload_count INTEGER NOT NULL`
- `null_presence_summary_json TEXT NOT NULL`
- `completed_at_utc TEXT NOT NULL`
- `result TEXT NOT NULL CHECK(result='applied')`

Suggested `arvin_schema_migrations`:
- `migration_id TEXT PRIMARY KEY`
- `from_version INTEGER NOT NULL`
- `to_version INTEGER NOT NULL UNIQUE`
- `definition_sha256 TEXT NOT NULL`
- `receipt_fingerprint TEXT NOT NULL`
- `applied_at_utc TEXT NOT NULL`

All fingerprint fields use SHA-256 over a versioned, length-delimited canonical serialization. Do not hash ambiguous concatenated strings.

## State model
Transient in-memory states: PREFLIGHT, COPYING, VALIDATING, READY_TO_COMMIT, ABORTED.
Only durable state: APPLIED. A receipt is inserted only after all data and parity checks pass, immediately before COMMIT, in the same transaction. A crash before COMMIT leaves neither data changes nor receipt. A crash after COMMIT leaves both.

Do not persist a durable SUCCESS/PENDING receipt outside the data transaction. A separate diagnostic log may record an attempt ID and failure, but must never be treated as migration proof.

## Retry decision
- Receipt exists, definition hash matches, schema fingerprint matches, and destination fingerprint recomputes exactly: ALREADY_APPLIED, no writes.
- Receipt missing and source complete: preflight and reconcile.
- Receipt missing and source absent: AMBIGUOUS; stop.
- Receipt mismatch or destination drift: CONFLICT; stop.
- Receipt exists but data is missing or altered: CORRUPT_AFTER_MIGRATION; stop and require restore/recovery.

## Atomicity
The receipt, schema ledger row, presence metadata, opaque payloads, Occurrence rows, checklist rows and any source-preservation metadata are committed in one transaction. A receipt must never be written before the final readback and FK/integrity checks.

## Audit
Store the migration definition hash, app build, source and destination fingerprints, row counts, and deterministic timestamp. Export the receipt with backup evidence. Receipts are append-only; corrections use a new migration ID and never rewrite historical receipt rows.
