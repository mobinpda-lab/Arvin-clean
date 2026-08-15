# Home → Unified Item Migration — 2026-08-15

## Audit result
The current Home UI in `lib/main.dart` still uses the legacy `ArvinTask`/`TaskRepository` path, while the canonical product model is `models/task.dart` with `Task`, `FollowUp[]`, `reminderDate`, and `recurrence`.

## Rule
Do not create a second Reminder/Recurring UI model. Home must migrate through an adapter-compatible slice first, preserving the `arvin.tasks` envelope and legacy fields.

## Execution gate
1. Add migration regression tests against real legacy JSON.
2. Introduce a small adapter boundary rather than rewriting Home in one large change.
3. Keep existing backup/filter/multi-select behavior unchanged.
4. Validate Analyze → Test → Build.
5. Only after green CI, wire Reminder/Recurring UI to the canonical Task.

## Definition of done
Home reads/writes the canonical Task model, legacy data loads without loss, Reminder/FollowUp/Recurring share the same source of truth, and no second persistence path remains.
