# COMMAND 35 — Architecture Consolidation
Audit baseline: `ed4f1e0c0e01f186155b194b34212b7f2ffb584b`
Status: IN PROGRESS / NOT ACCEPTED.

## Current canonical evidence
- Canonical Drift schema version: 8.
- TaskStore and ProjectStore blobs differ from the historical #3052/#3463 versions.
- Canonical ProjectStore currently reads and writes `project_items`; its inspected source includes project deletion/replacement paths that require review before any M2M foreign-key constraints are introduced.
- Canonical AppFonts exposes the Vazirmatn family.
- The M2M-specific CenterStore and migration files from #3463 are absent at this baseline.

## REV10 target boundaries
One authoritative path must serve:
- Task and TaskReminder
- Person directory and Task/Follow-up person relations
- Follow-up history
- Calendar and provider integration
- Center and Project
- Category and Tag
- M2M relationship persistence
- Backup/Restore
- Reporting and Notebook taxonomy

No second database, parallel repository, duplicated settings store, or shadow taxonomy is accepted.

## Consolidation decisions
1. Preserve existing Task/Project identities and serialized historical payloads.
2. Do not replace Canonical TaskStore/ProjectStore with historical branch versions.
3. M2M must be integrated into existing canonical stores and projections, not introduced as an isolated schema-only feature.
4. Backup/Restore must restore relationships and metadata consistently, not merely the SQLite file or JSON envelope.
5. Calendar reminder projection must follow the current owner-approved TaskReminder/Follow-up contracts; legacy metadata must not create duplicate calendar events.
6. Keep the shared UI font family as Vazirmatn. No parallel VazirHarf UI family.
7. Do not retire legacy tables, columns or payload fields until all readers/writers and restore paths have passed parity tests.

## Unresolved integration gates
- Sequential migration v8→v19→v20 is unproven.
- Center CRUD and M2M relationship lifecycle are not present in the canonical file set inspected.
- ProjectStore does not yet use the proposed M2M join tables.
- TaskStore end-to-end M2M fields and relationship writers are not proven.
- Category/Tag to Project relationships are not proven.
- Physical backup/restore of all relationships and metadata is not accepted.
- Full product surfaces and device-level REV10 acceptance remain separate gates.

Architecture status: NOT ACCEPTED. No production data or schema was modified.
