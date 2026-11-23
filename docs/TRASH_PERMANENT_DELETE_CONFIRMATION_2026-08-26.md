# Trash permanent delete confirmation — 2026-08-26

## Scope
This slice advances Issue #14 by guarding irreversible deletion from the existing Trash flow.

## Behavior
- The first delete action on an active task keeps the current behavior and moves the task to Trash.
- Deleting a task that is already in Trash opens an explicit confirmation dialog.
- Cancel leaves the task untouched in Trash.
- Confirm removes the task and persists the updated canonical task list.
- The dialog makes the irreversible nature of the action explicit.

## Regression coverage
Widget tests verify both sides of the transition:
1. Active task → Trash still works without the permanent-delete dialog.
2. Trash → permanent delete requires confirmation; cancel keeps the item and confirm removes it.

## Guardrails
- No new storage key or repository.
- No broad Home rewrite.
- Existing restore behavior is unchanged.
- This PR does not claim the whole Issue #14 scope; archive/trash navigation and other transitions remain tracked separately until verified.
- Merge only after exact-head `Arvin Build` and `Arvin Parallel Wave` validation.
