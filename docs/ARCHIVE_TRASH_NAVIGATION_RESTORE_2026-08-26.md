# Archive / Trash navigation and restore — 2026-08-26

## Scope
This slice continues Issue #14 after permanent-delete confirmation merged.

## What changed
- Added direct Archive and Trash entries to the existing app drawer.
- Each entry switches the existing Home filter instead of creating a second list or navigation stack.
- Archived tasks now expose the same explicit restore action as trashed tasks.
- Restore clears both archive/trash flags and returns the task to the existing Active list.
- Empty Archive now has its own empty-state message.

## Regression coverage
Widget tests verify:
1. Drawer → Archive opens archived tasks.
2. Archive → Active restore removes the task from Archive and makes it visible in Active.
3. Drawer → Trash opens trashed tasks.
4. Trash → Active restore removes the task from Trash and makes it visible in Active.
5. Existing permanent-delete behavior remains covered by prior tests in the same Home suite.

## Guardrails
- No new storage key or repository.
- No duplicate Archive/Trash screens.
- Existing Home filters remain the single list projection.
- Existing permanent-delete confirmation remains unchanged.
- Merge only after exact-head `Arvin Build` and `Arvin Parallel Wave` validation.
