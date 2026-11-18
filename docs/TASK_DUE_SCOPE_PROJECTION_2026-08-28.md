# Task due-scope projection — Issue #369

Status: focused domain/projection slice; this does not close #369.

## Binding behavior
Arvin's `امروز`, `آینده` and `عقب‌افتاده` task scopes are based on the Task's canonical `dueDate` only.

- `امروز`: active open items whose due calendar day is today.
- `آینده`: active open items due after today.
- `عقب‌افتاده`: active open items due before today.
- undated items are not silently assigned to any of these three scopes.
- archived, trashed and completed items are excluded from these active-work scopes.

Task reminder time and FollowUp timestamps never substitute for due date.

## Canonical foundation
- `Task.dueDate` from merged PR #376
- existing canonical `TaskStore/arvin.tasks`
- pure `TaskDueScopeService`; no new storage/repository/model

## Next #369 slices
- All / Notes / FollowUp-enabled discoverable list scopes
- sort by date / latest entry-update / title + direction toggle
- Move-to-Today write path changing the same Task's `dueDate`
- Home/list integration and search preservation
- RTL + exact-head Build/APK/Device acceptance

## Safety
Projection is read-only, preserves input identity/history, and must not mutate Reminder or FollowUp data.
