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


## 10. Entity and relationship preservation inventory
The Occurrence repair owns only Task Occurrence and occurrence-checklist data. All other V19 entities are protected dependencies and must remain byte/semantically unchanged unless another separately approved migration step explicitly owns them.

| Entity / table | Primary or natural key | V19 relationship / FK | Nullable or legacy payload notes | COMMAND 55-R policy |
|---|---|---|---|---|
| Tasks / `tasks` | `id` | Parent of reminders, follow-ups, occurrences, recurrence, checklist, people, tags, project membership | Nullable timestamps/due date/category/notebook/recurrence JSON/legacy payload; source envelope | Preserve Task IDs and every non-Occurrence field; never rewrite unrelated payload |
| Occurrences / `task_occurrences` | `id`; unique `(task_id, scheduled_at)` | `task_id → tasks.id` | `completed_at`, `result` nullable; presence is lost by V19 projection | Primary migration target; add explicit presence and opaque payload |
| Occurrence checklist / `occurrence_checklist_items` | `(occurrence_id, ordinal)` | `occurrence_id → task_occurrences.id` | Ordered string values; no nullable value column | Preserve order, exact text and parent occurrence ID |
| Recurrence / `task_recurrence_rules` | `task_id` | `task_id → tasks.id` | Nullable start/end/count; separate V19 codec and marker | Read-only protected dependency; do not conflate recurrence definition with occurrence history |
| Task checklist / `checklist_items` | `(task_id, ordinal)` | `task_id → tasks.id` | Ordered values | No mutation in this step |
| Task reminders / `task_reminders` | `id`; unique `(task_id, sequence)` | `task_id → tasks.id` | Reminder values have their own date/all-day semantics | No mutation in this step |
| Follow-ups / `follow_up_records` | `id`; unique `(task_id, ordinal)` | `task_id → tasks.id` | `title`, `result` nullable; legacy source metadata may exist | Preserve IDs, order, values and Task ownership |
| Follow-up people / `follow_up_record_people` | `(follow_up_id, person_id)` | Both endpoints FK to Follow-up and Person | Ordinal preserves order | Preserve every edge and ordinal |
| People / `persons` | `id` | Referenced by Task and Follow-up relation tables | Name/timestamps are canonical shared identity | Preserve IDs and display-name ownership |
| Person directory / `person_directory` | `person_id` | `person_id → persons.id` | Active membership is separate from historical identity | Never seed, delete or reactivate in this step |
| Task people / `task_persons` | `(task_id, person_id)` | Both endpoints FK to Task and Person | Ordinal | Preserve edges and order |
| Projects / `projects` | `id` | Optional Center/Template references; Task membership through project_items | Legacy payload may be nullable | No mutation |
| Project items / `project_items` | `(project_id, task_id)` | Both endpoints FK to Project and Task | Ordinal | Preserve membership and order |
| Tags / `tags` | `id` | Referenced through task_tags | Name is user data | No mutation |
| Task tags / `task_tags` | `(task_id, tag_id)` | Both endpoints FK to Task and Tag | Ordinal | Preserve all edges and order |
| Centers / `centers` | `id` | Referenced by Project and other optional assignments | Names/archive state are user data | No mutation |
| Categories / `taxonomy_categories` | `name` | Used by Task/template fields | Name is the natural key | Preserve exactly; do not infer or normalize |
| Templates / `task_templates`, `project_templates`, `project_template_tasks`, `template_task_applications` | IDs and declared unique template ordinals | Template and Project/Task FKs | JSON list columns and nullable recurrence/snapshots | Outside migration ownership; snapshot and assert unchanged |

For each table above, fixture snapshots must include every PK/natural key, FK edge, ordinal, nullable value, and legacy/opaque payload column. The migration is rejected if any protected table changes unexpectedly. The authoritative DDL and column definitions remain the pinned `g1_drift_schema.dart` blob; this table is a preservation inventory, not a replacement schema specification.

## 11. Performance and compatibility budgets (proposed, not measured)
These are acceptance targets for future physical testing, not observed performance claims. Record device/OS, SQLite version, storage type, data profile and p50/p95.

| Profile | Fixture size | Added migration wall time target | Peak additional RSS target | Read/query strategy |
|---|---|---:|---:|---|
| Small | 1k Tasks / 5k Occurrences / 10k checklist rows | p95 ≤ 1 s | ≤ 32 MiB | bounded pages; no per-row TaskStore reload |
| Medium | 10k / 100k / 250k | p95 ≤ 8 s | ≤ 96 MiB | streaming source scan and bounded insert/readback batches |
| Large | 100k / 1m / 2.5m | p95 ≤ 60 s | ≤ 256 MiB | cursor/page iteration; no full-database object graph |

Additional measurable constraints:
- SQL statement count must grow linearly with rows only for necessary inserts; schema/preflight query count must remain bounded.
- No N+1 TaskStore readback. Validate in batches and compute fingerprints incrementally.
- Peak memory must not scale with the entire decoded database; process one Task or bounded page at a time.
- Record database size before/after; report added bytes per occurrence and checklist row. No fixed growth threshold is asserted until measured baseline fixtures exist.
- Program startup impact must be measured separately from the migration duration. If the migration cannot finish within the profile budget, show a recoverable blocking state and do not expose partially migrated data.
- Downgrade compatibility is not promised. Older binaries must use a verified pre-migration backup.


## 12. Deployment and lineage qualification
Live GitHub verification on 2026-11-18 shows:
- Main currently declares `G1DriftSchema.version = 7`, blob `cd065ff25c680ed064e89068b3d063e737091025`.
- PR #3384 is OPEN / DRAFT / UNMERGED; its head is the V19 source snapshot `310c0e20e3447c488c1e1c102c38bea5040708ca`, based on `fix/wave3-cycle3-calendar-product-repair` at `8c4c23f0c2a4f9b2374a2092c931782c4455fd41`, not Main.
- PR #3463 is OPEN / DRAFT / UNMERGED; its V20 candidate head `812082964c649be7660c41213209ec34aea7167b` is based on PR #3384's head, not Main.
- PR #3495 remains OPEN / DRAFT / UNMERGED and its base is Main.

Therefore V19/V20 are verified source-lineage candidates, not evidence that the released Main application or all real user databases are already at V19. The actual production population must be inventoried independently. Main-v7 databases must follow an approved sequential v7 migration plan; this Occurrence adapter is not a shortcut from v7 to v20.

The V19 installer sets `schemaVersion = 19` for Drift's `QueryExecutorUser`, but its own source explicitly avoids writing SQLite `PRAGMA user_version`; the canonical metadata uses `arvin_storage_meta`. A future adapter must classify the database by schema fingerprint, required tables/columns, migration markers and data evidence. Neither a PR description nor `user_version` alone identifies a user's database lineage.
