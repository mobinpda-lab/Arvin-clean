# People / Contacts — canonical Task persistence — 2026-08-27

Refs #327 #325 #324 #320 #322 #195.

## Purpose
Persist the already accepted People/Contacts domain relation through Arvin's existing canonical Task path without creating a CRM, contact database, second repository or second source of truth.

## Canonical persistence contract
- `Task.people` is an optional collection of lightweight `PersonReference` values.
- Each Person reference keeps only the stable Arvin-owned `id` and offline `displayName` accepted by the merged domain contract.
- `Task.toJson()` emits `people` only when the relation is non-empty.
- `Task.fromJson()` treats missing `people` as an empty relation, preserving compatibility with older Task JSON.
- Persisted malformed entries, invalid Person identities and duplicate Person ids are rejected rather than silently normalized into ambiguous state.
- The in-memory Task relation is immutable.

## Existing storage only
- `TaskStore` continues to use the single existing `arvin.tasks` key.
- No People/Contacts repository, database, SharedPreferences key or parallel persistence path is introduced.
- The transitional Home writer remains lossless: it merges editable Home fields into existing Task JSON, so the canonical `people` field survives ordinary edits even before People UI exists.

## Backup / restore
Canonical backup already serializes Tasks through `Task.toJson()` and restore already rebuilds them through `Task.fromJson()`. Therefore the Person relation travels through the existing backup/restore path without a new backup format or a second data channel.

## Compatibility evidence
Focused tests cover:
- Person JSON round-trip;
- Task JSON round-trip;
- legacy Task JSON without `people`;
- malformed and duplicate persisted Person references;
- existing TaskStore key round-trip;
- lossless Home edit preservation;
- canonical backup/restore preservation without mutating storage during candidate restore.

## Explicit non-goals
- no device Contacts permission or provider import;
- no phone/email/provider-contact identity fields;
- no standalone CRM or contact storage;
- no network/cloud contacts sync;
- no People UI in this slice.

## Next safe slice
After this persistence slice is merged and validated on `main`, expose a read-only People projection or narrowly scoped Task-facing People UI using the canonical `Task.people` field. Device/provider access must remain a separate, explicit future boundary.
