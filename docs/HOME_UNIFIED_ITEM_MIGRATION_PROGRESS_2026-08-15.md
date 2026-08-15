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

Tests in `test/services/task_migration_adapter_test.dart` now cover:
- legacy `arvin.tasks` JSON → Unified `Task`
- preservation of legacy fields, category and follow-up date
- empty storage
- multiple tasks
- malformed task entries
- missing ids
- duplicate ids
- Unified serialization round-trip
- duplicate ids during Unified encoding
- rejection of a non-list storage payload

No `lib/main.dart` production behavior has been changed yet. This slice intentionally strengthens and proves the migration boundary before rewiring Home.

## Current gate
- Adapter boundary: PASS for the currently implemented contract.
- Production migration: BLOCKED intentionally.
- PR #96: keep open until CI and independent review confirm this slice and the next Home test boundary.

## Next implementation slice
Add a minimal HomePage characterization/widget-test boundary around the existing legacy behavior before changing Home's load/save path. Then take a small, reversible load-only migration slice. Do not introduce dual-write, a new storage key, or legacy removal until the concrete data-preservation and rollback strategy is tested and reviewed.

## Review rule
If storage semantics, migration idempotency, or Home behavior becomes ambiguous, stop the change and request a DeepSeek cross-review before continuing.
