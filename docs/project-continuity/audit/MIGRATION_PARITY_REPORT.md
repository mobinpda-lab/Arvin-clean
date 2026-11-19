# Migration Parity Report — WAVE 4

**Checkpoint SHA:** `dbfcdb02879ed3939cb6a69d3a150e2237283a51`  
**Status:** PARTIAL — Task and Project preference paths improved; global migration still blocked.

## Task preference migration

The writer now checks, before COMMIT:
- Source/target row count.
- Ordered Task IDs and storage ordinals.
- Scalar field parity, including null values.
- Unknown-field envelope parity after excluding fields now owned by relational Recurrence/Occurrence tables.
- TaskReminder IDs, content, sequence and enabled state.
- Follow-up history IDs, fields and order.
- Checklist item values and order.
- Task-Person and Task-Tag relation order.
- Follow-up-Person relations.
- Relational Recurrence parity.
- Occurrence and occurrence-checklist parity.
- SQLite foreign-key integrity.

A matching ID with different content now throws; the transaction rolls back. Existing rows are skipped only after parity.

## Project preference migration

The single Project migration writer validates Project row count, ordered IDs, storage ordinals, metadata fields, source envelope/unknown fields, Task membership IDs and membership order, and foreign keys before COMMIT. ProjectStore uses this writer. Project ordering is now stored in `projects.storage_ordinal`.

## Unresolved parity gaps

- Legacy Follow-up, Person and relation migration in `G1DriftSchema.migrateCanonicalEntities` still relies on insert-ignore behavior in places and does not yet prove full source/target field parity.
- The schema-upgrade transaction and Task/Project preference migrations are still separate transactions; the requested single atomic multi-source migration is not yet implemented.
- Null/empty semantics and ordering parity have not been proven for every persistent entity.
- Duplicate/conflict validation is not yet complete for every template, notification, prayer, settings and sync entity.
- Backup/Restore round-trip parity across the full approved entity set is NOT VERIFIED.

## Safety

Legacy tables and columns are retained. Destructive rebuild/retirement paths were disabled rather than executed without proof. No global migration-complete claim is authorized.
