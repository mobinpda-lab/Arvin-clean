# Unified Item Migration — 2026-08-15

## Architectural decision
`Task` in `lib/models/task.dart` is the single shared Unified Item for primary task data. `ArvinTask` and `TaskRepository` in `lib/main.dart` are legacy parallel data paths and must not remain the source of truth.

## Audit findings
- `TaskStore` already persists `Task` using the same SharedPreferences key `arvin.tasks`.
- `Task.fromJson()` already preserves legacy `followUpDate` by creating a `FollowUp` history entry when `followUps` is absent/empty.
- Therefore the first migration can be storage-preserving: switch Home to `TaskStore`/`Task` before removing the legacy classes.
- No new model or repository should be introduced.

## Safe migration sequence
1. Add regression tests for legacy JSON -> `Task` migration and Unified Item persistence.
2. Switch Home and TaskDialog from `ArvinTask` to `Task` and from `TaskRepository` to `TaskStore`.
3. Verify backup/restore continues to serialize `Task` JSON.
4. Remove `ArvinTask` and `TaskRepository` from `main.dart`.
5. Run analyze, tests, APK build and verification.

## Current verified progress — 2026-08-21
- The focused legacy FollowUp migration regression coverage from historical PR #102 has been reintroduced on top of the current `main` in PR #111.
- PR #111 is **OPEN / DRAFT / MERGEABLE** and changes only `test/task_legacy_follow_up_migration_test.dart`; no production behavior is changed.
- The tests cover both legacy `followUpDate` → `followUps` migration and the rule that an existing non-empty `followUps` list remains authoritative.
- The exact PR #111 commit currently has no combined status checks recorded. Therefore the tests are **not yet validated by CI** and PR #111 must not be merged until the exact commit passes the required validation.

## Guardrails
- Do not change the `arvin.tasks` key during migration.
- Do not delete or rewrite existing user data.
- Do not add a second persistence path.
- Do not proceed to Reminder/Recurring UI integration until this migration is green.
- Do not infer a green result from historical CI or from the logic of the test alone.

## Current implementation note
The migration work remains incremental and must be promoted only after full validation of the exact resulting commit/ref. Historical documents and prior CI results remain historical evidence and must not be presented as validation of a newer ref.
