# Arvin — Home Unified Item Migration Progress

## Audit result
The current `lib/main.dart` still defines legacy `ArvinTask` and `TaskRepository`, while the official `lib/models/task.dart` already contains the Unified `Task` model with reminders, follow-ups, recurrence, archive/trash and completion state.

## Rule
Do not add Reminder/Recurring UI to the legacy `ArvinTask` path. Migration must preserve legacy `arvin.tasks` data and avoid introducing a second persistence path.

## Current Wave
- Main remains untouched for the migration itself.
- Migration work stays isolated in `wave2/home-unified-migration-boundary`.
- CI is the merge gate: Analyze → Test → Build APK → Verify APK.
- Documentation is updated before the migration lands.

## Completed slice — migration boundary
Added `lib/services/task_migration_adapter.dart` as a small boundary around the canonical `Task` model.

Added `test/services/task_migration_adapter_test.dart` covering:
- legacy `arvin.tasks` JSON → Unified `Task`
- preservation of legacy fields and follow-up date
- Unified serialization round-trip
- rejection of a non-list storage payload

No `lib/main.dart` production behavior has been changed yet. This slice intentionally proves the migration boundary before rewiring Home.

## Next implementation slice
Wire Home's load/save path through the adapter and canonical `Task` model in a small, reversible change. Preserve existing backup/filter/multi-select behavior and avoid dual-write unless a concrete backward-compatibility test proves it is required.
