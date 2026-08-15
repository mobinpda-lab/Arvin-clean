# Unified Item Migration — 2026-08-15

## Architectural decision
`Task` in `lib/models/task.dart` is the single shared Unified Item for primary task data. `ArvinTask` and `TaskRepository` in `lib/main.dart` are legacy parallel data paths and must not remain the source of truth.

## Audit findings
- `TaskStore` already persists `Task` using the same SharedPreferences key `arvin.tasks`.
- `Task.fromJson()` already preserves legacy `followUpDate` by creating a `FollowUp` history entry when `followUps` is absent.
- Therefore the first migration can be storage-preserving: switch Home to `TaskStore`/`Task` before removing the legacy classes.
- No new model or repository should be introduced.

## Safe migration sequence
1. Add regression tests for legacy JSON -> `Task` migration and Unified Item persistence.
2. Switch Home and TaskDialog from `ArvinTask` to `Task` and from `TaskRepository` to `TaskStore`.
3. Verify backup/restore continues to serialize `Task` JSON.
4. Remove `ArvinTask` and `TaskRepository` from `main.dart`.
5. Run analyze, tests, APK build and verification.

## Guardrails
- Do not change the `arvin.tasks` key during migration.
- Do not delete or rewrite existing user data.
- Do not add a second persistence path.
- Do not proceed to Reminder/Recurring UI integration until this migration is green.
