# Arvin — Home Unified Item Migration Progress

## Audit result
The current `lib/main.dart` still defines legacy `ArvinTask` and `TaskRepository`, while the official `lib/models/task.dart` already contains the Unified `Task` model with reminders, follow-ups, recurrence, archive/trash and completion state.

## Rule
Do not add Reminder/Recurring UI to the legacy `ArvinTask` path. Migration must preserve legacy `arvin.tasks` data and avoid introducing a second persistence path.

## Current Wave
- Main remains untouched for the migration itself.
- Migration work stays isolated in a dedicated branch/PR.
- CI is the merge gate: Analyze → Test → Build APK → Verify APK.
- Documentation is updated before the migration lands.

## Next implementation slice
Introduce an adapter/migration boundary so existing Home UI can consume Unified `Task` without rewriting every UI operation in one change. Preserve old JSON fields during transition and add regression tests for load/save compatibility.
