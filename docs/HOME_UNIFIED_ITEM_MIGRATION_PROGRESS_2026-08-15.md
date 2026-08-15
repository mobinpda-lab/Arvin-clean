# Arvin — Home Unified Item Migration Progress

## Audit result
The current `lib/main.dart` still defines legacy `ArvinTask` and `TaskRepository`, while the official `lib/models/task.dart` already contains the Unified `Task` model with reminders, follow-ups, recurrence, archive/trash and completion state.

## Rule
Do not add Reminder/Recurring UI to the legacy `ArvinTask` path. Migration must preserve legacy `arvin.tasks` data and avoid introducing a second persistence path before the storage strategy is explicitly proven.

## Current Wave
- Main remains untouched for the migration itself.
- Migration work stays isolated in `wave2/home-unified-migration-boundary`.
- CI is the merge gate: Analyze → Test → Build APK → Verify APK.
- Documentation is updated alongside migration slices.
- Production storage behavior is not changed until the migration boundary and rollback/idempotency contracts are proven.

## Completed slice — migration boundary hardening
Added `lib/services/task_migration_adapter.dart` as a small boundary around the canonical `Task` model.

The adapter now:
- validates that each legacy task is an object
- requires a non-empty task id
- validates the optional legacy title type
- accepts an empty list safely
- supports multiple tasks
- rejects duplicate task ids during decode
- rejects duplicate/empty ids during unified encode
- preserves the existing `followUpDate` → `FollowUp` behavior supplied by `Task.fromJson`
- uses package imports so CI analysis does not depend on relative `lib` imports

Tests in `test/services/task_migration_adapter_test.dart` cover:
- legacy `arvin.tasks` JSON → Unified `Task`
- preservation of legacy fields, category and follow-up date
- empty storage
- multiple tasks
- malformed JSON and malformed task entries
- missing ids
- invalid title types
- duplicate ids
- Unified serialization round-trip
- repeated conversion stability (conversion-boundary idempotency)
- duplicate ids during Unified encoding
- rejection of a non-list storage payload

## Completed slice — HomePage characterization boundary
Added regression/widget characterization coverage in `test/widgets/home_page_test.dart` for the current production HomePage before any migration rewiring.

The characterization tests currently prove:
- the existing Persian application title remains present
- search and filter controls remain present
- the new-task action remains present
- an existing legacy `arvin.tasks` item is loaded and rendered
- search filters the currently loaded legacy tasks

This is intentionally a behavior baseline, not a Unified `Task` test. It protects the current UI contract before the next load-only migration slice.

## Completed slice — read-only load boundary
Added `lib/services/task_migration_reader.dart` as a reversible, write-free boundary over the existing `arvin.tasks` key.

The reader now:
- reads the existing storage key without changing it
- delegates conversion and validation to `TaskMigrationAdapter`
- returns canonical `Task` objects
- preserves the legacy `followUpDate` → `FollowUp` conversion
- returns an empty list when storage is absent/empty
- surfaces malformed storage instead of silently discarding it
- is directly testable with injected `SharedPreferences`

Tests in `test/services/task_migration_reader_test.dart` prove:
- empty/missing storage
- legacy task loading into Unified `Task`
- follow-up preservation
- read-only/no-write behavior
- malformed storage propagation

## Current validation — 2026-08-16
- Adapter boundary: PASS on the previously validated slice.
- HomePage characterization boundary: PASS on the previously validated slice.
- New read-only migration boundary: committed and awaiting current-head CI completion.
- `Arvin Build` run #399: IN PROGRESS (Analyze and Test already PASS; APK build running).
- `Arvin Parallel Wave` run #236: IN PROGRESS (quality and independent surface checks PASS; APK build running).
- PR #96 remains open and draft; no merge has been performed.
- Main remains on the legacy Home production path.
- Production migration remains intentionally blocked until storage semantics and rollback/idempotency strategy are independently reviewed.

## Current gate
- Adapter boundary: PASS.
- HomePage characterization boundary: PASS.
- Read-only load boundary: awaiting CI confirmation.
- Production migration: BLOCKED intentionally until the next storage/load boundary is reviewed.
- PR #96: keep open until the next migration boundary is independently reviewed.

## Next implementation slice
After the read-only boundary is green, wire only the HomePage `load` path through `TaskMigrationReader` behind the existing UI behavior. Preserve existing save, backup, restore, filter and multi-select behavior. Do not introduce dual-write, a new storage key, or legacy removal until concrete data-preservation and rollback strategy is tested and reviewed.

## Review rule
If storage semantics, migration idempotency, or Home behavior becomes ambiguous, stop the change and request a DeepSeek cross-review before continuing.
