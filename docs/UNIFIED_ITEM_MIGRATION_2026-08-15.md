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
- Focused legacy FollowUp migration regression coverage from historical PR #102 was reintroduced in PR #111 on top of the then-current `main`.
- PR #111 is now **MERGED** into `main` as `0bcf80d305fa5aedcc1bdd4678496fbeda3372aa`.
- The merged test file is `test/task_legacy_follow_up_migration_test.dart`; no production behavior was changed by PR #111.
- The tests cover both legacy `followUpDate` -> `followUps` migration and the rule that an existing non-empty `followUps` list remains authoritative.
- Historical CI results for older refs must not be attributed to the Merge Commit unless GitHub shows that exact ref was tested.

## Migration gate result
- Regression coverage: **MERGED**.
- Migration compatibility gate: **advanced past the focused regression-test gate**.
- The next executable slice must still respect the incremental migration guardrails and must be validated against its exact resulting commit/ref.

## Guardrails
- Do not change the `arvin.tasks` key during migration.
- Do not delete or rewrite existing user data.
- Do not add a second persistence path.
- Do not proceed to Reminder/Recurring UI integration until the migration gate is green for the applicable implementation slice.
- Do not infer a green result from historical CI or from the logic of the test alone.

## Current implementation note
The migration work remains incremental and must be promoted only after full validation of the exact resulting commit/ref. Historical documents and prior CI results remain historical evidence and must not be presented as validation of a newer ref.
